import Foundation
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    private weak var viewController: UIViewController?
    private let restartAction: (() -> Void)?
    
    init(viewController: UIViewController, restartAction: (() -> Void)? = nil) {
        self.viewController = viewController
        self.restartAction = restartAction
    }
    
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { [weak self] _ in
            self?.restartAction?()
        }
        
        alert.addAction(action)
        
        self.viewController?.present(alert, animated: true, completion: nil)
    }
}
