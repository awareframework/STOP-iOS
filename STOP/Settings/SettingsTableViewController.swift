//
//  SettingsTableViewController.swift
//  STOP
//
//  Created by Yuuki Nishiyama on 2018/04/12.
//  Copyright © 2018 Yuuki Nishiyama. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController{

    let tableSource = ["Ball game","Medication"]
    
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
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // load cell model
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        // set cell text
        cell.textLabel!.text = tableSource[indexPath.row]
        // set cell image
        var image:UIImage? = nil
        if indexPath.row == 0 {
            image = UIImage(named:"ic_game")
        }else if indexPath.row == 1{
            image = UIImage(named:"ic_medication")
        }
        cell.imageView!.image = image
        return cell
    }
    
//    detailSettings

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("cell:\(indexPath.row) fruits:\(medications[indexPath.row])")
        // let medication:EntityMedication = medications[indexPath.row]
        
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailSettingsView") as? DetailSettingsTableViewController {
            viewController.selectedItem = indexPath.item
            viewController.title = self.tableSource[indexPath.item]
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
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
