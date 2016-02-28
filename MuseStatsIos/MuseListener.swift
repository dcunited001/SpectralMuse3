//
//  MuseListener.swift
//  MuseStatsIos
//
//  Created by David Conner on 2/28/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

import Foundation

@objc class MuseListener: NSObject, IXNMuseDataListener, IXNMuseConnectionListener {
    
    weak var delegate: AnyObject? // ?? lulz
    
    init(delegate: AppDelegate) {
        self.delegate = delegate
    }
    
    func receiveMuseDataPacket(packet: IXNMuseDataPacket!) {
        switch packet.packetType {
        case .Battery: print("yo. battery's low."); break
        case .Accelerometer: break
        // case: alot of these
        default: break
        }
    }
    
    func receiveMuseArtifactPacket(packet: IXNMuseArtifactPacket!) {
        guard packet.headbandOn else {
            return
        }

        if packet.blink {
            print("it's a blink!")
        }
    }
    
    func receiveMuseConnectionPacket(packet: IXNMuseConnectionPacket!) {
        //holy shitty fuck!
        var state: String = "who the fuck knows!"
        switch packet.currentConnectionState {
        case .Unknown: state = "Unknown"; break
        case .NeedsUpdate: state = "Needs update"; break
        case .Connecting: state = "Connecting..."; break
        case .Connected: state = "Connected"; break
        case .Disconnected: state = "Disconnected"; break
        default: assert(false, "this shit is soooo fucked up and you know it"); break
        }
        
        print("Status: \(state)")
        
        if (packet.currentConnectionState == .Disconnected) {
            self.delegate?.performSelector("reconnectToMuse", withObject: nil, afterDelay: 0)
        }
        
        
    }
    
}