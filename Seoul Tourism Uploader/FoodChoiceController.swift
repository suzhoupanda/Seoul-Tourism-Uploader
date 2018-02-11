//
//  FoodChoiceController.swift
//  Seoul Tourism Uploader
//
//  Created by Aleksander Makedonski on 2/10/18.
//  Copyright © 2018 Aleksander Makedonski. All rights reserved.
//

import Foundation
import UIKit

class FoodChoiceController:UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var foodChoiceLabel: UILabel!
    
    @IBAction func showImagesButton(_ sender: Any) {
        
        if chosenFood != nil{
            
            performSegue(withIdentifier: "showFoodImages", sender: nil)

        } else {
            //TODO: notify user that they must select a food
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let userChosenFood = self.chosenFood else {
            //TODO: notify user
            return
        }
        
        if segue.identifier == "showFoodImages"{
            
            if let foodImageController = segue.destination as? FoodImageController{
                
                 foodImageController.chosenFood = userChosenFood
            }
        }
    }
    
    var foodChoices = NSMutableSet()
    
    var foodChoiceArray: Array<String>!
    
    var chosenFood: String?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        loadFoodChoices()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CKHelper.sharedHelper.container.accountStatus(){
            
            status, error in
            
            if(error != nil){
                print(error!.localizedDescription)
            } else {
                
                switch status{
                case .available:
                    print("Available")
                    break
                case .couldNotDetermine:
                    print("Could not determine")
                    break
                case .noAccount:
                    print("No account")
                    break
                case .restricted:
                    print("Restricted")
                    break
                    
                    
                    
                }
            }
    
        
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func loadFoodChoices(){
        let path = Bundle.main.path(forResource: "FlickrFoods", ofType: "plist")!
        
        if let dicts = NSArray(contentsOfFile: path) as? Array<Dictionary<String,String>>{
            for dict in dicts{
                if let searchTerm = dict["searchTerm"]{
                    foodChoices.add(searchTerm)
                }
            }
        }
        
        self.foodChoiceArray = (self.foodChoices.allObjects as! [String]).sorted(by: <)
        
        
        self.tableView.reloadData()
       
    
    }
}

extension FoodChoiceController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.foodChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodChoiceCell") as! UITableViewCell
        
        cell.textLabel?.text = self.foodChoiceArray[indexPath.row]
        
        return cell
    }
    
    
    
    
}

extension FoodChoiceController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.chosenFood = self.foodChoiceArray[indexPath.row]
        
        foodChoiceLabel.text = self.chosenFood

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.chosenFood = nil
        foodChoiceLabel.text = nil
    }
}
