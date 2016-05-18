//
//  DataManager.swift
//  SwiftChat
//
//  Created by Alexandr on 30.03.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import Foundation
import Firebase

class DataManager {

    static let sharedManager = DataManager()
    
    var ref: Firebase!
    var messageRef: Firebase!
    var userIsTypingRef: Firebase!
    var typingIndicatorRef: Firebase!
    var currentUserRef: Firebase!
    var usersRef: Firebase!
    var roomsRef: Firebase!

    var userName: String?
    func setOnline(online: Bool) -> Void {
        if let saveRef = currentUserRef {
            saveRef.childByAppendingPath("online").setValue(online)
        }
    }
    private var localTyping = false

    private init() {
        
        ref = Firebase(url: "https://blinding-torch-1202.firebaseio.com")
        typingIndicatorRef = ref.childByAppendingPath("typingIndicator")
        messageRef = ref
        usersRef = ref.childByAppendingPath("users")
        roomsRef = ref.childByAppendingPath("rooms")

    }
    
    func deviceID() -> String {
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
        //return "8B577D08-31DC-4641-9AD3-1B36F033DB86"
    }
    
    func authorization(completion: (found: Bool, name: User?) -> Void) {
        
        
        self.ref.authAnonymouslyWithCompletionBlock { (error, authData) in
            if error != nil { print(error.description); return }
            
            self.getUserWithId(self.deviceID(), completion: completion)
        }
    }
    
    func createUser(user: User) {
        
        let userRet = usersRef.childByAppendingPath(user.id)
        
        userRet.setValue(["name": user.name, "id": user.id, "online": user.isOnline])
    }
    
    func logIn(user: User) {
        
        userName = user.name
        currentUserRef = usersRef.childByAppendingPath(user.id)
        setOnline(true)
    }
    
    func getUserWithId(id: String, completion: (found: Bool, user: User?) -> Void) {
        
        usersRef.childByAppendingPath(id).observeSingleEventOfType(.Value, withBlock: { snapshot in

            if snapshot.exists() {
                let user = snapshot.value as! Dictionary<String, AnyObject>
                completion(found: true, user: User(
                    name: user["name"] as! String,
                    id: user["id"] as! String,
                    isOnline: user["online"] as! Bool)
                )
            } else {
                completion(found: false, user: nil)
            }
        })
    }
    
    func getUsers(completion: (Array<User> -> Void)){
        
        usersRef.queryOrderedByChild("name").observeSingleEventOfType(.Value, withBlock: { snapshot in
            var users: Array<User> = []

            for object in snapshot.children  {
                let user = (object as! FDataSnapshot).value as! Dictionary<String, AnyObject>
                users.append( User(
                    name: user["name"] as! String,
                    id: user["id"] as! String,
                    isOnline: user["online"] as! Bool)
                )
            }
            
            completion(users)
        })
    }
    
    
    func observeMessages(senderId senderId: String, recipientId: String, action: (Message) -> ()) {
                
        roomsRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            var found = false
            
            for children in snapshot.children {
                let room = (children as! FDataSnapshot).value as! Dictionary<String, AnyObject>
                let first = room["first"] as! String
                let second = room["second"] as! String
                
                if (first == senderId && second == recipientId) ||
                    (first == recipientId && second == senderId) {
                    
                    self.messageRef = self.roomsRef.childByAppendingPath(children.key!).childByAppendingPath("messages")
                    
                    found = true
                    break
                }
            }
            
            if !found {
                let roomRef = self.roomsRef.childByAutoId()
                roomRef.setValue(["first": senderId, "second": recipientId])
                self.messageRef = roomRef.childByAppendingPath("messages")
            }
            
            self.messageRef.observeEventType(.ChildAdded, withBlock: { snapshot in
                
                let message = Message(dictionary: snapshot.value as! Dictionary<String, String>)
                action(message)
            })
        })
    }
    
    func newMessage(message: Message) {
        
        let itemRef = messageRef.childByAutoId()
        itemRef.setValue(message.dictionary)
    }
    
    func observeTypingUser(userId: String, action: (isTyping: Bool) -> ()) {
        
        userIsTypingRef = typingIndicatorRef.childByAppendingPath(self.userName)
        userIsTypingRef.onDisconnectRemoveValue()
        
        typingIndicatorRef.observeEventType(.Value) { (data: FDataSnapshot!) in
            
            if let data: NSDictionary = data.value as? NSDictionary {
                for (key, value) in data {
                    if key as! String == userId {
                        action(isTyping: Bool(value as! NSNumber))
                    }
                }
            }
        }
    }
    
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    func removeObserver() {
        
        ref.removeAllObservers()
        messageRef.removeAllObservers()
        typingIndicatorRef.removeAllObservers()
    }
    
    func observeUsers(action: () -> ()) {
        
        usersRef.observeEventType(.Value, withBlock: { snapshot in
            
            action()
        })
        
    }
}
