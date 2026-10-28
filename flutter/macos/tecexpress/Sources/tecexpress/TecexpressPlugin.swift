import Cocoa
import FlutterMacOS

private final class DropView: NSView {
  weak var owner: TecexpressPlugin?
  // NSResponder forwards ordinary pointer events to the parent Flutter view.
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation { draggingUpdated(sender) }
  override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
    guard let owner = owner else { return [] }
    return owner.target(owner.point(sender)) == nil ? [] : .copy
  }
  override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
    guard let owner = owner else { return false }
    return owner.target(owner.point(sender)) != nil
  }
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool { owner?.drop(sender) ?? false }
}

public final class TecexpressPlugin: NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  private weak var view: NSView?
  private var overlay: DropView?
  private var targets: [[String: Any]] = []
  private var owned = Set<String>()
  private var saves: [String: FileHandle] = [:]
  private var busy = false
  init(channel: FlutterMethodChannel, view: NSView?) {
    self.channel = channel; self.view = view
    super.init()
    if let view = view {
      let overlay = DropView(frame: view.bounds)
      overlay.owner = self; overlay.autoresizingMask = [.width, .height]
      overlay.registerForDraggedTypes([.fileURL] + NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) })
      view.addSubview(overlay); self.overlay = overlay
    }
  }
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tecexpress/files", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(TecexpressPlugin(channel: channel, view: registrar.view), channel: channel)
  }
  deinit {
    overlay?.removeFromSuperview()
    for handle in saves.values { try? handle.close() }
    for path in owned { try? FileManager.default.removeItem(at: URL(fileURLWithPath: path).deletingLastPathComponent()) }
  }
  private func take(_ url: URL) throws -> [String: Any] {
    let access = url.startAccessingSecurityScopedResource()
    defer { if access { url.stopAccessingSecurityScopedResource() } }
    guard try url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory != true else { throw CocoaError(.fileReadUnsupportedScheme) }
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent("tecexpress-" + UUID().uuidString)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let out = dir.appendingPathComponent(url.lastPathComponent)
    try FileManager.default.copyItem(at: url, to: out); owned.insert(out.path)
    return ["path": out.path, "name": url.lastPathComponent, "owned": true]
  }
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    do {
      switch call.method {
      case "targets": targets = call.arguments as? [[String: Any]] ?? []; result(nil)
      case "pick":
        guard !busy else { result(FlutterError(code: "busy", message: "Another dialog is open", details: nil)); return }
        busy = true; defer { busy = false }
        let panel = NSOpenPanel(); panel.canChooseDirectories = false
        panel.allowsMultipleSelection = args["multiple"] as? Bool ?? false
        let extensions = args["extensions"] as? [String] ?? []
        panel.allowedFileTypes = extensions.isEmpty ? nil : extensions
        if panel.runModal() == .OK { result(try panel.urls.map(take)) } else { result([]) }
      case "beginSave":
        guard !busy else { result(FlutterError(code: "busy", message: "Another dialog is open", details: nil)); return }
        busy = true; defer { busy = false }
        let panel = NSSavePanel(); panel.nameFieldStringValue = args["name"] as? String ?? "file"
        guard panel.runModal() == .OK, let url = panel.url else { result(nil); return }
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let handle = try FileHandle(forWritingTo: url); try handle.truncate(atOffset: 0)
        let token = UUID().uuidString; saves[token] = handle; result(token)
      case "writeSave":
        guard let token = args["token"] as? String, let handle = saves[token], let data = args["bytes"] as? FlutterStandardTypedData else { throw CocoaError(.fileWriteUnknown) }
        try handle.write(contentsOf: data.data); result(nil)
      case "finishSave", "abortSave":
        if let token = args["token"] as? String, let handle = saves.removeValue(forKey: token) { try handle.close() }
        result(nil)
      case "release":
        if let path = args["path"] as? String, owned.remove(path) != nil { try FileManager.default.removeItem(at: URL(fileURLWithPath: path).deletingLastPathComponent()) }
        result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    } catch { result(FlutterError(code: "file_error", message: error.localizedDescription, details: nil)) }
  }
  fileprivate func point(_ sender: NSDraggingInfo) -> CGPoint {
    guard let view = view else { return .zero }
    let p = view.convert(sender.draggingLocation, from: nil)
    return CGPoint(x: p.x, y: view.isFlipped ? p.y : view.bounds.height - p.y)
  }
  fileprivate func target(_ point: CGPoint) -> [String: Any]? {
    targets.reversed().first { t in
      guard let l = t["left"] as? Double, let r = t["right"] as? Double, let top = t["top"] as? Double, let b = t["bottom"] as? Double else { return false }
      return point.x >= l && point.x < r && point.y >= top && point.y < b
    }
  }
  fileprivate func drop(_ sender: NSDraggingInfo) -> Bool {
    let p = point(sender); guard let t = target(p) else { return false }
    let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] ?? []
    if urls.isEmpty {
      let receivers = sender.draggingPasteboard.readObjects(forClasses: [NSFilePromiseReceiver.self], options: nil) as? [NSFilePromiseReceiver] ?? []
      guard !receivers.isEmpty else { return false }
      do {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("tecexpress-promise-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let queue = OperationQueue(); queue.maxConcurrentOperationCount = 1
        for receiver in receivers {
          receiver.receivePromisedFiles(atDestination: dir, options: [:], operationQueue: queue) { url, error in
            guard error == nil else { return }
            DispatchQueue.main.async {
              defer { try? FileManager.default.removeItem(at: url) }
              if let file = try? self.take(url) {
                self.channel.invokeMethod("drop", arguments: ["x": p.x, "y": p.y, "viewId": t["viewId"] ?? 0, "files": [file]])
              }
            }
          }
        }
        return true
      } catch { return false }
    }
    do {
      guard !urls.isEmpty, !urls.contains(where: { $0.hasDirectoryPath }) else { return false }
      let files = try urls.map(take)
      channel.invokeMethod("drop", arguments: ["x": p.x, "y": p.y, "viewId": t["viewId"] ?? 0, "files": files]); return true
    } catch { return false }
  }
}
