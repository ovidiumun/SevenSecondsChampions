//
//  ViewController.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 2/26/21.
//

import UIKit
import AVFoundation
import QuartzCore
import GameKit

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

class ViewController: UIViewController, ViewControllerGameOverDelegate, GKGameCenterControllerDelegate {
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
    
    @IBAction func buttonShowLeaderboard(_ sender: Any) {
        showLeaderboard()
    }
    
    var isGameCenterEnabled: Bool = false
    var leaderboardID = "seven.seconds.leaderboard"
    
    var impactMed: UIImpactFeedbackGenerator? = nil
    var fireEmitter: CAEmitterLayer? = nil
    
    var emitterLayerGlobal: CAEmitterLayer? = nil
    var emitterCellGlobal = CAEmitterCell()
    
    var emitterLayer: CAEmitterLayer? = nil
    var emitterCell = CAEmitterCell()
    
    var count = 0
    var seconds = 0
    var timer: Timer?
    var start = false
    var buttonBeep: AVAudioPlayer?
    var damageBeep: AVAudioPlayer?
    var explodeBeep: AVAudioPlayer?
    var backgroundMusic: AVAudioPlayer?
    var score = 0
    
    //let emitterNode = SKEmitterNode(fileNamed: "sparks.sks")!
    //var skView: SKView = SKView()
    //var scene: SKScene = SKScene()
    
    var animation: CABasicAnimation? = nil
    
    var fx: FxProtocol = Fx()
    var sparks: SparksProtocol = Sparks()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        authenticateLocalPlayer()
        
        impactMed = UIImpactFeedbackGenerator(style: .heavy)
        impactMed?.prepare()

        var imageView = fx.setBackgroundImageView(bounds: view.bounds, center: view.center)
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        fx.renderBlur(viewTarget: imageView, isDark: true)
        fx.addParallaxToView(vw: view)
        
        sparks.createSmallSparks(emitterLayerGlobal: &emitterLayerGlobal, emitterCellGlobal: emitterCellGlobal, view: viewMain)
        sparks.createSparks(emitterLayer: &emitterLayer, emitterCell: emitterCell, view: viewMain, button: buttonPushIt)
        
        buttonBeep = fx.setupAudioPlayer(withFile: "button", type: "wav")
        damageBeep = fx.setupAudioPlayer(withFile: "damage", type: "wav")
        explodeBeep = fx.setupAudioPlayer(withFile: "explode", type: "wav")

        labelTitleSeven.textColor = UIColor.white
        labelTitleSeconds.textColor = UIColor.white
        labelSubtitle.textColor = UIColor.white
        labelTimer.textColor = UIColor.white
        labelScore.textColor = UIColor.white
        labelValue.textColor = UIColor.white
        labelPoints.textColor = UIColor.white
        labelPrevious.textColor = UIColor.white
        labelLeaderboard.textColor = UIColor.white
        labelPrevious.text = String(format: "Previous score: %li hits", Int(score))

        start = false
        initGame()
        
