//
//  PostView.swift
//  Historic
//
//  Created by Kirill Varlamov on 29.03.17.
//  Copyright © 2017 Kirill Varlamov. All rights reserved.
//

import UIKit

class PostView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        
        let borderPath = UIBezierPath()
        borderPath.move(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: 5, y: 0))
        var curWidth : CGFloat = 10
        while curWidth < rect.width {
            borderPath.addArc(withCenter: CGPoint(x: curWidth, y: 0), radius: 5, startAngle: CGFloat(Double.pi), endAngle: CGFloat(Double.pi)*2, clockwise: false)
            borderPath.addLine(to: CGPoint(x: curWidth+10, y: 0))
            curWidth += 15
        }
        
        var curHeight : CGFloat = 10
        borderPath.addLine(to: CGPoint(x: rect.width, y: 5))
        while curHeight < rect.height {
            borderPath.addArc(withCenter: CGPoint(x:rect.width, y: curHeight), radius: 5, startAngle: CGFloat(Double.pi)*1.5, endAngle: CGFloat(Double.pi)/2, clockwise: false)
            borderPath.addLine(to: CGPoint(x: rect.width, y: curHeight+10))
            curHeight += 15
        }
        
        
        curWidth = rect.width - 10
        borderPath.addLine(to: CGPoint(x: rect.width - 5, y: rect.height))
        while curWidth > 0 {
            borderPath.addArc(withCenter: CGPoint(x: curWidth, y: rect.height), radius: 5, startAngle: CGFloat(Double.pi)*2, endAngle: CGFloat(Double.pi), clockwise: false)
            borderPath.addLine(to: CGPoint(x: curWidth-10, y: rect.height))
            curWidth -= 15
        }

        curHeight = rect.height - 10
        borderPath.addLine(to: CGPoint(x: 0, y: rect.height - 5))
        while curHeight > 0 {
            borderPath.addArc(withCenter: CGPoint(x:0, y: curHeight), radius: 5, startAngle: CGFloat(Double.pi)/2, endAngle: CGFloat(Double.pi)*1.5, clockwise: false)
            borderPath.addLine(to: CGPoint(x: 0, y: curHeight-10))
            curHeight -= 15
        }
        borderPath.stroke()

        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = borderPath.cgPath
        self.layer.mask = mask
        
        let pattern = UIImageView(image: UIImage(named: "OldPaper"))
        pattern.frame = CGRect(x: -10, y: -10, width: 200, height: 200)
        self.addSubview(pattern)
        
        let image = UIImageView(frame: CGRect(x: 10, y: 10, width: rect.width - 20, height: rect.height - 20))
        image.image = UIImage(named: "Railstation")
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
    
        
        self.addSubview(image)
        
        
    }

}
