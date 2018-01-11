//
//  MasterViewController.swift
//  PropertyApp
//
//  Created by Vaan on 07/01/18.
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

    var properties: [Property] = [Property]()
    weak var delegate: PropertySelectionDelegate?
    var isFirstLaunch: Bool = true;
    override func viewWillAppear(_ animated: Bool) {
        if isFirstLaunch {
            showLoadingHUD()
            isFirstLaunch = false
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.splitViewController!.delegate = self;

        self.splitViewController!.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        let url = "http://demo0065087.mockable.io/test/properties"
        loadURL(url: url)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    //function to fetch the json from URL
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return properties.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        let emptyString = " "
        let stringWithComma = ","
        let stringWithAUD = "$"

        cell.priceLabel.text = stringWithAUD+String(properties[indexPath.row].price)

        cell.nameLabel.text = properties[indexPath.row].firstName+emptyString+properties[indexPath.row].lastName
        cell.bedroomsLabel.text = String(properties[indexPath.row].bedRooms)
        cell.bathroomsLabel.text = String(properties[indexPath.row].bathRooms)
        cell.titleLabel.text = properties[indexPath.row].title
        cell.address1Label.text = properties[indexPath.row].address_1
        cell.address2Label.text = properties[indexPath.row].address_2+stringWithComma+properties[indexPath.row].suburb+stringWithComma+String(properties[indexPath.row].postcode)

        cell.nameLabel.text = properties[indexPath.row].firstName+emptyString+properties[indexPath.row].lastName
        print ("index path row outside, \(indexPath.row)")
        let propertyHud = MBProgressHUD.showAdded(to: cell.propertyImageView, animated: true)
        let avatarHud = MBProgressHUD.showAdded(to: cell.avatarImageView, animated: true)
        avatarHud.backgroundView.color = UIColor.white
        avatarHud.bezelView.color = UIColor.clear
        
        propertyHud.backgroundView.color = UIColor.white
        propertyHud.bezelView.color = UIColor.clear
        
        cell.avatarImageView?.layer.cornerRadius = (cell.avatarImageView?.frame.size.width)! / 2
        cell.avatarImageView?.layer.masksToBounds = true
        
        let fileManager : FileManager   = FileManager.default
        let docsDir     : URL       = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let propertyImagePath      : URL       = docsDir.appendingPathComponent("\(indexPath.row)_property.png")
        let strpropertyImagePath   : String    = propertyImagePath.path
        
        if fileManager.fileExists(atPath:strpropertyImagePath){
            cell.propertyImageView.image = UIImage (named: strpropertyImagePath)
            MBProgressHUD.hide(for: cell.propertyImageView, animated: true)
            print("Proprety Image Found at :: \(strpropertyImagePath)")
        }else{
            print("Proprety Image NOT Found at :: \(strpropertyImagePath)")
        }
        
        let avatarImagePath      : URL       = docsDir.appendingPathComponent("\(indexPath.row)_avatar.png")
        let stravatarImagePath   : String    = avatarImagePath.path

        if fileManager.fileExists(atPath:stravatarImagePath){
            cell.avatarImageView.image = UIImage (named: stravatarImagePath)
            MBProgressHUD.hide(for: cell.avatarImageView, animated: true)
            print("Avatar Image Found at :: \(stravatarImagePath)")
        }else{
            print("Avatar Image NOT Found at :: \(stravatarImagePath)")
        }
        
        return cell
    }
    
    func getPropertyImages(){
        for var i in (0..<properties.count){
            Alamofire.request(properties[i].propertyImageUrl).response { response in
                if let data = response.data {
                    let image = UIImage(data: data)
                    if let dataImage = UIImageJPEGRepresentation(image!, 0.8) {
                        let filename = self.getDocumentsDirectory().appendingPathComponent("\(i)_property.png")
                        try? dataImage.write(to: filename)
                        print("documents directory - ", filename)
                    }
                } else {
                    print("Data is nil.")
                    return
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func getAvatarImages(){
        for var i in (0..<properties.count){
            Alamofire.request(properties[i].avatar).response { response in
                if let data = response.data {
                    let image = UIImage(data: data)
                    if let dataImage = UIImageJPEGRepresentation(image!, 0.8) {
                        let filename = self.getDocumentsDirectory().appendingPathComponent("\(i)_avatar.png")
                        try? dataImage.write(to: filename)
                    }
                } else {
                    print("Data is nil.")
                    return
                }
            }
            self.tableView.reloadData()
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
    
    private func showLoadingHUD() {
        let window:UIWindow = UIApplication.shared.windows.last as UIWindow!
        let hud = MBProgressHUD.showAdded(to: window, animated: true)
        hud.label.text = "Loading..."
        hud.backgroundView.color = UIColor.white
        hud.bezelView.color = UIColor.clear
    }
    
    private func hideLoadingHUD() {
        let window:UIWindow = UIApplication.shared.windows.last as UIWindow!
        MBProgressHUD.hide(for: window, animated: true)
    }
    
}

