//
//  UIImage+SLKit.swift
//  SolarExtensionExample
//
//  Created by wyh on 2018/2/17.
//  Copyright © 2018年 SolarKit. All rights reserved.
//  compressedImage source: https://github.com/iCell/Mozi

import UIKit

public extension UIImage {
    
    public var base64: String {
        return UIImagePNGRepresentation(self)?.base64EncodedString() ?? ""
    }
    
}

public extension UIImage {
    
    public enum SLWatermakrLocation: Int {
        
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
        case Center
        case Overspread
        
        
        func rect(imageSize: CGSize, watermarkSize: CGSize) -> CGRect {
            switch self {
            case .TopLeft:
                return CGRect(origin: CGPoint.zero, size: watermarkSize)
                
            case .TopRight:
                return CGRect(origin: CGPoint(x: imageSize.width - watermarkSize.width, y: 0), size: watermarkSize)
                
            case .BottomLeft:
                return CGRect(origin: CGPoint(x: 0, y: imageSize.height - watermarkSize.height), size: watermarkSize)
            case .BottomRight:
                return CGRect(origin: CGPoint(x: imageSize.width - watermarkSize.width, y: imageSize.height - watermarkSize.height), size: watermarkSize)
            case .Center:
                return CGRect(origin: CGPoint(x: imageSize.width / 2 - watermarkSize.width / 2, y: imageSize.height / 2 - watermarkSize.height / 2), size: watermarkSize)
            case .Overspread:
                return CGRect.zero
            }
        }
        
    }
    
    
    /// add watermark to image
    ///
    /// - Parameters:
    ///   - watermark: watermark image
    ///   - location: location
    ///   - interval: 5~10
    /// - Returns: image with watermark
    public func watermark(_ watermark: UIImage, location: SLWatermakrLocation = .BottomRight, interval: Int = 10) -> UIImage {
        if interval < 5 || interval > 10 { return self }
        
        let maxImageLength = size.width > size.height ? size.width : size.height
        let minImageLength = size.width < size.height ? size.width : size.height
        let intervalLength = maxImageLength / CGFloat(interval)
        
        var watermarkSize = watermark.size
        let maxWatermarkLength = watermarkSize.width > watermarkSize.height ? watermarkSize.width : watermarkSize.height
        
        var watermarkLength: CGFloat
        if maxWatermarkLength > minImageLength {
            watermarkLength = minImageLength
        }
        else if intervalLength > maxWatermarkLength && maxWatermarkLength < minImageLength {
            watermarkLength = maxWatermarkLength
        }
        else {
            watermarkLength = intervalLength
        }
        
        let watermarkWidth = watermarkSize.width > watermarkSize.height ? watermarkLength : watermarkSize.width * (watermarkLength / maxWatermarkLength)
        let watermarkHeight = watermarkSize.width > watermarkSize.height ? watermarkSize.height * (watermarkLength / maxWatermarkLength) : watermarkLength
        watermarkSize = CGSize(width: watermarkWidth, height: watermarkHeight)
        
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        if location == .Overspread {
            
            var y: CGFloat = 0
            while (y < size.height) {
                var x: CGFloat = 0
                while (x < size.width) {
                    watermark.draw(in: CGRect(origin: CGPoint(x: x, y: y), size: watermarkSize))
                    x = x + 2 * intervalLength
                }
                y = y + 2 * intervalLength
            }
        }
        else {
            watermark.draw(in: location.rect(imageSize: size, watermarkSize: watermarkSize))
        }
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image ?? self
    }
    
}


public extension UIImage {
    
    enum WidthType {
        case small(minValue: CGFloat, maxValue: CGFloat)
        case middle(minValue: CGFloat, maxValue: CGFloat)
        case large(minValue: CGFloat, maxValue: CGFloat)
        case giant(minValue: CGFloat, maxValue: CGFloat)
        
        init(minV: CGFloat, maxV: CGFloat) {
            switch maxV {
            case 0..<1664:
                self = .small(minValue: minV, maxValue: maxV)
            case 1664..<4990:
                self = .middle(minValue: minV, maxValue: maxV)
            case 4990..<10240:
                self = .large(minValue: minV, maxValue: maxV)
            default:
                self = .giant(minValue: minV, maxValue: maxV)
            }
        }
        
