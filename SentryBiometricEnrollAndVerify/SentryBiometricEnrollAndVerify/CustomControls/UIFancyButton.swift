//
//  UIFancyButton.swift
//  SentryCardEnroll
//
//  Copyright © 2024 Sentry Enterprises
//

import UIKit

/**
 A drop in replacement for `UIButton` that exposes some extra properties and includes a gradient background.
 */
public class UIFancyButton: UIButton {
    // MARK: - Private Properties
    private var gradientLayer: CAGradientLayer             { layer as! CAGradientLayer }
    
    
    // MARK: - Public Properties
    
    /// The view’s Core Animation layer to use for rendering.
    public override class var layerClass: AnyClass         { CAGradientLayer.self }
   
    /// The starting color for the gradient background.
    @IBInspectable public var startColor: UIColor = .white { didSet { updateColors() } }
    
    /// The ending color for the gradient background.
    @IBInspectable public var endColor: UIColor = .red     { didSet { updateColors() } }
    
    /// The start point for the gradient background.
    @IBInspectable public var startPoint: CGPoint {
        get { gradientLayer.startPoint }
        set { gradientLayer.startPoint = newValue }
    }
    
    /// The endpoint for the gradient background.
    @IBInspectable public var endPoint: CGPoint {
        get { gradientLayer.endPoint }
        set { gradientLayer.endPoint = newValue }
    }
    
    /// The corner radius for the button.
    @IBInspectable public var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    /// The border width.
    @IBInspectable public var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    /// The border color.
    @IBInspectable public var borderColor: UIColor? {
        get { layer.borderColor.flatMap { UIColor(cgColor: $0) } }
        set { layer.borderColor = newValue?.cgColor }
    }
    
    
    // MARK: - Constructors
    
    /**
     Creates a new button with the specified frame.
     
     - Parameters:
        - frame: The frame rectangle for the view, measured in points.
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        updateColors()
    }
    
    /**
     Creates a new button with data in an unarchiver.
     
     - Parameters:
        - coder: An unarchiver object.
     */
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateColors()
    }
    
    
    // MARK: - Overrides
    
    /// A Boolean value indicating whether the control draws a highlight.
    public override var isHighlighted: Bool { didSet { updateColors() } }
    
    
    // MARK: - Private Methods
    
    /// Updates the gradient background.
    private func updateColors() {
        if isHighlighted {
            gradientLayer.colors = [endColor.cgColor, startColor.cgColor]
        } else {
            gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        }
    }
}

