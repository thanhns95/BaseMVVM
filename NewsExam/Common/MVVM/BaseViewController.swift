//
//  BaseViewController.swift
//  Common
//
//  Created by it on 28/10/2022.
//

import Foundation
import UIKit

 protocol BaseViewController: UIViewController {
    associatedtype ViewModel: BaseViewModel
    var viewModel: ViewModel! { get set }
    func setViewModel(_ viewModel: ViewModel)
    func setupViews()
    func bindViewModel()
    func initData()
}

 extension BaseViewController {
    func setViewModel(_ viewModel: ViewModel) {
        self.viewModel = viewModel
    }
}
