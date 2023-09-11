//
//  MessagesViewController.swift
//  PinnedEmojis MessagesExtension
//
//  Created by Ayush Satyavarpu on 9/4/23.
//

import UIKit
import Messages
import CoreData

func generateRandomEmoji() -> String {
    let emojiRanges: [ClosedRange<UInt32>] = [
        0x1F600...0x1F64F
    ]

    let randomRange = emojiRanges.randomElement()!
    let randomEmoji = UnicodeScalar(randomRange.lowerBound + arc4random_uniform(randomRange.upperBound - randomRange.lowerBound + 1))!
    return String(randomEmoji)
}

struct UIButtonWrapper{
    var button: UIButton
    var trailingConstraint: NSLayoutConstraint
    var centerYConstraint: NSLayoutConstraint
}

class MessagesViewController: MSMessagesAppViewController {
            
    var emojis: [EmojiEntity] = []
    var context = CoreDataHelper.persistentContainer.viewContext
    var emojiButtons: [UIButtonWrapper] = []
    var xButtons: [UIButton] = []
    var label = UILabel()
    var noEmojisLabel = UILabel()
    var isExpanded = false
    var mainTextField = UITextField()
    var mainTextConstraint:NSLayoutConstraint? = nil
    var addButton = UIButton()
    var addConstraint:NSLayoutConstraint? = nil
    
