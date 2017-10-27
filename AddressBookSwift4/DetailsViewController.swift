//
//  DetailsViewController.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 25/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import UIKit
import Kingfisher

protocol DetailsViewControllerDelegate: AnyObject {
    func deletePerson(person: Person)
}

class DetailsViewController: UIViewController {
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var familyNameLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    weak var person: Person?
    weak var delegate:DetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameLabel.text = person?.firstName
        familyNameLabel.text = person?.familyName
        
        // Download URL, put it in cache
        guard let avatarImage = person?.avatarUrl, let url = URL(string: avatarImage) else {
            print("Error")
            return
        }
        avatar.kf.setImage(with: url)
        
        let deleteContact = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteContactPress))
        self.navigationItem.rightBarButtonItem = deleteContact
    }
    
    @objc func deleteContactPress() {
        if let personToDelete = person {
            let alertDeleteController = UIAlertController(title: "Suppression", message: "Voulez-vous vraiment supprimer cette personne?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in
                
            }
            let okAction = UIAlertAction(title: "OK", style: .default) { action in
                self.delegate?.deletePerson(person: personToDelete)
            }
            alertDeleteController.addAction(cancelAction)
            alertDeleteController.addAction(okAction)
            self.present(alertDeleteController, animated: true)
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
