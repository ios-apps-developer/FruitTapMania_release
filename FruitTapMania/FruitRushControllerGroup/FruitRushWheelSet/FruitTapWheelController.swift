import UIKit
import SnapKit
import SpriteKit

final class FruitTapWheelController: UIViewController {
    private weak var wheelScene: FruitTapWheelScene?
    internal var fruitDataUpdateClosure: (() -> ())?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneConnection()
    }
    
    private func sceneConnection() {
        self.view = SKView(frame: view.frame)
        guard let skView = self.view as? SKView else { return }
        let gameWheelScene = FruitTapWheelScene(size: skView.bounds.size)
        self.wheelScene = gameWheelScene
        gameWheelScene.wheelController = self
        gameWheelScene.scaleMode = .aspectFill
        skView.ignoresSiblingOrder = true
        skView.presentScene(wheelScene)
        wheelScene?.backgroundColor = .init(red: 0.086, green: 0.039, blue: 0.196, alpha: 1)
    }
    
    internal func closeFruitWheelController() {
        fruitDataUpdateClosure?()
        self.dismiss(animated: true)
    }
    
    internal func presentWinnigScreen(_ winningCoins: Int) {
        let winVc = FruitTapWheelWinController(coins: winningCoins)
        winVc.modalPresentationStyle = .overFullScreen
        winVc.wheelExitClosure = { [weak self] in
            guard let self else { return }
            self.closeFruitWheelController()
        }
        present(winVc, animated: false)
    }
}

