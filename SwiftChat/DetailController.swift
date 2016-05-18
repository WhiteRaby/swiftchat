//
//  DetailController.swift
//  SwiftChat
//
//  Created by Alexandr on 30.03.16.
//  Copyright © 2016 Alexandr. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class DetailController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var recipientId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        setupBubbles()
        title = self.recipientId
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        title = recipientId
        
        DataManager.sharedManager.removeObserver()
        
        DataManager.sharedManager.observeMessages(senderId: self.senderId, recipientId: self.recipientId) {
            self.addMessage($0)
        }
        
        DataManager.sharedManager.observeTypingUser(self.recipientId) {
            self.showTypingIndicator = $0
            if $0 { self.scrollToBottomAnimated(true) }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if (!message.isMediaMessage) {
            if message.senderId == senderId { // 1
                cell.textView!.textColor = UIColor.whiteColor() // 2
            } else {
                cell.textView!.textColor = UIColor.blackColor() // 3
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func addMessage(message: Message) {
        
        if (message.imageString == "nil") {
            messages.append(JSQMessage(senderId: message.senderId, displayName: "", text: message.text))
        } else {
            let media = JSQPhotoMediaItem(image: message.image)
            messages.append(JSQMessage(senderId: message.senderId, displayName: "", media: media))
        }
        
        self.finishReceivingMessage()
    }
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        DataManager.sharedManager.isTyping = textView.text != ""
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {

        DataManager.sharedManager.newMessage(Message(senderId: senderId!, text: text!, image: nil))

        JSQSystemSoundPlayer.jsq_playMessageSentSound()

        finishSendingMessage()
        DataManager.sharedManager.isTyping = false
    }
    
    private func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        //picker.allowsEditing = false
        //picker.sourceType = .PhotoLibrary
        
        self.presentViewController(picker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
 
        DataManager.sharedManager.newMessage(Message(senderId: senderId, text: "image", image: image))

        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
}
