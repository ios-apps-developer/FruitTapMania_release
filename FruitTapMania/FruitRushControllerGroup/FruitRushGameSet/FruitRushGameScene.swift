import SpriteKit

final class FruitTapGameScene: SKScene {
    internal weak var parentGameFruitRushController: FruitTapGameController?
    
    private let fruitSceneBackground = FruitTapSceneBackground()
    private var currentFruitLevel: FruitTapLevelFolder = .fruitLevelOne
    
    private var isFruitRoundEnded = false
    private var fruitsCountOnScene = 0
    private var collectedFruits = 0
    private var roundTimeLeft = 0
    private var collectedCoins = 0
    private var totalCollectedFruits = 0
    
    private var fiestaBonus = false
    private var juicyRainBonus = false
    
    private let fruitCollectSound = SKAction.playSoundFileNamed("fruitCollectSound", waitForCompletion: false)
    private let roundWinSound = SKAction.playSoundFileNamed("fruitRoundWinSound", waitForCompletion: false)
    private let roundLoseSound = SKAction.playSoundFileNamed("", waitForCompletion: false)
    private let bonusSound = SKAction.playSoundFileNamed("fruitTapBonusSound", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        currentFruitLevel = parentGameFruitRushController?.fruitLaunchLevel ?? .fruitLevelOne
        allFruitElementsConfiguration()
        configurationSwitchLevel()
    }
    
    private func allFruitElementsConfiguration() {
        addChild(fruitSceneBackground)
        
        fruitSceneBackground.position = CGPoint(x: frame.midX, y: frame.midY)
    }
    
    private func configurationSwitchLevel() {
        collectedFruits = 0
        fruitsCountOnScene = 0
        collectedCoins = 0
        totalCollectedFruits = 0
        parentGameFruitRushController?.reloadProgressBar()
        roundTimeLeft = currentFruitLevel.roundTime
        self.parentGameFruitRushController?.updateTimeLabel(timeLeft: Double(roundTimeLeft))
        self.parentGameFruitRushController?.updateGoals(level: currentFruitLevel)
        self.parentGameFruitRushController?.reloadProgressBar()
        
        startFruitTimerAction()
        startFruitSpawnAction()
        startCoinsSpawnAction()
        
        isFruitRoundEnded = false
    }
    
    private func startFruitTimerAction() {
        let waitAction = SKAction.wait(forDuration: 1)
        let timerAction = SKAction.run { [weak self] in
            guard let self else { return }
            self.roundTimeLeft -= 1
            self.parentGameFruitRushController?.updateTimeLabel(timeLeft: Double(roundTimeLeft))
            if self.roundTimeLeft == 0 {
                isFruitRoundEnded = true
                removeAction(forKey: "fruitRoundTimer")
                removeAction(forKey: "fruitsSpawnAction")
                removeAction(forKey: "coinsSpawnAction")
                
                parentGameFruitRushController?.presentFinalController(isWin: false, collectedCoins: collectedCoins)
                
                if FruitTapDefaultsManager.fruitSoundIsOn {
                    run(roundLoseSound)
                }
                
                if FruitTapDefaultsManager.fruitLivesCount > 0 {
                    FruitTapDefaultsManager.fruitLivesCount -= 1
                }
            }
        }
        let sequence = SKAction.sequence([waitAction, timerAction])
        run(.repeatForever(sequence), withKey: "fruitRoundTimer")
    }
    
    private func startFruitSpawnAction() {
        let spawnFruitAction = SKAction.run {  [weak self] in
            guard let self, let randomType = FruitTapType.allCases.randomElement(), self.fruitsCountOnScene < 35 else { return }

            DispatchQueue.global(qos: .userInteractive).async {
                let fruit = MainTappableFruit(fruitType: self.juicyRainBonus ? self.currentFruitLevel.goalFruitType : randomType)
                self.getRandomPosition(fruit: fruit)
                DispatchQueue.main.async {
                    self.addChild(fruit)
                    fruit.showFruit()
                    self.fruitsCountOnScene += 1
                }
            }
        }
        
        let waitFruitAction = SKAction.wait(forDuration: currentFruitLevel.spawnDelay)
        let sequence = SKAction.sequence([waitFruitAction, spawnFruitAction])
        self.run(.repeatForever(sequence), withKey: "fruitsSpawnAction")
    }
    
    private func startCoinsSpawnAction() {
        let spawnCoinAction = SKAction.run {  [weak self] in
            guard let self else { return }

            DispatchQueue.global(qos: .userInteractive).async {
                let coin = TapSceneCoin()
                self.getRandomPosition(coin: coin)
                DispatchQueue.main.async {
                    self.addChild(coin)
                    coin.showCoin()
                }
            }
        }
        
        let waitFruitAction = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([waitFruitAction, spawnCoinAction])
        self.run(.repeatForever(sequence), withKey: "coinsSpawnAction")
    }
    
