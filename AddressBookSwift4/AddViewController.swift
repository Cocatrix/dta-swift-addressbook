//
//  AddViewController.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 25/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import UIKit

protocol AddViewControllerDelegate: AnyObject {
    func addPerson(firstName: String, familyName: String)
}

class AddViewController: UIViewController {
    
    @IBOutlet weak var newFirstName: UITextField!
    @IBOutlet weak var newFamilyName: UITextField!
    @IBOutlet weak var creatingProgressBar: UIProgressView!
    weak var delegate: AddViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatingProgressBar.setProgress(0, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickedCreateContact(_ sender: Any) {
        self.makeProgressOnBar()
    }
    
    func makeProgressOnBar() {
        //Async task : progress bar
        DispatchQueue.global(qos: .userInitiated).async {
            var percent: Float = 0
            while percent < 1 {
                Thread.sleep(forTimeInterval: 0.02)
                DispatchQueue.main.async {
                    self.creatingProgressBar.setProgress(percent + 0.01, animated: true)
                    percent = self.creatingProgressBar.progress
                }
            }
            DispatchQueue.main.async {
                if let newFirstName = self.newFirstName.text, let newFamilyName = self.newFamilyName.text {
                    /*
                    let newPerson = Person(firstName: newFirstName, familyName: newFamilyName)
                    self.delegate?.addPerson(newPerson: newPerson)
                     */
                    self.delegate?.addPerson(firstName: newFirstName, familyName: newFamilyName)
                    /*
                    let context = self.appDelegate().persistentContainer.viewContext
                    let person = Person(entity: Person.entity(), insertInto: context)
                    person.firstName = newFirstName
                    person.familyName = newFamilyName
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                     */
                }
            }
        }
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
