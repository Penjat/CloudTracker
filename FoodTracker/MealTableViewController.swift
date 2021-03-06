

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var meals = [Meal]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
      
        // Load any saved meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            //meals += savedMeals
          
        }
        else {
            // Load the sample data.
            //loadSampleMeals()
          
        }
    }
  override func viewDidAppear(_ animated: Bool) {
    loadMealsFromNetwork()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        meal.mealImage.getImage(imageView: cell.photoImageView)
        cell.ratingControl.rating = meal.rating
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
  @IBAction func pressedLogout(_ sender: Any) {
    print("pressed logout")
    //remove all user defaults
    UserDefaults.standard.removeObject(forKey: "username")
    UserDefaults.standard.removeObject(forKey: "password")
    UserDefaults.standard.removeObject(forKey: "token")
    //segue to sign in view
    performSegue(withIdentifier: "backToSignIn", sender: self)
    
  }
  

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        case "backToSignIn":
          print("back to sign in, don't freak out")
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
  func loadMealsFromNetwork(){
    
    let body = [String:Any]()
    let closure = {(json:[[String:Any]]? )->Void in
      print("converting json to meals \(json)")
      self.jsonToMeals(json:json)
    }
    let token = UserDefaults.standard.object(forKey: "token") as! String
    APIManager.getRequest(body: body, suffix: "/users/me/meals", closure: closure, token: token  )
  }
  
  func jsonToMeals(json:[[String:Any]]?){
    print("converting json to meals \(json)")
    
    //Not efficient but ok
    meals.removeAll()
    for jsonMeal in json! {
      let title = jsonMeal["title"] as! String
      let calories = jsonMeal["calories"] as! Int
      let description = jsonMeal["description"] as! String
      let imageUrl = (jsonMeal["imagePath"] as? String != nil) ? jsonMeal["imagePath"] as! String : ""
      let mealImage = MealImage(urlString:imageUrl)
      let rating =  ((jsonMeal["rating"] as? Int) != nil) ? jsonMeal["rating"] as! Int : 0
      
      let meal = Meal(name: title , mealImage: mealImage, rating: rating , cals:calories , mealDescription:description)
      
      meals.append(meal!)
    }
    tableView.reloadData()
  }
    
    //MARK: Actions
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the meals.
            saveMeals()
        }
    }
    
    //MARK: Private Methods
    
    private func loadSampleMeals() {
        
//        let photo1 = UIImage(named: "meal1")
//        let photo2 = UIImage(named: "meal2")
//        let photo3 = UIImage(named: "meal3")
//
//      guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4 , cals:33 , mealDescription:"hi") else {
//            fatalError("Unable to instantiate meal1")
//        }
//
//        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5 , cals:33 , mealDescription:"hi") else {
//            fatalError("Unable to instantiate meal2")
//        }
//
//        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3 , cals:33 , mealDescription:"hi") else {
//            fatalError("Unable to instantiate meal2")
//        }
//
//        meals += [meal1, meal2, meal3]
    }
    
    private func saveMeals() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMeals() -> [Meal]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }

}