    let numColumns = 7
    let emojiFontSize: CGFloat = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadData(true)
        updateUI()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    func initializeTextField(){
        
        self.view.addSubview(addButton)
        addButton.configuration = .filled()
        addButton.translatesAutoresizingMaskIntoConstraints = false
        if addConstraint == nil{
            addConstraint = addButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        }
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
        ])
        self.addConstraint?.isActive = true
        self.addButton.configuration?.title = "Add"
        self.addButton.addTarget(self, action: #selector(addEmoji), for: .touchUpInside)

        
        self.view.addSubview(mainTextField)
        if self.mainTextConstraint == nil{
            self.mainTextConstraint = mainTextField.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        }
        NSLayoutConstraint.activate([
            mainTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            mainTextField.trailingAnchor.constraint(equalTo: self.addButton.leadingAnchor, constant: -5),
            mainTextField.topAnchor.constraint(equalTo: self.addButton.topAnchor)
        ])
        self.mainTextConstraint?.isActive = true
        mainTextField.translatesAutoresizingMaskIntoConstraints = false
        mainTextField.placeholder = "Enter emoji"
        mainTextField.font = UIFont.systemFont(ofSize: 15)
        mainTextField.borderStyle = .roundedRect
        mainTextField.keyboardType = .default
        mainTextField.backgroundColor = UIColor.systemGray4
        
        

        
    }
    
    @objc func keyboardWillShow(_ notification : Notification){
        print("Keyboard will show")
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else{
            return
        }
        let kbHeight = keyboardFrame.height
        UIView.animate(withDuration: 0.2, animations: {
            self.mainTextConstraint?.constant = -kbHeight + 30
            self.addConstraint?.constant = -kbHeight + 30
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        UIView.animate(withDuration: 0.2, animations: {
            self.mainTextConstraint?.constant = -10
            self.addConstraint?.constant = -10
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func removeEmojis(){
        do{
            self.emojis = try self.context.fetch(EmojiEntity.fetchRequest())
            for e in self.emojis{
                context.delete(e)
            }
            do{
                try self.context.save()
            }catch {
                print("error in wiping data \(error)")
            }
            loadData(true)
        }catch{
            print("error in loadData \(error)")
        }
    }
    
    @objc func removeEmoji(_ sender: UIButton){
        print("removing \(sender.tag)")
        let emojiToDelete = self.emojis[sender.tag]
        context.delete(emojiToDelete)
        do{
            try self.context.save()
        }catch {
            print("error in wiping data \(error)")
        }
        loadData(false)
        let emojiButtonToDelete = self.emojiButtons[sender.tag]
        let xButtonToDelete = self.xButtons[sender.tag]
        self.emojiButtons.remove(at: sender.tag)
        self.xButtons.remove(at: sender.tag)
        for xButton in xButtons{
            if xButton.tag > sender.tag{
                xButton.tag = xButton.tag - 1
            }
        }
        UIView.animate(withDuration: 0.2, animations: {
            for i in sender.tag..<self.emojiButtons.count {
                    let emojiButton = self.emojiButtons[i]
                    let (xOffset, yOffset): (CGFloat, CGFloat) = self.getPosition(i)
                    
                    // Update the constant values of existing constraints
                    emojiButton.centerYConstraint.constant = yOffset
                    emojiButton.trailingConstraint.constant = xOffset
                }
                
                // Layout the views with animations
                self.view.layoutIfNeeded()
                
                // Fade out and remove the deleted button
                emojiButtonToDelete.button.alpha = 0.0
                xButtonToDelete.alpha = 0.0
            }) { (completed) in
                // After the animation is complete, remove the deleted button from the view hierarchy
                emojiButtonToDelete.button.removeFromSuperview()
                xButtonToDelete.removeFromSuperview()
            }
    }
    
    @objc func addEmoji(){
        
        if let insertChar: Character = mainTextField.text!.first {
            writeData(String(insertChar))
            self.loadData(true)
            DispatchQueue.main.async{
                self.mainTextField.resignFirstResponder()
                self.mainTextField.text = ""
                self.removeXButtons()
                self.addXButtons()
            }
            
            
        }else {
            mainTextField.resignFirstResponder()
        }
        
    }
    
    @objc func writeData(_ newEmojiCharacter: String){
        let newEmoji = EmojiEntity(context: self.context)
        newEmoji.emojiString = newEmojiCharacter
        do{
            try self.context.save()
        }catch{
            print("error in writeData \(error)")
        }
        loadData(false)
    }
    
    
    
    func loadData(_ updateUI: Bool){
        do{
            self.emojis = try self.context.fetch(EmojiEntity.fetchRequest())
            if updateUI{
                DispatchQueue.main.async{
                    self.updateUI()
                }
            }
        }catch{
            print("error in loadData \(error)")
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
            button.button.removeFromSuperview()
        }
        noEmojisLabel.removeFromSuperview()
        emojiButtons.removeAll()

        // Re-create buttons based on the updated emojis array
        setupLabel()
        setupButtons()
    }
    
    func getPosition(_ index: Int) -> (CGFloat, CGFloat){
        let rowIndex = floor(Float(Float(index)/Float(numColumns)))
        let colIndex = index % numColumns
        
        let xOffset = Float(colIndex + 1) * Float(self.view.frame.width - 30) / Float(numColumns)
        let yOffset = rowIndex * 40 + 60
        
        return (CGFloat(xOffset), CGFloat(yOffset))
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
            let (xOffset, yOffset) : (CGFloat, CGFloat) = getPosition(i)
            let newTrailingConstraint = currButton.trailingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: xOffset)
            let newCenterConstraint = currButton.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: yOffset)
            NSLayoutConstraint.activate([newTrailingConstraint, newCenterConstraint])
            currButton.configuration?.title = emoji.emojiString
            currButton.configuration?.attributedTitle = AttributedString(currButton.configuration!.title!, attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.systemFont(ofSize: emojiFontSize)]))
            currButton.addTarget(self, action: #selector(enterEmoji(_:)), for: .touchUpInside)
            currButton.addTarget(self, action:#selector(onUp(_:)), for: .touchDown)
            currButton.configuration!.contentInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
            emojiButtons.append(UIButtonWrapper(button: currButton, trailingConstraint: newTrailingConstraint, centerYConstraint: newCenterConstraint))
        }


    }
    
    @objc func onUp(_ btn: UIButton){
        if isExpanded{
            return
        }
        UIView.animate(withDuration: 0.15) {
                btn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
    }
    
    @objc func enterEmoji(_ btn: UIButton) {
        if isExpanded{
            return
        }
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
    
    func addXButtons(){
        for (i, emojiButton) in emojiButtons.enumerated() {
            shakeButton(button: emojiButton.button)
            let newX = UIButton()
            view.addSubview(newX)
            newX.configuration = .gray()
            newX.tintColor = .white
            newX.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newX.centerXAnchor.constraint(equalTo: emojiButton.button.leadingAnchor, constant: 10.0),
                newX.centerYAnchor.constraint(equalTo: emojiButton.button.topAnchor, constant: 10.0)
            ])
            newX.configuration?.title = "x"
            newX.configuration?.attributedTitle = AttributedString(newX.configuration!.title!, attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10)]))
            newX.tag = i
            newX.addTarget(self, action: #selector(removeEmoji), for: .touchUpInside)
            newX.configuration!.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 2, trailing: 2)
            view.bringSubviewToFront(newX)
            xButtons.append(newX)
            shakeButtonViolently(button: newX)
        }
    }
    
    func removeXButtons(){
        for xButton in xButtons{
            xButton.removeFromSuperview()
        }
        xButtons = []
    }
    
    func shakeButton(button: UIButton) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.1  // Adjust the duration as needed
        animation.autoreverses = true
        animation.repeatCount = .infinity  // Repeat indefinitely
        animation.fromValue = NSNumber(value: Float(-0.05)) // Rotate slightly counterclockwise
        animation.toValue = NSNumber(value: Float(0.05))   // Rotate slightly clockwise
        button.layer.add(animation, forKey: "rotation")
    }
    
    
    func shakeButtonViolently(button: UIButton) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.1  // Adjust the duration as needed
        animation.autoreverses = true
        animation.repeatCount = .infinity  // Repeat indefinitely
        animation.fromValue = NSNumber(value: Float(-0.13)) // Rotate slightly counterclockwise
        animation.toValue = NSNumber(value: Float(0.13))   // Rotate slightly clockwise
        button.layer.add(animation, forKey: "rotationViolent")
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if presentationStyle == .expanded{
            addXButtons()
            self.isExpanded = true
            self.initializeTextField()
            self.mainTextConstraint?.constant = -10
            self.addConstraint?.constant = -10
            self.view.layoutIfNeeded()
        }else if presentationStyle == .compact{
            for emojiButton in emojiButtons {
                emojiButton.button.layer.removeAnimation(forKey: "rotation")
            }
            removeXButtons()
            self.isExpanded = false
            self.loadData(true)
            self.mainTextConstraint?.constant = -10
            self.addConstraint?.constant = -10
            self.view.layoutIfNeeded()
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.se this method to finalize any behaviors associated with the change in presentation style.
    }

}
