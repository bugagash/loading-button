//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport

extension UIView {
    func blink() {
        self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        
        UIView.animate(withDuration: 0.09, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (success) in
            UIView.animate(withDuration: 0.09, delay: 0, options: .curveEaseOut, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image!.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

class EGLoaderLayer: CAShapeLayer {
    
    var loaderColor = UIColor.white {
        didSet {
            strokeColor = loaderColor.cgColor
        }
    }
    
    init(frame:CGRect) {
        super.init()
        let radius:CGFloat = (frame.height / 2) * 0.5
        self.frame = CGRect(x: 0, y: 0, width: frame.height, height: frame.height)
        
        let center = CGPoint(x: frame.height / 2, y: bounds.midY)
        let startAngle = 0 - Double.pi
        let endAngle = Double.pi * 2 - Double.pi/2
        let clockwise: Bool = true
        self.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise).cgPath
        
        self.fillColor = nil
        self.strokeColor = loaderColor.cgColor
        self.lineWidth = 2
        
        self.strokeEnd = 0.4
        self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animation() {
        self.isHidden = false
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0
        rotate.toValue = Double.pi * 2
        rotate.duration = 1
        rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        rotate.repeatCount = HUGE
        rotate.fillMode = kCAFillModeForwards
        rotate.isRemovedOnCompletion = false
        self.add(rotate, forKey: rotate.keyPath)
        
    }
    
    func stopAnimation() {
        self.isHidden = true
        self.removeAllAnimations()
    }
}

class EGButton: UIButton {
    
    @IBInspectable open var enabledColor: UIColor = UIColor(red:0.40, green:0.80, blue:0.28, alpha:1.0)  {
        didSet {
            if (self.isEnabled) {
                self.backgroundColor = enabledColor
            }
        }
    }
    
    @IBInspectable open var disabledColor: UIColor = .darkGray  {
        didSet {
            if (!self.isEnabled) {
                self.backgroundColor = disabledColor
            }
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    enum LoadingState {
        case normal
        case loading
    }
    
    private var loadingState: LoadingState = .normal
    
    open var isLoading: Bool {
        return loadingState == .loading
    }
    
    override var isEnabled: Bool {
        didSet {
            updateButton()
            if (isEnabled) {
                self.blink()
            }
        }
    }
    
    private lazy var loader: EGLoaderLayer = {
        let loader = EGLoaderLayer(frame: self.frame)
        loader.loaderColor = self.titleColor(for: .normal)!
        self.layer.addSublayer(loader)
        return loader
    }()
    
    private let sizeDuraction = CFTimeInterval(0.1)
    private let sizeTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        drawApperians()
        updateButton()
    }
    
    private func drawApperians() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 1
    }
    
    private func updateButton() {
        backgroundColor = isEnabled ? enabledColor : disabledColor
    }
    
    open func startLoading() {
        if (loadingState != .loading) {
            applyLoadingState()
        }
    }
    
    open func stopLoading() {
        if (loadingState != .normal) {
            applyNormalState()
        }
    }
    
    private func applyNormalState() {
        self.intoOriginalSize()
        
        UIView.animate(withDuration: 0.1, delay: sizeDuraction / 2, options: [], animations: {
            self.layer.cornerRadius = self.cornerRadius
        }, completion: nil)
        
        UIView.animate(withDuration: 0.1, delay: sizeDuraction, options: [], animations: {
            self.titleLabel?.alpha = 1
            self.loader.stopAnimation()
        }) { (success) in
            self.loadingState = .normal
            self.isUserInteractionEnabled = true
        }
    }
    
    private func intoOriginalSize() {
        let sizeAnim = CABasicAnimation(keyPath: "bounds.size.width")
        sizeAnim.fromValue = (self.bounds.height)
        sizeAnim.toValue = (self.bounds.width)
        sizeAnim.duration = sizeDuraction
        sizeAnim.timingFunction = sizeTimingFunction
        sizeAnim.fillMode = kCAFillModeForwards
        sizeAnim.isRemovedOnCompletion = false
        self.layer.add(sizeAnim, forKey: sizeAnim.keyPath)
    }
    
    private func applyLoadingState() {
        self.isUserInteractionEnabled = false
        
        titleLabel?.alpha = 0
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.layer.cornerRadius = self.frame.height / 2
        }, completion: { completed -> Void in
            self.intoSquare()
            
            self.loader.animation()
            
            self.loadingState = .loading
        })
    }
    
    private func intoSquare() {
        let squareAnim                   = CABasicAnimation(keyPath: "bounds.size.width")
        squareAnim.fromValue             = frame.width
        squareAnim.toValue               = frame.height
        squareAnim.duration              = sizeDuraction
        squareAnim.timingFunction        = sizeTimingFunction
        squareAnim.fillMode              = kCAFillModeForwards
        squareAnim.isRemovedOnCompletion = false
        layer.add(squareAnim, forKey: squareAnim.keyPath)
    }
    
}

class VC:UIViewController {
    
    let b = EGButton(type: .custom)
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        b.frame  = CGRect(x: 10, y: 10, width: 320, height: 45)
        b.setTitle("GOOOOO", for: .normal)
        b.cornerRadius = 10
        b.addTarget(self, action: #selector(tabButton(_:)) , for: .touchUpInside)
        view.addSubview(b)
        
        
        let b2 = EGButton(frame: CGRect(x: 10, y: 70, width: 180, height: 50))
        b2.backgroundColor = .gray
        b2.setTitle("enable/disable", for: .normal)
        b2.addTarget(self, action: #selector(tabButton2(_:)) , for: .touchUpInside)
        
        view.addSubview(b2)
        
        let b3 = EGButton(frame: CGRect(x: 10, y: 130, width: 180, height: 50))
        b3.backgroundColor = .gray
        b3.setTitle("start/stop", for: .normal)
        b3.addTarget(self, action: #selector(tabButton3(_:)) , for: .touchUpInside)
        
        view.addSubview(b3)
    }
    
    @objc func tabButton(_ sender: UIButton) {
        print("tabButton \(sender.isEnabled)")
    }
    
    @objc func tabButton2(_ sender: UIButton) {
        b.isEnabled = false
        b.startLoading()
    }
    
    @objc func tabButton3(_ sender: UIButton) {
        b.stopLoading()
        b.isEnabled = true
    }
}


PlaygroundPage.current.liveView = VC()

