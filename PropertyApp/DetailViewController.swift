//
//  DetailViewController.swift
//  PropertyApp
//
//  Created by Saravanan Rethinam on 07/01/18.
//  Copyright © 2018 TGL. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var propertyIdLabel: UILabel!

    var property: Property? {
        didSet {
            refreshUI()
        }
    }
    
    func refreshUI() {
        loadViewIfNeeded()
        propertyIdLabel.font = UIFont(name: "Lato-Regular", size: 16)
        descriptionTextView.font = UIFont(name: "Lato-Regular", size: 16)

        propertyIdLabel.text = ""
        descriptionTextView.text = ""
        let propertyIdString = "Property ID: "
        if let propertyId = property?.propertyId{
            propertyIdLabel.text = propertyIdString + String(propertyId)
        }
        if let description = property?.propertyDescription{
            descriptionTextView.text = description
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

extension DetailViewController: PropertySelectionDelegate {
    func propertySelected(_ newProperty: Property) {
        property = newProperty
        self.refreshUI()
    }
}
