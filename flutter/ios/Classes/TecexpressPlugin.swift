import Flutter
import UIKit
import UniformTypeIdentifiers

public final class TecexpressPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate, UIDropInteractionDelegate {
  private let channel: FlutterMethodChannel
  private weak var controller: UIViewController?
  private var pending: FlutterResult?
  private var mode = ""
  private var targets: [[String: Any]] = []
  private var owned = Set<String>()
  private let filesLock = NSLock()
  private var saves: [String: (URL, FileHandle)] = [:]
  private var exporting: URL?
  private var interaction: UIDropInteraction?

  init(channel: FlutterMethodChannel, controller: UIViewController?) {
    self.channel = channel; self.controller = controller
    super.init()
    let drop = UIDropInteraction(delegate: self)
    interaction = drop; controller?.view.addInteraction(drop)
  }
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tecexpress/files", binaryMessenger: registrar.messenger())
    let instance = TecexpressPlugin(channel: channel, controller: registrar.viewController())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  deinit {
    if let interaction = interaction { controller?.view.removeInteraction(interaction) }
    for (_, pair) in saves { try? pair.1.close(); try? FileManager.default.removeItem(at: pair.0.deletingLastPathComponent()) }
    for path in owned { try? FileManager.default.removeItem(at: URL(fileURLWithPath: path).deletingLastPathComponent()) }
  }
  private func error(_ e: Error) -> FlutterError { FlutterError(code: "file_error", message: e.localizedDescription, details: nil) }
  private func temp(_ name: String = "file") throws -> URL {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("tecexpress-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    return dir.appendingPathComponent((name as NSString).lastPathComponent)
  }
  private func take(_ url: URL) throws -> [String: Any] {
    let access = url.startAccessingSecurityScopedResource()
    defer { if access { url.stopAccessingSecurityScopedResource() } }
    guard try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory != true else { throw CocoaError(.fileReadUnsupportedScheme) }
    let out = try temp(url.lastPathComponent)
    do { try FileManager.default.copyItem(at: url, to: out) }
    catch { try? FileManager.default.removeItem(at: out.deletingLastPathComponent()); throw error }
    filesLock.lock(); owned.insert(out.path); filesLock.unlock()
    return ["path": out.path, "name": url.lastPathComponent, "owned": true]
  }
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    do {
      switch call.method {
      case "targets": targets = call.arguments as? [[String: Any]] ?? []; result(nil)
      case "pick":
        guard pending == nil, let controller = controller else { result(FlutterError(code: "busy", message: "No available view or another dialog is open", details: nil)); return }
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
          let types = (args["extensions"] as? [String] ?? []).compactMap { UTType(filenameExtension: $0) }
          picker = UIDocumentPickerViewController(forOpeningContentTypes: types.isEmpty ? [.data] : types, asCopy: true)
        } else { picker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import) }
        picker.allowsMultipleSelection = args["multiple"] as? Bool ?? false
        picker.delegate = self; pending = result; mode = "pick"
        controller.present(picker, animated: true)
      case "beginSave":
        guard pending == nil else { result(FlutterError(code: "busy", message: "Another dialog is open", details: nil)); return }
        let url = try temp(args["name"] as? String ?? "file")
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let token = UUID().uuidString
        saves[token] = (url, try FileHandle(forWritingTo: url)); result(token)
      case "writeSave":
        guard let token = args["token"] as? String, let pair = saves[token], let bytes = args["bytes"] as? FlutterStandardTypedData else { throw CocoaError(.fileWriteUnknown) }
        try pair.1.write(contentsOf: bytes.data); result(nil)
      case "finishSave":
        guard let token = args["token"] as? String, let pair = saves[token], let controller = controller, pending == nil else { throw CocoaError(.fileWriteUnknown) }
        saves.removeValue(forKey: token)
        try pair.1.close()
        let picker = UIDocumentPickerViewController(url: pair.0, in: .exportToService)
        picker.delegate = self; pending = result; mode = "save"; exporting = pair.0
        controller.present(picker, animated: true)
      case "abortSave":
        if let token = args["token"] as? String, let pair = saves.removeValue(forKey: token) {
          try? pair.1.close(); try? FileManager.default.removeItem(at: pair.0.deletingLastPathComponent())
        }
        result(nil)
      case "release":
        if let path = args["path"] as? String {
          filesLock.lock(); let exists = owned.remove(path) != nil; filesLock.unlock()
          if exists { try FileManager.default.removeItem(at: URL(fileURLWithPath: path).deletingLastPathComponent()) }
        }
        result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    } catch { result(self.error(error)) }
  }
  public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    let callback = pending; pending = nil
    if let url = exporting { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()); exporting = nil }
    if mode == "pick" { callback?([]) }
    else { callback?(FlutterError(code: "cancelled", message: "Save cancelled", details: nil)) }
  }
  public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    let callback = pending; pending = nil
    do {
      if mode == "pick" { callback?(try urls.filter { !$0.hasDirectoryPath }.map(take)) }
      else {
        if let url = exporting { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()); exporting = nil }
        callback?(nil)
      }
    } catch { callback?(self.error(error)) }
  }
  private func target(_ point: CGPoint) -> [String: Any]? {
    targets.reversed().first { t in
      guard let l = t["left"] as? Double, let r = t["right"] as? Double, let top = t["top"] as? Double, let b = t["bottom"] as? Double else { return false }
      return point.x >= l && point.x < r && point.y >= top && point.y < b
    }
  }
  public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
    !targets.isEmpty && session.hasItemsConforming(toTypeIdentifiers: ["public.data"])
  }
  public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
    UIDropProposal(operation: target(session.location(in: controller?.view)) == nil ? .forbidden : .copy)
  }
  public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
    let point = session.location(in: controller?.view)
    guard let t = target(point) else { return }
    let group = DispatchGroup(); var files: [[String: Any]] = []; let lock = NSLock()
    for item in session.items {
      group.enter()
      item.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.data") { url, _ in
        defer { group.leave() }
        guard let url = url, !url.hasDirectoryPath else { return }
        // Copy before the provider callback returns; its URL is ephemeral.
        if let file = try? self.take(url) { lock.lock(); files.append(file); lock.unlock() }
      }
    }
    group.notify(queue: .main) {
      self.channel.invokeMethod("drop", arguments: ["x": point.x, "y": point.y, "viewId": t["viewId"] ?? 0, "files": files])
    }
  }
}
