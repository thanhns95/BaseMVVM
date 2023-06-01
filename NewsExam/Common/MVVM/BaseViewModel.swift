//
//  BaseViewModel.swift
//  Common
//
//  Created by it on 28/10/2022.
//

import Foundation

 protocol BaseViewModel {
    associatedtype Input
    associatedtype Output
    var input: Input { get set }
    var output: Output { get set }
}
