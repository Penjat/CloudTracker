//
//  APIManager.swift
//  FoodTracker
//
//  Created by Spencer Symington on 2019-02-18.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

class APIManager{
  
  static func postRequest(body:[String:Any] , suffix:String ,closure: @escaping  ([String:Any]?) -> Void , token: String = ""){
    
    
    
    guard let postJSON = try? JSONSerialization.data(withJSONObject: body, options: []) else {
      print("could not serialize json")
      return
    }
    
    let url = URL(string: "https://cloud-tracker.herokuapp.com\(suffix)")!
    let request = NSMutableURLRequest(url: url)
    request.httpBody = postJSON
    request.httpMethod = "POST"
    //    request.allHTTPHeaderFields = ["":""]
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "token")
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
      
      guard let data = data else {
        print("no data returned from server \(String(describing: error?.localizedDescription))")
        return
      }
      
      guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String,Any> else {
        print("data returned is not json, or not valid")
        return
      }
      
      guard let response = response as? HTTPURLResponse else {
        print("no response returned from server \(String(describing: error))")
        return
      }
      
      guard response.statusCode == 200 else {
        // handle error
        
        print("an error occurred \(String(describing: json?["error"]))")
        return
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        closure(json)
      }
      
    }
    task.resume()
  }
  
  static func getRequest(body:[String:Any] , suffix:String ,closure: @escaping  ([[String:Any]]?) -> Void , token: String = ""){
    
    print("performing get request...")
    
    guard let postJSON = try? JSONSerialization.data(withJSONObject: body, options: []) else {
      print("could not serialize json")
      return
    }
    
    let url = URL(string: "https://cloud-tracker.herokuapp.com\(suffix)")!
    let request = NSMutableURLRequest(url: url)
    //request.httpBody = postJSON
    request.httpMethod = "GET"
    //    request.allHTTPHeaderFields = ["":""]
    //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "token")
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
      
      guard let data = data else {
        print("no data returned from server \(String(describing: error?.localizedDescription))")
        return
      }
      
      guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] else {
//        print("data returned is not json, or not valid \(String.init(describing: json))")
        return
      }
      
      guard let response = response as? HTTPURLResponse else {
        print("no response returned from server \(String(describing: error))")
        return
      }
      
      guard response.statusCode == 200 else {
        // handle error
        
        print("an error occurred \(String(describing: json))")
        return
      }
      
      print("running closure")
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        closure(json)
      }
      
    }
    task.resume()
  }
  
  static func postImage(image:UIImage , closure:@escaping (String)->Void){
    
    //let image = UIImage(named: "bb.png")
    let data = UIImagePNGRepresentation(image)
    
    
    
    let headers = [
      "Authorization": "Client-ID 887c27b7d390539",
      "Content-Type": "application/x-www-form-urlencoded",
      "cache-control": "no-cache",
      "Postman-Token": "a67afcfb-784e-42e5-affc-beef0e8a24b4"
      
    ]
    
    let request = NSMutableURLRequest(url: NSURL(string: "https://api.imgur.com/3/image")! as URL,
                                      cachePolicy: .useProtocolCachePolicy,
                                      timeoutInterval: 10.0)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = headers
    request.httpBody = data
    let session = URLSession.shared
    let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
      if (error != nil) {
        print(error)
      } else {
        let httpResponse = response as? HTTPURLResponse
        print(httpResponse)
        
        guard let jsonUnformatted = try? JSONSerialization.jsonObject(with: data!, options: []), let json = jsonUnformatted as? [String:Any] else {
                 print("data returned is not json, or not valid ")
          return
        }
        print("the json = \(json)")
        if let responsData = json["data"] as? [String:Any], let urlString =  responsData["link"] as? String{
          
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            closure(urlString)
          }
        }else{
          print("error, was not able to upload meal photo")
        }
        
        
      }
    })
    
    dataTask.resume()
  }
}
