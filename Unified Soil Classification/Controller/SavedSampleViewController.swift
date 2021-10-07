//
//  SavedSampleViewController.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 4.10.2021.
//

import UIKit
import CoreData

class SavedSampleViewController: UITableViewController {

    @IBOutlet weak var button: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var sample = [Sample]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = true
        
        let myBackButton:UIButton = UIButton(type: UIButton.ButtonType.custom) as UIButton
        myBackButton.addTarget(self, action: #selector(self.backPressed(_:)), for: UIControl.Event.touchUpInside)
        myBackButton.setTitle("Back", for: UIControl.State.normal)
        myBackButton.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        myBackButton.sizeToFit()
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem  = myCustomBackButtonItem
        
        loadData()
    }
    
    @objc func backPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sample.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: K.Cell.savedSampleCell)
        
        cell.textLabel?.text = sample[indexPath.row].name
        
        return cell
    }
    
    //MARK: -  Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segue.sampleViewToResult, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabCtrl = segue.destination as! UITabBarController
        let destinationVC = tabCtrl.viewControllers![0] as! EvaluatedResultViewController
        let destinationVC2 = tabCtrl.viewControllers![1] as! GradationChartViewController
        let destinationVC3 = tabCtrl.viewControllers![2] as! PlasticityChartViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.sample = sample[indexPath.row]
            destinationVC.buttonIsHidden = true
            destinationVC2.sample = sample[indexPath.row]
            destinationVC3.sample = sample[indexPath.row]
        }
    }
    
    //MARK: - Data manipulation
    
    func loadData() {
        let request: NSFetchRequest<Sample> = Sample.fetchRequest()
        
        do {
            sample = try context.fetch(request)
        } catch {
            print("Error fetch sample: \(error)")
        }
        
        tableView.reloadData()
    }

}