    private func getRandomPosition(fruit: MainTappableFruit) {
        let randomXRange = self.frame.maxX * 0.1...self.frame.maxX * 0.9
        let randomYRange = self.frame.maxY * 0.2...self.frame.maxY * 0.75
        let position = CGPoint(x: CGFloat.random(in: randomXRange), y: CGFloat.random(in: randomYRange))
        if nodes(at: position).contains(where: { $0.name == "mainTappableFruit" }) {
            getRandomPosition(fruit: fruit)
        } else {
            fruit.position = position
            return
        }
    }
    
    private func getRandomPosition(coin: TapSceneCoin) {
        let randomXRange = self.frame.maxX * 0.1...self.frame.maxX * 0.9
        let randomYRange = self.frame.maxY * 0.2...self.frame.maxY * 0.75
        let position = CGPoint(x: CGFloat.random(in: randomXRange), y: CGFloat.random(in: randomYRange))
        if nodes(at: position).contains(where: { $0.name == "mainTappableFruit" }) || nodes(at: position).contains(where: { $0.name == "tapCoin" }) {
            getRandomPosition(coin: coin)
        } else {
            coin.position = position
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        coinCollectAction(location: location)
        let fruit = nodes(at: location).compactMap({ $0 as? MainTappableFruit }).first
        if let fruit {
            fruit.removeFruit()
            fruitsCountOnScene -= 1
            totalCollectedFruits += 1
            if FruitTapDefaultsManager.fruitSoundIsOn {
                run(fruitCollectSound)
            }
            if totalCollectedFruits == 100 {
                FruitTapDefaultsManager.tasksProgress[3] += 100
                if FruitTapDefaultsManager.tasksProgress[3] == 100 {
                    FruitTapDefaultsManager.reachedRewardsCount += 1
                }
            }
            if fruit.fruitType == currentFruitLevel.goalFruitType {
                addPointToGoal()
            }
            if fiestaBonus {
                parentGameFruitRushController?.addCoin()
                collectedCoins += 1
            }
            guard let particle = SKEffectNode(fileNamed: fruit.fruitType.explosionName) else { return }
            particle.position = fruit.position
            particle.zPosition = 3
            addChild(particle)
            particle.run(.wait(forDuration: 3)) {
                particle.removeFromParent()
            }
        }
    }
    
    private func coinCollectAction(location: CGPoint) {
        let coin = nodes(at: location).compactMap({ $0 as? TapSceneCoin }).first
        if let coin {
            coin.removeCoin()
            parentGameFruitRushController?.addCoin()
            collectedCoins += 1
            if fiestaBonus {
                parentGameFruitRushController?.addCoin()
                collectedCoins += 1
            }
        }
    }
    
    private func addPointToGoal() {
        collectedFruits += 1
        parentGameFruitRushController?.addPointToGoal(level: currentFruitLevel)
        
        if collectedFruits == currentFruitLevel.goalFruitCount {
            guard !isFruitRoundEnded else { return }
            isFruitRoundEnded.toggle()
            removeAction(forKey: "fruitRoundTimer")
            removeAction(forKey: "fruitsSpawnAction")
            removeAction(forKey: "coinsSpawnAction")
            
            parentGameFruitRushController?.presentFinalController(isWin: true, collectedCoins: collectedCoins)
            if FruitTapDefaultsManager.fruitLivesCount < 10 {
                FruitTapDefaultsManager.fruitLivesCount += 1
            }
            
            if FruitTapDefaultsManager.fruitSoundIsOn {
                run(roundWinSound)
            }
            
            if !FruitTapDefaultsManager.fruitLevelsOpened.contains(currentFruitLevel.rawValue + 1) {
                FruitTapDefaultsManager.fruitLevelsOpened.append(currentFruitLevel.rawValue + 1)
            }
        }
    }
    
    internal func juicyRainBonusAction() {
        juicyRainBonus = true
        run(.wait(forDuration: 7)) { [weak self] in
            guard let self else { return }
            self.juicyRainBonus = false
        }
        if FruitTapDefaultsManager.fruitSoundIsOn {
            run(bonusSound)
        }
    }
    
    internal func fiestaBonusAction() {
        fiestaBonus = true
        run(.wait(forDuration: 7)) { [weak self] in
            guard let self else { return }
            self.fiestaBonus = false
        }
        if FruitTapDefaultsManager.fruitSoundIsOn {
            run(bonusSound)
        }
    }
    
    internal func fruitMixerAction() {
        enumerateChildNodes(withName: "mainTappableFruit") { [weak self] fruit, _ in
            guard let self else { return }
            if (fruit as? MainTappableFruit)?.fruitType == self.currentFruitLevel.goalFruitType {
                (fruit as? MainTappableFruit)?.removeFruit()
                self.fruitsCountOnScene -= 1
                self.addPointToGoal()
                if self.fiestaBonus {
                    self.parentGameFruitRushController?.addCoin()
                    self.collectedCoins += 1
                }
            } else {
                (fruit as? MainTappableFruit)?.removeFruit()
                self.fruitsCountOnScene -= 1
            }
            
            if FruitTapDefaultsManager.fruitSoundIsOn {
                run(bonusSound)
            }
            
            guard let particle = SKEffectNode(fileNamed: (fruit as? MainTappableFruit)?.fruitType.explosionName ?? "bananaExplosion") else { return }
            particle.position = fruit.position
            particle.zPosition = 3
            addChild(particle)
            particle.run(.wait(forDuration: 3)) {
                particle.removeFromParent()
            }
        }
    }
    
    private func getNextRoundValue() {
        var nextIndex = currentFruitLevel.rawValue + 1
        if nextIndex > 14 {
            nextIndex = 0
        }
        currentFruitLevel = FruitTapLevelFolder(rawValue: nextIndex) ?? .fruitLevelOne
    }
    
    internal func setNextRound() {
        enumerateChildNodes(withName: "tapCoin") { coin, _ in
            coin.removeFromParent()
        }
        enumerateChildNodes(withName: "mainTappableFruit") { fruit, _ in
            fruit.removeFromParent()
        }
        
        getNextRoundValue()
        configurationSwitchLevel()
        FruitTapDefaultsManager.tasksProgress[5] += 1
        if FruitTapDefaultsManager.tasksProgress[5] == 10 {
            FruitTapDefaultsManager.reachedRewardsCount += 1
        }
    }
    
    internal func restartFruitRound() {
        enumerateChildNodes(withName: "tapCoin") { coin, _ in
            coin.removeFromParent()
        }
        enumerateChildNodes(withName: "mainTappableFruit") { fruit, _ in
            fruit.removeFromParent()
        }
        
        configurationSwitchLevel()
    }
}

final class MainTappableFruit: SKSpriteNode {
    private(set) var fruitType: FruitTapType
    
