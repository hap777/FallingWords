//
//  ViewController.swift
//  FallingWords
//
//  Created by Hossein Asadi on 3/24/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var startBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        startBtn.setupPrimary(color: .systemGreen)
    }


}

