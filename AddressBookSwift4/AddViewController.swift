//
//  AddViewController.swift
//  AddressBookSwift4
//
//  Created by Maxime REVEL on 25/10/2017.
//  Copyright © 2017 Maxime REVEL. All rights reserved.
//

import UIKit

protocol AddViewControllerDelegate: AnyObject {
    func addPerson(newPerson: String)
}

class AddViewController: UIViewController {
    @IBOutlet weak var newContactName: UITextField!
    weak var delegate: AddViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickedCreateContact(_ sender: Any) {
        if let newName = newContactName.text {
            print(newName)
            delegate?.addPerson(newPerson: newName)
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
