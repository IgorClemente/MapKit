//
//  AppSingleton.swift
//  MinhasViagens
//
//  Created by MACBOOK AIR on 13/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import Foundation


var app: Singleton {
    return Singleton.shared
}

final class Singleton {
    
    static let shared = Singleton()
    private init() {}
    
    let ud = UserDefaults.standard
    
    func persistent(information info: Dictionary<String,String>,
                    completation: (Bool)->()) -> Void {
        var recovery = ud.object(forKey: "destinations") as? [Dictionary<String,String>] ?? [[:]]
        
        recovery.append(info)
        ud.setValue(recovery, forKey: "destinations")
        ud.synchronize()
        completation(true)
    }
    
    func recovery() -> [Dictionary<String,String>]? {
        return ud.object(forKey: "destinations") as? [Dictionary<String,String>]
    }
    
    func delete(registreFor i: Int?, completation:(Bool)->()) -> Void {
        guard var informationSalved = self.recovery(),
              let identifier = i else {
            completation(false)
            return
        }
        
        informationSalved.remove(at: identifier)
        ud.setValue(informationSalved, forKey: "destinations")
        ud.synchronize()
        completation(true)
    }
}
