//
//  ViewController.swift
//  Wee Coders
//
//  Created by Chuanxi Xiong on 4/5/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import UIKit

//  This is the first view of this app, which contains the title of the app and icons of three mini games. Texts and images are added in the interface builder.
//  This view can segue into three different views.
class ViewController: UIViewController {

    // MARK: Life Cycle
    // This is the given default method of the UIViewController class
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // This is the given default method of the UIViewController class
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Unwind Segue
    // These are the unwind segue methods. If the user clicks on the back button in the three game views, it will segue back into this view.
    @IBAction func unwindToMainPage(sender: UIStoryboardSegue) {
    }

    @IBAction func unwindToMainPageFromRainbow(sender: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToMainPageFromHSNT(sender: UIStoryboardSegue) {
        
    }
}

