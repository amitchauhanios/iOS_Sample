//
//  File.swift
//  BabySizeMe
//
//  Created by Ongraph Technologies on 19/04/22.
//

import UIKit

class MyTabBarCtrl: UITabBarController, UITabBarControllerDelegate {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        //MARK: - Setting UP UI For Tabbar
        
        let layer = CAShapeLayer()
            layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: tabBar.bounds.minY - 5, width: tabBar.bounds.width , height: tabBar.bounds.height + 50), cornerRadius: 22).cgPath
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
            layer.shadowRadius = 25.0
            layer.shadowOpacity = 0.3
            layer.borderWidth = 1.0
            layer.opacity = 1.0
            layer.isHidden = false
            layer.masksToBounds = false
            layer.fillColor = UIColor.white.cgColor
            tabBar.layer.insertSublayer(layer, at: 0)
            if let items = tabBar.items {
                items.forEach { item in
                    item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
            }
        tabBar.tintColor = UIColor(red: 0/255.0, green: 185/255.0, blue: 230/255.0, alpha: 1)
        tabBar.itemWidth = 23.0
   }
    
    //MARK: - For Dismisiing The presented VC So that there's no black screen issue left
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            if let currentlySelectedViewController = self.viewControllers?[self.selectedIndex] as? UIViewController,
               let presentedViewController = currentlySelectedViewController.presentedViewController {
                presentedViewController.dismiss(animated: false, completion: nil)
            }
            return true
        }
    
}


