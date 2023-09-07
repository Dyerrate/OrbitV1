//
//  BubbleButton.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 5/8/23.
//

import Foundation
import UIKit

class BubbleButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = UIColor.gray
        self.layer.cornerRadius = 25
    }
}
