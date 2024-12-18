import UIKit
import SnapKit

final class FruitTapLevelsController: UIViewController, UITableViewDelegate, UITableViewDataSource, FruitLevelsDelegate {
    private let fruitLevelsTable = UITableView()
    private let fruitSettingsButton = FruitTapButton(.fruitSettingsButton)
    private let fruitrRushLivesFrame = FruitTapConfiiguratedImage(.fruitRushLivesFrame)
    private let fruitrRushCoinsFrame = FruitTapConfiiguratedImage(.fruitRushCoinsFrame)
    private let livesCountLabel = FruitLabelWithShadow()
    private let coinsCountLabel = FruitLabelWithShadow(isCoins: true)
    private let timeToSpinLeftLabel = FruitLabelWithShadow()
    private let rushFormatter = DateComponentsFormatter()
    private let allFruitLevels = FruitTapLevelFolder.allCases
    private var canOpenWheel = false
    
    private let goTiFruitSpeenButton = FruitTapButton(.fruitRushGoToSpinButton)
    private var wheelIntervalTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        levelsRushConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFruitLabelsData()
    }

    @objc private func openFruitRushWheel() {
        guard canOpenWheel else { 
            errorFruitRushAnimation(for: timeToSpinLeftLabel)
            return
        }
        if FruitTapDefaultsManager.fruitCoinsCount == 0 {
            errorFruitRushAnimation(for: fruitrRushCoinsFrame)
            return
        }
        let fruitRushWheelVc = FruitTapWheelController()
        fruitRushWheelVc.modalPresentationStyle = .overFullScreen
        fruitRushWheelVc.fruitDataUpdateClosure = { [weak self] in
            guard let self else { return }
            self.canOpenWheel = false
            self.updateFruitLabelsData()
        }
        present(fruitRushWheelVc, animated: true)
    }
    
    private func updateFruitLabelsData() {
        coinsCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitCoinsCount)")
        livesCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitLivesCount)")
        
        let futureNextRushWheel = FruitTapDefaultsManager.fruitNextWheel
        let interval = futureNextRushWheel - Date().timeIntervalSince1970
        if interval > 0 {
            setTimerForTimerLabel()
        } else {
            canOpenWheel = true
        }
    }
    
    private func levelsRushConfiguration() {
        view.addSubview(fruitSettingsButton)
        view.addSubview(fruitLevelsTable)
        view.addSubview(fruitrRushLivesFrame)
        fruitrRushLivesFrame.addSubview(livesCountLabel)
        view.addSubview(fruitrRushCoinsFrame)
        view.addSubview(goTiFruitSpeenButton)
        view.addSubview(timeToSpinLeftLabel)
        fruitrRushCoinsFrame.addSubview(coinsCountLabel)
        view.sendSubviewToBack(fruitLevelsTable)
        
        fruitSettingsButton.addTarget(self, action: #selector(openFruitRushSettingsSettings), for: .touchUpInside)
        goTiFruitSpeenButton.addTarget(self, action: #selector(openFruitRushWheel), for: .touchUpInside)
        
        rushFormatter.allowedUnits = [.hour, .minute, .second]
        rushFormatter.unitsStyle = .positional
        rushFormatter.zeroFormattingBehavior = .pad
        
        let buttonWidth = UIScreen.main.bounds.width * 0.15 * FruitRushValues.screenMult
        fruitLevelsTable.backgroundColor = .clear
        fruitLevelsTable.separatorStyle = .none
        fruitLevelsTable.delegate = self
        fruitLevelsTable.dataSource = self
        fruitLevelsTable.register(FruitRushLevelCell.self, forCellReuseIdentifier: FruitRushLevelCell.id)
        fruitLevelsTable.showsVerticalScrollIndicator = false
        fruitLevelsTable.contentInset.bottom = buttonWidth
        
        fruitSettingsButton.snp.makeConstraints { make in
            make.width.height.equalTo(buttonWidth)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        
        fruitLevelsTable.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let livesWidth = buttonWidth * 1.7
        let livesHeight = 0.44 * livesWidth
        
        fruitrRushLivesFrame.snp.makeConstraints { make in
            make.centerY.equalTo(fruitSettingsButton)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(livesWidth)
            make.height.equalTo(livesHeight)
        }
        
        fruitrRushCoinsFrame.snp.makeConstraints { make in
            make.width.height.centerY.equalTo(fruitrRushLivesFrame)
            make.leading.equalTo(fruitrRushLivesFrame.snp.trailing).offset(livesWidth/7)
        }
        
        livesCountLabel.setLabel(size: livesHeight/1.4)
        coinsCountLabel.setLabel(size: livesHeight)
        timeToSpinLeftLabel.setLabel(size: livesHeight/1.8)
    
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
        
        goTiFruitSpeenButton.snp.makeConstraints { make in
            make.width.height.equalTo(buttonWidth * 1.3)
            make.trailing.equalTo(fruitSettingsButton)
            make.top.equalTo(fruitSettingsButton.snp.bottom).offset(buttonWidth/1.7)
        }
        
        timeToSpinLeftLabel.snp.makeConstraints { make in
            make.top.equalTo(goTiFruitSpeenButton.snp.bottom).offset(buttonWidth/3)
            make.centerX.equalTo(goTiFruitSpeenButton)
        }
        
        livesCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitLivesCount)")
        coinsCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitCoinsCount)")
        
        let futureNextRushWheel = FruitTapDefaultsManager.fruitNextWheel
        let interval = futureNextRushWheel - Date().timeIntervalSince1970
        guard let formattedRushString = rushFormatter.string(from: interval) else { return }
        timeToSpinLeftLabel.setLabel(text: formattedRushString)
        if interval <= 0 {
            canOpenWheel = true
            timeToSpinLeftLabel.setLabel(text: "Spin!")
        }
        
        setTimerForTimerLabel()
    }
    
    private func setTimerForTimerLabel() {
        wheelIntervalTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            let futureNextRushWheel = FruitTapDefaultsManager.fruitNextWheel
            let interval = futureNextRushWheel - Date().timeIntervalSince1970
            guard let formattedRushString = self.rushFormatter.string(from: interval) else { return }
            self.timeToSpinLeftLabel.setLabel(text: formattedRushString)
            canOpenWheel = false
            if interval <= 0 {
                canOpenWheel = true
                self.timeToSpinLeftLabel.setLabel(text: "Spin!")
                wheelIntervalTimer?.invalidate()
            }
        }
    }
    
    @objc private func openFruitRushSettingsSettings() {
        let fruitSettingsVc = FruitTapSettingsController()
        fruitSettingsVc.modalPresentationStyle = .overFullScreen
        present(fruitSettingsVc, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allFruitLevels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        FruitRushLevelCell(fruitLevelModel: allFruitLevels[indexPath.row], delegate: self)
    }
    
    func openFruitGoalLevel(level: FruitTapLevelFolder) {
        let gameVc = FruitTapGameController(fruitLaunchLevel: level)
        gameVc.modalPresentationStyle = .overFullScreen
        gameVc.fruitDataUpdate = { [weak self] in
            guard let self else { return }
            self.updateFruitLabelsData()
            self.fruitLevelsTable.reloadData()
        }
        present(gameVc, animated: true)
    }
    
    private func errorFruitRushAnimation(for view: UIView) {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [0, -10, 10, -10, 10, 0]
        shakeAnimation.duration = 0.7
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(shakeAnimation, forKey: nil)
    }
}

