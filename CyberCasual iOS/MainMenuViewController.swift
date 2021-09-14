//
//  MainMenuViewController.swift
//  CyberCasual iOS
//
//  Created by Александр Бисеров on 5/10/21.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "playSegue", sender: nil)
    }
}
