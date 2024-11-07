//
//  Glyphs.swift
//  Lirum-Glyphs
//
//  Created by Rogerio on 11/6/24.
//

import SwiftUI
import UIKit

public enum GlyphsType {
    case fontAwesome
    case sf
    case auto
}

public class Glyphs {
    public static let shared = Glyphs()
    
    private init() {
        registerFontAwesome()
    }
    
    private func registerFontAwesome() {
        guard let url = Bundle(for: Self.self).url(forResource: "FontAwesome", withExtension: "ttf") else {
            fatalError("Failed to find FontAwesome font file.")
        }
        
        var error: Unmanaged<CFError>?
        if #available(iOS 18.0, *) {
            guard CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) else {
                print("Error registering font: \(error.debugDescription)")
                return
            }
        } else {
            guard let fontDataProvider = CGDataProvider(url: url as CFURL),
                  let font = CGFont(fontDataProvider) else {
                fatalError("Failed to load FontAwesome font.")
            }
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                print("Error registering font: \(error.debugDescription)")
            }
        }
    }
    
    // Reference to our icon map
    private let fontAwesomeMap = fontAwesomeIconMap
}

#if canImport(SwiftUI)
import SwiftUI

public extension Glyphs {
    static func createImage(name: String, type: GlyphsType = .auto, size: CGFloat = 64) -> Image? {
        if let uiImage = Self.createUIImage(name: name, type: type, size: size) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}
#endif

public extension Glyphs {
    static func createUIImage(name: String, type: GlyphsType = .auto, size: CGFloat = 64) -> UIImage? {
        switch type {
            case .fontAwesome:
                return fontAwesomeImage(name: name, size: size)
            case .sf:
                return sfImage(name: name, size: size)
            case .auto:
                if let faImage = fontAwesomeImage(name: name, size: size) {
                    return faImage
                }
                return sfImage(name: name, size: size)
        }
    }
    
    private static func fontAwesomeImage(name: String, size: CGFloat) -> UIImage? {
        guard let iconCode = shared.fontAwesomeMap[name],
              let font = UIFont(name: "FontAwesome", size: size) else {
            return nil
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        
        let imageSize = size
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize, height: imageSize), false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let string = NSString(string: iconCode)
        let stringSize = string.size(withAttributes: attributes)
        let point = CGPoint(x: (imageSize - stringSize.width) / 2,
                            y: (imageSize - stringSize.height) / 2)
        
        string.draw(at: point, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private static func sfImage(name: String, size: CGFloat) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: size)
        return UIImage(systemName: name)?.withConfiguration(config)
    }
}

