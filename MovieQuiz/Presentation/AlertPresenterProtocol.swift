//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Kislov Vadim on 10.12.2025.
//

import UIKit

protocol AlertPresenterProtocol {
    func show(in viewControllerToPresent: UIViewController, model: AlertModel) -> Void
}
