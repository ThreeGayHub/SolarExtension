//
//  SLImagePickerController.swift
//  SolarExtensionExample
//
//  Created by wyh on 2018/2/18.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

/** add to info.plist
<key>NSCameraUsageDescription</key>
<string>Use Camera</string>
<key>NSMicrophoneUsageDescription</key>
<string>Use Microphone</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Use PhotoLibrary</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save photo to PhotoLibrary</string>
*/

import UIKit
import MobileCoreServices
import AVFoundation
import Photos

public enum SLImagePickerType: UInt {
    case TakePhoto
    case RecordVideo
    case AlbumList
    case AlbumTimeline
    
    public var sourceType: UIImagePickerControllerSourceType {
        
        switch self {
        case .TakePhoto:
            return .camera
            
        case .RecordVideo:
            return .camera
            
        case .AlbumList:
            return .photoLibrary
            
        case .AlbumTimeline:
            return .savedPhotosAlbum
        }
        
    }
}

// MARK: - Life Cycle
public class SLImagePickerController: UIImagePickerController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate {
    
    public typealias SLPhotoPickerCompleteClosure = (Data?, NSError?) -> Void
    
    public typealias SLVideoPickerCompleteClosure = (Data?, UInt, NSError?) -> Void
    
    public convenience init(_ pickerType: SLImagePickerType = .TakePhoto, isSaveToAlbum: Bool = true) {
        self.init()
        if UIImagePickerController.isSourceTypeAvailable(pickerType.sourceType) {
            self.pickerType = pickerType
            self.isSaveToAlbum = isSaveToAlbum
            sourceType = pickerType.sourceType
            delegate = self
            
            switch pickerType {
            case .TakePhoto:
                cameraCaptureMode = .photo
            case .RecordVideo:
                cameraCaptureMode = .video
                mediaTypes = [kUTTypeMovie as String]
            case .AlbumList, .AlbumTimeline:
                break
            }
        }
    }
    
    public func pickerPhotoComplete(_ closure: @escaping SLPhotoPickerCompleteClosure) {
        photoPickerCompleteClosure = closure
    }
    
    public func pickerVideoComplete(_ closure: @escaping SLVideoPickerCompleteClosure) {
        videoPickerCompleteClosure = closure
    }
    
    public func showOnVC(_ vc: UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(pickerType.sourceType) {
            
            switch pickerType {

            case .TakePhoto:
                canUseCamera {
                    vc.present(self, animated: true, completion: nil)
                }
                
            case .RecordVideo:
                canUseCamera {
                    self.canUseMicrophone {
                        vc.present(self, animated: true, completion: nil)
                    }
                }
                
            case .AlbumList, .AlbumTimeline:
                canUseAlbum {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        vc.present(self, animated: true, completion: nil)
                    })
                }
            }
            
        }
        else {
            if let closure = photoPickerCompleteClosure {
                closure(nil, NSError(code: -1, message: "SourceType Not Available!"))
            }
            else if let closure = videoPickerCompleteClosure {
                closure(nil, 0, NSError(code: -1, message: "SourceType Not Available!"))
            }
            debugPrint("SourceType Not Available!")
            UIAlertView(title: "相机或相册不可用", message: nil, delegate: nil, cancelButtonTitle: "知道了").show()
        }
    }
    
    private var pickerType: SLImagePickerType = .TakePhoto
    private var isSaveToAlbum: Bool = true
    private var photoPickerCompleteClosure: SLPhotoPickerCompleteClosure?
    private var videoPickerCompleteClosure: SLVideoPickerCompleteClosure?

}

// MARK: - Delegate
extension SLImagePickerController {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        switch pickerType {
        case .RecordVideo:
            
            if let URL = info[UIImagePickerControllerMediaURL] as? URL {
                do {
                    let data = try Data(contentsOf: URL)
                    let asset = AVURLAsset(url: URL)
                    let time = asset.duration
                    let second: UInt = UInt(time.value / Int64(time.timescale))
                    if isSaveToAlbum {
                        UISaveVideoAtPathToSavedPhotosAlbum(URL.absoluteString, self, #selector(video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
                    }
                    if let block = videoPickerCompleteClosure {
                        debugPrint("""
                            Length:\(data.count)
                            Seconds"\(second)
                            """)
                        block(data, second, nil)
                    }
                }
                catch {
                    if let block = videoPickerCompleteClosure {
                        block(nil, 0, error as NSError)
                    }
                }
            }
            else {
                if let block = videoPickerCompleteClosure {
                    block(nil, 0, NSError(code: -1, message: "No UIImagePickerControllerMediaURL!"))
                }
            }
            
        case .TakePhoto, .AlbumList, .AlbumTimeline:
            
            var selectedImage: UIImage?
            if allowsEditing {
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    selectedImage = image
                }
            }
            else {
                if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    selectedImage = image
                }
            }
            if let image = selectedImage {
                let data = UIImagePNGRepresentation(image)
                if pickerType == .TakePhoto, isSaveToAlbum {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                if let block = photoPickerCompleteClosure {
                    block(data, nil)
                }
            }
            else {
                if let block = photoPickerCompleteClosure {
                    block(nil, NSError(code: -1, message: "No Image!"))
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc private func video(videoPath: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            debugPrint("""
                videoPath:\(videoPath)
                error:\(error)
            """)
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        if let error = error {
            debugPrint("""
                image:\(image)
                error:\(error)
            """)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if let block = photoPickerCompleteClosure {
            block(nil, NSError(code: -1, message: "Cancel"))
        }
        if let block = videoPickerCompleteClosure {
            block(nil, 0, NSError(code: -1, message: "Cancel"))
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Authorization
extension SLImagePickerController {
    
    private func canUseCamera(_ block: @escaping () -> Void) {
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .denied, .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        block()
                    }
                    else {
                        self.showAuthorizationFailTips("相机")
                    }
                }
            })
            
        case .authorized:
            block()
            
        }
        
    }
    
    private func canUseAlbum(_ block: @escaping () -> Void) {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .denied, .notDetermined, .restricted:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    if status == .authorized {
                        block()
                    }
                    else {
                        self.showAuthorizationFailTips("相册")
                    }
                }
            })
            
        case .authorized:
            block()
            
        }
        
    }
    
    private func canUseMicrophone(_ block: @escaping () -> Void) {
        
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch status {
        case .denied, .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    if granted {
                        block()
                    }
                    else {
                        self.showAuthorizationFailTips("麦克风")
                    }
                }
            })
            
        case .authorized:
            block()
        }
        
    }
    
    private func showAuthorizationFailTips(_ function: String) {
        let title = function + "被禁用"
        let message = "请到[设置]-[隐私]-[\(function)]中允许[\(appName)]使用\(function)"
        UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "去设置").show()
    }
    
    private var appName: String {
        guard let name: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String else {
            return "应用"
        }
        return name
    }
    
}

