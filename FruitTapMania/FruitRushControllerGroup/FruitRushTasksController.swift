import UIKit
import SnapKit

final class FruitTapTasksController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tasksFruitHeader = FruitTapConfiiguratedImage(.tasksHeader)
    private let tasksFruitFrame = FruitTapConfiiguratedImage(.tasksFrame)
    private let timeFrame = FruitTapConfiiguratedImage(.timeLeftTaskFrame)
    private let reachedGiftBanner = FruitTapConfiiguratedImage(.emptyGift)
    private let timeLeftLabel = FruitLabelWithShadow()
    private let dateFormatter = DateComponentsFormatter()
    private let tasksTable = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tasksControllerConfiguration()
        self.tasksTableViewConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tasksTable.reloadData()
        
        let timeLeft = FruitTapDefaultsManager.nextWeekUpdate - Date().timeIntervalSince1970
        if timeLeft < 0 {
            FruitTapDefaultsManager.nextWeekUpdate = Date().timeIntervalSince1970 + 604800
            guard let timeLeft = dateFormatter.string(from: timeLeft) else { return }
            timeLeftLabel.setLabel(text: timeLeft)
            
            FruitTapDefaultsManager.reachedRewardsCount = 0
            FruitTapDefaultsManager.tasksProgress = [0, 0, 0, 0, 0, 0]
        }
        guard let timeLeft = dateFormatter.string(from: timeLeft) else { return }
        timeLeftLabel.setLabel(text: timeLeft)
    }
    
    @objc private func tapAction() {
        guard FruitTapDefaultsManager.reachedRewardsCount > 0 else { return }
        let winVc = FruitTapWheelWinController(coins: 100 * FruitTapDefaultsManager.reachedRewardsCount)
        winVc.modalPresentationStyle = .overFullScreen
        winVc.wheelExitClosure = { [weak self] in
            FruitTapDefaultsManager.reachedRewardsCount = 0
            self?.reachedGiftBanner.image = .emptyGift
        }
        present(winVc, animated: false)
    }
    
    private func tasksControllerConfiguration() {
        view.addSubview(tasksFruitHeader)
        view.addSubview(tasksFruitFrame)
        view.addSubview(timeFrame)
        view.addSubview(reachedGiftBanner)
        view.addSubview(tasksTable)
        timeFrame.addSubview(timeLeftLabel)
        
        reachedGiftBanner.image = switch FruitTapDefaultsManager.reachedRewardsCount {
            case 0: .emptyGift
            case 1: .oneGift
            case 2: .twoGift
            case 3: .threeGift
            default: .threeGift
        }
        
        let headerWidth = UIScreen.main.bounds.width * 0.9 * FruitRushValues.screenMult
        let headerHeight = headerWidth * 0.335
        let frameHeight = 1.3 * headerWidth
        let timeFrameWidth = headerWidth * 0.5
        let timeFrameHeight = timeFrameWidth * 0.39
        let giftWidth = headerWidth * 1.06
        let giftHeight = giftWidth * 0.185
        
        tasksFruitFrame.snp.makeConstraints { make in
            make.width.equalTo(headerWidth)
            make.height.equalTo(frameHeight)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(frameHeight/9)
        }
        
        tasksFruitHeader.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(headerWidth)
            make.height.equalTo(headerHeight)
            make.bottom.equalTo(tasksFruitFrame.snp.top)
        }
        
        timeFrame.snp.makeConstraints { make in
            make.width.equalTo(timeFrameWidth)
            make.height.equalTo(timeFrameHeight)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(tasksFruitFrame.snp.top)
        }
        
        reachedGiftBanner.snp.makeConstraints { make in
            make.width.equalTo(giftWidth)
            make.height.equalTo(giftHeight)
            make.centerX.equalToSuperview()
            make.top.equalTo(timeFrame.snp.bottom)
        }
        
        tasksTable.snp.makeConstraints { make in
            make.top.equalTo(reachedGiftBanner.snp.bottom)
            make.leading.trailing.bottom.equalTo(tasksFruitFrame).inset(timeFrameHeight/4)
        }
        
        timeLeftLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(timeFrameHeight/4)
            make.centerY.equalToSuperview()
        }
        
        dateFormatter.allowedUnits = [.day, .hour]
        dateFormatter.unitsStyle = .abbreviated
        dateFormatter.zeroFormattingBehavior = .pad

        timeLeftLabel.setLabel(size: timeFrameHeight/2.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func tasksTableViewConfiguration() {
        tasksTable.backgroundColor = .clear
        tasksTable.isScrollEnabled = false
        tasksTable.delegate = self
        tasksTable.dataSource = self
        tasksTable.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TasksModel.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        TaskFruitCell(task: TasksModel.allCases[indexPath.row])
    }
}

final class TaskFruitCell: UITableViewCell {
    private let task: TasksModel
    static let id = String(describing: TaskFruitCell.self)
    private let cellBackFrame = FruitTapConfiiguratedImage(.tasksCell)
    private let titleLabel = FruitLabelWithShadow(isButton: true)
    private let taskProgress = UIProgressView()
    
    init(task: TasksModel) {
        self.task = task
        super.init(style: .default, reuseIdentifier: TaskFruitCell.id)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        self.taskCellConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func taskCellConfiguration() {
        let frameWidth = UIScreen.main.bounds.width * 0.9 * FruitRushValues.screenMult
        let cellWidth = frameWidth * 0.9
        let cellHeight = cellWidth * 0.135
        addSubview(cellBackFrame)
        addSubview(taskProgress)
        cellBackFrame.addSubview(titleLabel)
        titleLabel.setLabel(size: cellHeight/2.8)
        titleLabel.setLabel(text: task.taskTitle)
        cellBackFrame.snp.makeConstraints { make in
            make.width.equalTo(cellWidth)
            make.height.equalTo(cellHeight)
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(cellHeight/6)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(cellHeight/3.5)
        }
        
        let progressStep = 1.0 / task.taskGoal
        var progress = progressStep * FruitTapDefaultsManager.tasksProgress[task.rawValue]
        if progress > 1.0 {
            progress = 1.0
        }
        
        taskProgress.progress = Float(progress)
        taskProgress.trackTintColor = .systemYellow
        taskProgress.progressTintColor = .systemGreen
        
        taskProgress.snp.makeConstraints { make in
            make.width.equalTo(cellWidth * 0.91)
            make.height.equalTo(cellHeight/4)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(cellHeight/3.5)
        }
    }
}

enum TasksModel: Int, CaseIterable {
    case collect200Fruits
    case collect30seasonalFruits
    case combo15
    case collect100FruitsinOneMinute
    case collect500coins
    case tenRounds
    
    var taskTitle: String {
        switch self {
            case .collect200Fruits:
                "Collect 200 regular fruits within the week"
            case .collect30seasonalFruits:
                "Collect 30 seasonal fruits"
            case .combo15:
                "Perform 15 combo moves"
            case .collect100FruitsinOneMinute:
                "Collect 100 fruits in 3 minutes in one game"
            case .collect500coins:
                "Collect 500 coins in a week"
            case .tenRounds:
                "Play 10 rounds in a row"
        }
    }
    
    var taskGoal: Double {
        switch self {
            case .collect200Fruits:
                200
            case .collect30seasonalFruits:
                30
            case .combo15:
                15
            case .collect100FruitsinOneMinute:
                100
            case .collect500coins:
                500
            case .tenRounds:
                10
        }
    }
}
