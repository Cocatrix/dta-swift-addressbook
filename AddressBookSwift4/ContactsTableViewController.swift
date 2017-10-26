//
//  ContactsTableViewController.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 25/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import UIKit
import CoreData

extension ContactsTableViewController: AddViewControllerDelegate {
    func addPerson(firstName: String, familyName: String) {
        
        let context = self.appDelegate().persistentContainer.viewContext
        let person = Person(entity: Person.entity(), insertInto: context)
        person.firstName = firstName
        person.familyName = familyName
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        navigationController?.popViewController(animated: true)
        reloadDataFromDB()
    }
}

extension ContactsTableViewController: DetailsViewControllerDelegate {
    func deletePerson(person: Person) {
        // TODO - Delete in DB
        persons = persons.filter({$0 != person})
        navigationController?.popViewController(animated: true)
        reloadDataFromDB()
    }
}

class ContactsTableViewController: UITableViewController {
    var persons = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Checking whether it is the first time app launch
        let value = UserDefaults.standard.value(forKey: "firstTimeLaunch") as? Bool ?? true
        if(value) {
            self.doFirstLaunch()
        }
        
        self.title = "Mes Contacts"
        
        // Test : adding from file (in DB)
        self.importFromFile(url: "names.plist")
        
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadDataFromDB()
    }
    
    func reloadDataFromDB() {
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortFamilyName = NSSortDescriptor(key: "familyName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName, sortFamilyName]
        
        let context = self.appDelegate().persistentContainer.viewContext
        // print(try? context.fetch(fetchRequest))
        if let personsDB =  try? context.fetch(fetchRequest) {
            persons = personsDB
            self.tableView.reloadData()
        }
    }
    
    func doFirstLaunch() {
        // Set preferences
        UserDefaults.standard.set(false, forKey: "firstTimeLaunch")
        
        // Show an alert view with welcoming message
        let alertFirstLaunchController = UIAlertController(title: "Arrivée", message: "Bienvenue dans votre nouvelle appli ! Utile pour gérer ses contacts", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            
        }
        alertFirstLaunchController.addAction(okAction)
        self.present(alertFirstLaunchController, animated: true)
    }
    
    @objc func addContactPress() {
        // Create and push AddViewController
        // Set the delegate
        let addVC = AddViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(addVC, animated: true)
        addVC.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return persons.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath)
        
        if let contactCell = cell as? ContactTableViewCell {
            contactCell.nameLabel.text = persons[indexPath.row].firstName
            contactCell.familyNameLabel.text = persons[indexPath.row].familyName
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = DetailsViewController(nibName: nil, bundle: nil)
        detailsVC.person = persons[indexPath.row]
        self.navigationController?.pushViewController(detailsVC, animated: true)
        detailsVC.delegate = self
    }
    
    func importFromFile(url: String) {
        // Importing names from file
        // url = "names.plist"
        let namesPList = Bundle.main.path(forResource: url, ofType: nil)
        if let namesPath = namesPList {
            let url = URL(fileURLWithPath: namesPath)
            let dataArray = NSArray(contentsOf: url)
            
            for dict in dataArray! {
                if let dictionnary = dict as? [String : String] {
                    let context = self.appDelegate().persistentContainer.viewContext
                    let person = Person(entity: Person.entity(), insertInto: context)
                    person.firstName = dictionnary["name"]!
                    person.familyName = dictionnary["lastname"]!
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            reloadDataFromDB()
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
