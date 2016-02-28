//
//  ViewController.swift
//  MuseStatsIos
//
//  Created by David Conner on 2/28/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//
import Foundation
import UIKit

// MuseController obtains reference to AppDelegate's muse via the muse manager
// - in setup, muse controller registers handlers for events
// - if muse controller goes offline or whatever, it unregisters all listeners

enum Visualizations: String {
    case Colors = "colors"
    
    func registerListeners(muse: IXNMuse) {
        switch self {
        case .Colors:
            muse.register
        }
    }
}

class MenuController: UITableViewController {
    
    weak var muse: IXNMuse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // obtains a reference to muse & 
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if appDelegate.muse == nil {
            print("muse is nil")
        } else {
            muse = appDelegate.muse
        }
        
        if appDelegate.loggingListener == nil {
            
        }
        
        
        muse?.unregisterAllListeners()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        muse?.unregisterAllListeners()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let segueName = segue.identifier {
            switch segue.identifier! {
            case "showColors": print("show colors"); break
            case "showCube": print("show cube"); break
            default: break
            }
        }
    }
    
}

class MuseController: UIViewController {
    
    var museListener: MuseListener!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class MetalController: MuseController {
    
}

class ColorsController: MetalController {
    
}
