//
//  GameViewController.swift
//  FallingWords
//
//  Created by Hossein Asadi on 3/24/22.
//

import UIKit

class GameViewController: UIViewController {
    @IBOutlet weak var currentWord: UILabel!

    @IBOutlet weak var fallingView: UIView!

    @IBOutlet weak var guessedWrong: UILabel!
    @IBOutlet weak var guessedCorrect: UILabel!
    @IBOutlet weak var notAnswered: UILabel!
    @IBOutlet weak var remainingLives: UILabel!

    @IBOutlet weak var correctBtn: UIButton!
    @IBOutlet weak var wrongBtn: UIButton!

    private var fallingLabel: UILabel = UILabel()

    var viewModel: GameViewModelProtocol!

    @IBAction func correct(_ sender: Any) {
        viewModel.decidedToCorrect(fallingLabel.text ?? "")
    }

    @IBAction func wrong(_ sender: Any) {
        viewModel.decidedToWrong(fallingLabel.text ?? "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: inject viewModel in production
        viewModel = GameViewModel(wordsRepo: LocalWordsRepo())
        viewModel.delegate = self
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startGame()
    }

    func setupUI() {
        correctBtn.setupPrimary(color: .systemGreen)
        wrongBtn.setupSecondary(color: .systemRed)
        fallingView.clipsToBounds = true
        setupFallingLabel()
        fallingLabel.text = viewModel.feedNextWord()
        updateView()
    }

    func setupFallingLabel() {
        fallingLabel.layer.removeAllAnimations()
        fallingLabel.removeFromSuperview()
        fallingLabel = UILabel()
        fallingLabel.textAlignment = .center
        fallingView.addSubview(fallingLabel)
        fallingLabel.frame = CGRect(x: view.frame.midX - 100, y: -25, width: 200, height: 25)
    }

    func updateView() {
        currentWord.text = viewModel.selectedWord
        guessedCorrect.text = "Correct: \(viewModel.correctAnswers)"
        guessedWrong.text = "Wrong: \(viewModel.wrongAnswers)"
        notAnswered.text = "No Answers: \(viewModel.notAnsweredCount)"
        remainingLives.text = "Remaining Lives: \(viewModel.remainingLives)"
    }

    func animateLabel() {
        UIView.animate(withDuration: 5, animations: {
            self.fallingLabel.frame.origin.y = self.fallingView.frame.maxY
        }, completion: { completed in
            if completed {
                self.viewModel.notAnswered()
            }
        })
    }
}
extension GameViewController: GameViewModelDelegate {
    func showNextWord(_ viewModel: GameViewModelProtocol) {
        setupFallingLabel()
        fallingLabel.text = viewModel.feedNextWord()
        animateLabel()
    }

    func updateView(_ viewModel: GameViewModelProtocol) {
        updateView()
    }

    func gameEnded(_ viewModel: GameViewModelProtocol) {
        fallingLabel.removeFromSuperview()
        fallingView.layer.removeAllAnimations()

        showAlert(title: "Game Over", message: "Your Score: \(viewModel.correctAnswers)\nWanna play again?") {
            viewModel.reset()
        }
    }
}
extension GameViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            completion?()
        }))
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }
}
