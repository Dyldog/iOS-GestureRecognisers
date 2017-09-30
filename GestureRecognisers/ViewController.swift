//
//  ViewController.swift
//  GestureRecognisers
//
//  Created by Dylan Elliott on 30/9/17.
//  Copyright © 2017 Dylan Elliott. All rights reserved.
//

import UIKit
import QuartzCore


class TransformableView : UIView, UIGestureRecognizerDelegate {
    lazy var tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
    lazy var panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(handleMovementGesture(sender:)))
    lazy var pinchGestureRecogniser = UIPinchGestureRecognizer(target: self, action: #selector(handleMovementGesture(sender:)))
    lazy var rotationGestureRecogniser = UIRotationGestureRecognizer(target: self, action: #selector(handleMovementGesture(sender:)))
    
    var originalTransform = CGAffineTransform.identity
    
    
    
    init() {
        super.init(frame : CGRect.zero)
        
        let gestureRecognisers : [UIGestureRecognizer] = [
            tapGestureRecogniser,
            panGestureRecogniser,
            pinchGestureRecogniser,
            rotationGestureRecogniser
        ]
        
        gestureRecognisers.forEach({
            $0.delegate = self
            self.addGestureRecognizer($0)
        })
    }
    
    override convenience init(frame : CGRect) {
        self.init()
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTap(sender : UITapGestureRecognizer) {
        let tapPos = sender.location(in: self)
        print("Tapped: \(tapPos.x), \(tapPos.y)")
        
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: .allowUserInteraction, animations: {
            let originalBGColor = self.backgroundColor
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
                self.backgroundColor = .blue
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.backgroundColor = originalBGColor
            })
        }, completion: nil)
    }
    
    func moveGestureViewToOriginalPosition(animated : Bool) {
        let movementBlock = {
            self.transform = self.originalTransform
        }
        
        if animated {
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: .allowUserInteraction, animations: {
                movementBlock()
            }, completion: nil)
        } else {
            movementBlock()
        }
    }
    
    func pinchAndRotateTransform(startingTransform : CGAffineTransform, scale : CGFloat, rotation: CGFloat, translation: CGPoint) -> CGAffineTransform {
        
        return startingTransform.translatedBy(x: translation.x, y: translation.y).scaledBy(x: scale, y: scale).rotated(by: rotation)
    }
    
    func updateGestureViewTransform() {
        self.transform = self.pinchAndRotateTransform(startingTransform: self.originalTransform, scale: self.pinchGestureRecogniser.scale, rotation: self.rotationGestureRecogniser.rotation, translation: self.panGestureRecogniser.translation(in: self.superview!))
    }
    
    @objc func handleMovementGesture(sender : UIGestureRecognizer) {
        switch sender.state {
        case .ended:
            self.moveGestureViewToOriginalPosition(animated: true)
        default:
            self.updateGestureViewTransform()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let allowedTypes = [UIPinchGestureRecognizer.self, UIRotationGestureRecognizer.self, UIPanGestureRecognizer.self]
        
        return allowedTypes.contains(where: { $0 == Mirror(reflecting: gestureRecognizer).subjectType })
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let gestureView : TransformableView = {
        let view = TransformableView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        view.backgroundColor = .green
        return view
    }()
    
    let viewSpacing : CGFloat = 20
    
    let stackView : UIStackView!
    
    required init?(coder aDecoder: NSCoder) {
        var gestureViews : [TransformableView] = [UIColor.green, UIColor.yellow, UIColor.red].map({
            let gestureView = TransformableView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            gestureView.backgroundColor = $0
            return gestureView
        })
        
        stackView = UIStackView(arrangedSubviews: gestureViews)
        stackView.axis = .vertical
        stackView.spacing = viewSpacing
        stackView.distribution = .fillEqually
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.view.addSubview(stackView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stackView.frame = self.view.frame.insetBy(dx: viewSpacing, dy: viewSpacing)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

