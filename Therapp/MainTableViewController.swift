//
//  MainTableViewController.swift
//  Therapp
//
//  Created by Luis Gizirian on 20/05/2021.
//

import UIKit
import SwiftUI

class MainTableViewController: UITableViewController {
    
    let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareCapture))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItems = [self.share]
        
        self.title = "Therap"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainCellIdentifier", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Local measurements"
            case 1:
                cell.textLabel?.text = "Remote BLE readings"
            case 2:
                cell.textLabel?.text = "Share current results"
                cell.imageView?.image = UIImage(systemName: "square.and.arrow.up")
                cell.accessoryType = .none
            case 3:
                cell.textLabel?.text = "Good luck!"
            case 4:
                cell.textLabel?.text = "Speech..."
            case 5:
                cell.textLabel?.text = "Nistagmometer (new idea)"
                cell.detailTextLabel?.text = "VideoNistagmography like test, using front facing camera."
            case 6:
                cell.textLabel?.text = "Quick tune-up (new idea)"
                cell.detailTextLabel?.text = "Follow the dot game for balance training."
            default:
                print("Unknown option")
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0:
                if let viewController = storyboard?.instantiateViewController(identifier: "LocalViewController") as? LocalViewController {
                        navigationController?.pushViewController(viewController, animated: true)
                    }
            case 1:
                if let viewController = storyboard?.instantiateViewController(identifier: "BLEViewController") as? BLEViewController {
                        navigationController?.pushViewController(viewController, animated: true)
                    }
            case 2:
                //shareCapture(self)
                break
            case 3:
                presentSwiftUIView()
                break
            case 4:
                presentSpeechUIView()
                break
            case 5:
                presentNistagmometerUIView()
                break
            case 6:
                presentTuneupUIView()
                break
            default:
                print("Unknown option")
            }
            
        }
    }
    
    @objc func shareCapture() {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)[0]
        let filePath = path + "/log.txt"
        
        let fileURL = NSURL(fileURLWithPath: filePath)

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileURL)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func presentSwiftUIView() {
        let swiftUIView = SwiftUIView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        present(hostingController, animated: true, completion: nil)
    }
    
    func presentNistagmometerUIView() {
        let nistagmometerUIView = NistagmometerUIView()
        let hostingController = UIHostingController(rootView: nistagmometerUIView)
        present(hostingController, animated: true, completion: nil)
    }
    
    func presentTuneupUIView() {
        let tuneupUIView = TuneupUIView()
        let hostingController = UIHostingController(rootView: tuneupUIView)
        present(hostingController, animated: true, completion: nil)
    }
    
    func presentSpeechUIView() {
        let speechUIView = SpeechUIView()
        let hostingController = UIHostingController(rootView: speechUIView)
        present(hostingController, animated: true, completion: nil)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
