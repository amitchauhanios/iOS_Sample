//
//  ViewController.swift
//  AdditionTest
//
//  Created by Amit on 23/08/22.
//

import UIKit
import Test
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let obj = AdditionTwoNumber()
        
        let add = obj.addNumber(num1: 5, num2: 5)
        
        print(add)
        // Do any additional setup after loading the view.
    }


    
    
    
}

