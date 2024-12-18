import UIKit
import SnapKit

final class FruitTapWheelWinController: UIViewController {
    private let mainRushFrame = FruitTapConfiiguratedImage(.winningInfoFrame)
    private let winHeader = FruitTapConfiiguratedImage(.fruitWinHeader)
    private let congratLabel = FruitLabelWithShadow()
    private let infoLabel = FruitLabelWithShadow()
    private let nextRushButton = FruitTapButton(.nextFruitRushButton)
    
    private let winnedCoins: Int
    internal var wheelExitClosure: (() -> ())?
    
    init(coins: Int) {
        self.winnedCoins = coins
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rushWheelGreetConfiguration()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rushControllerAppear()
    }
    
    @objc private func exitFromWheel() {
        rushControllerDisappear { [weak self] in
            guard let self else { return }
            self.dismiss(animated: false)
            self.wheelExitClosure?()
        }
    }
    
    private func rushWheelGreetConfiguration() {
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        self.view.alpha = 0
        
        let frameWidth = UIScreen.main.bounds.width * 0.8 * FruitRushValues.screenMult
        let frameHeight = frameWidth
        let headerHeight = frameWidth * 0.9
        
        let buttonWidth = frameWidth * 0.6
        let buttonHeight = buttonWidth * 0.3
        
        nextRushButton.addTarget(self, action: #selector(exitFromWheel), for: .touchUpInside)
        
        view.addSubview(winHeader)
        view.addSubview(mainRushFrame)
        view.addSubview(congratLabel)
        view.addSubview(infoLabel)
        view.addSubview(nextRushButton)
        
        congratLabel.setLabel(text: "Congratulations!")
        infoLabel.setLabel(text: "You won \(winnedCoins) coins")
        congratLabel.setLabel(size: frameHeight/10)
        infoLabel.setLabel(size: frameHeight/12)
        
        mainRushFrame.snp.makeConstraints { make in
            make.width.height.equalTo(frameWidth)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(frameHeight/3)
        }
        
        winHeader.snp.makeConstraints { make in
            make.width.equalTo(frameWidth)
            make.height.equalTo(headerHeight)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(mainRushFrame.snp.top).offset(headerHeight/10)
        }
        
        congratLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(mainRushFrame).offset(-frameHeight/4)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(mainRushFrame)
        }
        
        nextRushButton.snp.makeConstraints { make in
            make.width.equalTo(buttonWidth)
            make.height.equalTo(buttonHeight)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(mainRushFrame).offset(-buttonHeight/2)
        }
    }
}

extension UIViewController {
    internal func rushControllerAppear() {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.view.alpha.on()
        }
    }
    
    internal func rushControllerDisappear(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            self.view.alpha.off()
        } completion: { isFinish in
            guard isFinish else { return }
            completion()
        }
    }
}

extension CGFloat {
    mutating func on() {
        self = 1
    }
    
    mutating func off() {
        self = 0
    }
}
