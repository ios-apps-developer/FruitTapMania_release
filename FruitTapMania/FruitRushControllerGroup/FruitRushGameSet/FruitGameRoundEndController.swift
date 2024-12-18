import UIKit
import SnapKit

final class FruitGameRoundEndController: UIViewController {
    private let isWin: Bool
    private let collectedCoins: Int
    internal var finalExitClosure: ((Bool) -> ())?
    
    private let mainRushFrame = FruitTapConfiiguratedImage(.winningInfoFrame)
    private let winHeader = FruitTapConfiiguratedImage(.fruitWinHeader)
    private let congratLabel = FruitLabelWithShadow()
    private let infoLabel = FruitLabelWithShadow()
    private let nextRushButton = FruitTapButton(.nextFruitRushButton)
    private let retryRushButton = FruitTapButton(.retryFruitTapButton)
    
    init(isWin: Bool, collectedCoins: Int) {
        self.isWin = isWin
        self.collectedCoins = collectedCoins
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fruitTapControllerConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rushControllerAppear()
    }
    
    @objc private func nextLevelAction() {
        rushControllerDisappear { [weak self] in
            guard let self else { return }
            self.finalExitClosure?(true)
            self.dismiss(animated: false)
        }
    }
    
    @objc private func restartLevelAction() {
        rushControllerDisappear { [weak self] in
            guard let self else { return }
            self.finalExitClosure?(false)
            self.dismiss(animated: false)
        }
    }
    
    private func fruitTapControllerConfiguration() {
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        self.view.alpha = 0
        
        let frameWidth = UIScreen.main.bounds.width * 0.8 * FruitRushValues.screenMult
        let frameHeight = frameWidth
        let headerHeight = frameWidth * 0.9
        
        let buttonWidth = frameWidth * 0.6
        let buttonHeight = buttonWidth * 0.3
        
        view.addSubview(winHeader)
        view.addSubview(mainRushFrame)
        view.addSubview(congratLabel)
        view.addSubview(infoLabel)
        if isWin {
            view.addSubview(nextRushButton)
            nextRushButton.addTarget(self, action: #selector(nextLevelAction), for: .touchUpInside)
            congratLabel.setLabel(text: "Congratulations!")
        } else {
            view.addSubview(retryRushButton)
            retryRushButton.addTarget(self, action: #selector(restartLevelAction), for: .touchUpInside)
            winHeader.image = .fruitLossFrame
            congratLabel.setLabel(text: "Please, try again!")
        }
        
        infoLabel.setLabel(text: "You won \(collectedCoins) coins")
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
            if !isWin {
                make.bottom.equalTo(mainRushFrame.snp.top).offset(headerHeight/5.5)
            } else {
                make.bottom.equalTo(mainRushFrame.snp.top).offset(headerHeight/10)
            }
        }
        
        congratLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(mainRushFrame).offset(-frameHeight/4)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(mainRushFrame)
        }
        
        if isWin {
            nextRushButton.snp.makeConstraints { make in
                make.width.equalTo(buttonWidth)
                make.height.equalTo(buttonHeight)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(mainRushFrame).offset(-buttonHeight/2)
            }
        } else {
            retryRushButton.snp.makeConstraints { make in
                make.width.equalTo(buttonWidth)
                make.height.equalTo(buttonHeight)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(mainRushFrame).offset(-buttonHeight/2)
            }
        }
    }
}
