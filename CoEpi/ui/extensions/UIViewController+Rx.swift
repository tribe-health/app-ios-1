import Foundation
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIViewController, Base: ErrorDisplayer {
    var notification: Binder<UINotification> {
        return Binder<UINotification>(base) { viewController, notification in
            viewController.showNotification(notification: notification)
        }
    }
}