    init(fruitType: FruitTapType) {
        self.fruitType = fruitType
        let texture = SKTexture(image: fruitType.fruitImage)
        let width = UIScreen.main.bounds.width * 0.14 * FruitRushValues.screenMult
        let height = width * 1.25
        let size = CGSize(width: width, height: height)
        super.init(texture: texture, color: .clear, size: size)
        self.zPosition = 1
        self.name = "mainTappableFruit"
        setScale(0.0)
        addMovement()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addMovement() {
        let direction = Bool.random()
        if direction {
            let leftAction = SKAction.move(by: CGVector(dx: -10, dy: 0), duration: 2)
            let rightAction = SKAction.move(by: CGVector(dx: 10, dy: 0), duration: 2)
            run(.repeatForever(.sequence([leftAction, rightAction])))
        } else {
            let topAction = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 2)
            let bottomAction = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 2)
            run(.repeatForever(.sequence([topAction, bottomAction])))
        }
    }
    
    internal func showFruit() {
        run(.scale(to: 1.0, duration: 0.2))
    }
    
    internal func removeFruit() {
        run(.scale(to: 0.0, duration: 0.4)) { [weak self] in
            guard let self else { return }
            self.run(.removeFromParent())
        }
    }
}

final class TapSceneCoin: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let texture = SKTexture(image: .tapSceneCoin)
        let width = UIScreen.main.bounds.width * 0.14 * FruitRushValues.screenMult
        let height = width * 1.25
        let size = CGSize(width: width, height: height)
        super.init(texture: texture, color: .clear, size: size)
        self.zPosition = 2
        self.setScale(0.0)
        self.name = "tapCoin"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func showCoin() {
        run(.scale(to: 1.0, duration: 0.2))
    }
    
    internal func removeCoin() {
        run(.scale(to: 0.0, duration: 0.4)) { [weak self] in
            guard let self else { return }
            self.run(.removeFromParent())
        }
    }
}

final class FruitTapSceneBackground: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let backTexture = SKTexture(image: .fruitTapSceneBackground)
        let width = UIScreen.main.bounds.width
        let height = width * 2.17
        let size = CGSize(width: width, height: height)
        super.init(texture: backTexture, color: .clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
