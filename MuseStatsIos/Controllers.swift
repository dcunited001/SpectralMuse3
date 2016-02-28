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

enum Visualization: String {
    case Colors = "colors"
    
    // can't work with the app delegate's ish directly ...
//    func registerListeners(appDelegate: AppDelegate, muse: IXNMuse) {
//        switch self {
//        case .Colors: break
////            muse.register
//        default: break;
//        }
//        
//    }
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

        }
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        muse?.unregisterAllListeners()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        let appDelegate = getAppDelegate()
        
        if let segueName = segue.identifier {
            switch segue.identifier! {
//            case "showColors": Visualization.Colors.registerListeners(appDelegate, muse: appDelegate.muse); break
            case "showCube": print("show cube"); break
            default: break
            }
        }
    }
    
    private func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
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
    
    private func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    private func setAppDelegateAndMuse() {
        
        // obtains a reference to appdelegate & muse
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if appDelegate!.muse == nil {
            print("muse is nil")
        } else {
            muse = appDelegate!.muse
        }

        //Can't seem to call this method no matter what i do
        // - no idea why something so fucking simple is so fucking complicated
        // - and i really have no idea who to ask to fix this,
        // - but i'm sure anyone with a year of objective-c experience could tell me
        // - ... 
        appDelegate!.setListenerCtrlDelegate(self)
    }
}

class MetalController: MuseController {
    
}

class ColorsController: MetalController {
    
}
