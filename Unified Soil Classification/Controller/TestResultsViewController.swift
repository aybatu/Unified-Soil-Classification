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
    
    private let defaults = UserDefaults.standard
    private var labResult = LabResultDefault()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedOnView)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
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
    
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        saveData()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func evulatePressed(_ sender: UIButton) {
        
        if threeInchLabel.isEditing == false && threeFourInchLabel.isEditing == false && noFourLabel.isEditing == false && noTenLabel.isEditing == false && noFourLabel.isEditing == false && noTwoHundredLabel.isEditing == false && panLabel.isEditing == false && wetWeightLabel.isEditing == false && plasticLimitLabel.isEditing == false && liquidLimitLabel.isEditing == false {
            saveData()
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
        
        destinationVC.laboratoryTestResults = labResult
        destinationVC.buttonIsHidden = false
        
        destinationVC2.laboratoryTestResults = labResult
        destinationVC3.laboratoryResults = labResult
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
        if let safeThreeInch = threeInchLabel.text {
            defaults.set(Double(safeThreeInch) ?? 0.0, forKey: K.laboratoryTests.threeInch)
        }
        
        if let safeThreeFourInch = threeFourInchLabel.text {
            defaults.set(Double(safeThreeFourInch) ?? 0.0, forKey: K.laboratoryTests.threeFourInch)
        }
        
        if let safeNoFour = noFourLabel.text {
            defaults.set(Double(safeNoFour) ?? 0.0, forKey: K.laboratoryTests.noFour)
        }
        
        if let safeNoTen = noTenLabel.text {
            defaults.set(Double(safeNoTen) ?? 0.0, forKey: K.laboratoryTests.noTen)
        }
        
        if let safeNoFourty = noFourtyLabel.text {
            defaults.set(Double(safeNoFourty) ?? 0.0, forKey: K.laboratoryTests.noFourty)
        }
        
        if let safeNoTwoHundred = noTwoHundredLabel.text {
            defaults.set(Double(safeNoTwoHundred) ?? 0.0, forKey: K.laboratoryTests.noTwoHundred)
        }
        
        if let safePan = panLabel.text {
            defaults.set(Double(safePan), forKey: K.laboratoryTests.pan)
        }
        
        if let safeLL = liquidLimitLabel.text {
            defaults.set(Double(safeLL) ?? 0.0, forKey: K.laboratoryTests.liquidLimit)
        }
        
        if let safePL = plasticLimitLabel.text {
            defaults.set(Double(safePL) ?? 0.0, forKey: K.laboratoryTests.plasticLimit)
        }
        
        if let safeDried = driedLabel.text {
            defaults.set(Double(safeDried) ?? 0.0, forKey: K.laboratoryTests.driedWeight)
        }
        
        if let safeNotDried = wetWeightLabel.text {
            defaults.set(Double(safeNotDried) ?? 0.0, forKey: K.laboratoryTests.wetWeight)
        }
        
        var newLabResult = LabResultDefault()
        newLabResult.pan = defaults.double(forKey: K.laboratoryTests.pan)
        newLabResult.driedWeight = defaults.double(forKey: K.laboratoryTests.driedWeight)
        newLabResult.wetWeight = defaults.double(forKey: K.laboratoryTests.wetWeight)
        newLabResult.threeInch = defaults.double(forKey: K.laboratoryTests.threeInch)
        newLabResult.threeFourInch  = defaults.double(forKey: K.laboratoryTests.threeFourInch)
        newLabResult.no4 = defaults.double(forKey: K.laboratoryTests.noFour)
        newLabResult.no10 = defaults.double(forKey: K.laboratoryTests.noTen)
        newLabResult.no40 = defaults.double(forKey: K.laboratoryTests.noFourty)
        newLabResult.no200 = defaults.double(forKey: K.laboratoryTests.noTwoHundred)
        newLabResult.pL = defaults.double(forKey: K.laboratoryTests.plasticLimit)
        newLabResult.lL = defaults.double(forKey: K.laboratoryTests.liquidLimit)
        
        labResult = newLabResult
        
    }
    
    func loadData() {
        if defaults.double(forKey: K.laboratoryTests.threeInch) == 0 {
            threeInchLabel.text = ""
        } else {
            threeInchLabel.text = String(defaults.double(forKey: K.laboratoryTests.threeInch))
        }
        
        if defaults.double(forKey: K.laboratoryTests.threeFourInch) == 0 {
            threeFourInchLabel.text = ""
        } else {
            threeFourInchLabel.text = String(defaults.double(forKey:  K.laboratoryTests.threeFourInch))
        }
       
        if defaults.double(forKey: K.laboratoryTests.noFour) == 0 {
            noFourLabel.text = ""
        } else {
            noFourLabel.text = String(defaults.double(forKey: K.laboratoryTests.noFour))
        }
        
        if defaults.double(forKey: K.laboratoryTests.noTen) == 0 {
            noTenLabel.text = ""
        } else {
            noTenLabel.text = String(defaults.double(forKey: K.laboratoryTests.noTen))
        }
        
        if defaults.double(forKey: K.laboratoryTests.noFourty) == 0 {
            noFourtyLabel.text = ""
        } else {
            noFourtyLabel.text = String(defaults.double(forKey: K.laboratoryTests.noFourty))
        }
        
        if defaults.double(forKey: K.laboratoryTests.noTwoHundred) == 0 {
            noTwoHundredLabel.text = ""
        } else {
            noTwoHundredLabel.text = String(defaults.double(forKey: K.laboratoryTests.noTwoHundred))
        }
        
        if defaults.double(forKey: K.laboratoryTests.pan) == 0 {
            panLabel.text = ""
        } else {
            panLabel.text = String(defaults.double(forKey: K.laboratoryTests.pan))
        }
       
        if defaults.double(forKey: K.laboratoryTests.plasticLimit) == 0 {
            plasticLimitLabel.text = ""
        } else {
            plasticLimitLabel.text = String(defaults.double(forKey: K.laboratoryTests.plasticLimit))
        }
        
        if defaults.double(forKey: K.laboratoryTests.liquidLimit) == 0 {
            liquidLimitLabel.text = ""
        } else {
            liquidLimitLabel.text = String(defaults.double(forKey: K.laboratoryTests.liquidLimit))
        }
        
        if defaults.double(forKey: K.laboratoryTests.wetWeight) == 0 {
            wetWeightLabel.text = ""
        } else {
            wetWeightLabel.text = String(defaults.double(forKey: K.laboratoryTests.wetWeight))
        }
       
        driedLabel.text = String(defaults.double(forKey: K.laboratoryTests.driedWeight))
    }
}

//MARK: - Text field delegate

extension TestResultsViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let threeInch = Double(threeInchLabel.text ?? "0.0") ?? 0.0
        let threeFourInch = Double(threeFourInchLabel.text ?? "0.0") ?? 0.0
        let noFour = Double(noFourLabel.text ?? "0.0") ?? 0.0
        let noTen = Double(noTenLabel.text ?? "0.0") ?? 0.0
        let noFourty = Double(noFourtyLabel.text ?? "0.0") ?? 0.0
        let noTwoHundred = Double(noTwoHundredLabel.text ?? "0.0") ?? 0.0
        let pan = Double(panLabel.text ?? "0.0") ?? 0.0
        let cum = threeInch + threeFourInch + noFour + noTen + noFourty + noTwoHundred + pan
        
        driedLabel.text = String(cum)
    }
}
