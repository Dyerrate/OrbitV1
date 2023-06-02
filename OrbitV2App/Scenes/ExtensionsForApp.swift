//
//  ExtensionsForApp.swift
//  OrbitV2App
//
//  Created by Samuel Dyer on 5/31/23.
//

import Foundation
import UIKit

extension CGPath {
    func rotatedPath(by angle: CGFloat) -> CGPath {
        var transform = CGAffineTransform(rotationAngle: angle)
        return copy(using: &transform) ?? self
    }
}
