import UIKit
import AVFoundation
import GameKit

class ViewController: UIViewController, ViewControllerGameOverDelegate, GKGameCenterControllerDelegate {
        
    // Outlets
    @IBOutlet weak var buttonPushIt: UIButton!
    @IBOutlet weak var labelTitleSeven: UILabel!
    @IBOutlet weak var labelTitleSeconds: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    @IBOutlet weak var labelPoints: UILabel!
    @IBOutlet weak var labelPrevious: UILabel!
    @IBOutlet weak var labelLeaderboard: UILabel!
    @IBOutlet weak var buttonHighScores: UIButton!
    @IBOutlet var viewMain: UIView!

    // Properties
    private var isGameCenterEnabled = false
    private var leaderboardID = "seven.seconds.leaderboard"
    private var impactMed: UIImpactFeedbackGenerator?
    private var emitterLayerGlobal: CAEmitterLayer?
    private var emitterCellGlobal = CAEmitterCell()
    private var emitterLayer: CAEmitterLayer?
    private var emitterCell = CAEmitterCell()
    private var count = 0
    private var seconds = 0
    private var timer: Timer?
    private var start = false
    private var buttonBeep: AVAudioPlayer?
    private var damageBeep: AVAudioPlayer?
    private var explodeBeep: AVAudioPlayer?
    private var backgroundMusic: AVAudioPlayer?
    private var score = 0
    
    // Factory instances
    private let fx: Fx = Fx.shared
    private let sparks: Sparks = Sparks.shared
    
    func addItemViewController(_ controller: ViewControllerGameOver?, didFinishEnteringItem item: String?) {
        damageBeep?.play()
        
        labelPrevious.text = item
        start = false
        initGame()
        
        let newColor = CGColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
        emitterLayer?.setValue(
            newColor,
            forKeyPath: "emitterCells.cell.color")
        
        emitterLayer?.setValue(
            NSNumber(value: 20),
            forKeyPath: "emitterCells.cell.birthRate")
        
        emitterLayer?.setValue(
            NSNumber(value: 22),
            forKeyPath: "emitterCells.cell.velocity")
        
        emitterLayerGlobal?.setValue(
            NSNumber(value: 42),
            forKeyPath: "emitterCells.cellGlobal.velocity")
        
        guard isGameCenterEnabled else {
            print("Game Center Not Enabled")
            
            labelLeaderboard.isHidden = true
            buttonHighScores.isHidden = true
            
            return
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    // View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIManager.setupUIElements([labelTitleSeven, labelTitleSeconds, labelSubtitle, labelTimer, labelScore, labelValue, labelPoints, labelPrevious, labelLeaderboard])
        
        labelPrevious.text = "Previous score: \(score) hits"
        UIManager.setupButtonImages(button: buttonPushIt)
        
        GameCenterManager.shared.authenticateLocalPlayer { [weak self] success in
            if success {
                self?.setupGameCenterUI()
            }
        }
        
        prepareAudioPlayers()
        setupEmitterLayers()
    }

    // UI Setup
    private func setupGameCenterUI() {
        if GameCenterManager.shared.gameCenterEnabled() {
            labelLeaderboard.isHidden = false
            buttonHighScores.isHidden = false
        } else {
            print("Game Center Not Enabled")
            labelLeaderboard.isHidden = true
            buttonHighScores.isHidden = true
        }
    }

    // Audio Setup
    private func prepareAudioPlayers() {
        impactMed = UIImpactFeedbackGenerator(style: .heavy)
        impactMed?.prepare()
        
        buttonBeep = AudioPlayerFactory.createAudioPlayer(fileName: "button", fileType: "wav")
        damageBeep = AudioPlayerFactory.createAudioPlayer(fileName: "damage", fileType: "wav")
        explodeBeep = AudioPlayerFactory.createAudioPlayer(fileName: "explode", fileType: "wav")
    }

    // Emitter Layers Setup
    private func setupEmitterLayers() {
        sparks.createSmallSparks(emitterLayerGlobal: &emitterLayerGlobal, emitterCellGlobal: emitterCellGlobal, view: viewMain)
        sparks.createSparks(emitterLayer: &emitterLayer, emitterCell: emitterCell, view: viewMain, button: buttonPushIt)
    }

    // Game Initialization
    private func initGame() {
        seconds = 7
        count = 0
        labelTimer.textColor = UIColor.white
        labelTimer.text = "Time left: \(seconds) seconds"
        labelValue.text = "\(count)"
        labelScore.text = "YOUR SCORE IS"
        
        let imageNormal = UIImage(named: "button_normal.png")
        buttonPushIt.setImage(imageNormal, for: .normal)
        let imageSelected = UIImage(named: "button_pressed.png")
        buttonPushIt.setImage(imageSelected, for: .highlighted)
        
        labelLeaderboard.isHidden = false
        buttonHighScores.isHidden = false
    }

    // Game Logic
    private func setupGame() {
        initGame()
        labelLeaderboard.isHidden = true
        buttonHighScores.isHidden = true
        
        emitterLayerGlobal?.setValue(88, forKeyPath: "emitterCells.cellGlobal.velocity")
        buttonBeep?.play()
        labelTimer.textColor = UIColor(red: 255.0/255, green: 94.0/255, blue: 19.0/255, alpha: 1)
        
        start = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(subtractTime), userInfo: nil, repeats: true)
    }

