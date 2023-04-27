import Foundation
import UIKit

class ResultAlertPresenter: AlertProtocol {
    private let viewController: UIViewController
    private let restartAction: (() -> Void)?
    
    init(viewController: UIViewController, restartAction: (() -> Void)? = nil) {
        self.viewController = viewController
        self.restartAction = restartAction
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            self?.restartAction?()
        }
        
        alert.addAction(action)
        
        self.viewController.present(alert, animated: true, completion: nil)
    }
}
