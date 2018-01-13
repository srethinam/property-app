//
//  MasterViewController.swift
//  PropertyApp
//
//  Created by Saravanan Rethinam on 07/01/18.
//  Copyright © 2018 TGL. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import MBProgressHUD

protocol PropertySelectionDelegate: class {
    func propertySelected(_ newProperty: Property)
}

class MasterViewController: UITableViewController, UISplitViewControllerDelegate {
    var segmentControl: UISegmentedControl!
    var isPremium: Bool = false
    var premiumProperties: [Property] = [Property]()
    var standardProperties: [Property] = [Property]()

    /// properties variable holds all the properties list.
    var properties: [Property] = [Property]()
    weak var delegate: PropertySelectionDelegate?
    var isFirstLaunch: Bool = true;
    override func viewWillAppear(_ animated: Bool) {
        if isFirstLaunch {
            showLoadingHUD()
            isFirstLaunch = false
        }
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.splitViewController!.delegate = self;

        self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        segmentControl = UISegmentedControl(frame: CGRect(x: 50, y: 7, width: tableView.frame.width - 100, height: 37))
        segmentControl.insertSegment(withTitle: "Standard", at: 0, animated: false)
        segmentControl.insertSegment(withTitle: "Premium", at: 1, animated: false)
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(changeType(sender:)), for: .valueChanged)

