import UIKit
import GameKit

protocol ViewControllerGameOverDelegate: NSObjectProtocol {
    func addItemViewController(_ controller: ViewControllerGameOver?, didFinishEnteringItem item: String?)
}

class ViewControllerGameOver: UIViewController, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Outlets
    @IBOutlet weak var labelGameOver: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var labelPoints: UILabel!
    @IBOutlet weak var labelLeaderboard: UILabel!
    @IBOutlet weak var labelDeveloper: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var buttonHighScores: UIButton!

    // Properties
    weak var delegate: ViewControllerGameOverDelegate?
    var score = 0
    var isGameCenterEnabled = false
    var isAchievementSaved = false
    var leaderboardID = "seven.seconds.leaderboard"
    var achievementID = ""

    private var emitterLayerGlobal: CAEmitterLayer? = nil
    private var emitterCellGlobal = CAEmitterCell()

    // Factory instances
    private let fx: Fx = Fx.shared
    private let sparks: Sparks = Sparks.shared
    private let gameCenterFactory: GameCenterFactory = GameCenterFactory.shared
    
    // View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBackground()
        setupLabels()
        setupGameCenterUI()
    }
    
    // UI Setup
    private func setupUI() {
        isModalInPresentation = true
        labelGameOver.text = ""
    }
    
    private func setupBackground() {
        let imageView = fx.setBackgroundImageView(bounds: view.bounds, center: view.center)
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
        fx.renderBlur(viewTarget: imageView, isDark: true)
        sparks.createSmallSparks(emitterLayerGlobal: &emitterLayerGlobal, emitterCellGlobal: emitterCellGlobal, view: viewMain)
    }
        
    private func setupLabels() {
        let uiElements: [UILabel] = [labelGameOver, labelPoints, labelScore, labelValue, labelDeveloper, labelLeaderboard]
        uiElements.forEach { $0.textColor = UIColor.white }
        labelValue.text = "\(score)"
    }
        
    private func setupGameCenterUI() {
        guard isGameCenterEnabled else {
            print("Game Center Not Enabled")
            labelLeaderboard.isHidden = true
            buttonHighScores.isHidden = true
            return
        }
    }
    
    // Button Actions
    @IBAction func buttonBack() {
        let itemToPassBack = String(format: "Previous score: %li hits", Int(score))
        delegate?.addItemViewController(self, didFinishEnteringItem: itemToPassBack)
        dismiss(animated: true)
    }
        
    @IBAction func buttonShowLeaderboard(_ sender: Any) {
        gameCenterFactory.showLeaderboard(viewController: self, leaderboardID: leaderboardID)
    }
        
    @IBAction func buttonIMAWO() {
        if let url = URL(string: "https://www.facebook.com/groups/sevensecondschampions") {
            UIApplication.shared.openURL(url)
        }
    }
    
    // Game Center
    func showLeaderboard() {
        gameCenterFactory.showLeaderboard(viewController: self, leaderboardID: leaderboardID)
    }
    
    func reportAchievement(achievement: String, percentComplete: Double) {
        gameCenterFactory.reportAchievement(achievement: achievement, percentComplete: percentComplete)
    }
    
    func showAchievement() {
        gameCenterFactory.showAchievement(viewController: self)
    }
    
    func showAlert(achievement: String) {
        if isAchievementSaved {
            var title = ""
            
            if score > 150 {
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
    
    // Game Over Logic
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
}
