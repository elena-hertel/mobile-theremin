//
//  WatchToiOSConnector.swift
//  Theremin Watch App
//
//  Created by Elena Hertel on 5/21/24.
//

import Foundation
import WatchConnectivity

class WatchToiOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
        if session.activationState != .activated {
            print("Watch session activation failed: \(session.activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch session activation failed with error: \(error.localizedDescription)")
            return
        }
        
        if activationState == .activated {
            print("Watch session activated successfully")
        } else {
            print("Watch session activation failed with state: \(activationState.rawValue)")
        }
    }
    
    func sendFrequency (frequency : Double) {
        guard session.activationState == .activated else {
            print("Watch session is not activated.")
            return
        }
        
        if session.isReachable {
//            let message: [String: Double] = ["frequency": frequency]
            let message: [String: Double] = ["frequency": frequency, "timestamp": Date().timeIntervalSince1970]
            session.sendMessage(message, replyHandler: nil)
        } else {
            print("iPhone is not reachable.")
        }
    }
    
    func sendMessageToiOS () {
        guard session.activationState == .activated else {
            print("Watch session is not activated.")
            return
        }
        
        if session.isReachable {
            let message: [String: String] = ["message": "Hello iPhone"]
            session.sendMessage(message, replyHandler: nil)
        } else {
            print("iPhone is not reachable.")
        }
    }
}
