//
//  KeyboardViewController.swift
//  Idefix Keyboard
//
//  Created by Muhammed Köstekli on 12.04.2019.
//  Copyright © 2019 Kostekli. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    // Auto Complete Buttons
    @IBOutlet var suggestionButton: [UIButton] = []
    
    
    var capsLockOn = true
    var currentCharSet = 0
    
    @IBOutlet weak var row1: UIView!
    @IBOutlet weak var row2: UIView!
    @IBOutlet weak var row3: UIView!
    @IBOutlet weak var row4: UIView!
    
    @IBOutlet weak var charSet1: UIView!
    @IBOutlet weak var charSet2: UIView!
    
    // Saved Strings for Auto Complete
    var savedStrings = ["Bafetimbi","Galatasaray","Galata","Dürüm"]
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "IdefixKeyboard", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        view = objects[0] as? UIView
        
        
        charSet1.isHidden = true
        clearSuggestionButtons()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
    }
    
    
    // Keyboard Buttons Controller
    @IBAction func nextKeyboardPressed(button: UIButton) {
        advanceToNextInputMode()
    }
    
    @IBAction func capsLockPressed(button: UIButton) {
        capsLockOn = !capsLockOn
        
        changeCaps(containerView: row1)
        changeCaps(containerView: row2)
        changeCaps(containerView: row3)
        changeCaps(containerView: row4)
    }
    
    @IBAction func keyPressed(button: UIButton) {
        let string = button.titleLabel!.text
        (textDocumentProxy as UIKeyInput).insertText("\(string!)")
        let currentStr = (textDocumentProxy.documentContextBeforeInput ?? "") + (textDocumentProxy.documentContextAfterInput ?? "")
        DispatchQueue.main.async {
            self.changeSuggestionButtons(inputText: currentStr)
        }
        button.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.05, animations: {
            button.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }, completion: {(_) -> Void in
            button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func backSpacePressed(button: UIButton) {
        (textDocumentProxy as UIKeyInput).deleteBackward()
        let currentStr = (textDocumentProxy.documentContextBeforeInput ?? "") + (textDocumentProxy.documentContextAfterInput ?? "")
        DispatchQueue.main.async {
            self.changeSuggestionButtons(inputText: currentStr)
        }
    }
    
    @IBAction func spacePressed(button: UIButton) {
        (textDocumentProxy as UIKeyInput).insertText(" ")
    }
    
    @IBAction func returnPressed(button: UIButton) {
        (textDocumentProxy as UIKeyInput).insertText("\n")
    }
    
    @IBAction func charSetPressed(button: UIButton) {
        if currentCharSet == 0 {
            charSet1.isHidden = false
            charSet2.isHidden = true
            currentCharSet = 1
        } else {
            charSet1.isHidden = true
            charSet2.isHidden = false
            currentCharSet = 0
        }
    }
    
    func changeCaps(containerView: UIView) {
        for view in containerView.subviews {
            if let button = view as? UIButton {
                if let buttonTitle = button.titleLabel!.text{
                    if capsLockOn {
                        
                        if buttonTitle == "i" {
                            button.setTitle("İ", for: .normal)
                        }else{
                            if buttonTitle.count == 1{
                                let text = buttonTitle.uppercased()
                                button.setTitle("\(text)", for: .normal)
                            }
                        }
                        
                    } else {
                        if buttonTitle == "İ" {
                            button.setTitle("i", for: .normal)
                        }else if buttonTitle == "I"{
                            button.setTitle("ı", for: .normal)
                        }else{
                            if buttonTitle.count == 1{
                                let text = buttonTitle.lowercased()
                                button.setTitle("\(text)", for: .normal)
                                
                            }
                        }
                        
                    }
                }
                
            }
        }
    }
    
    // Check for Suggestion Buttons
    func changeSuggestionButtons(inputText: String){
        clearSuggestionButtons()
        for str in savedStrings{
            if(str.lowercased().contains(inputText.lowercased()) && str.count >= inputText.count){
                for button in suggestionButton{
                    if button.title(for: .normal) == "" && !wordIsAlreadySuggest(inputText: str){
                        button.setTitle(str, for: .normal)
                        break
                    }
                }
            }
        }
        
        
    }
    
    // Clear title of suggestion buttons
    func clearSuggestionButtons(){
        for button in suggestionButton{
            button.setTitle("", for: .normal)
        }
    }
    
    
    // Control word is already suggested
    func wordIsAlreadySuggest(inputText: String) -> Bool{
        for button in suggestionButton{
            if button.title(for: .normal) == inputText{
                return true
            }
        }
        return false
    }

}
