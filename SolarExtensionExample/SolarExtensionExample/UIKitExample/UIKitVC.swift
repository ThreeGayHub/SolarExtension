//
//  UIKitVC.swift
//  SolarExtensionExample
//
//  Created by wyh on 2018/2/12.
//  Copyright © 2018年 SolarKit. All rights reserved.
//

import UIKit

class UIKitVC: UITableViewController {
    
    private enum UIKitVCRow: Int {
        case ActionSheet
        case ActionSheetVC
        case AlertView
        case AlertVC
        case Color
        case Device
        case Image
        case ImagePicker
//        case Push
    }

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let row = UIKitVCRow(rawValue: indexPath.row) else { return }
        
        switch row {
        case .ActionSheet:
            
            let actionSheet = SLActionSheet(title: "title")
            actionSheet.addAction("cancel", .cancel)
            actionSheet.addAction("destructive", .destructive, {
                debugPrint("destructive")
            })
            actionSheet.addAction("other", .default, {
                debugPrint("other")
            })
            actionSheet.show(in: self.view)
            
        case .ActionSheetVC:
            
            let actionSheetVC = UIAlertController(title: "title", message: "message", preferredStyle: .actionSheet)
            actionSheetVC.addAction("cancel", .cancel)
            actionSheetVC.addAction("destructive", .destructive, { (action) in
                debugPrint(action.title ?? "")
            })
            actionSheetVC.addAction("other", .default, { (action) in
                debugPrint(action.title ?? "")
            })
            actionSheetVC.showInVC(self)

        case .AlertView:

            let alertView = SLAlertView(title: "Make a phone call", message: "Please input a phone number")
            alertView.alertViewStyle = .plainTextInput
            
            alertView.addAction("cancel", .cancel)
            alertView.addAction("call", .default, {
                debugPrint("call")
                if let text = alertView.textField?.text {
                    debugPrint(text)
                    UIApplication.call(phoneNumber: text)
                }
            })
            alertView.show()
            
        case .AlertVC:
            
            let alertVC = UIAlertController(title: "title", message: "message", preferredStyle: .alert)
            alertVC.addAction("cancel", .cancel)
            alertVC.addAction("destructive", .destructive, { (action) in
                debugPrint(action.title ?? "")
            })
            alertVC.addAction("other", .default, { (action) in
                debugPrint(action.title ?? "")
                
                if let textField = alertVC.textField(at: 0) {
                    debugPrint(textField.text ?? "")
                }
                
            })            
            alertVC.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "placeholder"
            })
            alertVC.showInVC(self)
            
        case .Color:
            
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor = UIColor(hexString: "#FF0000")
            
        case .Device:
            //            hostName:\(UIDevice.hostName)

            let cell = tableView.cellForRow(at: indexPath)
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.text = """
            Device
            hardwareString:\(UIDevice.hardwareString)
            platform:\(UIDevice.platform)
            phoneModel:\(UIDevice.phoneModel)
            IDFV:\(UIDevice.IDFV)
            IP:\(UIDevice.IP)
            """
            tableView.beginUpdates()
            tableView.endUpdates()
            
        case .Image:
            let cell = tableView.cellForRow(at: indexPath)
            cell?.imageView?.image = #imageLiteral(resourceName: "TestImage").compressedImage()
            
        case .ImagePicker:
            
            let actionSheetVC = UIAlertController(title: "ImagePicker", message: nil, preferredStyle: .actionSheet)
            actionSheetVC.addAction("cancel", .cancel)
            actionSheetVC.addAction("Take Photo", .default, { (action) in
                let picker = SLImagePickerController(.TakePhoto)
                picker.pickerPhotoComplete({ (data, error) in
                    debugPrint("""
                        data:\(data?.count ?? 0)
                        error:\(String(describing: error))
                    """)
                })
                picker.showOnVC(self)
            })
            
            actionSheetVC.addAction("Record Video", .default, { (action) in
                let picker = SLImagePickerController(.RecordVideo)
                picker.pickerVideoComplete({ (data, second, error) in
                    debugPrint("""
                        data:\(data?.count ?? 0)
                        second:\(second)
                        error:\(String(describing: error))
                        """)
                })
                picker.showOnVC(self)
            })
            
            actionSheetVC.addAction("Album List", .default, { (action) in
                let picker = SLImagePickerController(.AlbumList)
                picker.pickerPhotoComplete({ (data, error) in
                    debugPrint("""
                        data:\(data?.count ?? 0)
                        error:\(String(describing: error))
                        """)
                })
                picker.showOnVC(self)
            })
            
            actionSheetVC.addAction("Album Timeline", .default, { (action) in
                let picker = SLImagePickerController(.AlbumTimeline)
                picker.pickerPhotoComplete({ (data, error) in
                    debugPrint("""
                        data:\(data?.count ?? 0)
                        error:\(String(describing: error))
                        """)
                })
                picker.showOnVC(self)
            })
            actionSheetVC.showInVC(self)
            
        }
        
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
