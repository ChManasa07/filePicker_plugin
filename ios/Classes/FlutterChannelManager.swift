//
//  FlutterChannelManager.swift
//  Runner
//
//  Created by PC272562 on 04/12/20.
//

import Foundation

class FlutterChannelManager: NSObject, UIDocumentPickerDelegate {
    let channel: FlutterMethodChannel
    unowned let flutterViewController: FlutterViewController
    var flutterResult: FlutterResult!

    init(flutterViewController: FlutterViewController) {
        self.flutterViewController = flutterViewController
        channel = FlutterMethodChannel(name: "com.demo.flutter/documentPicker", binaryMessenger: flutterViewController as! FlutterBinaryMessenger)
    }

    func setUp() {
        channel.setMethodCallHandler{ (call, result) in
            switch call.method{
            case "openFilePicker":
                self.flutterResult = result;
                let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
                documentPicker.delegate = self
                self.flutterViewController.present(documentPicker, animated: true, completion: nil)
            default:
                result(FlutterMethodNotImplemented)
                break
            }
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
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
            flutterResult(tempUrl.path)
        }catch {
            flutterResult("Error")
            print(error.localizedDescription)
        }
        }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        flutterResult("Cancelled")
        }
}