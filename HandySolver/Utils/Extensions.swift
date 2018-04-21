//
//  Extensions.swift
//  UtilityComponent
//
//  Created by SHUBHAM GARG on 24/03/2018.
//  Copyright © 2018 SHUBHAM GARG. All rights reserved.
//

import UIKit


/// Extends UIView with a shortcut method.
/// - author: SHUBHAM GARG
extension UIView {
    // MARK: - Effective wayMake view Circular if view is not resizable
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor?, borderWidth: CGFloat?) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        self.layer.mask = mask
        
        if borderWidth != nil {
            addBorder(mask, borderWidth: borderWidth!, borderColor: borderColor!)
        }
    }
    
    private func addBorder(_ mask: CAShapeLayer, borderWidth: CGFloat, borderColor: UIColor) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
    
    // MARK: - Make view Circular when view is resizable
    func setCirculerViewWithBorder (radis:Float, borderColor:UIColor,borderWidth:Float) {
        layer.cornerRadius = CGFloat(radis)
        layer.borderWidth = CGFloat(borderWidth)
        layer.borderColor = borderColor.cgColor
    }
    
}
