import UIKit
import SnapKit
import SpriteKit

final class FruitTapGameController: UIViewController {
    private weak var fruitRushScene: FruitTapGameScene?
    private(set) var fruitLaunchLevel: FruitTapLevelFolder
    internal var fruitDataUpdate: (() -> ())?
    
    private let fruitRushLivesFrame = FruitTapConfiiguratedImage(.fruitRushLivesFrame)
    private let fruitRushCoinsFrame = FruitTapConfiiguratedImage(.fruitRushCoinsFrame)
    private let fruitTapTimeFrame = FruitTapConfiiguratedImage(.fruitTimerFrame)
    private let goalSceneBanner = FruitTapConfiiguratedImage(.goalBanner)
    private let bottomBonusFrame = FruitTapConfiiguratedImage(.bottomFruitSceneFrame)
    
    private let livesCountLabel = FruitLabelWithShadow()
    private let sceneTimerLabel = FruitLabelWithShadow()
    private let coinsCountLabel = FruitLabelWithShadow(isCoins: true)
    private let roundGoalLabel = FruitLabelWithShadow(isRound: true)
    
    private let mixerButton = FruitTapButton(FruitTapBonuses.fruitMixer.buttonImage)
    private let rainButton = FruitTapButton(FruitTapBonuses.juicyRain.buttonImage)
    private let fiestaButton = FruitTapButton(FruitTapBonuses.fruitFiesta.buttonImage)
    private let backToMenuButton = FruitTapButton(.fruitTapSceneBackButton)
    
    private let mixerBonusCountView = FruitTapConfiiguratedImage(.levelFruitCircleCell)
    private let mixerCountLabel = FruitLabelWithShadow(isButton: true)
    
    private let rainBonusCountView = FruitTapConfiiguratedImage(.levelFruitCircleCell)
    private let rainCountLabel = FruitLabelWithShadow(isButton: true)
    
    private let fiestaBonusCountView = FruitTapConfiiguratedImage(.levelFruitCircleCell)
    private let fiestaCountLabel = FruitLabelWithShadow(isButton: true)
    
    private let progressBar = UIProgressView()
    private var levelProgress = 0.0
    private let rushFormatter = DateComponentsFormatter()
        
    init(fruitLaunchLevel: FruitTapLevelFolder) {
        self.fruitLaunchLevel = fruitLaunchLevel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fruitRushSceneConfiguration()
        self.mainFruitRushHeaderElements()
        self.addTargetsToFruitButtons()
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    
    private func fruitRushSceneConfiguration() {
        self.view = SKView(frame: view.frame)
        guard let skFruitView = self.view as? SKView else { return }
        let gameFruitScene = FruitTapGameScene(size: skFruitView.bounds.size)
        self.fruitRushScene = gameFruitScene
        gameFruitScene.parentGameFruitRushController = self
        gameFruitScene.scaleMode = .aspectFill
        skFruitView.ignoresSiblingOrder = true
        skFruitView.presentScene(fruitRushScene)
    }
    
    private func mainFruitRushHeaderElements() {
        view.addSubview(fruitRushLivesFrame)
        fruitRushLivesFrame.addSubview(livesCountLabel)
        view.addSubview(fruitRushCoinsFrame)
        fruitRushCoinsFrame.addSubview(coinsCountLabel)
        view.addSubview(fruitTapTimeFrame)
        fruitTapTimeFrame.addSubview(sceneTimerLabel)
        view.addSubview(goalSceneBanner)
        goalSceneBanner.addSubview(roundGoalLabel)
        goalSceneBanner.addSubview(progressBar)
        view.addSubview(bottomBonusFrame)
        view.addSubview(rainButton)
        view.addSubview(mixerButton)
        view.addSubview(fiestaButton)
        view.addSubview(backToMenuButton)
                
        let livesWidth = UIScreen.main.bounds.width * 0.255 * FruitRushValues.screenMult
        let livesHeight = 0.44 * livesWidth
        let sideOffset = UIDevice.current.userInterfaceIdiom == .phone ? 16 : 49
        let topOffset = UIDevice.current.userInterfaceIdiom == .phone ? livesHeight/5 : livesHeight/2
        
        rushFormatter.allowedUnits = [.minute, .second]
        rushFormatter.unitsStyle = .positional
        rushFormatter.zeroFormattingBehavior = .default

        fruitRushLivesFrame.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(topOffset)
            make.leading.equalToSuperview().offset(sideOffset)
            make.width.equalTo(livesWidth)
            make.height.equalTo(livesHeight)
        }
        
        fruitRushCoinsFrame.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(fruitRushLivesFrame)
            make.trailing.equalToSuperview().offset(-sideOffset)
        }
        
