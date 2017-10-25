//
//  ContactsTableViewController.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 25/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import UIKit

extension ContactsTableViewController: AddViewControllerDelegate {
    func addPerson(newPerson: Person) {
        persons.append(newPerson)
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
}

extension ContactsTableViewController: DetailsViewControllerDelegate {
    func deletePerson(person: Person) {
        persons = persons.filter({$0 != person})
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
}

class ContactsTableViewController: UITableViewController {
    var persons = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Importing names from file
        let namesPList = Bundle.main.path(forResource: "names.plist", ofType: nil)
        if let namesPath = namesPList {
            let url = URL(fileURLWithPath: namesPath)
            let dataArray = NSArray(contentsOf: url)
            
            for dict in dataArray! {
                if let dictionnary = dict as? [String : String] {
                    let person = Person(firstName: dictionnary["name"]!, familyName: dictionnary["lastname"]!)
                    persons.append(person)
                    //print(dictionnary)
                }
            }
 
            //print(dataArray)
        }
        self.title = "Mes Contacts"
        
        persons.append(Person(firstName: "Thibault", familyName: "GOUDOUNEIX"))
        persons.append(Person(firstName: "Guillaume",familyName: "LAZARO"))
        
        let addContact = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactPress))
        self.navigationItem.rightBarButtonItem = addContact
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
