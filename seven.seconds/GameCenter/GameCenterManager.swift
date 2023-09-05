//
//  GameCenterManager.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 05.09.2023.
//

import UIKit
import AVFoundation
import GameKit

class GameCenterManager {
    static let shared = GameCenterManager()
    
    private var isGameCenterEnabled = false
    private var leaderboardID = "seven.seconds.leaderboard"
    
    private init() {}
    
    func authenticateLocalPlayer(completion: @escaping (Bool) -> Void) {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewControllerGame, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                completion(false)
                return
            }
            if viewControllerGame != nil {
                // Handle the case where authentication is required
                completion(false)
            } else if localPlayer.isAuthenticated {
                self.isGameCenterEnabled = true
                localPlayer.loadDefaultLeaderboardIdentifier { (leaderboardIdentifer, error) in
                    if let leaderboardID = leaderboardIdentifer, error == nil {
                        self.leaderboardID = leaderboardID
                        completion(true)
                    } else {
                        print(error ?? "error")
                        completion(false)
                    }
                }
            } else {
                self.isGameCenterEnabled = false
                print("Game center is not enabled on the user's device")
                print(error ?? "error")
                let alert = UIAlertController(title: "Game Center", message: "Game center is not enabled on the user's device!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                // Present the alert or perform other actions as needed
                completion(false)
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
    
    func showLeaderboard(viewController: UIViewController) {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID
        viewController.show(gcViewController, sender: viewController)
    }
    
    func gameCenterEnabled() -> Bool {
        return isGameCenterEnabled
    }
}
