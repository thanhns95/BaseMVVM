//
//  ViewControllerExtensions.swift
//  Common
//
//  Created by it on 28/10/2022.
//

import UIKit

extension UIViewController {
    func showAlert(message: String, title: String = "Alert", confirmTitle: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: confirmTitle, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
