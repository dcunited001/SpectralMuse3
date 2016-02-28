//
//  ViewController.swift
//  MuseStatsIos
//
//  Created by David Conner on 2/28/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//
import Foundation
import UIKit
import MetalKit

class MuseView: MetalView {
    
    // TODO: update to iOS 9.3
    //    var plane = MDLMesh.newPlaneWithDimensions(vector_float2(100.0,100.0), segments: vector_uint2(11,11), geometryType: .Triangles) // allocator?
    var ellipsoid = MDLMesh.newEllipsoidWithRadii([50.0, 30.0, 75.0], radialSegments: 30, verticalSegments: 20, geometryType: .TypeTriangles, inwardNormals: true, hemisphere: false, allocator: nil)  // allocator?
    var icosohedron = MDLMesh.newIcosahedronWithRadius(100.0, inwardNormals: true, allocator: nil) // allocator?
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        
        renderBlock = {(encoder) in
            // pull mesh data from shapes, insert into buffers
        }
    }
    
}

class MuseController: UIViewController, MuseListenerCtrlDelegate {
    
    var renderer: MuseRenderer!
    var metalView: MetalView!
    
    weak var muse: IXNMuse?
    weak var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rect = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        renderer = MuseRenderer()
        metalView = TexturedQuadView(frame: rect, device: MTLCreateSystemDefaultDevice())
        renderer.configure(metalView)
        positionObjects()
        metalView.metalViewDelegate = renderer
        
        self.view.addSubview(metalView)
        metalView.hidden = true
        // TODO: setupGestures()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    }
    
    func positionObjects() {
        // 
    }
}

class MuseRenderer: BaseRenderer {
    
}

