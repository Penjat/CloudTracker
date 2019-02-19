

import UIKit
import os.log


class Meal {
  
  //MARK: Properties
  
  var name: String
  var mealImage: MealImage
  var rating: Int
  var cals: Int
  var mealDescription: String
  
  //MARK: Archiving Paths
  static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
  
  
  
  
  //MARK: Initialization
  
  init?(name: String, mealImage: MealImage, rating: Int , cals:Int , mealDescription:String) {
    
    // The name must not be empty
    guard !name.isEmpty else {
      return nil
    }
    
    // The rating must be between 0 and 5 inclusively
    guard (rating >= 0) && (rating <= 5) else {
      return nil
    }
    
    // Initialization should fail if there is no name or if the rating is negative.
    if name.isEmpty || rating < 0  {
      return nil
    }
    
    // Initialize stored properties.
    self.name = name
    self.mealImage = mealImage
    self.rating = rating
    self.cals = cals
    self.mealDescription = mealDescription
    
  }
  
  
}
