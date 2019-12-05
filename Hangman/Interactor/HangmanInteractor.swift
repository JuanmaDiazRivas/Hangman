//
//  HangmanInteractor.swift
//  Hangman
//
//  Created by Plexus on 05/12/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

public protocol HangmanInteractor{
    func initalizeGame()
    func presenterDidLoad(hangmanInteractorDelegate: HangmanInteractorDelegate?)
}

public protocol HangmanInteractorDelegate: class{
    func newMainWord(text:String)
    func changeLifeBarStatus(_ progressCalculated: Float)
    func attemptFailed(currentAttempts: Float)
}

class HangmanInteractorImpl: HangmanInteractor{
    
    //Aux variables
    var triesLeft = Float()
    var originalWord = [Character]()
    var lifeProgress = Float()
    var currentWord: String = ""
    var allWords = [String]()
    
    //Constants
    private let errorsOnInitAllowed: Float = 7
    
    //Delegate
    private weak var delegate: HangmanInteractorDelegate?
    
    func presenterDidLoad(hangmanInteractorDelegate: HangmanInteractorDelegate?){
        self.delegate = hangmanInteractorDelegate
        
        prepareWordsModel()
    }
    
    
    func initalizeGame() {
        triesLeft = errorsOnInitAllowed
        
        //load the word from dicitionary
        let wordFromDictionary = shuffleDictionaryWord()
        
        var firstWord = String(repeating: "_", count: originalWord.count)
        
        originalWord = Array(wordFromDictionary)
        
        //take 3 random positions and reveal all the letters in word for this letter
        for _ in 0..<3{
            let random = Int.random(in: 0..<originalWord.count)
            let letterToPlay = Array(originalWord)[random]
            initWord(letterUsed: letterToPlay, firstWord: &firstWord)
        }
        
        currentWord = firstWord
        
        delegate?.newMainWord(text: firstWord)
    }
    

    private func initWord(letterUsed : Character, firstWord: inout String){
        
        var auxWordArray = Array(firstWord)
        
        originalWord.enumerated().forEach { index, character in
            if character.uppercased() == letterUsed.uppercased() {
                auxWordArray[index] = character
            }
        }

        firstWord = String(auxWordArray)
    }
    
    private func modifyWord(letterUsed : Character,currenWord: String) -> Bool?{
        
        var auxWordArray = Array(currenWord)
        var wordModified = false
        
        originalWord.enumerated().forEach { index, character in
            if character.uppercased() == letterUsed.uppercased() {
                wordModified = true
                auxWordArray[index] = character
            }
        }
        
        if wordModified {
            self.delegate?.newMainWord(text: String(auxWordArray))
        }
        
        return wordModified
    }
    
    private func shuffleDictionaryWord() -> String {
        var auxWord = String()
        allWords.shuffle()
        allWords.forEach { (valor) in
            if valor.count <= 8{
                auxWord = valor
            }
        }
        return auxWord
    }
    
    private func formatMessage(message: String,messageType : MessageType) -> NSMutableAttributedString{
        
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message + String(presenter.originalWord).uppercased(), attributes: [NSAttributedString.Key : Any]())
        messageMutableString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: NSRange(location:message.count,length: presenter.originalWord.count))
        
        let color = (messageType == MessageType.Sucess) ? sucessColor : errorColor
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location:message.count,length:presenter.originalWord.count))
        
        return messageMutableString
        
    }
    
    private func changeGameStatus(containsHealthBar: Bool){
        triesLeft -= 1
        
        delegate?.attemptFailed(currentAttempts: triesLeft)
        
        if containsHealthBar{
            let decrease = Float((100/errorsOnInitAllowed)/100)
            
            let progressCalculated = lifeProgress - decrease
            
            updateProgress(progessCalculated: progressCalculated)
        }
        
        if triesLeft.isEqual(to: 0){
            endGame()
        }
    }
    
    private func updateProgress(progessCalculated: Float){
        delegate?.changeLifeBarStatus(progessCalculated)
    }

    //repository
    private func prepareWordsModel() {
        dictionaryService.getDictionary().forEach { (wordFromDictionary) in
            allWords.append(wordFromDictionary.word)
        }
    }
    
}
