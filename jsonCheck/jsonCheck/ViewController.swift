//
//  ViewController.swift
//  jsonCheck
//
//  Created by Amit on 17/01/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        checkModel()
        // Do any additional setup after loading the view.
    }

    
    func checkModel(){
        if let path = Bundle.main.path(forResource: "CountryCodes", ofType: "json")
        {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String:Any]]
                print("state>>", jsonResult)
                
            }
            catch let error{
            }
        }
        else{
        }

    }
    
    

}

