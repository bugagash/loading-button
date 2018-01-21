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

class CHFButton: UIButton {
    
    @IBInspectable
    open var enabledColor: UIColor = UIColor(red:0.12, green:0.69, blue:0.11, alpha:1.0)
    
    @IBInspectable
    open var disabledColor: UIColor = .darkGray
    
    @IBInspectable
    open var loaderColor: UIColor = .darkGray
    
    @IBInspectable
    open var accessWhenDisabled: Bool = false
    
    open var isLoading: Bool {
        return loadingState == .loading
    }
    
    enum LoadingState {
        case normal
        case loading
    }
    
    private var loadingState: LoadingState = .normal {
        didSet {
            updateButton(forLoading: loadingState)
        }
    }
    
    private let activitiIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    private var _enabled: Bool = true {
        didSet {
            updateButton()
        }
    }
    dynamic override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            _enabled = newValue
            super.isEnabled = accessWhenDisabled || newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    private func commonInit() {
        setupActivitiIndicator()
        drawApperians()
        
        updateButton()
    }
    
    private func drawApperians() {
        layer.cornerRadius = 10
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 1
    }
    
    private func setupActivitiIndicator() {
        activitiIndicator.frame = CGRect(x: 0, y: 0, width: frame.height, height: frame.height)
        activitiIndicator.center = center
        activitiIndicator.hidesWhenStopped = true
        activitiIndicator.color = loaderColor
        
        addSubview(activitiIndicator)
    }
    
    private func updateButton(forLoading state: LoadingState) {
        if (state == .loading) {
            let circle = transformToCircle()
            layer.add(circle, forKey: "circle_animation")
            layer.cornerRadius = bounds.width / 2
            
        }
    }
    
    private func transformToCircle() -> CABasicAnimation {
        let a = CABasicAnimation(keyPath: "cornerRadius")
        
        a.duration = 0.5
        
        a.fromValue = 10
        a.toValue = bounds.width / 2
        
        a.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return a
    }
    
    private func updateButton() {
        backgroundColor = _enabled ? enabledColor : disabledColor
        
        if (_enabled) {
            self.blink()
        }
    }
    
    open func startLoading() {
        if (loadingState != .loading) {
            loadingState = .loading
        }
    }
    
    open func stopLoading() {
        if (loadingState != .normal) {
            loadingState = .normal
        }
    }
}

class VC:UIViewController {
    
    let b = CHFButton(frame: CGRect(x: 10, y: 10, width: 180, height: 50))
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        
        b.setTitle("GOOOOO", for: .normal)
        b.addTarget(self, action: #selector(tabButton(_:)) , for: .touchUpInside)
        view.addSubview(b)
        
        
        let b2 = CHFButton(frame: CGRect(x: 10, y: 70, width: 180, height: 50))
        b2.backgroundColor = .gray
        b2.setTitle("enable/disable", for: .normal)
        b2.addTarget(self, action: #selector(tabButton2(_:)) , for: .touchUpInside)
        
        view.addSubview(b2)
        
        let b3 = CHFButton(frame: CGRect(x: 10, y: 130, width: 180, height: 50))
        b3.backgroundColor = .gray
        b3.setTitle("start/stop", for: .normal)
        b3.addTarget(self, action: #selector(tabButton3(_:)) , for: .touchUpInside)
        
        view.addSubview(b3)
    }
    
    @objc func tabButton(_ sender: UIButton) {
        print("tabButton \(sender.isEnabled)")
    }
    
    @objc func tabButton2(_ sender: UIButton) {
        b.isEnabled = !b.isEnabled
    }
    
    @objc func tabButton3(_ sender: UIButton) {
        if (b.isLoading) {
            b.stopLoading()
        } else {
            b.startLoading()
        }
    }
}


PlaygroundPage.current.liveView = VC()

