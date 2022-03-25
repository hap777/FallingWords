//
//  GameViewModelTest.swift
//  FallingWordsTests
//
//  Created by Hossein Asadi on 3/25/22.
//

import XCTest
@testable import FallingWords

class GameViewModelTests: XCTestCase {
    var sut: GameViewModel!
    var delegate: ViewModelDelegateSpy?

    static let words = [
        Word(english: "primary school", spanish: "escuela primaria"),
        Word(english: "teacher", spanish: "profesor / profesora"),
        Word(english: "pupil", spanish: "alumno / alumna"),
        Word(english: "holidays", spanish: "vacaciones"),
        Word(english: "class", spanish: "curso"),
        Word(english: "bell", spanish: "timbre")
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = GameViewModel(wordsRepo: WordsRepoSpy())
        delegate = ViewModelDelegateSpy()
        sut.delegate = delegate
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        delegate = nil
    }

    func testSetAllWords() {
        sut.allWords = GameViewModelTests.words
        XCTAssertEqual(sut.words, sut.allWords)
        XCTAssertNil(sut.currentWord)
    }

    func testSelectedWord() {
        sut.currentWord = Word(english: "class", spanish: "curso")
        XCTAssertEqual(sut.selectedWord, sut.currentWord?.english)
    }
    
    func testRemainingLives_MoreOrEqualThanOne() {
        sut.remainingLives = 1
        XCTAssertEqual(delegate?.gameEnded, false)
    }

    func testRemainingLives_LessThanOne() {
        sut.remainingLives = 0
        XCTAssertEqual(delegate?.gameEnded, true)
    }

    func testShouldShowNextWord_returnTrue() {
        sut.remainingLives = 1
        XCTAssertTrue(sut.shouldShowNextWord)
    }

    func testShouldShowNextWord_returnFalse() {
        sut.remainingLives = 0
        XCTAssertFalse(sut.shouldShowNextWord)
    }

    func testStartGame_wordsIsEmpty() {
        sut.words = []
        sut.startGame()
        XCTAssertFalse(delegate?.viewUpdated ?? false)
        XCTAssertFalse(delegate?.showedNextWord ?? false)
        XCTAssertTrue(sut.gameStartsOnResult)
    }

    func testStartGame_wordsIsNotEmpty() {
        sut.allWords = GameViewModelTests.words
        sut.startGame()
        XCTAssertTrue(delegate?.viewUpdated ?? false)
        XCTAssertTrue(delegate?.showedNextWord ?? false)
        XCTAssertFalse(sut.gameStartsOnResult)
    }

    func testFetchWords_NotStartOnResult() {
        sut.gameStartsOnResult = false
        sut.fetchWords()
        XCTAssertEqual(sut.allWords.count, 6)
        XCTAssertFalse(delegate?.showedNextWord ?? false)
        XCTAssertFalse(delegate?.viewUpdated ?? false)
    }

    func testFetchWords_StartOnResult() {
        sut.gameStartsOnResult = true
        sut.fetchWords()
        XCTAssertEqual(sut.allWords.count, 6)
        XCTAssertTrue(delegate?.showedNextWord ?? false)
        XCTAssertTrue(delegate?.viewUpdated ?? false)
    }

    func testSetCurrentWord() {
        sut.allWords = GameViewModelTests.words
        sut.setCurrentWord()
        XCTAssertNotNil(sut.currentWord)
        XCTAssertFalse(sut.currentWord != nil ? sut.words.contains(sut.currentWord!) : true)
    }

    func testRemoveWord_removesWord() {
        let word = Word(english: "bell", spanish: "timbre")
        sut.allWords = GameViewModelTests.words
        XCTAssertTrue(sut.words.contains(word))
        sut.removeWord("timbre")
        XCTAssertFalse(sut.words.contains(word))
    }

    func testRemoveWord_doesNothing() {
        let word = Word(english: "bell", spanish: "timbre")
        sut.allWords = GameViewModelTests.words
        XCTAssertTrue(sut.words.contains(word))
        sut.removeWord("timbr")
        XCTAssertTrue(sut.words.contains(word))
    }

    func testDecidedToWrong_WrongGuess() {
        let word = Word(english: "bell", spanish: "timbre")
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 3
        sut.wrongAnswers = 1
        sut.currentWord = word
        sut.decidedToWrong(word.spanish)
        XCTAssertFalse(sut.words.contains(word))
        XCTAssertEqual(sut.remainingLives, 2)
        XCTAssertEqual(sut.wrongAnswers, 2)
        XCTAssertNotEqual(sut.currentWord, word)
        XCTAssertTrue(delegate?.viewUpdated ?? false)
    }

