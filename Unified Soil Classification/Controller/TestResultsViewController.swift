//
//  TestResultsViewController.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 3.10.2021.
//

import UIKit
import CoreData

class TestResultsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var threeInchLabel: UITextField!
    @IBOutlet weak var threeFourInchLabel: UITextField!
    @IBOutlet weak var noFourLabel: UITextField!
    @IBOutlet weak var noTenLabel: UITextField!
    @IBOutlet weak var noFourtyLabel: UITextField!
    @IBOutlet weak var noTwoHundredLabel: UITextField!
    @IBOutlet weak var liquidLimitLabel: UITextField!
    @IBOutlet weak var plasticLimitLabel: UITextField!
    @IBOutlet weak var panLabel: UITextField!
    @IBOutlet weak var wetWeightLabel: UITextField!
    @IBOutlet weak var driedLabel: UILabel!
    
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var laboratoryTestResults: [LaboratoryResults]?
    private var testResultsCalculationModel = TestResultsCalculationModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedOnView)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveData()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        updateDriedLabel()
    }
    
    
    
    //MARK: - Keyboard settings
    
    @objc func keyboardWillShow(notification:NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @objc func tappedOnView() {
        view.endEditing(true)
    }
    
    //MARK: - Button pressed
    
    @IBAction func evulatePressed(_ sender: UIButton) {
        saveData()
        if threeInchLabel.isEditing == false && threeFourInchLabel.isEditing == false && noFourLabel.isEditing == false && noTenLabel.isEditing == false && noFourLabel.isEditing == false && noTwoHundredLabel.isEditing == false && panLabel.isEditing == false && wetWeightLabel.isEditing == false && plasticLimitLabel.isEditing == false && liquidLimitLabel.isEditing == false {
            performSegue(withIdentifier: K.Segue.sieveResultsToTabCtrl, sender: self)
        } else {
            threeInchLabel.endEditing(true)
            threeFourInchLabel.endEditing(true)
            noFourLabel.endEditing(true)
            noTenLabel.endEditing(true)
            noFourLabel.endEditing(true)
            noTwoHundredLabel.endEditing(true)
            panLabel.endEditing(true)
            wetWeightLabel.endEditing(true)
            plasticLimitLabel.endEditing(true)
            liquidLimitLabel.endEditing(true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let tabCtrl = segue.destination as! UITabBarController
        
        let destinationVC = tabCtrl.viewControllers![0] as! EvaluatedResultViewController
        let destinationVC2 = tabCtrl.viewControllers![1] as! GradationChartViewController
        let destinationVC3 = tabCtrl.viewControllers![2] as! PlasticityChartViewController
       
        destinationVC.laboratoryTestResults = laboratoryTestResults?.last
        destinationVC2.laboratoryTestResults = laboratoryTestResults?.last
        destinationVC3.laboratoryResults = laboratoryTestResults?.last
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        noFourtyLabel.text = ""
        noTenLabel.text = ""
        noFourLabel.text = ""
        noTwoHundredLabel.text = ""
        liquidLimitLabel.text = ""
        plasticLimitLabel.text = ""
        threeFourInchLabel.text = ""
        threeInchLabel.text = ""
        panLabel.text = ""
        wetWeightLabel.text = ""
    }
    
    //MARK: - Data Manipulation
    
    func saveData() {
        let newLaboratoryResults = LaboratoryResults(context: context)
        updateOrCreateData(with: newLaboratoryResults)
    }
    
    func loadData() {
        let request: NSFetchRequest<LaboratoryResults> = LaboratoryResults.fetchRequest()
        
        do {
            laboratoryTestResults = try context.fetch(request)
        } catch {
            print("Error fetching laboratory results: \(error)")
        }
        
        if laboratoryTestResults?.last?.plasticLimit == 0 {
            plasticLimitLabel.text = ""
        } else if let pLSafe = laboratoryTestResults?.last?.plasticLimit {
            plasticLimitLabel.text = String(pLSafe)
        }
        
        if laboratoryTestResults?.last?.liquidLimit == 0 {
            liquidLimitLabel.text = ""
        } else if let lLSafe = laboratoryTestResults?.last?.liquidLimit {
            liquidLimitLabel.text = String(lLSafe)
        }
        
        if laboratoryTestResults?.last?.threeInch == 0 {
            threeInchLabel.text = ""
        } else if let safeThreeInch = laboratoryTestResults?.last?.threeInch{
            threeInchLabel.text = String(safeThreeInch)
        }
        
        if laboratoryTestResults?.last?.threeFourInch == 0 {
            threeFourInchLabel.text = ""
        } else if let safeThreeFourInch = laboratoryTestResults?.last?.threeFourInch {
            threeFourInchLabel.text = String(safeThreeFourInch)
        }
        
        if laboratoryTestResults?.last?.no4 == 0 {
            noFourLabel.text = ""
        } else if let safeNoFour = laboratoryTestResults?.last?.no4{
            noFourLabel.text = String(safeNoFour)
        }
        
        if laboratoryTestResults?.last?.no10 == 0 {
            noTenLabel.text = ""
        } else if let safeNoTen = laboratoryTestResults?.last?.no10 {
            noTenLabel.text = String(safeNoTen)
        }
        
        if laboratoryTestResults?.last?.no40 == 0 {
            noFourtyLabel.text = ""
        } else if let safeNoFourty = laboratoryTestResults?.last?.no40{
            noFourtyLabel.text = String(safeNoFourty)
        }
        
        if laboratoryTestResults?.last?.no200 == 0 {
            noTwoHundredLabel.text = ""
        } else if let safeNoTwoHundred = laboratoryTestResults?.last?.no200 {
            noTwoHundredLabel.text = String(safeNoTwoHundred)
        }
        
        if laboratoryTestResults?.last?.pan == 0 {
            panLabel.text = ""
        } else if let safePan = laboratoryTestResults?.last?.pan {
            panLabel.text = String(safePan)
        }
        
        if laboratoryTestResults?.last?.driedWeight == 0 {
            driedLabel.text = ""
        } else if let safeDried = laboratoryTestResults?.last?.driedWeight {
            driedLabel.text = String(safeDried)
        }
        
        if laboratoryTestResults?.last?.wetWeight == 0 {
            wetWeightLabel.text = ""
        } else if let safeNotDried = laboratoryTestResults?.last?.wetWeight {
            wetWeightLabel.text = String(safeNotDried)
        }
    }
    
    func updateData() {
        let request: NSFetchRequest<LaboratoryResults> = LaboratoryResults.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            if let resultSafe = results.last {
                updateOrCreateData(with: resultSafe)
            }
        } catch {
            print("Error fetching laboratory results: \(error)")
        }
    }
    
    func updateOrCreateData(with newLaboratoryResults: LaboratoryResults) {
        if let safeThreeInch = threeInchLabel.text {
            newLaboratoryResults.threeInch = Double(safeThreeInch) ?? 0.0
        }
        
        if let safeThreeFourInch = threeFourInchLabel.text {
            newLaboratoryResults.threeFourInch = Double(safeThreeFourInch) ?? 0.0
        }
        
        if let safeNoFour = noFourLabel.text {
            newLaboratoryResults.no4 = Double(safeNoFour) ?? 0.0
        }
        
        if let safeNoTen = noTenLabel.text {
            newLaboratoryResults.no10 = Double(safeNoTen) ?? 0.0
        }
        
        if let safeNoFourty = noFourtyLabel.text {
            newLaboratoryResults.no40 = Double(safeNoFourty) ?? 0.0
        }
        
        if let safeNoTwoHundred = noTwoHundredLabel.text {
            newLaboratoryResults.no200 = Double(safeNoTwoHundred) ?? 0.0
        }
        
        if let safePan = panLabel.text {
            newLaboratoryResults.pan = Double(safePan) ?? 0.0
        }
        
        if let safeLL = liquidLimitLabel.text {
            newLaboratoryResults.liquidLimit = Double(safeLL) ?? 0.0
        }
        
        if let safePL = plasticLimitLabel.text {
            newLaboratoryResults.plasticLimit = Double(safePL) ?? 0.0
        }
        
        if let safeDried = driedLabel.text {
            newLaboratoryResults.driedWeight = Double(safeDried) ?? 0.0
        }
        
        if let safeNotDried = wetWeightLabel.text {
            newLaboratoryResults.wetWeight = Double(safeNotDried) ?? 0.0
        }
        
        laboratoryTestResults = [newLaboratoryResults]
        
        do {
            try context.save()
        } catch {
            print("Error saving test results: \(error)")
        }
    }
}

//MARK: - Text field delegate

extension TestResultsViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateDriedLabel()
    }
    
    func updateDriedLabel() {
        let threeInch = Double(threeInchLabel.text ?? "0.0") ?? 0.0
        let threeFourInch = Double(threeFourInchLabel.text ?? "0.0") ?? 0.0
        let noFour = Double(noFourLabel.text ?? "0.0") ?? 0.0
        let noTen = Double(noTenLabel.text ?? "0.0") ?? 0.0
        let noFourty = Double(noFourtyLabel.text ?? "0.0") ?? 0.0
        let noTwoHundredLabel = Double(noTwoHundredLabel.text ?? "0.0") ?? 0.0
        let pan = Double(panLabel.text ?? "0.0") ?? 0.0
        let cum = threeInch + threeFourInch + noFour + noTen + noFourty + noTwoHundredLabel + pan
        driedLabel.text = String(cum)
    }
}
