//
//  MessagesCollectionViewController.swift
//  iRefalla
//
//  Created by Pavel Balderrama on 03/10/17.
//  Copyright © 2017 Pavel Balderrama. All rights reserved.
//

import UIKit

private let senderMessageCell = "senderMessageCell"
private let messageCell = "messageCell"

class MessagesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var currentMessages = [Mensaje]()
    lazy private var messages = {
            return self.currentMessages + self.newMesssages
    }
    private var newMesssages = [Mensaje] ()
    private let messageInputContainerView = UIView()
    private let inputTextField = UITextField()
    private var sendButton = UIButton()
    private var bottomConstraint:NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        setupInputBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "guardarIcon") , style: .done, target: self, action: #selector(saveButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: #selector(dismissVC))
        self.hideKeyboardWhenTappedAround()
        // Observer for Keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        scrollToLast()
    
    }
    
    private func loadData() {
        self.newMesssages = Mensaje.getLocalLabel(label: newItemsLabel)
        self.collectionView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.collectionView?.reloadData()
    }
    
    @objc private func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButton() {
        Mensaje.pinAllLabel(objects: self.newMesssages, label: newItemsLabel)
        self.dismiss(animated: true, completion: nil)
    }
    private func setupInputBar(){
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        // Setup 
        messageInputContainerView.backgroundColor = UIColor.white
        // InputField
        inputTextField.placeholder = "Ingresa el comentario"
        //sendButton config
        sendButton = UIButton(type: .system)
        sendButton.setTitle("Enviar", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField ,sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorderView)
    }
    @objc func handleSend(){
        if let text = inputTextField.text, inputTextField.text != "" {
            let message = Mensaje(texto: text)
            newMesssages.append( message)
            
            //inputTextField.endEditing(true)
            inputTextField.text = nil
            self.collectionView?.performBatchUpdates({
                self.collectionView?.insertItems(at: [IndexPath(item: messages().count-1, section: 0)] )
            }, completion: { (_) in
                self.scrollToLast()
            })
        }
    }
    
    func scrollToLast() {
        let lastItem =  self.messages().count != 0 ? self.messages().count - 1 : 0
        let indexPath = IndexPath(item: lastItem, section: 0)
        print(indexPath)
        self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    @objc func handleKeyboard(notification:NSNotification){
        if let userInfo = notification.userInfo{
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            bottomConstraint?.constant = isKeyboardShowing ? -(keyboardFrame?.height)! : 0
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if (isKeyboardShowing){
                    self.scrollToLast()
                }
            })
            
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return messages().count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let message = messages()[indexPath.item]
        let isSender = message.userName == currentUser?.username
        let reuseIdentifier = isSender ? senderMessageCell : messageCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCollectionViewCell
        cell.message = message
        cell.bubbleImageView.image = isSender ? MessageCollectionViewCell.blueBubbleImage : MessageCollectionViewCell.grayBubbleImage
        cell.bubbleImageView?.tintColor = isSender ? UIColor(white: 0.95, alpha: 1) : UIColor(r: 0, g: 137, b: 249, alpha: 1)
        cell.messageTextView?.textColor = isSender ? UIColor.black : UIColor.white
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages()[indexPath.item]
        let messageText = message.texto ?? ""
        let width = view.frame.width - 203 // 154 texview a celda
        let size = messageText.estimateSize(width: Int(width), fontSize: 16)
        let isSender = message.usuario == currentUser ? true : false
        let padding: CGFloat = isSender ? 20+20: 31+20
        return CGSize(width: view.frame.width, height: size.height + padding)
    }
    
}