    func testDecidedToWrong_CorrectGuess() {
        let word = Word(english: "bell", spanish: "timbre")
        let guessedWord = Word(english: "class", spanish: "curso")
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 3
        sut.wrongAnswers = 1
        sut.currentWord = word
        sut.decidedToWrong("curso")
        XCTAssertFalse(sut.words.contains(guessedWord))
        XCTAssertEqual(sut.remainingLives, 3)
        XCTAssertEqual(sut.wrongAnswers, 1)
        XCTAssertEqual(sut.currentWord, word)
        XCTAssertFalse(delegate?.viewUpdated ?? true)

    }

    func testDecidedToWrong_ShowNextWord() {
        let word = Word(english: "bell", spanish: "timbre")
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 1
        sut.currentWord = word
        sut.decidedToWrong("curso")
        XCTAssertTrue(delegate?.showedNextWord ?? false)
    }

    func testDecidedToWrong_DontShowNextWord() {
        let word = Word(english: "bell", spanish: "timbre")
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 1
        sut.currentWord = word
        sut.decidedToWrong("timbre")
        XCTAssertFalse(delegate?.showedNextWord ?? true)
    }

    func testDecidedToCorrect_CorrectGuess() {
        let word = Word(english: "bell", spanish: "timbre")
        sut.allWords = GameViewModelTests.words
        sut.currentWord = word
        sut.remainingLives = 3
        sut.correctAnswers = 1
        sut.decidedToCorrect(word.spanish)
        XCTAssertFalse(sut.words.contains(word))
        XCTAssertEqual(sut.remainingLives, 3)
        XCTAssertEqual(sut.correctAnswers, 2)
        XCTAssertNotEqual(sut.currentWord, word)
        XCTAssertTrue(delegate?.viewUpdated ?? false)
    }

    func testDecidedToCorrect_WrongGuess() {
        let word = Word(english: "bell", spanish: "timbre")
        let guessedWord = Word(english: "class", spanish: "curso")
        sut.allWords = GameViewModelTests.words
        sut.currentWord = word
        sut.remainingLives = 3
        sut.wrongAnswers = 1
        sut.decidedToCorrect("curso")
        XCTAssertFalse(sut.words.contains(guessedWord))
        XCTAssertEqual(sut.remainingLives, 2)
        XCTAssertEqual(sut.wrongAnswers, 2)
        XCTAssertTrue(delegate?.viewUpdated ?? false)
    }

    func testDecidedToCorrect_DontShowNextWord() {
        let word = Word(english: "bell", spanish: "timbre")
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 1
        sut.currentWord = word
        sut.decidedToCorrect("curso")
        XCTAssertFalse(delegate?.showedNextWord ?? true)
    }

    func testDecidedToCorrect_ShowNextWord() {
        let word = Word(english: "bell", spanish: "timbre")
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 1
        sut.currentWord = word
        sut.decidedToCorrect("timbre")
        XCTAssertTrue(delegate?.showedNextWord ?? false)
    }

    func testNotAnswered_ShowNextWord() {
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 2
        sut.notAnsweredCount = 1
        sut.notAnswered()
        XCTAssertTrue(delegate?.viewUpdated ?? false)
        XCTAssertEqual(sut.remainingLives, 1)
        XCTAssertEqual(sut.notAnsweredCount, 2)
        XCTAssertTrue(delegate?.showedNextWord ?? false)
    }

    func testNotAnswered_DontShowNextWord() {
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 1
        sut.notAnswered()
        XCTAssertFalse(delegate?.showedNextWord ?? false)
    }

    func testReset() {
        let word = Word(english: "group", spanish: "grupo")
        sut.allWords = GameViewModelTests.words
        sut.remainingLives = 2
        sut.correctAnswers = 2
        sut.wrongAnswers = 1
        sut.notAnsweredCount = 2
        sut.currentWord = word
        sut.reset()
        XCTAssertEqual(sut.remainingLives, 5)
        XCTAssertEqual(sut.correctAnswers, 0)
        XCTAssertEqual(sut.wrongAnswers, 0)
        XCTAssertEqual(sut.notAnsweredCount, 0)
        XCTAssertNotEqual(sut.currentWord, word)
        XCTAssertTrue(delegate?.viewUpdated ?? false)
        XCTAssertTrue(delegate?.showedNextWord ?? false)
    }

    //MARK: Spy classes
    class WordsRepoSpy: WordsRepo {
        func fetchWords(completion: @escaping (Result<[Word], Error>) -> Void) {
            completion(.success(words))
        }
    }

    class ViewModelDelegateSpy: GameViewModelDelegate {
        var viewUpdated = false
        var gameEnded = false
        var showedNextWord = false

        func updateView(_ viewModel: GameViewModelProtocol) {
            viewUpdated = true
        }

        func gameEnded(_ viewModel: GameViewModelProtocol) {
            gameEnded = true
        }

        func showNextWord(_ viewModel: GameViewModelProtocol) {
            showedNextWord = true
        }
    }
}
