//
//  ApiRequest.swift
//  ClashX
//
//  Created by CYC on 2018/7/30.
//  Copyright © 2018年 west2online. All rights reserved.
//

import Cocoa
import Alamofire



class ApiRequest{
    static let shared = ApiRequest()
    
    var trafficReq:DataRequest? = nil
    
    static func requestConfig(completeHandler:@escaping ((ClashConfig)->())){
        request(ConfigManager.apiUrl + "/configs", method: .get).responseData{
            res in
            guard let data = res.result.value else {return}
            let config = ClashConfig.fromData(data)
            completeHandler(config)
        }
    }
    
    func requestTrafficInfo(callback:@escaping ((Int,Int)->()) ){
        self.trafficReq?.cancel()
        
        self.trafficReq =
            request(ConfigManager.apiUrl + "/traffic").stream {(data) in
            if let jsonData = try? JSONSerialization.jsonObject(with: data) as? [String:Int] {
                callback(jsonData!["up"] ?? 0, jsonData!["down"] ?? 0)
            }
        }
    }
    
    static func requestConfigUpdate(callback:@escaping ((Bool)->())){
        let success = updateAllConfig()
        callback(success==0)
    }
    
    static func requestUpdateConfig(newConfig:ClashConfig?, callback:@escaping ((Bool)->())) {
        guard (newConfig != nil) else {
            callback(false)
            return
        }
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(newConfig)
        
        let url = URL(string:ConfigManager.apiUrl + "/configs")!
        var req = URLRequest(url: url)
        req.httpMethod = HTTPMethod.put.rawValue
        req.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = jsonData
        
        request(req).responseJSON { response in
            switch response.result {
            case .success(_):
                callback(true)
            case .failure(_):
                callback(false)
            }
        }
    }
}