        guard isGameCenterEnabled else {
            print("Game Center Not Enabled")
            
            labelLeaderboard.isHidden = true
            buttonHighScores.isHidden = true
            
            return
        }
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground

    }
    
    func initGame() {
        seconds = 7
        count = 0

        labelTimer.textColor = UIColor.white

        labelTimer.text = String(format: "Time left: %li seconds", Int(seconds))
        labelValue.text = String(format: "%li", Int(count))
        labelScore.text = "YOUR SCORE IS"
        
        let imageNormal = UIImage(named: "button_normal.png")
        buttonPushIt.setImage(imageNormal, for: .normal)
        
        let imageSelected = UIImage(named: "button_pressed.png")
        buttonPushIt.setImage(imageSelected, for: .highlighted)
        
        labelLeaderboard.isHidden = false
        buttonHighScores.isHidden = false
    }
    
    func setupGame() {
        initGame()

        labelLeaderboard.isHidden = true
        buttonHighScores.isHidden = true
        
        emitterLayerGlobal?.setValue(
            NSNumber(value: 88),
            forKeyPath: "emitterCells.cellGlobal.velocity")
        
        buttonBeep?.play()
        labelTimer.textColor = UIColor(red: 255.0/255, green: 94.0/255, blue: 19.0/255, alpha: 1)

        start = true
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(self.subtractTime),
            userInfo: nil,
            repeats: true)
    }

    @IBAction func buttonPressed() {
        if start == false {
            setupGame()
        }

        count += 1
        labelValue.text = String(format: "%li", Int(count))
        
        emitterLayer?.setValue(
            NSNumber(value: count * 2),
            forKeyPath: "emitterCells.cell.birthRate")
        
        emitterLayer?.setValue(
            NSNumber(value: 22 + count * 4),
            forKeyPath: "emitterCells.cell.velocity")
        
        impactMed?.impactOccurred()
    }
    
    
    @IBAction func buttonUpInside(_ sender: Any) {
        //self.view.viewWithTag(4)?.isHidden = true
    }
    
    
    @IBAction func buttonUpOutside(_ sender: Any) {
        //self.view.viewWithTag(4)?.isHidden = true
    }
    
    @objc func subtractTime() {
        if start == true {
            seconds -= 1

            labelTimer.text = String(format: "Time left: %li seconds", Int(seconds))
            buttonBeep?.play()
            
            if seconds > 3 {
                let newColor = CGColor(red: 255.0/255.0, green: 94.0/255.0, blue: 19.0/255.0, alpha: 1);
                emitterLayer?.setValue(
                    newColor,
                    forKeyPath: "emitterCells.cell.color")
            }
            
            if seconds <= 3 {
                labelScore.text = "HIT FASTER !!!!!"
                labelTimer.textColor = UIColor(red: 255.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1)
                
                let newColor = CGColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1);
                emitterLayer?.setValue(
                    newColor,
                    forKeyPath: "emitterCells.cell.color")
            }

            if seconds == 0 {
                explodeBeep?.play()
                
                timer?.invalidate()
                start = false
                
                if ((isGameCenterEnabled == true) && (count < 180)) {
                    self.submitScore(with: count)
                }
                
                let storyboard: UIStoryboard? = self.storyboard
                let viewControllerGameOver = storyboard?.instantiateViewController(withIdentifier: "viewGameOver") as? ViewControllerGameOver
                viewControllerGameOver?.isGameCenterEnabled = self.isGameCenterEnabled
                viewControllerGameOver?.score = Int(count)
                viewControllerGameOver?.birthRate = Float(count)
                viewControllerGameOver?.velocity = CGFloat(22 + count * 4)
                viewControllerGameOver?.delegate = self

                if let viewControllerGameOver = viewControllerGameOver {
                    present(viewControllerGameOver, animated: true)
                }
            }
        }
    }
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewControllerGame, error in
            guard error == nil else {
              print(error?.localizedDescription ?? "")
              return
            }
            
            if viewControllerGame != nil {
                self.present(viewControllerGame!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.isGameCenterEnabled = true

                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                 if error != nil { print(error ?? "error")
                    } else {
                        self.leaderboardID = leaderboardIdentifer!
                    }
                })
                
                self.isGameCenterEnabled = true
                print("Adding GameCenter user was a success")
            } else {
                // 3. Game center is not enabled on the users device
                self.isGameCenterEnabled = false
                print("Game center is not enabled on the users device")
                print(error ?? "error")
                
                let alert = UIAlertController(title: "Game Center", message: "Game center is not enabled on the users device!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (alertAction) in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func submitScore(with value: Int) {
        // Submit score to GC leaderboard
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
    
    func showLeaderboard() {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID
        self.show(gcViewController, sender: self)
        self.navigationController?.pushViewController(gcViewController, animated: true)
         // self.presentViewController(gcViewController, animated: true, completion: nil)
    }
}

