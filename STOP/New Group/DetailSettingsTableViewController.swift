//
//  DetailSettingsTableViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/05/09.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit

class DetailSettingsTableViewController: UITableViewController {

    public var selectedItem:Int = 0
    
    let gameSettingItems = [
                    ["title":"Ball size",         "key":STOPKeys.SETTING_BALL_SIZE],
                    // ["title":"Small circle size", "key":STOPKeys.SETTING_SMALL_CIRCLE_SIZE],
                    // ["title":"Big circle size",   "key":STOPKeys.SETTING_BIG_CIRCLE_SIZE],
                    ["title":"Sensitivity",       "key":STOPKeys.SETTING_SENSITIVITY],
                    ["title":"Game time",         "key":STOPKeys.SETTING_GAME_TIME]
                ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        if selectedItem == 0 {
            return gameSettingItems.count
        }else if selectedItem == 1 {
            return 1
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailSettingCell", for: indexPath)

        // Configure the cell...
        if selectedItem == 0 {
            cell.textLabel!.text = gameSettingItems[indexPath.row]["title"]
            let key = gameSettingItems[indexPath.row]["key"]
            let value = UserDefaults.standard.integer(forKey: key!)
            
            if let detailTextLabel = cell.detailTextLabel{
                detailTextLabel.text = "\(value)"
            }
            
            return cell
        }else if selectedItem == 1{
            cell.textLabel!.text = "Clear medication list"
            cell.detailTextLabel!.text = ""
            return cell
        }

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedItem == 0 {
            let key = gameSettingItems[indexPath.row]["key"]
            let title = gameSettingItems[indexPath.row]["title"]
            let value = UserDefaults.standard.integer(forKey: key!)
            
            let alertController = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
            
            alertController.addTextField(configurationHandler: {(text:UITextField!) -> Void in
                text.text = "\(value)"
            })
            
            let okButton = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action) in
                let textFields:Array<UITextField>? =  alertController.textFields as Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {

                        if let value = Double(textField.text!){
                            UserDefaults.standard.set(value, forKey: key!)
                            // UserDefaults.synchronize(UserDefaults.standard)
                            self.tableView.reloadData()
                            
                        }
                    }
                }
            }
            
            let cancelButton = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            
            alertController.addAction(okButton)
            alertController.addAction(cancelButton)
            
            self.present(alertController, animated: true) {
            }
        } else {
            
        }
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
