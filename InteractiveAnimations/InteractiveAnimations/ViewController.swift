//
//  ViewController.swift
//  InteractiveAnimations
//
//  Created by Nathan Gitter on 9/4/17.
//  Copyright © 2017 Nathan Gitter. All rights reserved.
//

import UIKit

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class ViewController: UIViewController {
    
    private let popupOffset: CGFloat = 440
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        popupView.addGestureRecognizer(tapRecognizer)
        popupView.addGestureRecognizer(panRecognizer)
    }
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private func layout() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
    }
    
    private var currentState: State = .closed
    
    private var transitionAnimator = UIViewPropertyAnimator()
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewTapped(recognizer:)))
        return recognizer
    }()
    
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        if transitionAnimator.isRunning { return }
        transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
            self.view.layoutIfNeeded()
        })
        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
        }
        transitionAnimator.startAnimation()
    }
    
    @objc private func popupViewTapped(recognizer: UITapGestureRecognizer) {
        animateTransitionIfNeeded(to: currentState.opposite, duration: 1.5)
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1.5)
            transitionAnimator.pauseAnimation()
        case .changed:
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / popupOffset
            if currentState == .open { fraction *= -1 }
            transitionAnimator.fractionComplete = fraction
        case .ended:
            transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            ()
        }
    }
    
}
