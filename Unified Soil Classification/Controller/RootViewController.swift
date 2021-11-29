//
//  ViewController.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 3.10.2021.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    @IBAction func evaluatePressed(_ sender: UIButton) {
        sender.alpha = 0.4
        Timer.scheduledTimer(withTimeInterval: 0.15 , repeats: false ) { timer in
            sender.alpha = 1
        }
    }
    
    @IBAction func mySamplesPressed(_ sender: UIButton) {
        sender.alpha = 0.4
        Timer.scheduledTimer(withTimeInterval: 0.15 , repeats: false ) { timer in
            sender.alpha = 1
        }
    }
}

