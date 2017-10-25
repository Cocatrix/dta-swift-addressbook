//
//  DetailsViewController.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 25/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import UIKit

protocol DetailsViewControllerDelegate: AnyObject {
    func deletePerson(person: Person)
}

class DetailsViewController: UIViewController {
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var familyNameLabel: UILabel!
    weak var person: Person?
    weak var delegate:DetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameLabel.text = person?.firstName
        familyNameLabel.text = person?.familyName
        
        let deleteContact = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteContactPress))
        self.navigationItem.rightBarButtonItem = deleteContact
    }
    
    @objc func deleteContactPress() {
        if let personToDelete = person {
            delegate?.deletePerson(person: personToDelete)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
