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
        let itemToPassBack = String(format: "Previous score: %li hits", Int(score))
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
    
    var fx: FxProtocol = Fx()
    var sparks: SparksProtocol = Sparks()
        
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
        
        //Static Background
        var imageView = fx.setBackgroundImageView(bounds: view.bounds, center: view.center)
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        fx.renderBlur(viewTarget: imageView, isDark: true)
        sparks.createSmallSparks(emitterLayerGlobal: &emitterLayerGlobal, emitterCellGlobal: emitterCellGlobal, view: viewMain)
        
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
    
    func showLeaderboard() {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID
        self.show(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
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
}

