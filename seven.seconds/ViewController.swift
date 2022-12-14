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
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addItemViewController(_ controller: ViewControllerGameOver?, didFinishEnteringItem item: String?) {
        damageBeep?.play()
        
        labelPrevious.text = item
        start = false

        initGame()
        //rotateButton(22)
        
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
    
    let emitterNode = SKEmitterNode(fileNamed: "sparks.sks")!
    var skView: SKView = SKView()
    var scene: SKScene = SKScene()
    
    var animation: CABasicAnimation? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        authenticateLocalPlayer()
        
        impactMed = UIImpactFeedbackGenerator(style: .heavy)
        impactMed?.prepare()
        
        //Background static
         var bounds: CGRect = view.bounds
        bounds.size.width += 0
        bounds.size.height += 0
        
        let background = UIImage(named: "santa_light.png")
        var imageView : UIImageView!
        imageView = UIImageView(frame: bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        //renderBlur(viewTarget: imageView, isDark: true)
        
        createSmallSparks()
        addSparks()
        createSparks()
        //addParallaxToView(vw: view)
        //createFire()
        
        buttonBeep = setupAudioPlayer(withFile: "button", type: "wav")
        damageBeep = setupAudioPlayer(withFile: "damage", type: "wav")
        explodeBeep = setupAudioPlayer(withFile: "explode", type: "wav")

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

        //infiniteScroll(duration: 20.0)
    }
    
    func infiniteScroll(duration: CGFloat) {
        let backgroundImage = UIImage(named: "2022.jpg")!
        let backgroundPattern = UIColor(patternImage: backgroundImage)

        let background = CALayer()
        background.backgroundColor = backgroundPattern.cgColor
        background.transform = CATransform3DMakeScale(1, -1, 1)
        background.anchorPoint = CGPoint(x: 0, y: 1)
        background.name = "background"
 
        let viewSize = self.view.layer.bounds.size
        background.frame = CGRect(x: 0, y: 0, width: viewSize.width, height: backgroundImage.size.height + viewSize.height)
        view.layer.insertSublayer(background, at: 0)

        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: -backgroundImage.size.height)
        
        animation = CABasicAnimation(keyPath: "position")
        guard let animation = self.animation else { return }
        
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fromValue = NSValue(cgPoint: endPoint)
        animation.toValue = NSValue(cgPoint: startPoint)
        animation.repeatCount = .greatestFiniteMagnitude
        animation.duration = duration
        background.add(animation, forKey: "position")
    }
    
    func initGame() {
        seconds = 7
        count = 0

        labelTimer.textColor = UIColor.white

        labelTimer.text = String(format: "Time left: %li seconds", Int(seconds))
        labelValue.text = String(format: "%li", Int(count))
        labelScore.text = "YOUR SCORE IS"
        
        //let imageNormal = UIImage(named: "button_normal.png")
        buttonPushIt.setImage(nil, for: .normal)
        
        //let imageSelected = UIImage(named: "button_pressed.png")
        buttonPushIt.setImage(nil, for: .highlighted)
        
        self.view.viewWithTag(4)?.isHidden = true
        
        labelLeaderboard.isHidden = false
        buttonHighScores.isHidden = false
    }
    
    func setupGame() {
        initGame()
        self.view.viewWithTag(4)?.isHidden = false
        
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
        
        /*var fireY = CGFloat(-2 * count)
        if (fireY < -100) {
            fireY = -100
        }
        fireEmitter?.transform = CATransform3DMakeTranslation(0, fireY, 0)*/
        
        //self.view.viewWithTag(4)?.isHidden = false
        
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
    
    private func addSparks() {
        skView = SKView(frame: view.frame)
        scene = SKScene(size: view.frame.size)
        
        skView.backgroundColor = .clear
        scene.backgroundColor = .clear
        
        skView.presentScene(scene)
        skView.isUserInteractionEnabled = false
        
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.addChild(emitterNode)
        
        //emitterNode.position.x = scene.frame.maxX - buttonPushIt.frame.height - 0
        //emitterNode.position.y = scene.frame.midY
        
        emitterNode.position.x = scene.frame.maxX - buttonPushIt.frame.height / 2 - 20
        emitterNode.position.y = scene.frame.midY - buttonPushIt.frame.width / 2 + 20
        
        skView.tag = 4
        view.addSubview(skView)
        self.view.viewWithTag(4)?.isHidden = true
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
    
    func rotateButton(_ duration: Int) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = NSNumber(value: 0)
        rotation.toValue = NSNumber(value: (360 * Double.pi) / 180)
        rotation.duration = CFTimeInterval(duration)
        rotation.repeatCount = .infinity
        buttonPushIt.layer.add(rotation, forKey: "360")
    }
    
    func createFire() {
        fireEmitter = CAEmitterLayer()
        fireEmitter?.name = "fire"

        fireEmitter?.emitterPosition.x = viewMain.frame.midX
        fireEmitter?.emitterPosition.y = viewMain.frame.maxY + 100
        
        fireEmitter?.emitterSize = CGSize(width: viewMain.frame.maxX / 1.5, height: 10);
        fireEmitter?.renderMode = CAEmitterLayerRenderMode.additive;
        fireEmitter?.emitterShape = CAEmitterLayerEmitterShape.line
        fireEmitter?.emitterCells = [createFireCell()];
        
        self.view.layer.addSublayer(fireEmitter!)
    }
    
    func createSmallSparks() {
        guard let image = UIImage(named: "snow.png")?.cgImage else { fatalError("Failed loading image.") }
        
        emitterLayerGlobal = CAEmitterLayer(layer: image)
        emitterLayerGlobal?.name = "Emitter"
        
        emitterLayerGlobal?.emitterPosition.x = viewMain.frame.midX - 10
        emitterLayerGlobal?.emitterPosition.y = -50
        
        let color = CGColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1);
        emitterCellGlobal.color = color
        emitterCellGlobal.name = "cell"
        emitterCellGlobal.birthRate = 120
        emitterCellGlobal.lifetime = 20
        emitterCellGlobal.velocity = 42

        emitterCellGlobal.scale = 0.05
        emitterCellGlobal.scaleRange = 0.1
        emitterCellGlobal.emissionRange = CGFloat.pi * 2.0
        emitterCellGlobal.contents = image
        
        emitterLayerGlobal?.emitterCells = [emitterCellGlobal]
        viewMain.layer.addSublayer(emitterLayerGlobal!)
    }
    
    func createSparks() {
        guard let image = UIImage(named: "spark.png")?.cgImage else { fatalError("Failed loading image.") }
        
        emitterLayer = CAEmitterLayer(layer: image)
        emitterLayer?.name = "Emitter"
        
        emitterLayer?.emitterPosition.x = (viewMain?.frame.maxX)! -
            buttonPushIt.frame.height / 2 - 10
        emitterLayer?.emitterPosition.y = viewMain.frame.midY +
            buttonPushIt.frame.height / 2 - 40
        
         let newColor = CGColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1);
         emitterCell.color = newColor
         emitterCell.name = "cell"
         emitterCell.birthRate = 20
         emitterCell.lifetime = 16
         emitterCell.velocity = 22
         
         emitterCell.scale = 0.18
         emitterCell.scaleRange = 0.2
         emitterCell.emissionLongitude = .pi / 2.0
         emitterCell.emissionRange = CGFloat.pi / 4.0
         emitterCell.contents = image
        
        emitterLayer?.emitterCells = [emitterCell]
        viewMain.layer.addSublayer(emitterLayer!)
    }
    
    func createFireCell() -> CAEmitterCell {
        let fire = CAEmitterCell();
        fire.alphaSpeed = -0.3
        fire.birthRate = 600;
        fire.lifetime = 60.0;
        fire.lifetimeRange = 0.5
        fire.color = UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 0.6).cgColor
        fire.contents = UIImage(named: "fire")?.cgImage
        fire.emissionLongitude = CGFloat(Double.pi);
        fire.velocity = 80;
        fire.velocityRange = 5;
        fire.emissionRange = 0.5;
        fire.yAcceleration = -200;
        fire.scaleSpeed = 0.3;
        
        return fire
    }
    
    func setupAudioPlayer(withFile file: String?, type: String?) -> AVAudioPlayer? {
        let path = Bundle.main.path(forResource: file, ofType: type)
        let url = URL(fileURLWithPath: path ?? "")

        var _: Error?

        var audioPlayer: AVAudioPlayer? = nil
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
        }

        return audioPlayer
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
