//
//  GameViewModel.swift
//  FallingWords
//
//  Created by Hossein Asadi on 3/24/22.
//

import Foundation

protocol GameViewModelDelegate: AnyObject {
    func updateView(_ viewModel: GameViewModelProtocol)
    func gameEnded(_ viewModel: GameViewModelProtocol)
    func showNextWord(_ viewModel: GameViewModelProtocol)
}

protocol GameViewModelProtocol {
    var words: [Word] { get }
    var selectedWord: String { get }
    var delegate: GameViewModelDelegate? { get set }
    var remainingLives: Int { get }
    var wrongAnswers: Int { get }
    var correctAnswers: Int { get }
    var notAnsweredCount: Int { get }
    func startGame()
    func feedNextWord() -> String
    func decidedToWrong(_ text: String)
    func decidedToCorrect(_ text: String)
    func notAnswered()
    func reset()
}

final class GameViewModel: GameViewModelProtocol {
    var allWords: [Word] = [] {
        didSet {
            words = allWords
            currentWord = nil
        }
    }
    var words: [Word] = []
    var currentWord: Word?

    var selectedWord: String {
        return currentWord?.english ?? ""
    }

    var gameStartsOnResult = false
    private let wordsRepo: WordsRepo
    weak var delegate: GameViewModelDelegate?

    var remainingLives: Int = 5 {
        didSet {
            if remainingLives < 1 {
                delegate?.gameEnded(self)
            }
        }
    }
    var wrongAnswers = 0
    var correctAnswers = 0
    var notAnsweredCount = 0

    var shouldShowNextWord: Bool {
        return remainingLives >= 1
    }
    
    init(wordsRepo: WordsRepo) {
        self.wordsRepo = wordsRepo
        fetchWords()
    }

    func startGame() {
        if !words.isEmpty {
            delegate?.updateView(self)
            delegate?.showNextWord(self)
        }
        gameStartsOnResult = words.isEmpty
    }

    func fetchWords() {
        wordsRepo.fetchWords { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let words):
                self.allWords = words
                self.setCurrentWord()
                if self.gameStartsOnResult {
                    self.delegate?.updateView(self)
                    self.delegate?.showNextWord(self)
                }
            case .failure:
                self.allWords = []
            }
        }
    }

    func setCurrentWord() {
        let randomIndex = Int.random(in: 0..<words.count)
        currentWord = words[randomIndex]
        words.remove(at: randomIndex)
    }

    func feedNextWord() -> String {
        let sendAnswer = Int.random(in: 0..<5)
        if sendAnswer == 2 {
            return currentWord?.spanish ?? ""
        }
        let randomIndex = Int.random(in: 0..<words.count)
        return words[randomIndex].spanish
    }

    func removeWord(_ word: String) {
        if let index = words.firstIndex(where: { $0.spanish == word }),
           index < words.count {
            words.remove(at: index)
        }
    }

    func decidedToWrong(_ text: String) {
        removeWord(text)
        if currentWord?.spanish == text {
            remainingLives -= 1
            wrongAnswers += 1
            setCurrentWord()
            delegate?.updateView(self)
        }
        if shouldShowNextWord {
            delegate?.showNextWord(self)
        }
    }

    func decidedToCorrect(_ text: String) {
        removeWord(text)
        if currentWord?.spanish == text {
            correctAnswers += 1
            setCurrentWord()
        } else {
            remainingLives -= 1
            wrongAnswers += 1
        }
        delegate?.updateView(self)
        if shouldShowNextWord {
            delegate?.showNextWord(self)
        }
    }

    func notAnswered() {
        notAnsweredCount += 1
        remainingLives -= 1
        delegate?.updateView(self)
        if shouldShowNextWord {
            delegate?.showNextWord(self)
        }
    }

    func reset() {
        remainingLives = 5
        notAnsweredCount = 0
        correctAnswers = 0
        wrongAnswers = 0
        words = allWords
        setCurrentWord()
        delegate?.updateView(self)
        delegate?.showNextWord(self)
    }
}
