//
//  ContentView.swift
//  Word Scrabble
//
//  Created by David OH on 10/03/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMsg = ""
    @State private var showError = false
    
    
    //correct words logic
    func addWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 2 else {
            wordError(title: "Word can't be less than 3", message: "find a longer word")
            return
        }
        guard isEqual(word: answer) else {
            wordError(title: "Word can't be equals to the root word", message: "don't try to play smart😎")
            return
        }
        guard isOriginal(word: answer)  else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isReal(word: answer)  else {
            wordError(title: "Word not recognised", message: "You can't just make them up, you know! ")
            return
        }
        guard isPossible(word: answer)  else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    //logic conditions
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    func isEqual(word: String) -> Bool{
        return word.lowercased() != rootWord
    }
    func isPossible(word : String) -> Bool{
        var tempWord = rootWord
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else{
                return false
            }
        }
        
        return true
    }
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misSpelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misSpelledRange.location == NSNotFound
    }
    
    //helper for error alert
    func wordError(title: String, message: String, showerror: Bool = true){
        errorTitle = title
        errorMsg = message
        self.showError = showerror
    }
    
    
    //read the json
    func startGame(){
        self.usedWords.removeAll()
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                let allwords = startWords.components(separatedBy: "\n")
                rootWord = allwords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Couldn't load words from bundle.")
    }

    
    
    //view
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter Your Word", text: $newWord)
                        .autocapitalization(.none)
                }
                Section{
                    ForEach(usedWords, id : \.self ){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit {
                addWord()
            }
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showError){
                Button("OK"){}
            }message: {
                Text(errorMsg)
            }
               .toolbar{
                                Button("Restart", action: startGame)
                            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
