

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
    if let _ = UserDefaults.standard.object(forKey: "password") , let username = UserDefaults.standard.object(forKey: "username") , let token = UserDefaults.standard.object(forKey: "token"){
      print("user info found, logging in \(username)")
      performSegue(withIdentifier: "fromLogin", sender: self)
      print("token is \(token)")
    }else{
      print("user info not found, please log in or sign up")
    }
  }

  @IBAction func pressedLogIn(_ sender: Any) {
    let myData = [
      "username": usernameTextField.text ?? "",
      "password": passwordTextField.text ?? ""
    ]
    let completionClosure = {(json:[String:Any]?)->Void in
      print("the closure is running")
      
      if let json = json , let username = json["username"] , let password = json["password"] , let token = json["token"]{
        
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(token, forKey: "token")
        
        self.performSegue(withIdentifier: "fromLogin", sender: self)
        
      }
    }
    APIManager.postRequest(body: myData, suffix: "/login", closure:completionClosure )
    
  }
  @IBAction func pressedSignUp(_ sender: Any) {
    
    let myData = [
      "username": usernameTextField.text ?? "",
      "password": passwordTextField.text ?? ""
    ]
    let completionClosure = {(json:[String:Any]?)->Void in
      print("the closure is running")
      if let json = json , let username = json["username"] , let password = json["password"] , let token = json["token"]{
        
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.set(token, forKey: "token")
        
        self.performSegue(withIdentifier: "fromLogin", sender: self)
        
      }
    }
    APIManager.postRequest(body: myData, suffix: "/signup", closure:completionClosure )
    
    
    
  }
  
  
  
  
}