final class FruitRushLevelCell: UITableViewCell {
    static let id = String(String(describing: FruitRushLevelCell.self))
    private let fruitLevelModel: FruitTapLevelFolder
    private let levelCircleViewButton = FruitTapButton(.levelFruitCircleCell)
    private let levelSeparator = FruitTapConfiiguratedImage(.circleCellsSeparator)
    private let tapSensorView = UIView()
    
    weak var delegate: FruitLevelsDelegate?
    
    init(fruitLevelModel: FruitTapLevelFolder, delegate: FruitLevelsDelegate) {
        self.fruitLevelModel = fruitLevelModel
        self.delegate = delegate
        super.init(style: .default, reuseIdentifier: FruitRushLevelCell.id)
        self.levelFruitCellConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func levelFruitCellConfiguration() {
        let containerView = UIView()
        let fruitlabel = FruitLabelWithShadow()

        let cellWidth = UIScreen.main.bounds.width * 0.3 * FruitRushValues.screenMult
        addSubview(levelSeparator)
        addSubview(containerView)
        containerView.addSubview(levelCircleViewButton)
        containerView.addSubview(fruitlabel)
        
        addSubview(tapSensorView)

        selectionStyle = .none
        self.backgroundColor = .clear
        
        if !FruitTapDefaultsManager.fruitLevelsOpened.contains(fruitLevelModel.rawValue) {
            levelCircleViewButton.setImage(.closedLevelCircleFrame, for: .normal)
            levelCircleViewButton.setImage(.closedLevelCircleFrame, for: .highlighted)
        }

        fruitlabel.setLabel(size: cellWidth/2)
        fruitlabel.setLabel(text: "\(fruitLevelModel.rawValue + 1)")
        let cellOffset = UIDevice.current.userInterfaceIdiom == .pad ? cellWidth/4 : cellWidth/12
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(cellOffset)
            make.width.height.equalTo(cellWidth)
        }
        fruitlabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-cellWidth/20)
        }
        levelCircleViewButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        levelSeparator.snp.makeConstraints { make in
            make.width.equalTo(10)
            make.height.equalTo(cellWidth * 1.5)
            make.bottom.equalTo(levelCircleViewButton.snp.centerY)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(-cellWidth/6.5)
        }
        
        tapSensorView.snp.makeConstraints { make in
            make.width.height.equalTo(cellWidth)
            make.center.equalTo(containerView)
        }
        
        layoutIfNeeded()
        tapSensorView.layer.cornerRadius = tapSensorView.frame.width/2
        levelSeparator.alpha = fruitLevelModel.rawValue == 0 ? 0.0 : 0.7
        self.bringSubviewToFront(tapSensorView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(levelOpenButton))
        tapSensorView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc private func levelOpenButton() {
        if FruitTapDefaultsManager.fruitLevelsOpened.contains(fruitLevelModel.rawValue) {
            delegate?.openFruitGoalLevel(level: fruitLevelModel)
        }
    }
}

