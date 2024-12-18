import UIKit
import SnapKit

final class FruitTapStoreController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let fruitrRushLivesFrame = FruitTapConfiiguratedImage(.fruitRushLivesFrame)
    private let fruitrRushCoinsFrame = FruitTapConfiiguratedImage(.fruitRushCoinsFrame)
    private let fruitSettingsButton = FruitTapButton(.fruitSettingsButton)
    private let livesCountLabel = FruitLabelWithShadow()
    private let coinsCountLabel = FruitLabelWithShadow(isCoins: true)
    private let storeTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storeFruitRushControllerConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateFruitLabelsData()
    }
    
    private func updateFruitLabelsData() {
        coinsCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitCoinsCount)")
        livesCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitLivesCount)")
    }
    
    private func storeFruitRushControllerConfiguration() {
        view.addSubview(fruitrRushLivesFrame)
        view.addSubview(fruitSettingsButton)
        fruitrRushLivesFrame.addSubview(livesCountLabel)
        view.addSubview(fruitrRushCoinsFrame)
        fruitrRushCoinsFrame.addSubview(coinsCountLabel)
        view.addSubview(storeTableView)
        
        fruitSettingsButton.isHidden = true
        
        storeTableView.dataSource = self
        storeTableView.delegate = self
        storeTableView.register(FruitBonusStoreCell.self, forCellReuseIdentifier: FruitBonusStoreCell.id)
        storeTableView.separatorStyle = .none
        storeTableView.isScrollEnabled = false
        storeTableView.contentInset.top = UIScreen.main.bounds.width * 0.04 * FruitRushValues.screenMult

        let livesWidth = UIScreen.main.bounds.width * 0.255 * FruitRushValues.screenMult
        let livesHeight = 0.44 * livesWidth
        let buttonWidth = UIScreen.main.bounds.width * 0.15 * FruitRushValues.screenMult
        
        fruitSettingsButton.snp.makeConstraints { make in
            make.width.height.equalTo(buttonWidth)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        
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
        storeTableView.backgroundColor = .clear
        storeTableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(fruitrRushCoinsFrame.snp.bottom)
        }
        
        livesCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitLivesCount)")
        coinsCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitCoinsCount)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FruitTapBonuses.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        FruitBonusStoreCell(bonus: FruitTapBonuses.allCases[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (storeTableView.cellForRow(at: indexPath) as? FruitBonusStoreCell)?.cellAction()
        livesCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitLivesCount)")
        coinsCountLabel.setLabel(text: "\(FruitTapDefaultsManager.fruitCoinsCount)")
    }
}

final class FruitBonusStoreCell: UITableViewCell {
    static let id = String(describing: FruitBonusStoreCell.self)
    private let bonusType: FruitTapBonuses
    private let cellMainImage = FruitTapConfiiguratedImage(.juicyRainCell)
    
    init(bonus: FruitTapBonuses) {
        self.bonusType = bonus
        super.init(style: .default, reuseIdentifier: FruitBonusStoreCell.id)
        self.fruitRushConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func fruitRushConfiguration() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        cellMainImage.image = bonusType.storeImage
        addSubview(cellMainImage)
        var cellMult = 0.88
        if UIScreen.main.bounds.height == 667 || UIScreen.main.bounds.height == 736 {
            cellMult = 0.77
        }
        let cellWidth = UIScreen.main.bounds.width * cellMult * FruitRushValues.screenMult
        let cellHeight = cellWidth * 0.54
        cellMainImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(cellHeight/15)
            make.width.equalTo(cellWidth)
            make.height.equalTo(cellHeight)
        }
    }
    
    internal func cellAction() {
        switch bonusType {
            case .fruitMixer:
                guard FruitTapDefaultsManager.fruitCoinsCount >= 150 else { return errorFruitRushAnimation(for: self) }
                FruitTapDefaultsManager.fruitCoinsCount -= 150
                FruitTapDefaultsManager.fruitMixerBonusCount += 1
                FruitTapDefaultsManager.fruitLivesCount += 1
            case .juicyRain:
                guard FruitTapDefaultsManager.fruitCoinsCount >= 250 else { return errorFruitRushAnimation(for: self) }
                FruitTapDefaultsManager.fruitCoinsCount -= 250
                FruitTapDefaultsManager.juicyRainBonusCount += 1
                FruitTapDefaultsManager.fruitLivesCount += 2
            case .fruitFiesta:
                guard FruitTapDefaultsManager.fruitCoinsCount >= 500 else { return errorFruitRushAnimation(for: self) }
                FruitTapDefaultsManager.fruitCoinsCount -= 500
                FruitTapDefaultsManager.fruitFiestaBonusCount += 1
                FruitTapDefaultsManager.fruitLivesCount += 5
        }
        
        UIView.animate(withDuration: 0.16) { [weak self] in
            guard let self else { return }
            self.cellMainImage.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { isFinish in
            guard isFinish else { return }
            UIView.animate(withDuration: 0.16) { [weak self] in
                guard let self else { return }
                self.cellMainImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
    private func errorFruitRushAnimation(for view: UIView) {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.values = [0, -10, 10, -10, 10, 0]
        shakeAnimation.duration = 0.7
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(shakeAnimation, forKey: nil)
    }
}

enum FruitTapBonuses: Int, CaseIterable {
    case fruitMixer
    case juicyRain
    case fruitFiesta
    
    var storeImage: UIImage {
        switch self {
            case .fruitMixer:
                    .fruitMixerCell
            case .juicyRain:
                    .juicyRainCell
            case .fruitFiesta:
                    .fruitFiestaCell
        }
    }
    
    var buttonImage: UIImage {
        switch self {
            case .fruitMixer:
                    .fruitMixerButton
            case .juicyRain:
                    .juicyRainButton
            case .fruitFiesta:
                    .fruitFiestaButton
        }
    }
}