        let url = "http://demo0065087.mockable.io/test/properties"
        loadURL(url: url)
    }

    /**
     Function to fetch the json from URL.
     
     - Parameter url: json url string to provide properties list.
     - Returns: void
     */
    func loadURL(url:String){
        
        DispatchQueue.global().async {
            
            do{
                let appURL = URL(string:url)!
                let data = try Data(contentsOf:appURL)
                let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                let array = json["data"] as! [Any]
                self.properties.removeAll()
                for value in array{
                    let results = value as! [String:Any]
                    //print("value - \(value)")
                    let propertyObj   = Property()
                    propertyObj.title = results["title"] as! String
                    propertyObj.price = results["price"] as! Double
                    propertyObj.propertyId = results["id"] as! Int

                    propertyObj.propertyState = results["state"] as! String
                    propertyObj.isPremium = results["is_premium"] as! Bool
                    propertyObj.bedRooms = results["bedrooms"] as! Int
                    propertyObj.bathRooms = results["bathrooms"] as! Int
                    propertyObj.carSpots = results["carspots"] as! Int
                    propertyObj.propertyDescription = results["description"] as! String
                    propertyObj.price = results["price"] as! Double
                    
                    let owner = results["owner"] as! [String:Any]
                    propertyObj.firstName = owner["first_name"] as! String
                    propertyObj.lastName = owner["last_name"] as! String
                    propertyObj.email = owner["email"] as! String
                    let avatar = owner["avatar"] as! [String:Any]
                    let profile = avatar["small"] as! [String:Any]
                    propertyObj.avatar = profile["url"] as! String

                    let location = results["location"] as! [String:Any]
                    propertyObj.address_1 = location["address_1"] as! String
                    propertyObj.address_2 = location["address_2"] as! String
                    propertyObj.suburb = location["suburb"] as! String
                    propertyObj.state = location["state"] as! String
                    propertyObj.postcode = location["postcode"] as! String
                    propertyObj.country = location["country"] as! String
                    
                    let photo = results["photo"] as! [String:Any]
                    let image = photo["image"] as! [String:Any]
                    let propertyImage = image["small"] as! [String:Any]
                    propertyObj.propertyImageUrl = propertyImage["url"] as! String

                    self.properties.append(propertyObj)

                }
                DispatchQueue.main.async {
                    //print("properties count: \(self.properties.count)")
                    self.premiumProperties = self.properties.filter({$0.isPremium == true})
                    print("premiumProperties count: \(self.premiumProperties.count)")
                    self.standardProperties = self.properties.filter({$0.isPremium == false})
                    print("standardProperties count: \(self.standardProperties.count)")

                    self.getPropertyImages()
                    self.getAvatarImages()
                    //self.tableView.reloadData()
                    self.hideLoadingHUD()
                }
            }catch{
                DispatchQueue.main.async {
                    
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section"
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = UIColor.white
        vw.addSubview(segmentControl)
        
        return vw
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 50.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isPremium {
            return premiumProperties.count
        }
        return standardProperties.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let emptyString = " "
        let stringWithComma = ","
        let stringWithAUD = "$"
        var propertiesObj:[Property] = [Property]()
        
        if isPremium {
            propertiesObj = premiumProperties
        }
        else{
            propertiesObj = standardProperties
        }
        
        cell.titleLabel?.font = UIFont(name: "Lato-Regular", size: 18)
        cell.address1Label?.font = UIFont(name: "Lato-Light", size: 14)
        cell.address2Label?.font = UIFont(name: "Lato-Light", size: 14)
        cell.nameLabel?.font = UIFont(name: "Lato-Light", size: 16)
        cell.priceLabel?.font = UIFont(name: "Lato-Bold", size: 18)

        cell.priceLabel.text = stringWithAUD+String(propertiesObj[indexPath.row].price)
        cell.priceLabel.backgroundColor = UIColor.lightGray
        cell.nameLabel.text = propertiesObj[indexPath.row].firstName+emptyString+propertiesObj[indexPath.row].lastName
        cell.bedroomsLabel.text = String(propertiesObj[indexPath.row].bedRooms)
        cell.bathroomsLabel.text = String(propertiesObj[indexPath.row].bathRooms)
        cell.titleLabel.text = propertiesObj[indexPath.row].title
        cell.address1Label.text = propertiesObj[indexPath.row].address_1
        cell.address2Label.text = propertiesObj[indexPath.row].address_2+stringWithComma+propertiesObj[indexPath.row].suburb+stringWithComma+String(propertiesObj[indexPath.row].postcode)

        cell.nameLabel.text = propertiesObj[indexPath.row].firstName+emptyString+propertiesObj[indexPath.row].lastName
        //print ("index path row outside, \(indexPath.row)")
        cell.premiumImageView.isHidden = true
        
        if isPremium{
            cell.premiumImageView.isHidden = false
        }
        cell.avatarImageView?.layer.cornerRadius = (cell.avatarImageView?.frame.size.width)! / 2
        cell.avatarImageView?.layer.masksToBounds = true
        
        cell.propertyImageView.image = UIImage (named: "house-illustration-clipart.png")
        
        let fileManager : FileManager   = FileManager.default
        let docsDir     : URL       = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let propertyImagePath      : URL       = docsDir.appendingPathComponent("\(propertiesObj[indexPath.row].title!)_property.png")
        let strpropertyImagePath   : String    = propertyImagePath.path
        
        if fileManager.fileExists(atPath:strpropertyImagePath){
            cell.propertyImageView.image = UIImage (named: strpropertyImagePath)
            MBProgressHUD.hide(for: cell.propertyImageView, animated: true)
            //print("Proprety Image Found at :: \(strpropertyImagePath)")
        }else{
            let propertyHud = MBProgressHUD.showAdded(to: cell.propertyImageView, animated: true)
            propertyHud.backgroundView.color = UIColor.white
            propertyHud.bezelView.color = UIColor.clear
            //print("Proprety Image NOT Found at :: \(strpropertyImagePath)")
        }
        
        let avatarImagePath      : URL       = docsDir.appendingPathComponent("\(propertiesObj[indexPath.row].title!)_avatar.png")
        let stravatarImagePath   : String    = avatarImagePath.path

        if fileManager.fileExists(atPath:stravatarImagePath){
            MBProgressHUD.hide(for: cell.avatarImageView, animated: false)
            let availableImage: UIImage = UIImage (named: stravatarImagePath)!
            cell.avatarImageView.image = availableImage
            //print("Avatar Image Found at :: \(stravatarImagePath)")
        }else{
            let avatarHud = MBProgressHUD.showAdded(to: cell.avatarImageView, animated: true)
            avatarHud.backgroundView.color = UIColor.white
            avatarHud.bezelView.color = UIColor.clear
            //print("Avatar Image NOT Found at :: \(stravatarImagePath)")
        }
        
        return cell
    }
    
    /**
     Function to fetch all the property images in lazy loading.
     
     - Parameter url:
     - Returns:
     */
    func getPropertyImages(){
        
        for i in (0..<properties.count){
            Alamofire.request(properties[i].propertyImageUrl).response { response in
                if let data = response.data {
                    let image = UIImage(data: data)
                    if let dataImage = UIImageJPEGRepresentation(image!, 0.8) {
                        let filename = self.getDocumentsDirectory().appendingPathComponent("\(self.properties[i].title!)_property.png")
                        try? dataImage.write(to: filename)
                        //print("documents directory - ", filename)
                        self.tableView.reloadData()
                    }
                } else {
                    print("Data is nil.")
                    return
                }
            }
        }
    }
    
    /**
     Function to fetch all the avatar images in lazy loading.
     
     - Parameter url:
     - Returns:
     */
    func getAvatarImages(){
        
        for i in (0..<properties.count){
            Alamofire.request(properties[i].avatar).response { response in
                if let data = response.data {
                    let image = UIImage(data: data)
                    if let dataImage = UIImageJPEGRepresentation(image!, 0.8) {
                        let filename = self.getDocumentsDirectory().appendingPathComponent("\(self.properties[i].title!)_avatar.png")
                        try? dataImage.write(to: filename)
                        //print("documents directory - ", filename)
                        self.tableView.reloadData()
                    }
                } else {
                    print("Data is nil.")
                    return
                }
            }
        }
    }

    /**
     Function to get the document directory.
     
     - Parameter:
     - Returns: Document directory URL
     */
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedProperty = properties[indexPath.row]
        delegate?.propertySelected(selectedProperty)
        if let detailViewController = delegate as? DetailViewController,
            let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        hideLoadingHUD()
        return true
    }
    
    /**
     Function to show the loading bar.
     */
    private func showLoadingHUD() {
        let window:UIWindow = UIApplication.shared.windows.last as UIWindow!
        let hud = MBProgressHUD.showAdded(to: window, animated: true)
        hud.label.text = "Loading..."
        hud.backgroundView.color = UIColor.white
        hud.bezelView.color = UIColor.clear
    }
    
    
    /**
     Function to hide the loading bar.
     */
    private func hideLoadingHUD() {
        let window:UIWindow = UIApplication.shared.windows.last as UIWindow!
        MBProgressHUD.hide(for: window, animated: true)
    }
    
    /**
     Handler for when custom Segmented Control changes and will change the
     background color of the view depending on the selection.
     */
    @objc func changeType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isPremium = false
            self.tableView.reloadData()
        case 1:
            isPremium = true
            self.tableView.reloadData()
        default:
            break
        }
    }
    
}

