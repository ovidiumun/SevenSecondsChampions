//
//  GameCenterFactory.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 05.09.2023.
//

import UIKit
import GameKit

class GameCenterFactory {
    static let shared = GameCenterFactory()
    
    private init() {}
    
    // Show the Game Center leaderboard
    func showLeaderboard(viewController: UIViewController, leaderboardID: String) {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        gcViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID
        
        viewController.show(gcViewController, sender: viewController)
    }
    
    // Report an achievement to Game Center
    func reportAchievement(achievement: String, percentComplete: Double) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player not authenticated.")
            return
        }
        
        let achievement = GKAchievement(identifier: achievement)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { (error) in
            if let error = error {
                print("Error reporting achievement: \(error.localizedDescription)")
            }
        }
    }
    
    // Show the Game Center achievements
    func showAchievement(viewController: UIViewController) {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        gcViewController.viewState = .achievements
        viewController.present(gcViewController, animated: true, completion: nil)
    }
}

