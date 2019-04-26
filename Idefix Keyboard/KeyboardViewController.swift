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
    
    // Delete text button
    @IBOutlet weak var deleteKeyboardButton: UIButton!
    
    // Auto Complete Buttons
    @IBOutlet var suggestionButton: [UIButton] = []
    
    // Control capsLock variables
    var capsLockOn = true
    var currentCharSet = 0
    
    @IBOutlet weak var row1: UIView!
    @IBOutlet weak var row2: UIView!
    @IBOutlet weak var row3: UIView!
    @IBOutlet weak var row4: UIView!
    
   
    
    // All words Lists in json
    var wordsLists = [String()]
    var nextWordsList = [NSArray()]
    
    // control for auto complete sequence
    var autoCompletionStarted = false
    
    // Timer for long delete
    var timer: Timer?
    

    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Parse words arrays
        ParseWordsJson()
        
        let nib = UINib(nibName: "IdefixKeyboard", bundle: nil)
        let objects = nib.instantiate(withOwner: self, options: nil)
        view = objects[0] as? UIView
        
        //charSet1.isHidden = true
        clearSuggestionButtons()
        
        // Make long press settings
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        deleteKeyboardButton.addGestureRecognizer(longPress)
        
        
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
        autoCompletionStarted = false
        
        // Take button letter
        let string = button.titleLabel!.text
        // Insert it to textField
        (textDocumentProxy as UIKeyInput).insertText("\(string!)")
        // find Last word on Text Field
        let currentStr = findCurrentWord()
        // Start Suggestion Process
        DispatchQueue.main.async {
            self.changeSuggestionButtons(inputText: currentStr)
        }
        button.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.01, animations: {
            button.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }, completion: {(_) -> Void in
            button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func backSpacePressed(button: UIButton) {
        autoCompletionStarted = false
        (textDocumentProxy as UIKeyInput).deleteBackward()
        let FullStr = (textDocumentProxy.documentContextBeforeInput ?? "") + (textDocumentProxy.documentContextAfterInput ?? "")
        
        // If all text deleted then change Caps
        if FullStr == ""{
            if !capsLockOn{
                capsLockPressed(button: deleteKeyboardButton)
            }
            self.clearSuggestionButtons()
        }else{
            let currentStr = findCurrentWord()
            DispatchQueue.main.async {
                self.changeSuggestionButtons(inputText: currentStr)
            }
        }
    }
    
    @IBAction func spacePressed(button: UIButton) {
        autoCompletionStarted = false
        let FullStr = (textDocumentProxy.documentContextBeforeInput ?? "") + (textDocumentProxy.documentContextAfterInput ?? "")
        
        // Make caps lock on after dot
        if FullStr.last == "." {
            if !capsLockOn{
                capsLockPressed(button: deleteKeyboardButton)
            }
        }
        self.clearSuggestionButtons()
        (textDocumentProxy as UIKeyInput).insertText(" ")
    }
    
    @IBAction func returnPressed(button: UIButton) {
        autoCompletionStarted = false
        self.clearSuggestionButtons()
        (textDocumentProxy as UIKeyInput).insertText("\n")
    }
    
    @IBAction func charSetPressed(button: UIButton) {
        autoCompletionStarted = false
        if currentCharSet == 0 {
            //charSet1.isHidden = false
            //charSet2.isHidden = true
            currentCharSet = 1
        } else {
            //charSet1.isHidden = true
            //charSet2.isHidden = false
            currentCharSet = 0
        }
    }
    
    func changeCaps(containerView: UIView) {
        autoCompletionStarted = false
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
        // Search on wordsLists
        for str in wordsLists{
            // Find suggested words
            if(str.lowercased().contains(inputText.lowercased()) && str.count >= inputText.count && str.prefix(1).caseInsensitiveCompare(inputText.prefix(1)) == .orderedSame){
                // Fill free suggestion Buttons
                for button in suggestionButton{
                    if button.title(for: .normal) == "" && !wordIsAlreadySuggest(inputText: str){
                        button.setTitle(str, for: .normal)
                        break
                    }
                }
            }
        }
        
        
    }
    
    // Change suggestion buttons after one suggestion button clicked
    func changeSuggestionButtonsForNext(nextWords: [String]){
        var count = 0
        for word in nextWords{
            suggestionButton[count].setTitle(word, for: .normal)
            count += 1
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
    
    // suggestion buttons clicked
    @IBAction func suggestedButtonClicked(_ sender: UIButton) {
        if let completeWord = sender.title(for: .normal){
            if completeWord != ""{
                let currentStr = findCurrentWord()
                makeAutocompletion(completeWord: completeWord, currentWord: currentStr)
                clearSuggestionButtons()
                let nextWords = findNextWords(currWord: completeWord)
                changeSuggestionButtonsForNext(nextWords: nextWords)
                autoCompletionStarted = true
            }
        }
        
    }
    
    // Find current writing Text
    func findCurrentWord() -> String{
        let FullStr = (textDocumentProxy.documentContextBeforeInput ?? "") + (textDocumentProxy.documentContextAfterInput ?? "")
        let currentStrArray = FullStr.components(separatedBy: " ")
        let currentStr = currentStrArray[currentStrArray.count - 1]
        return currentStr
    }
    
    // find next word after current words
    func findNextWords(currWord: String) -> [String]{
        var nextWords = [String()]
        if let index = wordsLists.firstIndex(of: currWord){
            nextWords = nextWordsList[index] as! [String]
        }
        return nextWords
    }
    
    // Make AutoCompletion
    func makeAutocompletion(completeWord :String, currentWord: String){
        if !autoCompletionStarted{
            for _ in 0...currentWord.count-1 {
                (textDocumentProxy as UIKeyInput).deleteBackward()
            }
            (textDocumentProxy as UIKeyInput).insertText(completeWord + " ")
        }else{
            (textDocumentProxy as UIKeyInput).insertText(completeWord + " ")
        }
    }

    // Parsing for Supporting Language
    func ParseWordsJson(){
        if let path = Bundle.main.path(forResource: "name_prediction", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let JSONResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,AnyObject>
                
                if let data = JSONResult["data"] as? NSArray{
                    if let allWords = data.value(forKey: "name") as? NSArray{
                        if let allNextWords = data.value(forKey: "next_names") as? [NSArray]{
                            self.wordsLists = allWords as! [String]
                            self.nextWordsList = allNextWords
                        }
                    }
                }
                
            } catch {
                print("error parsing json")
            }
        }
    }
    
    // If long press occured on deleted button
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            timer = Timer.scheduledTimer(timeInterval: 0.06, target: self, selector: #selector(backSpacePressed(button:)), userInfo: nil, repeats: true)
        } else if gesture.state == .ended || gesture.state == .cancelled {
            timer?.invalidate()
            timer = nil
        }
    }
   
}
