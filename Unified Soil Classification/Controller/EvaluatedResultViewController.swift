//
//  EvaluatedResultViewController.swift
//  Unified Soil Classification
//
//  Created by Aybatu Kerküklüoğlu on 3.10.2021.
//

import UIKit
import CoreData

class EvaluatedResultViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var soilLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var soilClassificationModel = SoilClassificationModel()
    private var testResultsCalculation = TestResultsCalculationModel()
    private var imagePicker = UIImagePickerController()
    var sample: Sample? {
        didSet {
            loadSampleData()
        }
    }
    var buttonIsHidden = false
    
    var laboratoryTestResults: LabResultDefault? {
        didSet {
            testResultsCalculation.soilEvaluation(threeInch: laboratoryTestResults?.threeInch ?? 0.0, threeFourInch: laboratoryTestResults?.threeFourInch ?? 0.0, noFour: laboratoryTestResults?.no4 ?? 0.0, noTen: laboratoryTestResults?.no10 ?? 0.0, noFourty: laboratoryTestResults?.no40 ?? 0.0, noTwoHundred: laboratoryTestResults?.no200 ?? 0.0, pan: laboratoryTestResults?.pan ?? 0.0, plasticLimit: laboratoryTestResults?.pL ?? 0.0, liquidLimit: laboratoryTestResults?.lL ?? 0.0, driedWeight: laboratoryTestResults?.driedWeight ?? 0.0, notDriedWeight: laboratoryTestResults?.wetWeight ?? 0.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        saveButton.isHidden = buttonIsHidden
        discardButton.isHidden = buttonIsHidden
        loadResultViewData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tappedOnView)))
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
        sender.alpha = 0.4
        Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: false ) { timer in
            sender.alpha = 1
        }
        
        if nameField.text == "" {
            let alert = UIAlertController(title: "Please Enter A Title", message: "You must specify a Sample Name before saving a new sample.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            let newLaboratoryResult = LaboratoryResults(context: context)
            
            newLaboratoryResult.threeInch = laboratoryTestResults!.threeInch
            newLaboratoryResult.threeFourInch = laboratoryTestResults!.threeFourInch
            newLaboratoryResult.no4 = laboratoryTestResults!.no4
            newLaboratoryResult.no10 = laboratoryTestResults!.no10
            newLaboratoryResult.no40 = laboratoryTestResults!.no40
            newLaboratoryResult.no200 = laboratoryTestResults!.no200
            newLaboratoryResult.pan = laboratoryTestResults!.pan
            newLaboratoryResult.plasticLimit = laboratoryTestResults!.pL
            newLaboratoryResult.liquidLimit = laboratoryTestResults!.lL
            newLaboratoryResult.wetWeight = laboratoryTestResults!.wetWeight
            newLaboratoryResult.driedWeight = laboratoryTestResults!.driedWeight

            let newSample = Sample(context: context)
            if let comment = commentField.text {
                newSample.comment = comment
            }
            newSample.uuid = UUID().uuidString
            newSample.name = nameField.text
            newSample.img = imageView.image?.pngData()
            newLaboratoryResult.parentSample = newSample
           
            saveData()
            performSegue(withIdentifier: K.Segue.resultViewToTableView, sender: self)
        }
    }
    
    @IBAction func discardPressed(_ sender: UIButton) {
        sender.alpha = 0.4
        Timer.scheduledTimer(withTimeInterval: 0.2 , repeats: false ) { timer in
            sender.alpha = 1
        }
        
        let alert = UIAlertController(title: "Discard?", message: "All data will be lost if you discard the sample. Are you sure?", preferredStyle: .alert)
        let discard = UIAlertAction(title: "Discard", style: .default) { action in
            self.resignFirstResponder()
            let lastData = UserDefaults.standard
            lastData.set(0, forKey: K.laboratoryTests.threeInch)
            lastData.set(0, forKey: K.laboratoryTests.threeFourInch)
            lastData.set(0, forKey: K.laboratoryTests.noFour)
            lastData.set(0, forKey: K.laboratoryTests.noTen)
            lastData.set(0, forKey: K.laboratoryTests.noFourty)
            lastData.set(0, forKey: K.laboratoryTests.noTwoHundred)
            lastData.set(0, forKey: K.laboratoryTests.pan)
            lastData.set(0, forKey: K.laboratoryTests.driedWeight)
            lastData.set(0, forKey: K.laboratoryTests.wetWeight)
            lastData.set(0, forKey: K.laboratoryTests.plasticLimit)
            lastData.set(0, forKey: K.laboratoryTests.liquidLimit)
           
            self.nameField.text = ""
            self.commentField.text = ""
            self.laboratoryTestResults = self.newLabTest(data: nil)
            self.loadResultViewData()
        }
       
        let dontDiscard = UIAlertAction(title: "Don't Discard", style: .default) { action in
            self.resignFirstResponder()
        }
        alert.addAction(discard)
        alert.addAction(dontDiscard)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Pick Image", message: "Pick an image from gallery or take a new photo.", preferredStyle: .alert)
        
        let galleryAction = UIAlertAction(title: "Open Gallery", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {

                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        let cameraAction = UIAlertAction(title: "Take a New Photo", style: .default) { alert in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
                {
                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                self.present(self.imagePicker, animated: true, completion: nil)
                }
        }
        
        alert.addAction(galleryAction)
        alert.addAction(cameraAction)
        
        present(alert, animated: true) {
            alert.view.superview?.isUserInteractionEnabled = true
                  alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        }
        
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
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
        let samplePredicate = NSPredicate(format: "parentSample.uuid MATCHES %@", sample!.uuid!)

        request.predicate = samplePredicate

        do {
            let data = try context.fetch(request).first
            laboratoryTestResults = newLabTest(data: data)
        } catch {
            print("Error fetch predicate sample: \(error)")
        }
    }
    
    func newLabTest(data: LaboratoryResults?) -> LabResultDefault? {
        var newLabResults = LabResultDefault()
        
        newLabResults.threeInch = data?.threeInch ?? 0.0
        newLabResults.threeFourInch = data?.threeFourInch ?? 0.0
        newLabResults.no4 = data?.no4 ?? 0.0
        newLabResults.no10 = data?.no10 ?? 0.0
        newLabResults.no40 = data?.no40 ?? 0.0
        newLabResults.no200 = data?.no200 ?? 0.0
        newLabResults.pan = data?.pan ?? 0.0
        newLabResults.pL = data?.plasticLimit ?? 0.0
        newLabResults.lL = data?.liquidLimit ?? 0.0
        newLabResults.wetWeight = data?.wetWeight ?? 0.0
        newLabResults.driedWeight = data?.driedWeight ?? 0.0
        
        return newLabResults
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
        
        let lL = laboratoryTestResults?.lL ?? 0.0
        let pL = laboratoryTestResults?.pL ?? 0.0
        let organicConstant = testResultsCalculation.organicConstant
        let cc = testResultsCalculation.cC
        let cu = testResultsCalculation.cU
         
        soilLabel.text = soilClassificationModel.classificateSoil(d60: d60, d30: d30, d10: d10, threeIncPer: threeIncPer, threeFourPer:threeFourPer, noFourPer: noFourPer, noTenPer: noTenPer, noFourtyPer: noFourtyPer, noTwoHundredPer: noTwoHundredPer, lL: lL, pL: pL, organicConstant: organicConstant, cc: cc, cu: cu)
        if let sample = sample {
            if let sampleComment = sample.comment {
                commentField.text = sampleComment
            }
            
            if let sampleImg = sample.img {
                let image = UIImage(data: sampleImg)
                imageView.contentMode = .scaleAspectFill
                imageView.image = image
            }
            
            guard let sampleName = sample.name else {
                fatalError()
            }
            nameField.text = sampleName
        }
        
        
        if soilLabel.text == "Check test results you have entered, soil type couldn't identified." {
            soilLabel.backgroundColor = .systemRed
        } else {
            soilLabel.backgroundColor = .systemGreen
        }
    }
}
//MARK: - UIImagaPicker Delegate Methods
extension EvaluatedResultViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError()
        }
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
    }
}