        livesCountLabel.setLabel(size: livesHeight/1.4)
        sceneTimerLabel.setLabel(size: livesHeight/1.4)
        coinsCountLabel.setLabel(size: livesHeight)
        if UIDevice.current.userInterfaceIdiom == .phone {
            roundGoalLabel.setLabel(size: livesHeight/3)
        } else {
            roundGoalLabel.setLabel(size: livesHeight/2)
        }

    
        livesCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-livesHeight/30)
            make.centerX.equalToSuperview().offset(livesWidth/5)
        }
        
        coinsCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-livesHeight/30)
            make.centerX.equalToSuperview().offset(livesWidth/5.5)
            make.width.equalTo(livesWidth/2)
            make.height.equalTo(livesHeight * 1.05)
        }
        
        fruitTapTimeFrame.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(coinsCountLabel)
            make.width.equalTo(livesWidth * 1.1)
            make.height.equalTo(livesHeight * 1.1)
        }
        
        sceneTimerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let frameWidth = UIScreen.main.bounds.width * 0.8
        let frameHeight = frameWidth * 0.123
        
        goalSceneBanner.snp.makeConstraints { make in
            make.top.equalTo(fruitTapTimeFrame.snp.bottom).offset(livesHeight/4)
            make.trailing.equalTo(fruitRushCoinsFrame).offset(frameWidth/16)
            make.width.equalTo(frameWidth)
            make.height.equalTo(frameHeight)
        }
        
        let bottomWidth = UIScreen.main.bounds.width * 1.1 * FruitRushValues.screenMult
        let bottomHeight = bottomWidth * 0.22
        
        bottomBonusFrame.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(bottomWidth)
            make.height.equalTo(bottomHeight)
            make.bottom.equalToSuperview()
        }
        
        rainButton.snp.makeConstraints { make in
            make.width.height.equalTo(bottomHeight * 0.7)
            make.centerX.equalTo(bottomBonusFrame)
            make.top.equalTo(bottomBonusFrame).offset(bottomHeight/8)
        }
        
        mixerButton.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(rainButton)
            make.trailing.equalTo(rainButton.snp.leading).offset(-bottomHeight/4)
        }
        
        fiestaButton.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(mixerButton)
            make.leading.equalTo(rainButton.snp.trailing).offset(bottomHeight/4)
        }
        
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            roundGoalLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(livesHeight/4)
            }
        } else {
            roundGoalLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(livesHeight/2.4)
            }
        }

        progressBar.trackTintColor = .lightGray
        progressBar.progressTintColor = .systemGreen
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            progressBar.snp.makeConstraints { make in
                make.width.equalTo(frameWidth * 0.7)
                make.centerX.equalToSuperview()
                make.height.equalTo(livesHeight/5)
                make.top.equalTo(roundGoalLabel.snp.bottom).offset(livesHeight/5)
            }
        } else {
            progressBar.snp.makeConstraints { make in
                make.width.equalTo(frameWidth * 0.7)
                make.centerX.equalToSuperview()
                make.height.equalTo(livesHeight/3)
                make.top.equalTo(roundGoalLabel.snp.bottom).offset(livesHeight/3.5)
            }
        }
        
        backToMenuButton.snp.makeConstraints { make in
            make.width.height.equalTo(livesWidth * 0.5)
            make.centerY.equalTo(goalSceneBanner)
            make.leading.equalTo(fruitRushLivesFrame)
        }
        
        view.addSubview(mixerBonusCountView)
        mixerBonusCountView.addSubview(mixerCountLabel)
        mixerCountLabel.setLabel(size: bottomHeight * 0.2)
        mixerBonusCountView.snp.makeConstraints { make in
            make.width.height.equalTo(bottomHeight * 0.3)
            make.trailing.equalTo(mixerButton).offset(bottomHeight * 0.1)
            make.top.equalTo(mixerButton).offset(-bottomHeight * 0.05)
        }
        mixerCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-bottomHeight * 0.01)
        }   
        
        view.addSubview(rainBonusCountView)
        rainBonusCountView.addSubview(rainCountLabel)
        rainCountLabel.setLabel(size: bottomHeight * 0.2)
        rainBonusCountView.snp.makeConstraints { make in
            make.width.height.equalTo(bottomHeight * 0.3)
            make.trailing.equalTo(rainButton).offset(bottomHeight * 0.1)
            make.top.equalTo(rainButton).offset(-bottomHeight * 0.05)
        }
        rainCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-bottomHeight * 0.01)
        }  
        
        view.addSubview(fiestaBonusCountView)
        fiestaBonusCountView.addSubview(fiestaCountLabel)
        fiestaCountLabel.setLabel(size: bottomHeight * 0.2)
        fiestaBonusCountView.snp.makeConstraints { make in
            make.width.height.equalTo(bottomHeight * 0.3)
            make.trailing.equalTo(fiestaButton).offset(bottomHeight * 0.1)
            make.top.equalTo(fiestaButton).offset(-bottomHeight * 0.05)
        }
        fiestaCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-bottomHeight * 0.01)
        }
        
        updateBonusStates()
        
        livesCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitLivesCount)")
        coinsCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitCoinsCount)")
        roundGoalLabel.setLabel(text: "Collect \(fruitLaunchLevel.goalFruitCount) \(fruitLaunchLevel.goalFruitType.goalTitle)")
        guard let formattedRushString = rushFormatter.string(from: Double(fruitLaunchLevel.roundTime)) else { return }
        sceneTimerLabel.setLabel(text: formattedRushString)
        
        progressBar.progress = 0.0
    }
    
    private func updateBonusStates() {
        mixerCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitMixerBonusCount)")
        rainCountLabel.setLabel(text: "\(FruitTapDefaultsManager.juicyRainBonusCount)")
        fiestaCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitFiestaBonusCount)")
        
        mixerButton.isEnabled = FruitTapDefaultsManager.fruitMixerBonusCount > 0
        rainButton.isEnabled = FruitTapDefaultsManager.juicyRainBonusCount > 0
        fiestaButton.isEnabled = FruitTapDefaultsManager.fruitFiestaBonusCount > 0
    }
    
    @objc private func tapFruitMixerBonus() {
        FruitTapDefaultsManager.fruitMixerBonusCount -= 1
        fruitRushScene?.fruitMixerAction()
        updateBonusStates()
    }
    
    @objc private func tapJuicyRainBonus() {
        FruitTapDefaultsManager.juicyRainBonusCount -= 1
        fruitRushScene?.juicyRainBonusAction()
        updateBonusStates()
    }
    
    @objc private func tapFruitFiestaBonus() {
        FruitTapDefaultsManager.fruitFiestaBonusCount -= 1
        fruitRushScene?.fiestaBonusAction()
        updateBonusStates()
    }
    
    private func addTargetsToFruitButtons() {
        backToMenuButton.addTarget(self, action: #selector(backToMenu), for: .touchUpInside)
        mixerButton.addTarget(self, action: #selector(tapFruitMixerBonus), for: .touchUpInside)
        rainButton.addTarget(self, action: #selector(tapJuicyRainBonus), for: .touchUpInside)
        fiestaButton.addTarget(self, action: #selector(tapFruitFiestaBonus), for: .touchUpInside)
    }
    
    @objc private func backToMenu() {
        fruitDataUpdate?()
        dismiss(animated: true)
    }
    
    internal func reloadProgressBar() {
        progressBar.progress = 0
    }
    
    internal func addPointToGoal(level: FruitTapLevelFolder) {
        let progressStep = 1.0/Float(level.goalFruitCount)
        progressBar.progress += progressStep
    }
    
    internal func updateTimeLabel(timeLeft: Double) {
        guard let formattedRushString = rushFormatter.string(from: timeLeft) else { return }
        sceneTimerLabel.setLabel(text: formattedRushString)
    }
    
    internal func updateGoals(level: FruitTapLevelFolder) {
        roundGoalLabel.setLabel(text: "Collect \(level.goalFruitCount) \(level.goalFruitType.goalTitle)")
    }
    
    internal func addCoin() {
        FruitTapDefaultsManager.fruitCoinsCount += 1
        coinsCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitCoinsCount)")
        FruitTapDefaultsManager.tasksProgress[0] += 1
        FruitTapDefaultsManager.tasksProgress[4] += 1
        
        if FruitTapDefaultsManager.tasksProgress[0] == 200 {
            FruitTapDefaultsManager.reachedRewardsCount += 1
        }
        
        if FruitTapDefaultsManager.tasksProgress[4] == 500 {
            FruitTapDefaultsManager.reachedRewardsCount += 1
        }
    }
    
    internal func presentFinalController(isWin: Bool, collectedCoins: Int) {
        let finalController = FruitGameRoundEndController(isWin: isWin, collectedCoins: collectedCoins)
        livesCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitLivesCount)")
        finalController.modalPresentationStyle = .overFullScreen
        finalController.finalExitClosure = { [weak self] nextRound in
            guard let self else { return }
            if nextRound {
                self.fruitRushScene?.setNextRound()
            } else {
                self.fruitRushScene?.restartFruitRound()
            }
        }
        present(finalController, animated: false)
    }
}
