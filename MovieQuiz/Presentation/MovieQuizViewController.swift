import Foundation
import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    private var statisticService: StatisticService = StatisticServiceImplementation()
    private var alertPresenter: ResultAlertPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        imageView.layer.cornerRadius = 20 //скругление рамок постера при ответе
        imageView.layer.masksToBounds = true
        
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "inception.json"
        documentsURL.appendPathComponent(fileName)
        
        if alertPresenter == nil {
            alertPresenter = ResultAlertPresenter(viewController: self, restartAction: restartQuiz)
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let bestGame = statisticService.bestGame //лучшая игра
            let date = bestGame.date.dateTimeString //форматирование даты игры
            let gamesCount = statisticService.gamesCount //количество сыгранных квизов
            let formattedAccuracy = (String(format: "%.2f", statisticService.totalAccuracy)) //средняя точность

            let message = "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/10 (\(date))\nСредняя точность: \(formattedAccuracy)%"

            let viewModel = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: message,
            buttonText: "Сыграть еще раз")
            alertPresenter?.show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
            }
}
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
}
