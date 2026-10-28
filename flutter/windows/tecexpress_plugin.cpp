#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <shlobj.h>
#include <shlwapi.h>
#include <shobjidl.h>
#include <wrl/client.h>
#include <filesystem>
#include <fstream>
#include <map>
#include <memory>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>

using flutter::EncodableValue;
using flutter::EncodableMap;
using flutter::EncodableList;
using Microsoft::WRL::ComPtr;
namespace fs = std::filesystem;
namespace {
std::wstring Wide(const std::string& value) {
  const int size = MultiByteToWideChar(CP_UTF8, 0, value.data(), static_cast<int>(value.size()), nullptr, 0);
  std::wstring result(size, 0);
  MultiByteToWideChar(CP_UTF8, 0, value.data(), static_cast<int>(value.size()), result.data(), size);
  return result;
}
std::string Utf8(const std::wstring& value) {
  const int size = WideCharToMultiByte(CP_UTF8, 0, value.data(), static_cast<int>(value.size()), nullptr, 0, nullptr, nullptr);
  std::string result(size, 0);
  WideCharToMultiByte(CP_UTF8, 0, value.data(), static_cast<int>(value.size()), result.data(), size, nullptr, nullptr);
  return result;
}
const EncodableValue& Get(const EncodableMap& map, const char* key) {
  const auto it = map.find(EncodableValue(key));
  if (it == map.end()) throw std::runtime_error("Missing method argument");
  return it->second;
}
std::string String(const EncodableMap& map, const char* key) {
  const auto value = std::get_if<std::string>(&Get(map, key));
  if (!value) throw std::runtime_error("Expected a string argument");
  return *value;
}
double Number(const EncodableValue& v) {
  if (auto d = std::get_if<double>(&v)) return *d;
  if (auto i = std::get_if<int32_t>(&v)) return *i;
  if (auto i = std::get_if<int64_t>(&v)) return static_cast<double>(*i);
  throw std::runtime_error("Expected a numeric argument");
}
void Check(HRESULT hr) { if (FAILED(hr)) throw std::runtime_error("Windows file operation failed: " + std::to_string(hr)); }

class TecexpressPlugin final : public flutter::Plugin, public IDropTarget {
  class ViewDropTarget final : public IDropTarget {
   public:
    ViewDropTarget(TecexpressPlugin* owner, HWND window, int64_t view)
        : owner_(owner), window_(window), view_(view) {}
    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** out) override {
      if (iid == IID_IUnknown || iid == IID_IDropTarget) { *out = static_cast<IDropTarget*>(this); AddRef(); return S_OK; }
      *out = nullptr; return E_NOINTERFACE;
    }
    ULONG STDMETHODCALLTYPE AddRef() override { return ++refs_; }
    ULONG STDMETHODCALLTYPE Release() override { const auto count = --refs_; if (!count) delete this; return count; }
    void Disconnect() { owner_ = nullptr; }
    HRESULT STDMETHODCALLTYPE DragEnter(IDataObject* data, DWORD keys, POINTL point, DWORD* effect) override {
      if (!owner_) { *effect = DROPEFFECT_NONE; return S_OK; }
      Select(); return owner_->DragEnter(data, keys, point, effect);
    }
    HRESULT STDMETHODCALLTYPE DragOver(DWORD keys, POINTL point, DWORD* effect) override {
      if (!owner_) { *effect = DROPEFFECT_NONE; return S_OK; }
      Select(); return owner_->DragOver(keys, point, effect);
    }
    HRESULT STDMETHODCALLTYPE DragLeave() override { if (!owner_) return S_OK; Select(); return owner_->DragLeave(); }
    HRESULT STDMETHODCALLTYPE Drop(IDataObject* data, DWORD keys, POINTL point, DWORD* effect) override {
      if (!owner_) { *effect = DROPEFFECT_NONE; return S_OK; }
      Select(); return owner_->Drop(data, keys, point, effect);
    }
   private:
    void Select() { owner_->window_ = window_; owner_->current_view_ = view_; }
    TecexpressPlugin* owner_;
    HWND window_;
    int64_t view_;
    ULONG refs_ = 1;
  };
 public:
  explicit TecexpressPlugin(flutter::PluginRegistrarWindows* registrar) : registrar_(registrar) {
    channel_ = std::make_unique<flutter::MethodChannel<EncodableValue>>(registrar->messenger(), "tecexpress/files", &flutter::StandardMethodCodec::GetInstance());
    channel_->SetMethodCallHandler([this](const auto& call, auto result) { Handle(call, std::move(result)); });
    if (const auto view = registrar->GetViewById(0)) window_ = view->GetNativeWindow();
    ole_ = SUCCEEDED(OleInitialize(nullptr));
    // Flutter may already own a drop target. Registration is checked and never
    // silently replaces another plugin's target.
  }
  ~TecexpressPlugin() override {
    // The registrar destroys plugins during engine teardown. Its messenger's
    // engine pointer may already be null, so never call back into it here.
    for (const auto& entry : endpoints_) { entry.second->Disconnect(); RevokeDragDrop(entry.first); }
    endpoints_.clear();
    saves_.clear();
    for (const auto& path : owned_) { std::error_code ec; fs::remove_all(path.parent_path(), ec); }
    if (ole_) OleUninitialize();
  }
  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID iid, void** out) override {
    if (iid == IID_IUnknown || iid == IID_IDropTarget) { *out = static_cast<IDropTarget*>(this); AddRef(); return S_OK; }
    *out = nullptr; return E_NOINTERFACE;
  }
  ULONG STDMETHODCALLTYPE AddRef() override { return ++refs_; }
  ULONG STDMETHODCALLTYPE Release() override { return --refs_; }
  HRESULT STDMETHODCALLTYPE DragEnter(IDataObject* data, DWORD, POINTL point, DWORD* effect) override {
    FORMATETC paths{CF_HDROP, nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL};
    FORMATETC virtuals{static_cast<CLIPFORMAT>(RegisterClipboardFormatW(CFSTR_FILEDESCRIPTORW)), nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL};
    accepts_ = SUCCEEDED(data->QueryGetData(&paths)) || SUCCEEDED(data->QueryGetData(&virtuals));
    return DragOver(0, point, effect);
  }
  HRESULT STDMETHODCALLTYPE DragOver(DWORD, POINTL point, DWORD* effect) override {
    *effect = accepts_ && Target(point) ? DROPEFFECT_COPY : DROPEFFECT_NONE; return S_OK;
  }
  HRESULT STDMETHODCALLTYPE DragLeave() override { accepts_ = false; return S_OK; }
  HRESULT STDMETHODCALLTYPE Drop(IDataObject* data, DWORD, POINTL point, DWORD* effect) override {
    *effect = DROPEFFECT_NONE;
    const auto target = Target(point); if (!target) return S_OK;
    try {
      EncodableList files;
      FORMATETC format{CF_HDROP, nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL};
      STGMEDIUM medium{};
      if (SUCCEEDED(data->GetData(&format, &medium))) {
        const auto drop = reinterpret_cast<HDROP>(medium.hGlobal);
        const UINT count = DragQueryFileW(drop, 0xFFFFFFFF, nullptr, 0);
        for (UINT i = 0; i < count; ++i) {
          std::wstring path(DragQueryFileW(drop, i, nullptr, 0) + 1, 0);
          DragQueryFileW(drop, i, path.data(), static_cast<UINT>(path.size())); path.pop_back();
          std::error_code ec;
          const bool directory = fs::is_directory(path, ec);
          if (ec) { ReleaseStgMedium(&medium); throw std::runtime_error(ec.message()); }
          if (directory) { ReleaseStgMedium(&medium); return S_OK; }
          files.push_back(Take(path));
        }
        ReleaseStgMedium(&medium);
      } else {
        format.cfFormat = static_cast<CLIPFORMAT>(RegisterClipboardFormatW(CFSTR_FILEDESCRIPTORW));
        Check(data->GetData(&format, &medium));
        const auto group = static_cast<FILEGROUPDESCRIPTORW*>(GlobalLock(medium.hGlobal));
        if (!group) { ReleaseStgMedium(&medium); throw std::runtime_error("Cannot read dropped file descriptors"); }
        struct Descriptor { std::wstring name; uint64_t size; bool has_size; };
        std::vector<Descriptor> names;
        for (UINT i = 0; i < group->cItems; ++i) {
          if (group->fgd[i].dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) { GlobalUnlock(medium.hGlobal); ReleaseStgMedium(&medium); return S_OK; }
          const auto& descriptor = group->fgd[i];
          names.push_back({descriptor.cFileName,
            (static_cast<uint64_t>(descriptor.nFileSizeHigh) << 32) | descriptor.nFileSizeLow,
            (descriptor.dwFlags & FD_FILESIZE) != 0});
        }
        GlobalUnlock(medium.hGlobal); ReleaseStgMedium(&medium);
        for (size_t i = 0; i < names.size(); ++i) {
          FORMATETC content{static_cast<CLIPFORMAT>(RegisterClipboardFormatW(CFSTR_FILECONTENTS)), nullptr, DVASPECT_CONTENT, static_cast<LONG>(i), TYMED_ISTREAM | TYMED_HGLOBAL};
          STGMEDIUM bytes{}; Check(data->GetData(&content, &bytes));
          struct ReleaseMedium { STGMEDIUM* value; ~ReleaseMedium() { ReleaseStgMedium(value); } } release{&bytes};
          const auto path = Temp(names[i].name);
          std::ofstream out(path, std::ios::binary);
          if (!out) throw std::runtime_error("Cannot create temporary dropped file");
          if (bytes.tymed == TYMED_ISTREAM) {
            char buffer[65536]; ULONG read = 0;
            do { Check(bytes.pstm->Read(buffer, sizeof(buffer), &read)); out.write(buffer, read); } while (read);
          } else {
            const auto allocated = GlobalSize(bytes.hGlobal);
            const auto size = names[i].has_size ? names[i].size : allocated;
            if (size > allocated) throw std::runtime_error("Truncated virtual file");
            const auto ptr = static_cast<const char*>(GlobalLock(bytes.hGlobal));
            if (ptr) out.write(ptr, static_cast<std::streamsize>(size));
            else if (size) throw std::runtime_error("Cannot read virtual file");
            GlobalUnlock(bytes.hGlobal);
          }
          out.close();
          if (!out) throw std::runtime_error("Cannot write temporary dropped file");
          files.push_back(Metadata(path, Utf8(fs::path(names[i].name).filename().wstring()), true));
        }
      }
      POINT client{point.x, point.y}; ScreenToClient(window_, &client);
      const auto scale = static_cast<double>(GetDpiForWindow(window_)) / 96.0;
      channel_->InvokeMethod("drop", std::make_unique<EncodableValue>(EncodableMap{
        {EncodableValue("x"), EncodableValue(client.x / scale)}, {EncodableValue("y"), EncodableValue(client.y / scale)},
        {EncodableValue("viewId"), Get(*target, "viewId")}, {EncodableValue("files"), EncodableValue(files)}}));
      *effect = DROPEFFECT_COPY;
    } catch (...) { /* OLE reports rejection through DROPEFFECT_NONE. */ }
    return S_OK;
  }
 private:
  fs::path Temp(const std::wstring& name) {
    GUID guid{}; Check(CoCreateGuid(&guid)); wchar_t text[40]; StringFromGUID2(guid, text, 40);
    std::error_code ec;
    auto dir = fs::temp_directory_path(ec);
    if (ec) throw std::runtime_error(ec.message());
    dir /= std::wstring(L"tecexpress-") + text;
    fs::create_directory(dir, ec);
    if (ec) throw std::runtime_error(ec.message());
    auto path = dir / fs::path(name).filename(); owned_.insert(path); return path;
  }
  EncodableValue Metadata(const fs::path& path, const std::string& name, bool owned) {
    return EncodableValue(EncodableMap{{EncodableValue("path"), EncodableValue(Utf8(path.wstring()))}, {EncodableValue("name"), EncodableValue(name)}, {EncodableValue("owned"), EncodableValue(owned)}});
  }
  EncodableValue Take(const fs::path& path) {
    auto output = Temp(path.filename().wstring());
    std::error_code ec; fs::copy_file(path, output, ec);
    if (ec) { owned_.erase(output); std::error_code cleanup; fs::remove_all(output.parent_path(), cleanup); throw std::runtime_error(ec.message()); }
    return Metadata(output, Utf8(path.filename().wstring()), true);
  }
  const EncodableMap* Target(POINTL point) {
    POINT client{point.x, point.y}; ScreenToClient(window_, &client);
    const double scale = GetDpiForWindow(window_) / 96.0;
    const double x = client.x / scale, y = client.y / scale;
    for (auto it = targets_.rbegin(); it != targets_.rend(); ++it) {
      const auto& t = std::get<EncodableMap>(*it);
      if (static_cast<int64_t>(Number(Get(t, "viewId"))) != current_view_) continue;
      if (x >= Number(Get(t, "left")) && x < Number(Get(t, "right")) && y >= Number(Get(t, "top")) && y < Number(Get(t, "bottom"))) return &t;
    }
    return nullptr;
  }
  void Handle(const flutter::MethodCall<EncodableValue>& call, std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
    try {
      if (call.method_name() == "targets") {
        targets_ = std::get<EncodableList>(*call.arguments());
        std::set<HWND> active;
        for (const auto& value : targets_) {
          const auto& t = std::get<EncodableMap>(value);
          const auto id = static_cast<int64_t>(Number(Get(t, "viewId")));
          const auto view = registrar_->GetViewById(id);
          if (!view) continue;
          const auto handle = view->GetNativeWindow(); active.insert(handle);
          if (!endpoints_.count(handle)) {
            ComPtr<ViewDropTarget> endpoint; endpoint.Attach(new ViewDropTarget(this, handle, id));
            Check(RegisterDragDrop(handle, endpoint.Get()));
            endpoints_[handle] = std::move(endpoint);
          }
        }
        for (auto it = endpoints_.begin(); it != endpoints_.end();) {
          if (!active.count(it->first)) { it->second->Disconnect(); RevokeDragDrop(it->first); it = endpoints_.erase(it); }
          else { ++it; }
        }
        result->Success(); return;
      }
      const auto& args = std::get<EncodableMap>(*call.arguments());
      if (call.method_name() == "pick" || call.method_name() == "beginSave") {
        if (busy_) { result->Error("busy", "Another dialog is open"); return; }
        busy_ = true;
        struct Reset { bool& value; ~Reset() { value = false; } } reset{busy_};
        ComPtr<IFileDialog> dialog;
        const bool pick = call.method_name() == "pick";
        Check(CoCreateInstance(pick ? CLSID_FileOpenDialog : CLSID_FileSaveDialog, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&dialog)));
        DWORD flags = 0; Check(dialog->GetOptions(&flags));
        flags |= FOS_FORCEFILESYSTEM | (pick ? FOS_FILEMUSTEXIST : FOS_OVERWRITEPROMPT);
        if (pick && std::get<bool>(Get(args, "multiple"))) flags |= FOS_ALLOWMULTISELECT;
        Check(dialog->SetOptions(flags));
        std::wstring filter;
        if (pick) {
          for (const auto& ext : std::get<EncodableList>(Get(args, "extensions"))) {
            if (!filter.empty()) filter += L";";
            filter += L"*." + Wide(std::get<std::string>(ext));
          }
          if (!filter.empty()) { COMDLG_FILTERSPEC spec{L"Files", filter.c_str()}; Check(dialog->SetFileTypes(1, &spec)); }
        } else Check(dialog->SetFileName(Wide(String(args, "name")).c_str()));
        const auto hr = dialog->Show(GetAncestor(window_, GA_ROOT));
        if (hr == HRESULT_FROM_WIN32(ERROR_CANCELLED)) { if (pick) result->Success(EncodableValue(EncodableList{})); else result->Success(); return; }
        Check(hr);
        if (pick) {
          ComPtr<IFileOpenDialog> open; Check(dialog.As(&open)); ComPtr<IShellItemArray> items; Check(open->GetResults(&items));
          DWORD count; Check(items->GetCount(&count)); EncodableList files;
          for (DWORD i = 0; i < count; ++i) {
            ComPtr<IShellItem> item; Check(items->GetItemAt(i, &item)); PWSTR path = nullptr; Check(item->GetDisplayName(SIGDN_FILESYSPATH, &path));
            fs::path file(path); CoTaskMemFree(path); files.push_back(Take(file));
          }
          result->Success(EncodableValue(files));
        } else {
          ComPtr<IShellItem> item; Check(dialog->GetResult(&item)); PWSTR path = nullptr; Check(item->GetDisplayName(SIGDN_FILESYSPATH, &path));
          fs::path file(path); CoTaskMemFree(path);
          auto token = std::to_string(++serial_); auto out = std::make_unique<std::ofstream>(file, std::ios::binary | std::ios::trunc);
          if (!*out) throw std::runtime_error("Cannot open output file"); saves_[token] = std::move(out); result->Success(EncodableValue(token));
        }
      } else if (call.method_name() == "writeSave") {
        const auto it = saves_.find(String(args, "token"));
        if (it == saves_.end()) throw std::runtime_error("Unknown save handle");
        auto& out = it->second; const auto& bytes = std::get<std::vector<uint8_t>>(Get(args, "bytes"));
        out->write(reinterpret_cast<const char*>(bytes.data()), static_cast<std::streamsize>(bytes.size())); if (!*out) throw std::runtime_error("Write failed"); result->Success();
      } else if (call.method_name() == "finishSave" || call.method_name() == "abortSave") {
        auto it = saves_.find(String(args, "token"));
        if (it != saves_.end()) { it->second->flush(); if (!*it->second) throw std::runtime_error("Write failed"); saves_.erase(it); } result->Success();
      } else if (call.method_name() == "release") {
        fs::path path(Wide(String(args, "path")));
        if (owned_.erase(path)) { std::error_code ec; fs::remove_all(path.parent_path(), ec); if (ec) throw std::runtime_error(ec.message()); }
        result->Success();
      } else result->NotImplemented();
    } catch (const std::exception& e) { result->Error("file_error", e.what()); }
  }
  flutter::PluginRegistrarWindows* registrar_;
  std::unique_ptr<flutter::MethodChannel<EncodableValue>> channel_;
  HWND window_ = nullptr;
  ULONG refs_ = 1;
  bool ole_ = false, accepts_ = false, busy_ = false;
  int64_t current_view_ = 0;
  std::map<HWND, ComPtr<ViewDropTarget>> endpoints_;
  int serial_ = 0;
  EncodableList targets_;
  std::set<fs::path> owned_;
  std::map<std::string, std::unique_ptr<std::ofstream>> saves_;
};
}
void RegisterTecexpress(flutter::PluginRegistrarWindows* registrar) {
  registrar->AddPlugin(std::make_unique<TecexpressPlugin>(registrar));
}
