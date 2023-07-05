//
//  LoginAnimationController.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 6/11/23.
//

import Foundation
import UIKit

class LoginAnimationController {
    private weak var viewController: LoginViewController?

    init(viewController: LoginViewController) {
        self.viewController = viewController
    }

    // Animation-related methods will be added here.
    
    func animateImagesSlideUp() {
        guard let viewController = viewController else { return }

        let homePlanetImageView = viewController.view.viewWithTag(100) as! UIImageView
        let loginBottomImageView = viewController.view.viewWithTag(101) as! UIImageView

        // Set initial positions for the images
        homePlanetImageView.transform = CGAffineTransform(translationX: 0, y: viewController.view.bounds.height)
        loginBottomImageView.transform = CGAffineTransform(translationX: 0, y: viewController.view.bounds.height)

        // Animate the images sliding up
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut) {
            homePlanetImageView.transform = .identity
            loginBottomImageView.transform = .identity
        }
    }
}
