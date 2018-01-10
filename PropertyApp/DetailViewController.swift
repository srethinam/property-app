//
//  DetailViewController.swift
//  PropertyApp
//
//  Created by Saravanan Rethinam on 07/01/18.
//  Copyright © 2018 TGL. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var property: Property? {
        didSet {
            refreshUI()
        }
    }
    
    func refreshUI() {
        loadViewIfNeeded()
        //descriptionLabel.text = ""
        //descriptionLabel.text = property?.propertyDescription

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
    }
}
