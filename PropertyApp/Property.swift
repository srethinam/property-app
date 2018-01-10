//
//  Property.swift
//  PropertyApp
//
//  Created by Saravanan Rethinam on 07/01/18.
//  Copyright © 2018 TGL. All rights reserved.
//

import Foundation


class Property: NSObject {
    var title: String!
    var propertyState: String!
    var propertyImageUrl: String!
    var isPremium: Bool!
    var bedRooms: Int!
    var bathRooms: Int!
    var propertyDescription: String!
    var carSpots: Int!
    var price: Double!
    var firstName: String!
    var lastName: String!
    var email: String!
    var avatar: String!
    var address_1: String!
    var address_2: String!
    var suburb  : String!
    var state: String!
    var postcode: String!
    var country: String!
    //var propertyPhoto: String!

    static var selfInstance: Property!

    class func sharedInstance() -> Property {
        if (selfInstance == nil) {
            selfInstance = Property()
        }
        return selfInstance
    }
    
    override init() {
        super.init()
    }
}