        var size: (minV: CGFloat, maxV: CGFloat, size: CGFloat) {
            switch self {
            case .small(let minV, let maxV):
                return (minV: minV, maxV: maxV, size: max(60, minV * maxV / pow(1664, 2) * 150))
            case .middle(let minV, let maxV):
                return (minV: minV / 2, maxV: maxV / 2, size: max(60, ((minV / 2) * (maxV / 2)) / pow(4990 / 2, 2) * 300))
            case .large(let minV, let maxV):
                return (minV: minV / 4, maxV: maxV / 4, size: max(100, ((minV / 4) * (maxV / 4)) / pow(10240 / 4, 2) * 300))
            case .giant(let minV, let maxV):
                let multiple = ((maxV / 1280) == 0) ? 1 : (maxV / 1280)
                return (minV: minV / multiple, maxV: maxV / multiple, size: max(100, ((minV / multiple) * (maxV / multiple)) / pow(2560, 2) * 300))
            }
        }
    }
    
    enum SizeType {
        case square(minValue: CGFloat, maxValue: CGFloat)
        case rectangle(minValue: CGFloat, maxValue: CGFloat)
        case other(minValue: CGFloat, maxValue: CGFloat)
        
        init?(size: CGSize) {
            let minV = min(size.width, size.height)
            let maxV = max(size.width, size.height)
            
            let ratio = minV / maxV
            
            if ratio > 0 && ratio <= 0.5 {
                // [1:1 ~ 9:16)
                self = .square(minValue: minV, maxValue: maxV)
            } else if ratio > 0.5 && ratio < 0.5625 {
                // [9:16 ~ 1:2)
                self = .other(minValue: minV, maxValue: maxV)
            } else if ratio >= 0.5625 && ratio <= 1 {
                // [1:2 ~ 1:∞)
                self = .rectangle(minValue: minV, maxValue: maxV)
            } else {
                return nil
            }
        }
        
        var size: (minV: CGFloat, maxV: CGFloat, size: CGFloat) {
            switch self {
            case .square(let minV, let maxV):
                let widthType = WidthType.init(minV: minV, maxV: maxV)
                return widthType.size
            case .rectangle(let minV, let maxV):
                let multiple = ((maxV / 1280) == 0) ? 1 : (maxV / 1280)
                let size = max(100, ((minV / multiple) * (maxV / multiple)) / (1440 * 2560) * 400)
                return (minV: minV / multiple, maxV: maxV / multiple, size: size)
            case .other(let minV, let maxV):
                let ratio = minV / maxV
                let multiple = CGFloat(ceilf(Float(maxV / (1280 / ratio))))
                let size = max(100, ((minV / multiple) * (maxV / multiple)) / (1280 * (1280 / ratio)) * 500)
                return (minV: minV / multiple, maxV: maxV / multiple, size: size)
            }
        }
    }
    
    public func compressedImage() -> UIImage {
        if let imgData = UIImageJPEGRepresentation(self, 1) {
            let imgFileSize = imgData.count
            print("origin file size: \(imgFileSize)")
            
            if let type = SizeType.init(size: size) {
                let compressSize = type.size.size
                let resizedImage = resizeTo(size: CGSize(width: type.size.minV, height: type.size.maxV))
                if let data = resizedImage.compressTo(size: compressSize) {
                    print("compressed file size: \(data.count)")
                    return UIImage(data: data) ?? self
                }
            }
        }
        return self
    }
    
    public func compressedData() -> Data? {
        if let imgData = UIImageJPEGRepresentation(self, 1) {
            let imgFileSize = imgData.count
            print("origin file size: \(imgFileSize)")
            
            if let type = SizeType.init(size: self.size) {
                let compressSize = type.size.size
                let resizedImage = resizeTo(size: CGSize(width: type.size.minV, height: type.size.maxV))
                if let data = resizedImage.compressTo(size: compressSize) {
                    print("compressed file size: \(data.count)")
                    return data
                }
            }
        }
        return nil
    }
    
    public func resizeTo(size: CGSize) -> UIImage {
        let ratio = self.size.height / self.size.width
        var factor: CGFloat = 1.0
        if ratio > 1 {
            factor = size.height / size.width
        } else {
            factor = size.width / size.height
        }
        let toSize = CGSize(width: self.size.width * factor, height: self.size.height * factor)
        
        UIGraphicsBeginImageContext(toSize)
        draw(in: CGRect.init(origin: CGPoint(x: 0, y: 0), size: toSize))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image ?? self
    }
    
    public func compressTo(size: CGFloat) -> Data? {
        var compression: CGFloat = 1.0
        let maxCompression: CGFloat = 0.1
        guard var data = UIImageJPEGRepresentation(self, compression) else {
            return nil
        }
        while CGFloat(data.count) > size && compression > maxCompression {
            compression -= 0.1
            if let temp = UIImageJPEGRepresentation(self, compression) {
                data = temp
            } else {
                return data
            }
        }
        return data
    }
    
    public func compressToScale(scale: CGFloat) -> UIImage {
        if scale >= 1 { return self }
        
        let scaleImageSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContext(scaleImageSize)
        draw(in: CGRect(origin: CGPoint.zero, size: scaleImageSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }

}
