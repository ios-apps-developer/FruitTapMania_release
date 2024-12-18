import UIKit
import SnapKit

final class FruitTapSettingsController: UIViewController {
    private let settingsFruitFrame = FruitTapConfiiguratedImage(.fruitRushSettingsFrame)
    private let closeFruitSettings = FruitTapButton(.fruitRushCloseButton)
    private let fruitPolicyButton = FruitTapButton(.privacyOfFruitRushButton)
    
    private let soundFruitSwithcer = UISwitch()
    private let vibrationsFruitSwithcer = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.controllerConfiguration()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.alpha = 1
        }
    }
    
    private func controllerConfiguration() {
        self.view.alpha = 0
        self.view.backgroundColor = .black.withAlphaComponent(0.3)
        
        view.addSubview(settingsFruitFrame)
        view.addSubview(closeFruitSettings)
        view.addSubview(soundFruitSwithcer)
        view.addSubview(vibrationsFruitSwithcer)
        view.addSubview(fruitPolicyButton)
        
        let frameWidth = UIScreen.main.bounds.width * 0.9 * FruitRushValues.screenMult
        let frameHeight = frameWidth * 0.95
        
        settingsFruitFrame.snp.makeConstraints { make in
            make.width.equalTo(frameWidth)
            make.height.equalTo(frameHeight)
            make.center.equalToSuperview()
        }
        
        closeFruitSettings.snp.makeConstraints { make in
            make.width.height.equalTo(frameWidth/6)
            make.centerY.equalTo(settingsFruitFrame.snp.top).offset(-frameWidth/30)
            
            make.trailing.equalTo(settingsFruitFrame.snp.trailing)
        }
        
        soundFruitSwithcer.snp.makeConstraints { make in
            make.centerY.equalTo(settingsFruitFrame).offset(-frameHeight/3)
            make.trailing.equalTo(settingsFruitFrame).offset(-frameWidth/12)
        }
                
        vibrationsFruitSwithcer.snp.makeConstraints { make in
            make.centerX.equalTo(soundFruitSwithcer)
            make.centerY.equalTo(settingsFruitFrame).offset(-frameHeight/5.8)
        }
        let policyWidth = frameWidth / 2
        let policyHeight = 0.165 * policyWidth
        
        fruitPolicyButton.snp.makeConstraints { make in
            make.width.equalTo(policyWidth)
            make.height.equalTo(policyHeight)
            make.bottom.equalTo(settingsFruitFrame).offset(-policyWidth/5)
            make.trailing.equalTo(settingsFruitFrame).offset(-policyWidth/5)
        }
        
        soundFruitSwithcer.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        vibrationsFruitSwithcer.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

        soundFruitSwithcer.isOn = FruitTapDefaultsManager.fruitSoundIsOn
        vibrationsFruitSwithcer.isOn = FruitTapDefaultsManager.fruitVibrationIsOn
        
        soundFruitSwithcer.addTarget(self, action: #selector(soundFruitActionToggle), for: .valueChanged)
        vibrationsFruitSwithcer.addTarget(self, action: #selector(vibrationsFruitActionToggle), for: .valueChanged)
        fruitPolicyButton.addTarget(self, action: #selector(fruitRushPolicyOpen), for: .touchUpInside)
        closeFruitSettings.addTarget(self, action: #selector(returnToFruitMainNavigator), for: .touchUpInside)
    }
    
    @objc private func soundFruitActionToggle() {
        FruitTapDefaultsManager.fruitSoundIsOn.toggle()
        soundFruitSwithcer.isOn = FruitTapDefaultsManager.fruitSoundIsOn
        FruitRushAppFeedback.shared.fullButtonEffect()
    }   
    
    @objc private func vibrationsFruitActionToggle() {
        FruitTapDefaultsManager.fruitVibrationIsOn.toggle()
        vibrationsFruitSwithcer.isOn = FruitTapDefaultsManager.fruitVibrationIsOn
        FruitRushAppFeedback.shared.fullButtonEffect()
    }
    
    @objc private func fruitRushPolicyOpen() {
        guard let fruitPolicyUrl = URL(string: "https://sites.google.com/view/fruittapmania-privacy/home") else { return }
        UIApplication.shared.open(fruitPolicyUrl, options: [:], completionHandler: nil)
    }
    
    @objc private func returnToFruitMainNavigator() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.alpha = 0
        } completion: { isFinish in
            guard isFinish else { return }
            self.dismiss(animated: false)
        }
    }
}

final class FruitTapDefaultsManager {
    static private let standardDefaults = UserDefaults.standard
    
    static var fruitSoundIsOn: Bool {
        get { standardDefaults.value(forKey: #function) as? Bool ?? true }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var fruitVibrationIsOn: Bool {
        get { standardDefaults.value(forKey: #function) as? Bool ?? true }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var fruitCoinsCount: Int {
        get { standardDefaults.value(forKey: #function) as? Int ?? 0 }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var fruitLivesCount: Int {
        get { standardDefaults.value(forKey: #function) as? Int ?? 5 }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var fruitNextWheel: Double {
        get { standardDefaults.value(forKey: #function) as? Double ?? Date().timeIntervalSince1970 }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var nextWeekUpdate: Double {
        get { standardDefaults.value(forKey: #function) as? Double ?? 0.0 }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var isFirstAppLaunch: Bool {
        get { standardDefaults.value(forKey: #function) as? Bool ?? true }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var fruitLevelsOpened: [Int] {
        get { standardDefaults.value(forKey: #function) as? [Int] ?? [0] }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var fruitMixerBonusCount: Int {
        get { standardDefaults.value(forKey: #function) as? Int ?? 1 }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var juicyRainBonusCount: Int {
        get { standardDefaults.value(forKey: #function) as? Int ?? 1 }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var fruitFiestaBonusCount: Int {
        get { standardDefaults.value(forKey: #function) as? Int ?? 1 }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var tasksProgress: [Double] {
        get { standardDefaults.value(forKey: #function) as? [Double] ?? [0, 0, 0, 0, 0, 0] }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
    
    static var reachedRewardsCount: Int {
        get { standardDefaults.value(forKey: #function) as? Int ?? 0 }
        set { standardDefaults.set(newValue, forKey: #function) }
    }
 }

import AVFAudio

final class FruitRushAppFeedback {
    private let fruitRushImpactGenerator: UIImpactFeedbackGenerator
    static let shared = FruitRushAppFeedback()
    internal var toggleForInit = false
    
    private init() {
        self.fruitRushImpactGenerator = UIImpactFeedbackGenerator()
    }
    
    private func fruitSoundEffect() {
        if FruitTapDefaultsManager.fruitSoundIsOn {
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    internal func fruitVibrationEffect() {
        if FruitTapDefaultsManager.fruitVibrationIsOn {
            fruitRushImpactGenerator.impactOccurred()
        }
    }
    
    internal func fullButtonEffect() {
        fruitSoundEffect()
        fruitVibrationEffect()
    }
}