final class FruitLabelWithShadow: UIView {
    private let fruitlabel = UILabel()
    private let shadowlabel = UILabel()
    private let isCoins: Bool
    private let isRound: Bool
    private let isButton: Bool

    init(isCoins: Bool = false, isRound: Bool = false, isButton: Bool = false) {
        self.isCoins = isCoins
        self.isRound = isRound
        self.isButton = isButton
        super.init(frame: .zero)
        self.configurationOfLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configurationOfLabel() {
        addSubview(shadowlabel)
        addSubview(fruitlabel)
        fruitlabel.textColor = .white
        shadowlabel.textColor = .black.withAlphaComponent(0.7)
        if isRound {
            fruitlabel.textColor = .gray
            shadowlabel.textColor = .lightGray.withAlphaComponent(0.9)
        }
        
        if isButton {
            fruitlabel.textColor = .white
            shadowlabel.textColor = .black.withAlphaComponent(0.3)
        }
        
        if isCoins {
            fruitlabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            shadowlabel.snp.makeConstraints { make in
                make.center.equalTo(fruitlabel).offset(3)
                make.width.height.equalTo(fruitlabel)
            }
            
            fruitlabel.textAlignment = .center
            shadowlabel.textAlignment = .center
            fruitlabel.adjustsFontSizeToFitWidth = true
            shadowlabel.adjustsFontSizeToFitWidth = true
            fruitlabel.minimumScaleFactor = 0.3
            shadowlabel.minimumScaleFactor = 0.3
        } else {
            fruitlabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            shadowlabel.snp.makeConstraints { make in
                if isRound {
                    make.center.equalTo(fruitlabel).offset(2)
                } else {
                    if isButton {
                        make.center.equalTo(fruitlabel).offset(1)
                    } else {
                        make.center.equalTo(fruitlabel).offset(3)
                    }
                }
            }
        }
    }
    
    internal func setLabel(size: CGFloat) {
        fruitlabel.font = UIFont(name: "Baloo", size: size)
        shadowlabel.font = UIFont(name: "Baloo", size: size)
    }
    
    internal func setLabel(text: String) {
        fruitlabel.text = text
        shadowlabel.text = text
    }
}

enum FruitTapLevelFolder: Int, CaseIterable {
    case fruitLevelOne
    case fruitLevelTwo
    case fruitLevelThree
    case fruitLevelFour
    case fruitLevelFive
    case fruitLevelSix
    case fruitLevelSeven
    case fruitLevelEight
    case fruitLevelNine
    case fruitLevelTen
    case fruitLevelEleven
    case fruitLevelTwelve
    case fruitLevelThirteen
    case fruitLevelFourteen
    case fruitLevelFifteen
    