    @IBAction func buttonPressed() {
        if !start {
            setupGame()
        }
        
        count += 1
        labelValue.text = "\(count)"
        emitterLayer?.setValue(count * 2, forKeyPath: "emitterCells.cell.birthRate")
        emitterLayer?.setValue(22 + count * 4, forKeyPath: "emitterCells.cell.velocity")
        impactMed?.impactOccurred()
    }

    @objc private func subtractTime() {
        if start {
            seconds -= 1
            labelTimer.text = "Time left: \(seconds) seconds"
            buttonBeep?.play()
            if seconds > 3 {
                let newColor = CGColor(red: 255.0/255.0, green: 94.0/255.0, blue: 19.0/255.0, alpha: 1)
                emitterLayer?.setValue(newColor, forKeyPath: "emitterCells.cell.color")
            }
            if seconds <= 3 {
                labelScore.text = "HIT FASTER !!!!!"
                labelTimer.textColor = UIColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1)
                let newColor = CGColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
                emitterLayer?.setValue(newColor, forKeyPath: "emitterCells.cell.color")
            }
            if seconds == 0 {
                explodeBeep?.play()
                timer?.invalidate()
                start = false
                if isGameCenterEnabled && count < 180 {
                    submitScore(with: count)
                }
                showGameOver()
            }
        }
    }

    // Button Actions
    @IBAction func buttonUpInside(_ sender: Any) {
        // Handle button up inside action
    }

    @IBAction func buttonUpOutside(_ sender: Any) {
        // Handle button up outside action
    }

    // Game Center
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { [weak self] viewControllerGame, error in
            guard let self = self else { return }
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            if viewControllerGame != nil {
                self.present(viewControllerGame!, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                self.isGameCenterEnabled = true
                localPlayer.loadDefaultLeaderboardIdentifier { (leaderboardIdentifer, error) in
                    if error != nil {
                        print(error ?? "error")
                    } else {
                        self.leaderboardID = leaderboardIdentifer!
                    }
                }
                self.isGameCenterEnabled = true
                print("Adding GameCenter user was a success")
            } else {
                self.isGameCenterEnabled = false
                print("Game center is not enabled on the user's device")
                print(error ?? "error")
                let alert = UIAlertController(title: "Game Center", message: "Game center is not enabled on the user's device!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func submitScore(with value: Int) {
        guard isGameCenterEnabled else {
            print("Game Center Not Enabled")
            return
        }
        
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)
        GKScore.report([score]) { (error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
        }
    }

    func showGameOver() {
        let storyboard = self.storyboard
        let viewControllerGameOver = storyboard?.instantiateViewController(withIdentifier: "viewGameOver") as? ViewControllerGameOver
        viewControllerGameOver?.isGameCenterEnabled = self.isGameCenterEnabled
        viewControllerGameOver?.score = Int(count)
        viewControllerGameOver?.delegate = self
        
        if let viewControllerGameOver = viewControllerGameOver {
            present(viewControllerGameOver, animated: true)
        }
    }

    // Game Center UI
    @IBAction func buttonShowLeaderboard(_ sender: Any) {
        showLeaderboard()
    }

    func showLeaderboard() {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID
        self.show(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
    }
}

