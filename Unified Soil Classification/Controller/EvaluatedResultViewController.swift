//
//  EvaluatedResultViewController.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 3.10.2021.
//

import UIKit
import CoreData

class EvaluatedResultViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var soilLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var soilClassificationModel = SoilClassificationModel()
    private var testResultsCalculation = TestResultsCalculationModel()
    var sample: Sample? {
        didSet {
            loadSampleData()
        }
    }
    
    var laboratoryTestResults: LaboratoryResults? {
        didSet {
            testResultsCalculation.soilEvaluation(threeInch: laboratoryTestResults?.threeInch ?? 0.0, threeFourInch: laboratoryTestResults?.threeFourInch ?? 0.0, noFour: laboratoryTestResults?.no4 ?? 0.0, noTen: laboratoryTestResults?.no10 ?? 0.0, noFourty: laboratoryTestResults?.no40 ?? 0.0, noTwoHundred: laboratoryTestResults?.no200 ?? 0.0, pan: laboratoryTestResults?.pan ?? 0.0, plasticLimit: laboratoryTestResults?.plasticLimit ?? 0.0, liquidLimit: laboratoryTestResults?.liquidLimit ?? 0.0, driedWeight: laboratoryTestResults?.driedWeight ?? 0.0, notDriedWeight: laboratoryTestResults?.wetWeight ?? 0.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadResultViewData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedOnView)))
        
        if soilLabel.text == "Check test results you have entered, soil type couldn't identified." {
            soilLabel.backgroundColor = .systemRed
        } else {
            soilLabel.backgroundColor = .systemGreen
        }
    }
    
    
    //MARK: - Keyboard Hide Settings
    
    @objc func tappedOnView() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    //MARK: - Button Pressed
    
    @IBAction func savePressed(_ sender: UIButton) {
        if nameField.text == "" {
            let alert = UIAlertController(title: "Please Enter A Title", message: "You must specify a Sample Name before saving a new sample.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {

            let newSample = Sample(context: context)
            if let comment = commentField.text {
                newSample.comment = comment
            }
            newSample.name = nameField.text

            laboratoryTestResults?.parentSample = newSample
           
            saveData()
            performSegue(withIdentifier: K.Segue.resultViewToTableView, sender: self)
        }
    }
    
    @IBAction func discardPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Discard?", message: "All data will be lost if you discard the sample. Are you sure?", preferredStyle: .alert)
        let discard = UIAlertAction(title: "Discard", style: .default) { action in
            self.resignFirstResponder()
            let request: NSFetchRequest<LaboratoryResults> = LaboratoryResults.fetchRequest()
            do {
                let laboratoryLast = try self.context.fetch(request).last
                guard let lastData = laboratoryLast else {
                    fatalError()
                }
                lastData.threeInch = 0
                lastData.threeFourInch = 0
                lastData.no4 = 0
                lastData.no10 = 0
                lastData.no40 = 0
                lastData.no200 = 0
                lastData.pan = 0
                lastData.driedWeight = 0
                lastData.wetWeight = 0
                lastData.plasticLimit = 0
                lastData.liquidLimit = 0
        
                try self.context.save()
                self.laboratoryTestResults = lastData
                self.loadResultViewData()
                
            } catch {
                print("Error deleting data: \(error)")
            }
           
            self.nameField.text = ""
            self.commentField.text = ""
        }
       
        let dontDiscard = UIAlertAction(title: "Don't Discard", style: .default) { action in
            self.resignFirstResponder()
        }
        alert.addAction(discard)
        alert.addAction(dontDiscard)
        
        present(alert, animated: true, completion: nil)
        
    }
    
   
    
    //MARK: - Data Manupilaction
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving results: \(error)")
        }
    }
    
    func loadSampleData() {
        let request: NSFetchRequest<LaboratoryResults> = LaboratoryResults.fetchRequest()
        let samplePredicate = NSPredicate(format: "parentSample.name MATCHES %@", sample!.name!)

        request.predicate = samplePredicate

        do {
            laboratoryTestResults = try context.fetch(request).first
        } catch {
            print("Error fetch predicate sample: \(error)")
        }
    }
    
    
    func loadResultViewData() {
        let d60 = testResultsCalculation.dx["60"] ?? 0.0
        let d30 = testResultsCalculation.dx["30"] ?? 0.0
        let d10 = testResultsCalculation.dx["10"] ?? 0.0
        
        let threeIncPer = testResultsCalculation.passingPercent["threeInchPer"] ?? 0.0
        let threeFourPer = testResultsCalculation.passingPercent["threeFourInchPer"] ?? 0.0
        let noFourPer = testResultsCalculation.passingPercent["noFourPer"] ?? 0.0
        let noTenPer = testResultsCalculation.passingPercent["noTenPer"] ?? 0.0
        let noFourtyPer = testResultsCalculation.passingPercent["noFourtyPer"] ?? 0.0
        let noTwoHundredPer = testResultsCalculation.passingPercent["noTwoHundredPer"] ?? 0.0
        
        let lL = laboratoryTestResults?.liquidLimit ?? 0.0
        let pL = laboratoryTestResults?.plasticLimit ?? 0.0
        let organicConstant = testResultsCalculation.organicConstant
        let cc = testResultsCalculation.cC
        let cu = testResultsCalculation.cU
         
        self.soilLabel.text = soilClassificationModel.classificateSoil(d60: d60, d30: d30, d10: d10, threeIncPer: threeIncPer, threeFourPer:threeFourPer, noFourPer: noFourPer, noTenPer: noTenPer, noFourtyPer: noFourtyPer, noTwoHundredPer: noTwoHundredPer, lL: lL, pL: pL, organicConstant: organicConstant, cc: cc, cu: cu)
        
    }
}
