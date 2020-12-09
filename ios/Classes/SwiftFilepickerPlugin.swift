import Flutter
import UIKit

public class SwiftFilepickerPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
    var flutterResult: FlutterResult!
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "filepicker", binaryMessenger: registrar.messenger())
    let instance = SwiftFilepickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    self.flutterResult = result;
    if(call.method == "getPlatformVersion"){
       result("iOS " + UIDevice.current.systemVersion)
    } else if(call.method == "openFilePicker"){
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
                        documentPicker.delegate = self
        UIApplication.shared.keyWindow?.rootViewController?.present(documentPicker, animated: true, completion: nil)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print(urls)
        guard let url = urls.first else {
            return
        }
        let fileExtension = url.pathExtension
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let tempUrl = paths.appendingPathComponent("document.\(fileExtension)")
        do{
            if FileManager.default.fileExists(atPath: tempUrl.path) {
                            try FileManager.default.removeItem(atPath: tempUrl.path)
                        }
            try FileManager.default.moveItem(atPath: url.path, toPath: tempUrl.path)
            self.flutterResult(tempUrl.path)
        }catch {
            self.flutterResult("Error")
            print(error.localizedDescription)
        }
        }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.flutterResult("Cancelled")
        }
    
}
