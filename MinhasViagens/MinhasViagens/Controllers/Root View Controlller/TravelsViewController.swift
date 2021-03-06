//
//  ViewController.swift
//  MinhasViagens
//
//  Created by MACBOOK AIR on 12/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import UIKit

class TravelsViewController: UITableViewController {

    @IBOutlet weak var travelsTableView: UITableView?
    var travels:[Dictionary<String,String>]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        guard let travelsRecovery = app.recovery() else {
            return
        }
        self.travels = travelsRecovery
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension TravelsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let travels = self.travels else {
            return 0
        }
        return travels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellTravel = tableView.dequeueReusableCell(withIdentifier: "cell"),
              let travels    = self.travels else {
            return UITableViewCell()
        }
        
        let travelForRow = travels[indexPath.row]["address"]
        cellTravel.textLabel?.text = travelForRow
        return cellTravel
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard var _ = self.travels else {
                return
            }
            
            app.delete(registreFor: indexPath.row, completation: { (delete) in
                if delete {
                   self.travels = app.recovery()
                   tableView.deleteRows(at: [indexPath], with: .fade)
                   tableView.reloadData()
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let travels = self.travels else {
            return
        }
        let travelSelected = travels[indexPath.row]
        performSegue(withIdentifier: "presentMap", sender: travelSelected)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? MapViewController,
              let travelInformation = sender as? [String:String]  else {
            return
        }
        destination.travelInformation = travelInformation
    }
}

