//
//  ContactsTableViewController.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 25/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import UIKit
import CoreData
import WebKit

extension ContactsTableViewController: AddViewControllerDelegate {
    // Adds a person in the DB (just by giving names now)
    func addPerson(firstName: String, familyName: String) {
        let context = self.appDelegate().persistentContainer.viewContext
        let person = Person(entity: Person.entity(), insertInto: context)
        person.firstName = firstName
        person.familyName = familyName
        // Add on server
        self.addPersonOnServer(person: person)
        
        // After adding, return to contactTable screen and refresh
        navigationController?.popViewController(animated: true)
        
    }
    
    private func addPersonOnServer(person: Person) {
        
        var json = [String: String]()
        json["surname"] = person.firstName
        json["lastname"] = person.familyName
        json["pictureUrl"] = imgURL
        let url = URL(string: urlGiven)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("error = ");print(error ?? "")
                return
            }
            guard let data = data else {
                return
            }
            
            let jsonDict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
            guard let dict = jsonDict as? [String:Any] else {
                return
            }
            DispatchQueue.main.async {
                let context = self.appDelegate().persistentContainer.viewContext
                person.firstName = dict["surname"] as? String
                person.familyName = dict["lastname"] as? String
                person.id = Int32(dict["id"] as? Int ?? 0)
                // Already done after in addPerson() above ?
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}

extension ContactsTableViewController: DetailsViewControllerDelegate {
    // Deletes given person in DB
    func deletePerson(person: Person) {
        let context = self.appDelegate().persistentContainer.viewContext
        context.delete(person)
        self.deleteOnServer(person: person)
        // After deleting, return to contactTable screen and refresh
        navigationController?.popViewController(animated: true)
    }
    
    func deleteOnServer(person: Person) {
        
        let url = URL(string: urlGiven + "/" + String(person.id))!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("error = ");print(error ?? "")
                return
            }
            DispatchQueue.main.async {
                let context = self.appDelegate().persistentContainer.viewContext
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
}

class ContactsTableViewController: UITableViewController {
    var persons = [Person]() // Useful for displaying persons from DB
    
    var resultController: NSFetchedResultsController<Person>!
    
    var urlGiven = "http://192.168.116.2:3000/persons"
    let imgURL = "http://fandeloup.f.a.pic.centerblog.net/5nccwlok.jpg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Mes Contacts"
        
        // Checking whether it is the first time app launch
        if UserDefaults.standard.isFirstLaunch() {
            let alertFirstLaunchController = UserDefaults.standard.doFirstLaunch()
            self.present(alertFirstLaunchController, animated: true)
        }
        
        // Adding from file (in DB)
        // self.importFromFile(url: "names.plist")
        
        // Adding add button in bar
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact
        
        self.createResultController()
    }
    
    func createResultController () {
        // Setting fetchedResultsController
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortFamilyName = NSSortDescriptor(key: "familyName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName, sortFamilyName]
        
        let context = self.appDelegate().persistentContainer.viewContext
        // sectionNameKeyPath: "firstLetter"
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        
        try? resultController.performFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.appDelegate().updateDataFromServer()
    }
    
    func reloadDataFromDB() {
        /* Doing : fetch request = "select * from Person"
         * and reload table with result of request
         */
        let fetchRequest = NSFetchRequest<Person>(entityName: "Person")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortFamilyName = NSSortDescriptor(key: "familyName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName, sortFamilyName]
        
        let context = self.appDelegate().persistentContainer.viewContext
        
        if let personsDB =  try? context.fetch(fetchRequest) {
            persons = personsDB
            self.tableView.reloadData()
        }
    }
    
    @objc func addContactPress() {
        /* Create and push AddViewController
         * Set the delegate
         */
        let addVC = AddViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(addVC, animated: true)
        addVC.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readFromServer(urlGiven: String) {
        //optional func webView(_ webView: WebView!, decidePolicyForNavigationAction actionInformation: [AnyHashable : Any]!, request: URLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!)
        
        var urlSession: URLSession!
        
        let conf = URLSessionConfiguration.default
        urlSession = URLSession(configuration: conf)
        
        let remoteURL = URL(string: urlGiven)
        /*
         let dlTask = urlSession.downloadTask(with: remoteURL! as URL) { location, response, error in
         if (error == nil) {
         let res = response as! HTTPURLResponse
         if (res.statusCode == 200) {
         let fileManager = FileManager.default
         
         var error: NSError = "Error"
         if (fileManager.moveItemAtURL(location!, toURL: remoteURL) == false) {
         print(error)
         }
         }
         else {
         print(res)
         let desc = HTTPURLResponse.localizedStringForStatusCode(res.statusCode);
         print(desc)
         }
         }
         else {
         print(error)
         }
         }
         dlTask.resume()
         */
        let dlTask = urlSession.dataTask(with: remoteURL!)
        dlTask.resume()
        
    }
    
    func importFromFile(url: String) {
        // Importing names from file
        // like url = "names.plist"
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
            // reloadDataFromDB()
        }
    }
    
    // MARK: - Table view data source
    // UPDATE : Corresponding methods in extension NSFetchedResultsControllerDelegate
    
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

extension ContactsTableViewController: NSFetchedResultsControllerDelegate {
    
    // MARK: - Table view data source
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = self.resultController {
            return frc.sections!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Modified from Developer Doc
        guard let cellPerson = self.resultController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath)
        if let contactCell = cell as? ContactTableViewCell {
            // .name! is OK because non-optional fields in DB
            contactCell.nameLabel.text = cellPerson.firstName!
            contactCell.familyNameLabel.text = cellPerson.familyName!
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = resultController?.sections?[section] else {
            return nil
        }
        return sectionInfo.name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return resultController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let result = resultController?.section(forSectionIndexTitle: title, at: index) else {
            fatalError("Unable to locate section for \(title) at index: \(index)")
        }
        return result
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsVC = DetailsViewController(nibName: nil, bundle: nil)
        detailsVC.person = self.resultController?.object(at: indexPath)
        self.navigationController?.pushViewController(detailsVC, animated: true)
        detailsVC.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
