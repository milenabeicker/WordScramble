//
//  ContentView.swift
//  WordScramble
//
//  Created by Milena Beicker on 15/07/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter sua palavra", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section("Score: \(score)"){
                    ForEach(usedWords, id: \.self) {word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("New Game", action: startGame)
            }
        }
    }
    
    func addNewWord() {
        score = 0
        newWord = ""
        usedWords.removeAll()
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 3 else {return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Palavra já usada", message: "Seja mais original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Palavra não é possível", message: "Você não pode soletrar essa palavra de '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Palavra não reconhecida", message: "Você não pode simplesmente inventá-los, você sabe!")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
            newWord = ""
            score += answer.count
    }
    
    func startGame() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordURL) {
                let allWord = startWords.components(separatedBy: "\n")
                rootWord = allWord.randomElement() ?? "silkworn"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

#Preview {
    ContentView()
}