    var goalFruitType: FruitTapType {
        switch self {
            case .fruitLevelOne: .banana
            case .fruitLevelTwo: .orange
            case .fruitLevelThree: .strawberry
            case .fruitLevelFour: .watermelon
            case .fruitLevelFive: .grape
            case .fruitLevelSix: .banana
            case .fruitLevelSeven: .orange
            case .fruitLevelEight: .strawberry
            case .fruitLevelNine: .watermelon
            case .fruitLevelTen: .grape
            case .fruitLevelEleven: .banana
            case .fruitLevelTwelve: .orange
            case .fruitLevelThirteen: .strawberry
            case .fruitLevelFourteen: .watermelon
            case .fruitLevelFifteen: .grape
        }
    }
    
    var goalFruitCount: Int {
        switch self {
            case .fruitLevelOne: 20
            case .fruitLevelTwo: 30
            case .fruitLevelThree: 40
            case .fruitLevelFour: 50
            case .fruitLevelFive: 60
            case .fruitLevelSix: 70
            case .fruitLevelSeven: 80
            case .fruitLevelEight: 90
            case .fruitLevelNine: 100
            case .fruitLevelTen: 140
            case .fruitLevelEleven: 150
            case .fruitLevelTwelve: 160
            case .fruitLevelThirteen: 170
            case .fruitLevelFourteen: 180
            case .fruitLevelFifteen: 200
        }
    }
    
    var roundTime: Int {
        switch self {
            case .fruitLevelOne: 120
            case .fruitLevelTwo: 110
            case .fruitLevelThree: 100
            case .fruitLevelFour: 90
            case .fruitLevelFive: 80
            case .fruitLevelSix: 70
            case .fruitLevelSeven: 60
            case .fruitLevelEight: 55
            case .fruitLevelNine: 50
            case .fruitLevelTen: 45
            case .fruitLevelEleven: 40
            case .fruitLevelTwelve: 35
            case .fruitLevelThirteen: 30
            case .fruitLevelFourteen: 25
            case .fruitLevelFifteen: 20
        }
    }
    
    var spawnDelay: Double {
        switch self {
            case .fruitLevelOne: 0.5
            case .fruitLevelTwo: 0.5
            case .fruitLevelThree: 0.5
            case .fruitLevelFour: 0.4
            case .fruitLevelFive: 0.4
            case .fruitLevelSix: 0.4
            case .fruitLevelSeven: 0.3
            case .fruitLevelEight: 0.3
            case .fruitLevelNine: 0.3
            case .fruitLevelTen: 0.2
            case .fruitLevelEleven: 0.2
            case .fruitLevelTwelve: 0.2
            case .fruitLevelThirteen: 0.1
            case .fruitLevelFourteen: 0.1
            case .fruitLevelFifteen: 0.1
        }
    }
}

enum FruitTapType: String, CaseIterable {
    case banana
    case orange
    case strawberry
    case watermelon
    case grape
    
    var goalTitle: String {
        switch self {
            case .banana:
                "bananas"
            case .orange:
                "oranges"
            case .strawberry:
                "strawberries"
            case .watermelon:
                "watermelons"
            case .grape:
                "grapes"
        }
    }
    
    var explosionName: String {
        switch self {
            case .banana:
                "bananaExplosion"
            case .orange:
                "orangeExplosion"
            case .strawberry:
                "strawberryExplosion"
            case .watermelon:
                "watermelonExplosion"
            case .grape:
                "grapeExplosion"
        }
    }
    
    var fruitImage: UIImage {
        switch self {
            case .banana:
                    .banana
            case .orange:
                    .orange
            case .strawberry:
                    .strawberry
            case .watermelon:
                    .watermelon
            case .grape:
                    .grape
        }
    }
}

final class FruitTapButton: UIButton {
    init(_ fruitImage: UIImage) {
        super.init(frame: .zero)
        setImage(fruitImage, for: .normal)
        setImage(fruitImage, for: .highlighted)
        self.fruitButtonConfiguration()
        
        addTarget(self, action: #selector(fruitButtonTapEffect), for: .touchDown)
        addTarget(self, action: #selector(fruitButtonDragOutEffect), for: .touchUpInside)
        addTarget(self, action: #selector(fruitButtonDragOutEffect), for: .touchDragOutside)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fruitButtonConfiguration() {
        contentMode = .scaleAspectFit
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
    }
    
    @objc private func fruitButtonTapEffect(_ button: UIButton) {
        FruitRushAppFeedback.shared.fullButtonEffect()
        UIView.animate(withDuration: 0.135) {
            button.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        }
    }
    
    @objc private func fruitButtonDragOutEffect(_ button: UIButton) { 
        UIView.animate(withDuration: 0.135) {
            button.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}

protocol FruitLevelsDelegate: AnyObject {
    func openFruitGoalLevel(level: FruitTapLevelFolder)
}
