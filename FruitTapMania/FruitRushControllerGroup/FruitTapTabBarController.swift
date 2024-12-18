import UIKit

final class FruitTapTabBarController: UITabBarController {
    private let fruitRushViewBackground = FruitTapConfiiguratedBackground(.fruitRushLevelsBackground)
    private let fruitBackgroundShadow = UIView()
    private let generator = UIImpactFeedbackGenerator()
    private let homeLevelsVc = FruitTapLevelsController()
    
    private let bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.1, 0.9, 1.0]
        bounceAnimation.duration = 0.3
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.alpha = 0
        firstConfigurations()
        setFruitControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAppearAnimation()
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item),
              tabBar.subviews.count > index + 1,
              let imageView = tabBar.subviews[index + 1].subviews.compactMap({ $0 as? UIImageView }).first else { return }
        imageView.layer.add(bounceAnimation, forKey: nil)
        generator.impactOccurred()
    }
    
    private func setFruitControllers() {
        let shopVc = FruitTapStoreController()
        let tasksController = FruitTapTasksController()
        
        var homeBarImage =  UIImage(resource: .iphoneMainHomeBar).withRenderingMode(.alwaysTemplate)
        var storeBarImage =  UIImage(resource: .iphoneMainStoreBar).withRenderingMode(.alwaysTemplate)
        var tasksBarImage =  UIImage(resource: .iphoneMainTasksBar).withRenderingMode(.alwaysTemplate)
        
        tabBar.itemPositioning = .fill
        
        if UIScreen.main.bounds.height == 667 || UIScreen.main.bounds.height == 736 {
            homeBarImage = UIImage(resource: .homeBarForSe).withRenderingMode(.alwaysTemplate)
            storeBarImage = UIImage(resource: .storeBarForSe).withRenderingMode(.alwaysTemplate)
            tasksBarImage = UIImage(resource: .dailyBarForSe).withRenderingMode(.alwaysTemplate)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            homeBarImage = UIImage(resource: .ipadHomeBarItem).withRenderingMode(.alwaysTemplate)
            storeBarImage = UIImage(resource: .ipadStoreBarItem).withRenderingMode(.alwaysTemplate)
            tasksBarImage = UIImage(resource: .ipadTasksBarItem).withRenderingMode(.alwaysTemplate)
        }

        homeLevelsVc.tabBarItem = UITabBarItem(
            title: nil,
            image: homeBarImage,
            tag: 0
        )
        shopVc.tabBarItem = UITabBarItem(
            title: nil,
            image: storeBarImage,
            tag: 1
        )
        tasksController.tabBarItem = UITabBarItem(
            title: nil,
            image: tasksBarImage,
            tag: 2
        )

        self.viewControllers = [homeLevelsVc, shopVc, tasksController]
        homeLevelsVc.view.alpha = 0
        self.view.sendSubviewToBack(fruitRushViewBackground)
        tabBar.tintColor = .init(red: 0.978, green: 0.763, blue: 0.118, alpha: 1)
        tabBar.unselectedItemTintColor = .lightGray
        tabBar.backgroundColor = .init(red: 0.341, green: 0.251, blue: 0.584, alpha: 1)
        tabBar.barTintColor = .init(red: 0.314, green: 0.184, blue: 0.604, alpha: 1)
        tabBar.scrollEdgeAppearance?.backgroundColor = .init(red: 0.314, green: 0.184, blue: 0.604, alpha: 1)
    }
    
    private func firstConfigurations() {
        view.addSubview(fruitRushViewBackground)
        fruitRushViewBackground.addSubview(fruitBackgroundShadow)
        fruitRushViewBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fruitBackgroundShadow.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fruitBackgroundShadow.backgroundColor = .black.withAlphaComponent(0.2)
        
        fruitBackgroundShadow.alpha = 0
        
        tabBar.layer.cornerRadius = 32
        tabBar.layer.masksToBounds = true
        tabBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        if FruitTapDefaultsManager.isFirstAppLaunch {
            FruitTapDefaultsManager.isFirstAppLaunch = false
            FruitTapDefaultsManager.nextWeekUpdate = Date().timeIntervalSince1970 + 604800
        }
    }
    
    private func startAppearAnimation() {
        UIView.animate(withDuration: 0.7) { [weak self] in
            guard let self else { return }
            self.fruitBackgroundShadow.alpha = 1
            self.homeLevelsVc.view.alpha = 1
            self.tabBar.alpha = 1
        }
    }
}

final class CustomTabBarItem: UIView {
    init() {
        super.init(frame: .zero)

        let imageView = FruitTapConfiiguratedImage(UIImage(systemName: "homekit")!)
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
