

import UIKit

class SignInViewController: UIViewController {
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var statusLabel: UILabel!
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  override func viewDidAppear(_ animated:Bool) {
    super.viewDidAppear(false)
    print("checking for username and password...")
    if let _ = UserDefaults.standard.object(forKey: "password") , let username = UserDefaults.standard.object(forKey: "username") , let _ = UserDefaults.standard.object(forKey: "token"){
      print("user info found, logging in \(username)")
      performSegue(withIdentifier: "fromLogin", sender: self)
      
    }else{
      print("user info not found, please log in or sign up")
    }
  }

  @IBAction func pressedLogIn(_ sender: Any) {
    let postData = [
      "username": usernameTextField.text ?? "",
      "password": passwordTextField.text ?? ""
    ]
    
    guard let postJSON = try? JSONSerialization.data(withJSONObject: postData, options: []) else {
      print("could not serialize json")
      return
    }
    
    let url = URL(string: "https://cloud-tracker.herokuapp.com/login")!
    let request = NSMutableURLRequest(url: url)
    request.httpBody = postJSON
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
      print("the json is \(json)")
      if let username = json?["username"] , let password = json?["password"] , let token = json?["token"]{
        
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(token, forKey: "token")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.performSegue(withIdentifier: "fromLogin", sender: self)
        }
      }
    }
    // do something with the json object
    task.resume()
  }
  @IBAction func pressedSignUp(_ sender: Any) {
    let postData = [
      "username": usernameTextField.text ?? "",
      "password": passwordTextField.text ?? ""
    ]
    
    guard let postJSON = try? JSONSerialization.data(withJSONObject: postData, options: []) else {
      print("could not serialize json")
      return
    }
    
    let url = URL(string: "https://cloud-tracker.herokuapp.com/signup")!
    let request = NSMutableURLRequest(url: url)
    request.httpBody = postJSON
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
        
        if response.statusCode == 409{
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.statusLabel.text = "user \(self.usernameTextField.text ?? "") already exists"
          }
          
        }
        print("an error occurred \(response.statusCode) \(String(describing: json?["error"]))")
        return
      }
      print("the json is \(json)")
      if let username = json?["username"] , let password = json?["password"] , let token = json?["token"]{
        
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(token, forKey: "token")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.performSegue(withIdentifier: "fromLogin", sender: self)
        }
      }
      
    }
    // do something with the json object
    task.resume()
  }
  
  
  
  
}
