import SpriteKit

final class FruitTapWheelScene: SKScene, SKPhysicsContactDelegate {
    internal weak var wheelController: FruitTapWheelController?
    
    private let wheelSceneTitle = WheelFruitTitleNode()
    private let mainWheelFrameNode = MainWheelFruitFrameNode()
    private let wheelFruitCloseButton = CloseSceneButton()
    private let fruitRushWheel = FruitRushWheel()
    private let spinActionButton = FruitRushSpinActionButton()
    private let fruitRushWheelDetector = FruitRushWheelDetector()
    
    private var isFruitSpinEnabled = true
    private var canCloseController = true
    
    private var currentFruitMultiplier: Int = .zero
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        self.wheelFruitElementsConfiguration()
    }
    
    private func wheelFruitElementsConfiguration() {
        self.physicsWorld.contactDelegate = self

        addChild(wheelSceneTitle)
        addChild(mainWheelFrameNode)
        addChild(wheelFruitCloseButton)
        addChild(fruitRushWheel)
        addChild(spinActionButton)
        addChild(fruitRushWheelDetector)
        
        if UIScreen.main.bounds.height == 667 || UIScreen.main.bounds.height == 736 {
            wheelSceneTitle.position = CGPoint(x: frame.midX, y: frame.maxY - wheelSceneTitle.frame.height/1.4)
            mainWheelFrameNode.position = CGPoint(x: frame.midX, y: wheelSceneTitle.frame.minY - mainWheelFrameNode.frame.height/1.85)
        } else {
            wheelSceneTitle.position = CGPoint(x: frame.midX, y: frame.maxY - wheelSceneTitle.frame.height * 1.5)
            mainWheelFrameNode.position = CGPoint(x: frame.midX, y: wheelSceneTitle.frame.minY - mainWheelFrameNode.frame.height/1.7)
        }
        

        wheelFruitCloseButton.position = CGPoint(x: mainWheelFrameNode.frame.maxX - wheelFruitCloseButton.frame.width/2, y: mainWheelFrameNode.frame.maxY)
        
        fruitRushWheel.position = CGPoint(x: mainWheelFrameNode.position.x, y: mainWheelFrameNode.position.y  + fruitRushWheel.wheelSide/8)
        
        spinActionButton.position = CGPoint(x: mainWheelFrameNode.position.x, y: mainWheelFrameNode.frame.minY + spinActionButton.frame.height)
        
        fruitRushWheelDetector.position = CGPoint(x: frame.midX, y: fruitRushWheel.position.y + fruitRushWheel.wheelSide/2.3)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        spinButtonTouch(location: touches.first?.location(in: self))
        closeButtonTouch(location: touches.first?.location(in: self))
    }
    
    private func spinButtonTouch(location: CGPoint?) {
        guard let location, isFruitSpinEnabled else { return }
        let spinButton = nodes(at: location).compactMap({ $0 as? FruitRushSpinActionButton }).first
        if let spinButton {
            spinButton.spinButtonActionAnimation()
            isFruitSpinEnabled.toggle()
            canCloseController.toggle()
            fruitRushWheel.fruitWheelRotationAction { [weak self] in
                guard let self else { return }
                let currentBalance = FruitTapDefaultsManager.fruitCoinsCount
                let totalSummAfterSpin = currentBalance * currentFruitMultiplier
                let winningCoins = totalSummAfterSpin - currentBalance
                
                FruitTapDefaultsManager.fruitCoinsCount = totalSummAfterSpin
                FruitTapDefaultsManager.fruitNextWheel = Date().timeIntervalSince1970 + 86400
                self.wheelController?.presentWinnigScreen(winningCoins)
            }
        }
    }
    
    private func closeButtonTouch(location: CGPoint?) {
        guard let location else { return }
        let closeButton = nodes(at: location).compactMap({ $0 as? CloseSceneButton }).first
        if let closeButton {
            closeButton.closeButtonActionAnimation()
            if canCloseController {
                wheelController?.closeFruitWheelController()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == WheelBonanzaBits.fruitSegment | WheelBonanzaBits.wheelRushDetector {
            if let rushSegment = contact.bodyA.node as? FruitRushWheelSegment {
                currentFruitMultiplier = rushSegment.fruitRushMultiplier
            } else if let rushSegment = contact.bodyB.node as? FruitRushWheelSegment {
                currentFruitMultiplier = rushSegment.fruitRushMultiplier
            }
        }
    }
}

final class FruitRushWheel: SKNode {
    internal let wheelSide = UIScreen.main.bounds.width * 0.86 * FruitRushValues.screenMult
    private let wheelTexture = SKTexture(image: .mainFruitWheelNode)
    private lazy var fruitTushWheelSprite = SKSpriteNode(texture: wheelTexture, size: CGSize(width: wheelSide, height: wheelSide))
    
    override init() {
        super.init()
        self.configurationOfFruitRushWheel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func fruitWheelRotationAction(_ completion: @escaping () -> ()) {
        let randomFruitRusihAngle = Double.random(in: 67.4...71.84)
        let rotationWheelAction = SKAction.rotate(byAngle: randomFruitRusihAngle, duration: 6)
        rotationWheelAction.timingMode = .easeInEaseOut
        self.run(rotationWheelAction) {
            completion()
        }
    }
    
    private func configurationOfFruitRushWheel() {
        self.zPosition = 1
        self.addChild(fruitTushWheelSprite)
        
        let threeXFruitsegment = FruitRushWheelSegment(size: wheelSide/2, startPoint: -0.3927, endPoint: 0.3927, fruitRushMultiplier: 3)
        addChild(threeXFruitsegment)
        
        let sevenXFruitsegment = FruitRushWheelSegment(size: wheelSide/2, startPoint: 0.3927, endPoint: 1.1781, fruitRushMultiplier: 7)
        addChild(sevenXFruitsegment)
        
        let twoXFruitsegment = FruitRushWheelSegment(size: wheelSide/2, startPoint: 1.1781, endPoint: 1.9635, fruitRushMultiplier: 2)
        addChild(twoXFruitsegment)
        
        let sixXFruitsegment = FruitRushWheelSegment(size: wheelSide/2, startPoint: 1.9635, endPoint: 2.7489, fruitRushMultiplier: 6)
        addChild(sixXFruitsegment)
        
        let fiveXFruitsegment = FruitRushWheelSegment(size: wheelSide/2, startPoint: 2.7489, endPoint: 3.5343, fruitRushMultiplier: 5)
        addChild(fiveXFruitsegment)
        
        let nineXFruitsegment = FruitRushWheelSegment(size: wheelSide/2, startPoint: 3.5343, endPoint: 4.3197, fruitRushMultiplier: 9)
        addChild(nineXFruitsegment)
        
        let fourXFruitsegment = FruitRushWheelSegment(size: wheelSide/2, startPoint: 4.3197, endPoint: 5.1051, fruitRushMultiplier: 4)
        addChild(fourXFruitsegment)
        
        let eightXFruitsegment = FruitRushWheelSegment(size: wheelSide/2, startPoint: 5.1051, endPoint: 5.8905, fruitRushMultiplier: 8)
        addChild(eightXFruitsegment)
    }
}

final class FruitRushSpinActionButton: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let spinTexture = SKTexture(image: .wheelSpinButton)
        let width = UIScreen.main.bounds.width * 0.54 * FruitRushValues.screenMult
        let height = width * 0.3
        let size = CGSize(width: width, height: height)
        super.init(texture: spinTexture, color: .clear, size: size)
        self.zPosition = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func spinButtonActionAnimation() {
        FruitRushAppFeedback.shared.fullButtonEffect()
        run(.scale(to: 0.95, duration: 0.15)) { [weak self] in
            self?.run(.scale(to: 1.0, duration: 0.15))
        }
    }
}

final class FruitRushWheelSegment: SKShapeNode {
    internal var fruitRushMultiplier: Int
    
    init(size: CGFloat, startPoint: CGFloat, endPoint: CGFloat, fruitRushMultiplier: Int) {
        self.fruitRushMultiplier = fruitRushMultiplier
        super.init()
        self.fruitSegmentSettings(size: size, startPoint: startPoint, endPoint: endPoint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fruitSegmentSettings(size: CGFloat, startPoint: CGFloat, endPoint: CGFloat) {
        let pathOfFruitRushWheel = UIBezierPath()
        pathOfFruitRushWheel.move(to: .zero)
        pathOfFruitRushWheel.addArc(withCenter: .zero, radius: size, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        pathOfFruitRushWheel.close()
        
        self.path = pathOfFruitRushWheel.cgPath
        self.strokeColor = .clear
        self.zPosition = 2
        self.physicsBody = SKPhysicsBody(polygonFrom: pathOfFruitRushWheel.cgPath)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        
        self.physicsBody?.categoryBitMask = WheelBonanzaBits.fruitSegment
        self.physicsBody?.contactTestBitMask = WheelBonanzaBits.wheelRushDetector
        self.physicsBody?.collisionBitMask = 0
    }
}

struct WheelBonanzaBits {
    static let fruitSegment: UInt32 = 0x1 << 0
    static let wheelRushDetector: UInt32 = 0x1 << 1
}

final class FruitRushWheelDetector: SKSpriteNode {
    private let detectorHeight: CGFloat
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let frRushTexture = SKTexture(image: .wheelSegmentDetector)
        let detectorWidth = UIScreen.main.bounds.width * 0.13 * FruitRushValues.screenMult
        detectorHeight = detectorWidth * 1.08
        let detectorSize = CGSize(width: detectorWidth, height: detectorHeight)
        super.init(texture: frRushTexture, color: .clear, size: detectorSize)
        self.fruitRushDetectorSettings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fruitRushDetectorSettings() {
        zPosition = 3
        
        let rushSegmentDetector = SKShapeNode(circleOfRadius: 5)
        rushSegmentDetector.fillColor = .clear
        rushSegmentDetector.strokeColor = .clear
        rushSegmentDetector.position.y -= detectorHeight/2
        rushSegmentDetector.zPosition = 4
        rushSegmentDetector.physicsBody = SKPhysicsBody(circleOfRadius: 5)
        rushSegmentDetector.physicsBody?.isDynamic = false
        rushSegmentDetector.physicsBody?.affectedByGravity = false
        
        rushSegmentDetector.physicsBody?.categoryBitMask = WheelBonanzaBits.wheelRushDetector
        rushSegmentDetector.physicsBody?.contactTestBitMask = WheelBonanzaBits.fruitSegment
        rushSegmentDetector.physicsBody?.collisionBitMask = 0
        self.addChild(rushSegmentDetector)
    }
}

final class CloseSceneButton: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let textureOfButton = SKTexture(image: .fruitRushCloseButton)
        let buttonSide = UIScreen.main.bounds.width * 0.15 * FruitRushValues.screenMult
        let size = CGSize(width: buttonSide, height: buttonSide)
        super.init(texture: textureOfButton, color: .clear, size: size)
        self.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func closeButtonActionAnimation() {
        FruitRushAppFeedback.shared.fullButtonEffect()
        run(.scale(to: 0.95, duration: 0.15)) { [weak self] in
            self?.run(.scale(to: 1.0, duration: 0.15))
        }
    }
}

final class WheelFruitTitleNode: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let titleTexture = SKTexture(image: .wheelTitleNode)
        let titleWidth = UIScreen.main.bounds.width * 0.88 * FruitRushValues.screenMult
        let titleHeight = titleWidth * 0.335
        let titleSize = CGSize(width: titleWidth, height: titleHeight)
        super.init(texture: titleTexture, color: .clear, size: titleSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class MainWheelFruitFrameNode: SKSpriteNode {
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        let frameTexture = SKTexture(image: .wheelFrameNode)
        let frameWidth = UIScreen.main.bounds.width * 0.88 * FruitRushValues.screenMult
        let frameHeight = frameWidth * 1.4
        let frameSize = CGSize(width: frameWidth, height: frameHeight)
        super.init(texture: frameTexture, color: .clear, size: frameSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
