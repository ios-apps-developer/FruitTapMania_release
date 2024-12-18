import UIKit
import SnapKit

final class FruitTapAppStartController: UIViewController {
    private let fruitRushViewBackground = FruitTapConfiiguratedBackground(.fruitRushLevelsBackground)
    private let fruitLaunchBerry = FruitTapConfiiguratedImage(.fruitRushLoadBerry)
    private let fruitLaunchTitle = FruitTapConfiiguratedImage(.fruitRushLoadTitle)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fullFtuitLayoutConfiguration()
        
        self.mainTransitionToMenuController()
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
        
    private func mainTransitionToMenuController() {
        Timer.scheduledTimer(withTimeInterval: 3.6, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.removeAnimationsAndDo() {
                self.fruitMainControllerSwitch()
            }
        }
    }
    
    private func fruitMainControllerSwitch() {
        let newFruitRootVc = FruitTapTabBarController()
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = newFruitRootVc
    }
}

extension FruitTapAppStartController {
    private func fullFtuitLayoutConfiguration() {
        view.addSubview(fruitRushViewBackground)
        view.addSubview(fruitLaunchBerry)
        view.addSubview(fruitLaunchTitle)
        FruitRushAppFeedback.shared.toggleForInit.toggle()
        fruitRushViewBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let berryWidth = UIScreen.main.bounds.width * FruitRushValues.screenMult * 0.34
        let berryHeight = berryWidth * 1.042
        let titleWidth = berryWidth * 1.4
        let titleHeight = titleWidth * 0.17
        
        fruitLaunchBerry.snp.makeConstraints { make in
            make.width.equalTo(berryWidth)
            make.height.equalTo(berryHeight)
            make.center.equalToSuperview()
        }
        
        fruitLaunchTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(fruitLaunchBerry.snp.bottom).offset(titleHeight/2)
            make.width.equalTo(titleWidth)
            make.height.equalTo(titleHeight)
        }
        
        UIView.animate(withDuration: 1.2, delay: 0, options: [.repeat, .autoreverse]) { [weak self] in
            guard let self else { return }
            self.fruitLaunchBerry.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.fruitLaunchTitle.transform = CGAffineTransform(translationX: 0, y: berryHeight/5)
        }
    }
    
    private func removeAnimationsAndDo(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            guard let self else { return }
            self.fruitLaunchBerry.transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
            self.fruitLaunchBerry.alpha = 0
            self.fruitLaunchTitle.alpha = 0
            self.fruitLaunchTitle.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height/3)
        } completion: { [weak self] isFinish in
            guard let self, isFinish else { return }
            self.fruitLaunchBerry.layer.removeAllAnimations()
            self.fruitLaunchTitle.layer.removeAllAnimations()
            completion()
        }
    }
}

struct FruitRushValues {
    static let screenMult = UIDevice.current.userInterfaceIdiom == .phone ? 1.0 : 0.6
}

final class FruitTapConfiiguratedImage: UIImageView {
    init(_ fruitRushAsset: UIImage) {
        super.init(image: fruitRushAsset)
        self.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FruitTapConfiiguratedBackground: UIImageView {
    init(_ fruitRushAsset: UIImage) {
        super.init(image: fruitRushAsset)
        self.contentMode = .scaleAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
