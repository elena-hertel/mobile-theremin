//
//  WatchConnector.swift
//  Theremin
//
//  Created by Elena Hertel on 5/21/24.
//

import Foundation
import WatchConnectivity

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {
    @Published var messageReceived = false
    @Published var receivedMessage: [String: Any]?
    
    var session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
        
        if session.activationState != .activated {
            print("iOS session activation failed: \(session.activationState.rawValue)")
            // Handle the activation failure here
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("iOS session activated successfully.")
        } else {
            print("iOS session activation failed with state: \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iOS session deactivated")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.messageReceived = true
            self?.receivedMessage = message
        }
//        print("Message received from watch: \(message)")
    }
}
