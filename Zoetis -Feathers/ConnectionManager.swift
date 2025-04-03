//
//  ConnectionManager.swift
//  Zoetis -Feathers
//
//  Created by MobileProgramming on 27/04/22.
//
import Foundation
import Reachability

class ConnectionManager {

    static let shared = ConnectionManager()


    func hasConnectivity() -> Bool {
        do {
            let reachability: Reachability = try Reachability()
            let networkStatus = reachability.connection
            
            switch networkStatus {
            case .unavailable:
                return false
            case .wifi, .cellular:
                return true
            case .none:
                return false
            }
        }
        catch {
            return false
        }
    }
    /*
    func hasConnectivity() -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var isConnected = false
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isConnected = true
            } else {
                isConnected = false
            }
            monitor.cancel()
        }
        monitor.start(queue: queue)
        
        // Adding a small delay to allow the network check to complete
        usleep(100000) // 100 milliseconds
        return isConnected
    }
    */
}
