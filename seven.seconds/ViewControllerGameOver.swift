//
//  ViewControllerGameOver.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 2/26/21.
//

import UIKit
import AVFoundation
import QuartzCore
import GameKit

protocol ViewControllerGameOverDelegate: NSObjectProtocol {
    func addItemViewController(_ controller: ViewControllerGameOver?, didFinishEnteringItem item: String?)
}

class ViewControllerGameOver: UIViewController, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var labelGameOver: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var labelPoints: UILabel!
    @IBOutlet weak var labelLeaderboard: UILabel!
    @IBOutlet weak var labelDeveloper: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var buttonHighScores: UIButton!
    
    @IBAction func buttonBack() {
        let itemToPassBack = String(format: "Previous score: %li points", Int(score))
        delegate?.addItemViewController(self, didFinishEnteringItem: itemToPassBack)

        dismiss(animated: true)
    }
    
    @IBAction func buttonShowLeaderboard(_ sender: Any) {
        showLeaderboard()
    }
    
    @IBAction func buttonIMAWO() {
        if let url = URL(string: "https://www.facebook.com/groups/sevensecondschampions") {
            UIApplication.shared.openURL(url)
        }
    }
        
    var isGameCenterEnabled: Bool = false
    var isAchievementSaved: Bool = false
    var leaderboardID = "seven.seconds.leaderboard"
    var achievementID: String = ""
    
    var emitterLayerGlobal: CAEmitterLayer? = nil
    var emitterCellGlobal = CAEmitterCell()
    
    var emitterLayer: CAEmitterLayer? = nil
    var emitterCell = CAEmitterCell()
    
    weak var delegate: ViewControllerGameOverDelegate?
    var score = 0
    var birthRate: Float = 0
    var velocity: CGFloat = 0
    
    var animation: CABasicAnimation? = nil
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        switch score {
        case 0 ..< 10:
            labelGameOver.text = "Seriously?"
        case 10 ..< 30:
            labelGameOver.text = "Nice one!"
        case 30 ..< 50:
            labelGameOver.text = "Wow!"
            achievementID = "seven.seconds.dedicated.player"
            reportAchievement(achievement: achievementID, percentComplete: 100)
            showAlert(achievement: "\nYou are now: \nSEVEN SECONDS DEDICATED PLAYER!")
        case 50 ..< 75:
            labelGameOver.text = "It's crazy!"
            achievementID = "seven.seconds.super.player"
            reportAchievement(achievement: achievementID, percentComplete: 100)
            showAlert(achievement: "\nYou are now: \nSEVEN SECONDS SUPER PLAYER!")
        case 75 ..< 100:
            labelGameOver.text = "What!?!"
            achievementID = "seven.seconds.master"
            reportAchievement(achievement: achievementID, percentComplete: 100)
            showAlert(achievement: "\nYou are now: \nSEVEN SECONDS MASTER!")
        case 100 ..< 125:
            labelGameOver.text = "Oh my God!"
            achievementID = "seven.seconds.achievement"
            reportAchievement(achievement: achievementID, percentComplete: 100)
            showAlert(achievement: "\nYou are now: \nSEVEN SECONDS SUPER HERO!")
        case 125 ..< 150:
            labelGameOver.text = "No way!"
            achievementID = "seven.seconds.god"
            reportAchievement(achievement: achievementID, percentComplete: 100)
            showAlert(achievement: "\nYou are now: \nSEVEN SECONDS GOD!")
        case 150 ... 1000:
            labelGameOver.text = "Cheater!!!"
            achievementID = "seven.seconds.cheater"
            reportAchievement(achievement: achievementID, percentComplete: 100)
            showAlert(achievement: "\nYou are a \nSEVEN SECONDS CHEATER!")
            
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        isModalInPresentation = true
        labelGameOver.text = ""
        
        //Background static
        
        var bounds: CGRect = view.bounds
        bounds.size.width += 0
        bounds.size.height += 0
        
        let background = UIImage(named: "2022_original.jpg")
        var imageView : UIImageView!
        imageView = UIImageView(frame: bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        renderBlur(viewTarget: imageView, isDark: true)
        createSmallSparks()
        //addParallaxToView(vw: view)
        
        labelGameOver.textColor = UIColor.white
        
        labelPoints.textColor = UIColor.white
        labelScore.textColor = UIColor.white
        labelValue.textColor = UIColor.white
        labelDeveloper.textColor = UIColor.white
        labelLeaderboard.textColor = UIColor.white
        labelValue.text = String(format: "%li", Int(score))
        
        guard isGameCenterEnabled else {
            print("Game Center Not Enabled")
            
            labelLeaderboard.isHidden = true
            buttonHighScores.isHidden = true
            
            return
        }
    }
        
    func addParallaxToView(vw: UIView) {
        let amount = 40

        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        vw.addMotionEffect(group)
    }
    
    func createSmallSparks() {
        guard let image = UIImage(named: "spark.png")?.cgImage else { fatalError("Failed loading image.") }
        
        emitterLayerGlobal = CAEmitterLayer(layer: image)
        emitterLayerGlobal?.name = "Emitter"
        
        emitterLayerGlobal?.emitterPosition.x = viewMain.frame.midX - 10
        emitterLayerGlobal?.emitterPosition.y = -50
        
        let color = CGColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1);
        emitterCellGlobal.color = color
        emitterCellGlobal.name = "cell"
        emitterCellGlobal.birthRate = 80
        emitterCellGlobal.lifetime = 10
        emitterCellGlobal.velocity = 42

        emitterCellGlobal.scale = 0.1
        emitterCellGlobal.scaleRange = 0.1
        emitterCellGlobal.emissionRange = CGFloat.pi * 2.0
        emitterCellGlobal.contents = image
        
        emitterLayerGlobal?.emitterCells = [emitterCellGlobal]
        viewMain.layer.addSublayer(emitterLayerGlobal!)
    }
    
    func createSparks() {
        guard let image = UIImage(named: "spark.png")?.cgImage
            else { fatalError("Failed loading image.") }
        
        emitterLayer = CAEmitterLayer(layer: image)
        emitterLayer?.name = "Emitter"
        
        emitterLayer?.emitterPosition.x = viewMain.frame.midX
        emitterLayer?.emitterPosition.y = labelValue.frame.midY + 22
        
        emitterCell.name = "cell"
        emitterCell.birthRate = 1
        emitterCell.velocity = 22
        emitterCell.contents = image
        emitterCell.emissionLongitude = .pi / 2.0
        emitterCell.emissionRange = CGFloat.pi / 4.0
        emitterCell.lifetime = 16
        emitterCell.scale = 0.2
        emitterCell.scaleRange = 0.2
        
        emitterLayer?.emitterCells = [emitterCell]
        viewMain.layer.addSublayer(emitterLayer!)
    }
    
    func showLeaderboard() {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID
        self.show(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
         // self.presentViewController(gcViewController, animated: true, completion: nil)
    }
        
    func reportAchievement(achievement: String, percentComplete: Double) {
        guard isGameCenterEnabled else {
            print("Game Center Not Enabled")
            return
        }
        
        let achievement = GKAchievement(identifier: achievement)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { (error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                self.isAchievementSaved = false
                return
            }
        }
        
        self.isAchievementSaved = true
    }
        
    func showAchievement() {
        guard isAchievementSaved else {
            print("Achievement Not Saved")
            return
        }
        
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .achievements
        present(gcViewController, animated: true, completion: nil)
    }
        
    func showAlert(achievement: String) {
        if (isAchievementSaved == true) {
            var title: String = ""
            
            if (score > 150) {
                title = "YOU CHEATED!"
            } else {
                title = "Congratulations!"
            }
            
            let alert = UIAlertController(title: title, message: achievement, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Show my Achievements", style: .destructive, handler: { action in
                self.showAchievement()
            }))
            alert.addAction(UIAlertAction(title: "Show the Leaderboard", style: .default, handler: { action in
                self.showLeaderboard()
            }))
            alert.addAction(UIAlertAction(title: "Return to game", style: .cancel, handler: { action in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func renderBlur(viewTarget: UIView, isDark: Bool) {
        var blurEffect: UIBlurEffect? = nil
        
        if #available(iOS 10.0, *) {
            if (isDark) {
                blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            } else {
                blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            }
        } else {
            if (isDark) {
                blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            } else {
                blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            }
        }
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewTarget.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewTarget.addSubview(blurEffectView)
    }
}

