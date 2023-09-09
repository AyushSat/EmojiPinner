//
//  MessagesViewController.swift
//  PinnedEmojis MessagesExtension
//
//  Created by Ayush Satyavarpu on 9/4/23.
//

import UIKit
import Messages
import CoreData

class MessagesViewController: MSMessagesAppViewController {

    var emojis: [String] = []
    var emojiButtons: [UIButton] = []
    var label = UILabel()
    var noEmojisLabel = UILabel()
    var tempWrite = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadData()
        updateUI()
        view.addSubview(tempWrite)
        tempWrite.configuration = .filled()
        tempWrite.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tempWrite.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempWrite.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        tempWrite.configuration?.title = "Update"
        tempWrite.addTarget(self, action: #selector(writeData), for: .touchUpInside)
    }
    
    @objc func writeData(){
        emojis = ["🤌🏽", "💀", "📌"]
        updateUI()
        print(emojis)
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EmojiPinner MessagesExtension")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
        
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    func loadData(){
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let emojisPath = paths[0].appending(path: "emojis.txt")
        do {
            let input = try String(contentsOf: emojisPath)
            if let jsonData = input.data(using: .utf8){
                do{
                    if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String] {
                        emojis = jsonArray
                    }else{
                        print("Could not be cast")
                    }
                }catch {
                    print("Error parsing JSON \(error)")
                }
            }else{
                print("Error converting JSON to data")
            }
        }catch {
            do{
                try "[]".write(to: emojisPath, atomically: true, encoding: .utf8)
                let input = try String(contentsOf: emojisPath)
                if let jsonData = input.data(using: .utf8){
                    do{
                        if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String] {
                            emojis = jsonArray
                        }else{
                            print("Could not be cast")
                        }
                    }catch {
                        print("Error parsing JSON \(error)")
                    }
                }else{
                    print("Error converting JSON to data")
                }
            }catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func setupLabel(){
        view.addSubview(label)
        label.text = "F A V O R I T E D   E M O J I S"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5)
        ])
    }
    
    func updateUI() {
        // Remove existing buttons from the view
        for button in emojiButtons {
            button.removeFromSuperview()
        }
        noEmojisLabel.removeFromSuperview()
        emojiButtons.removeAll()

        // Re-create buttons based on the updated emojis array
        setupLabel()
        setupButtons()
    }
    
    func setupButtons(){
        if(emojis.isEmpty){
            view.addSubview(noEmojisLabel)
            noEmojisLabel.text = "No emojis favorited yet. Swipe up to add some!"
            noEmojisLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            noEmojisLabel.textColor = .systemGray2
            NSLayoutConstraint.activate([
                noEmojisLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                noEmojisLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10)
            ])
            noEmojisLabel.translatesAutoresizingMaskIntoConstraints = false
            return
        }
        for (i, emoji) in emojis.enumerated() {
            let currButton = UIButton()
            view.addSubview(currButton)
            currButton.configuration = .plain()
            currButton.translatesAutoresizingMaskIntoConstraints = false
            if i == 0 {
                NSLayoutConstraint.activate([
                    currButton.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
                    currButton.centerYAnchor.constraint(equalTo: label.bottomAnchor, constant: 25),
                ])
            }else{
                let prevButton = emojiButtons[i - 1]
                NSLayoutConstraint.activate([
                    currButton.centerXAnchor.constraint(equalTo: prevButton.centerXAnchor, constant: 50),
                    currButton.centerYAnchor.constraint(equalTo: label.bottomAnchor, constant: 25),
                ])
            }
            currButton.configuration?.title = emoji
            currButton.configuration?.attributedTitle = AttributedString(currButton.configuration!.title!, attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30)]))
            currButton.addTarget(self, action: #selector(enterEmoji(_:)), for: .touchUpInside)
            currButton.addTarget(self, action:#selector(onUp(_:)), for: .touchDown)
            emojiButtons.append(currButton)
        }


    }
    
    @objc func onUp(_ btn: UIButton){
        UIView.animate(withDuration: 0.15) {
                btn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
    }
    
    @objc func enterEmoji(_ btn: UIButton) {
        UIView.animate(withDuration: 0.15) {
                btn.transform = CGAffineTransform.identity
            }
        if let title = btn.configuration?.title {
            self.activeConversation?.insertText(title)
        }
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }

}
