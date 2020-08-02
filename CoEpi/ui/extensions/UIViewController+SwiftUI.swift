import Foundation
import SwiftUI
import UIKit

extension UIViewController {
    func setRootSwiftUIView<T: View>(view: T) {
        let host = UIHostingController(rootView: view)
        guard let hostView = host.view else { return }
        hostView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(hostView)
        hostView.pinAllEdgesToParent()
    }
}
