//
//  Message.swift
//  SwiftChat
//
//  Created by Alexandr on 31.03.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import Foundation
import UIKit

class Message {

    var senderId: String!
    var text: String!
    var imageString: String?
    var image: UIImage? {
        get {
            if (imageString != nil) {
                let decodedData = NSData(base64EncodedString: imageString!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                return UIImage(data: decodedData!)
            } else {
                return nil
            }
        }
        set (value) {
            if (value != nil) {
                let data = UIImageJPEGRepresentation(value!, 0.1)
                let base64String = data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                self.imageString = base64String
            } else {
                self.imageString = nil
            }
        }
    }
    
    var dictionary: Dictionary<String, String> {
        get {
            return ["senderId": senderId,
                    "text": text,
                    "imageString": (imageString != nil ? imageString : "nil")!]
        }
        set (value) {
            senderId = value["senderId"]
            text = value["text"]
            imageString = value["imageString"]
        }
    }
    
    init (senderId: String, text: String, image: UIImage?) {
        self.senderId = senderId
        self.text = text
        self.image = image
    }
    
    init (dictionary: [String: String]) { 
        self.dictionary = dictionary
    }
}
