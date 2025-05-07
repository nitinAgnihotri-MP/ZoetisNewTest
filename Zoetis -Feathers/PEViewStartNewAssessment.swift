//
//  PEStartNewAssessment.swift
//  Zoetis -Feathers
//
//  Created by "" ""on 13/12/19.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import CoreData

class PEViewStartNewAssessment: BaseViewController {
    
    
    var deviceIDFORSERVER = ""
    var saveTypeString : [Int] = []
    var inovojectData : [InovojectData] = []
    var dayOfAgeData : [InovojectData] = []
    var dayOfAgeSData : [InovojectData] = []
    var certificateData : [PECertificateData] = []
    var callRequest4Int = 0
    var totalImageToSync : [Int] = []
    var peAssessmentSyncArray : [PENewAssessment] = []
    var peHeaderViewController:PEHeaderViewController!
    var peNewAssessment:PENewAssessment!
    let dropdownManager = ZoetisDropdownShared.sharedInstance
    var jsonRe : JSON = JSON()
    var pECategoriesAssesmentsResponse =  PECategoriesAssesmentsResponse(nil)
    var isFlockAgeGreaterTheAllProd : Bool = false
    var isFlockAgeGreaterThen50Weeks : Bool = false
    var constantToSave : String = "S"
    var  regionID = Int()
    var draftArray = [PENewAssessment]()
    var editExtendedMicro = String()
    
    @IBOutlet weak var inventoryView: UIView!
    @IBOutlet weak var extendedPELbl: PEFormLabel!
    @IBOutlet weak var extendedPESwitch: UISwitch!
    @IBOutlet weak var btn_MoveToDraft: UIButton!
    @IBOutlet weak var chlorineStripsSwitch: UISwitch!
    @IBOutlet weak var heightFlockAge: NSLayoutConstraint!
    @IBOutlet weak var topIncubation: NSLayoutConstraint!
    @IBOutlet weak var heightIncubation: NSLayoutConstraint!
    @IBOutlet weak var topBreed: NSLayoutConstraint!
    @IBOutlet weak var heightBreed: NSLayoutConstraint!
    @IBOutlet weak var syncWebBtn: UIButton!
    @IBOutlet weak var manfacturerOtherBtn: customButton!
    @IBOutlet weak var manfacturerOtherTxt: PEFormTextfield!
    @IBOutlet weak var isAutomaticFailView: UIView!
    @IBOutlet weak var isAutomaticSwitch: UISwitch!
    @IBOutlet weak var isAutomaticHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var eggsOtherBtn: customButton!
    @IBOutlet weak var eggsOtherTxt: PEFormTextfield!
    @IBOutlet weak var notesTop: NSLayoutConstraint!
    @IBOutlet weak var heightManufacturerView: NSLayoutConstraint!
    @IBOutlet weak var heightNumberOfEggsView: NSLayoutConstraint!
    @IBOutlet weak var selectedEvaluationDateText: UITextField!
    @IBOutlet weak var selectedCustomerText: UITextField!
    @IBOutlet weak var selectedSiteText: UITextField!
    @IBOutlet weak var selectedEvaluatorText: UITextField!
    @IBOutlet weak var selectedTSR: UITextField!
    @IBOutlet weak var selectedEvaluationType: UITextField!
    @IBOutlet weak var selectedVisitText: UITextField!
    @IBOutlet weak var customerButton: customButton!
    @IBOutlet weak var siteButton: customButton!
    @IBOutlet weak var evaluatorButton: customButton!
    @IBOutlet weak var visitButton: customButton!
    @IBOutlet weak var evaluationTypeButton: customButton!
    @IBOutlet weak var tsrButton: customButton!
    @IBOutlet weak var hatcherySwitch: UISwitch!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cameraSwitch: UISwitch!
    @IBOutlet weak var evaluationDateButton: customButton!
    @IBOutlet weak var labelEvaluationDate: PEFormLabel!
    @IBOutlet weak var labelCustomer: PEFormLabel!
    @IBOutlet weak var labelSite: PEFormLabel!
    @IBOutlet weak var labelEvaluationType: PEFormLabel!
    @IBOutlet weak var labelReasonForVisit: PEFormLabel!
    @IBOutlet weak var labelApprover: PEFormLabel!
    @IBOutlet weak var labelEvaluator: PEFormLabel!
    @IBOutlet weak var btnNext: PESubmitButton!
    @IBOutlet weak var viewForGradient: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var manufacturerButton: customButton!
    @IBOutlet weak var txtManufacturer: PEFormTextfield!
    @IBOutlet weak var txtNumberOfEggs: PEFormTextfield!
    @IBOutlet weak var numberOfEggsButton: customButton!
    @IBOutlet weak var btnFlockAgeGreater: UIButton!
    @IBOutlet weak var btnFlockImageLower: UIButton!
    @IBOutlet weak var flockView: UIView!
    @IBOutlet weak var flockAgeLower: UILabel!
    @IBOutlet weak var btnBreed: customButton!
    @IBOutlet weak var btnBreedOthers: customButton!
    @IBOutlet weak var btnIncubation: customButton!
    @IBOutlet weak var btnIncubationOthers: customButton!
    @IBOutlet weak var txtBreedOfBird: PEFormTextfield!
    @IBOutlet weak var txtBreedOfBirdsOthers: PEFormTextfield!
    @IBOutlet weak var txtIncubation: PEFormTextfield!
    @IBOutlet weak var txtIncubationOthers: PEFormTextfield!
    @IBOutlet weak var handmixSwitch: UISwitch!
    
    fileprivate func viewDidLoadRefactoringPart1(_ strdate1: String, _ defautUsername: String) {
        if peNewAssessment.evaluationDate == "" {
            selectedEvaluationDateText.text = strdate1
            self.peNewAssessment.evaluationDate = strdate1
        } else {
            selectedEvaluationDateText.text = peNewAssessment.evaluationDate ?? strdate1
        }
        self.peNewAssessment.evaluationID = peNewAssessment.evaluationID
        selectedEvaluatorText.text =  peNewAssessment.evaluatorName ?? defautUsername
        selectedEvaluationType.text = peNewAssessment.evaluationName ?? ""
        
        if self.peNewAssessment.manufacturer?.count ?? "".count > 0 {
            txtManufacturer.text = self.peNewAssessment.manufacturer
        }
        if self.peNewAssessment.noOfEggs ?? 0 > 0 {
            txtNumberOfEggs.text = String(self.peNewAssessment.noOfEggs ?? 0)
        }
   
        if let character = peNewAssessment.breedOfBird?.character(at: 1), character == constantToSave.character(at: 0) {
            showBreedOthers()
            let str = peNewAssessment.breedOfBird?.replacingOccurrences(of: constantToSave, with: "")
            txtBreedOfBirdsOthers.text = str
            txtBreedOfBird.text = "Other"
        }

        
        if peNewAssessment.breedOfBird == "Other"{
            showBreedOthers()
        } else {
            hideBreedOthers()
        }
        txtBreedOfBird.text = self.peNewAssessment.breedOfBird
        
        if let character = peNewAssessment.breedOfBird?.character(at: 1), character == constantToSave.character(at: 0) {
            showBreedOthers()
            let str = peNewAssessment.breedOfBird?.replacingOccurrences(of: constantToSave, with: "")
            txtBreedOfBirdsOthers.text = str
            txtBreedOfBird.text = "Other"
        }

        
        txtBreedOfBirdsOthers.text =    self.peNewAssessment.breedOfBirdOther
        txtIncubation.text =  self.peNewAssessment.incubation
        txtIncubationOthers.text =   self.peNewAssessment.incubationOthers
    }
    
    fileprivate func viewDidLoadRefactoringPart2() {
        if selectedEvaluationType.text == "" {
            hideFlockView()
        } else {
            if selectedEvaluationType.text?.contains("Non") ?? false  {
                self.flockAgeLower.isHidden = true
                self.btnFlockImageLower.isHidden = true
                self.heightFlockAge.constant = 51
            } else {
                self.flockAgeLower.isHidden = false
                self.btnFlockImageLower.isHidden = false
                self.heightFlockAge.constant = 78
            }
            showFlockView()
            
        }
        
        selectedVisitText.text =  peNewAssessment.visitName ?? ""
        if peNewAssessment.camera == 1{
            cameraSwitch.setOn(true, animated: false)
        } else {
            cameraSwitch.setOn(false, animated: false)
        }
        if peNewAssessment.hatcheryAntibiotics == 1{
            hatcherySwitch.setOn(true, animated: false)
        } else {
            hatcherySwitch.setOn(false, animated: false)
        }
        
        if peNewAssessment.isHandMix == true{
            
            handmixSwitch.setOn(true, animated: false)
        } else {
            handmixSwitch.setOn(false, animated: false)
        }
        
        labelEvaluationDate.addLabelWithAstric(placeHolder: "Evaluation Date")
        labelCustomer.addLabelWithAstric(placeHolder: "Customer")
        labelSite.addLabelWithAstric(placeHolder: "Site")
        labelEvaluationType.addLabelWithAstric(placeHolder: "Evaluation Type")
        labelReasonForVisit.addLabelWithAstric(placeHolder: "Reason for visit")
        labelEvaluator.addLabelWithAstric(placeHolder: "Evaluator")
        peNewAssessment.evaluatorName =  UserDefaults.standard.value(forKey: "FirstName") as? String ?? ""
        let userID =  UserDefaults.standard.value(forKey:"Id") as? Int ?? 0
        peNewAssessment.evaluatorID = userID
        selectedTSR.text = peNewAssessment.selectedTSR
        if peNewAssessment.selectedTSR?.count ?? 0 > 1 {
            selectedTSR.text = peNewAssessment.selectedTSR
        }
        else {
            print(appDelegateObj.testFuntion())
        }
    }
    
    fileprivate func viewDidLoadRefactoringPart3() {
        if txtManufacturer.text != "", let character = peNewAssessment.manufacturer?.character(at: 0) {
            if txtManufacturer.text == "Other" {
                showManufacturerOthers()
            }
            if character == constantToSave.character(at: 0) {
                showManufacturerOthers()
                let str = peNewAssessment.manufacturer?.replacingOccurrences(of: constantToSave, with: "")
                manfacturerOtherTxt.text = str
                txtManufacturer.text = "Other"
            }
        }

        let xx = String(self.peNewAssessment.noOfEggs ?? 000)
        if xx != "0" {
            let last3 = String(xx.suffix(3))
            if last3 ==  "000" {
                showEggsOthers()
                let str =  xx.replacingOccurrences(of: "000", with: "")
                eggsOtherTxt.text = str
                txtNumberOfEggs.text = "Other"
            }
        }
        manfacturerOtherTxt.isUserInteractionEnabled = false
        eggsOtherTxt.isUserInteractionEnabled = false
        txtManufacturer.isUserInteractionEnabled = false
        txtNumberOfEggs.isUserInteractionEnabled = false
        if peNewAssessment.isFlopSelected == 1 ||  peNewAssessment.isFlopSelected == 3 ||  peNewAssessment.isFlopSelected == 4 {
            isFlockAgeGreaterTheAllProd = true
            btnFlockAgeGreater.setImage(UIImage(named: "checkIconPE"), for: .normal)
            isFlockAgeGreaterThen50Weeks = false
            btnFlockImageLower.setImage(UIImage(named: "uncheckIconPE"), for: .normal)
        } else  if peNewAssessment.isFlopSelected == 2 ||  peNewAssessment.isFlopSelected == 5  {
            isFlockAgeGreaterTheAllProd = false
            btnFlockAgeGreater.setImage(UIImage(named: "uncheckIconPE"), for: .normal)
            isFlockAgeGreaterThen50Weeks = true
            btnFlockImageLower.setImage(UIImage(named: "checkIconPE"), for: .normal)
        }
       
        if peNewAssessment?.isChlorineStrip ?? 0 == 1{
            chlorineStripsSwitch.isOn = true
        }else{
            chlorineStripsSwitch.isOn = false
        }
    }
    
    override func viewDidLoad() {
        print("<<<<",self)
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        regionID = UserDefaults.standard.integer(forKey: "Regionid")
        btn_MoveToDraft.isHidden = true
        let dateFormatter = DateFormatter()
        setupUI()
        dateFormatter.dateFormat=Constants.MMddyyyyStr
        let currentDate: NSDate = NSDate()
        let strdate1 = dateFormatter.string(from: currentDate as Date) as String
        self.cameraSwitch.tintColor = UIColor.getTextViewBorderColorStartAssessment()
        self.extendedPESwitch.tintColor = UIColor.getTextViewBorderColorStartAssessment()
        self.hatcherySwitch.tintColor = UIColor.getTextViewBorderColorStartAssessment()
        self.chlorineStripsSwitch.tintColor = UIColor.getTextViewBorderColorStartAssessment()
        self.isAutomaticSwitch.tintColor = UIColor.getTextViewBorderColorStartAssessment()
        peHeaderViewController = PEHeaderViewController()
        peHeaderViewController.titleOfHeader = "View Assessment"
        peHeaderViewController.assId = "C-\(peNewAssessment.dataToSubmitID!)"
        self.headerView.addSubview(peHeaderViewController.view)
        self.topviewConstraint(vwTop: peHeaderViewController.view)
        
        notesTextView.delegate = self
        notesTextView.layer.borderColor = UIColor.getTextViewBorderColorStartAssessment().cgColor
        notesTextView.textContainer.lineFragmentPadding = 12
        notesTextView.text = ""
        notesTextView.text =  peNewAssessment.notes
        selectedCustomerText.text = peNewAssessment.customerName
        selectedSiteText.text =  peNewAssessment.siteName
        let defautUsername =  UserDefaults.standard.value(forKey: "FirstName") as? String ?? ""
        
        viewDidLoadRefactoringPart1(strdate1, defautUsername)
        
        viewDidLoadRefactoringPart2()
        hideManufacturerOthers()
        hideEggsOthers()
        txtManufacturer.text = self.peNewAssessment.manufacturer ?? ""
        viewDidLoadRefactoringPart3()
        if peNewAssessment?.isAutomaticFail ?? 0 == 1{
            isAutomaticSwitch.isOn = true
        }else{
            isAutomaticSwitch.isOn = false
        }
        if chlorineStripsSwitch.isOn{
            self.isAutomaticHeightConstraints.constant = 0
            self.isAutomaticFailView.isHidden = true
        }else{
            self.isAutomaticHeightConstraints.constant = 40
            self.isAutomaticFailView.isHidden = false
        }
        
        showExtendedPE()
        enableExtendedPE(flag:false)
        
        extendedPESwitch.isOn = peNewAssessment.sanitationValue ?? false
        
        if peNewAssessment.evaluationID != nil{
            if peNewAssessment.evaluationID == 1{
                self.inventoryView.isHidden = false
            }else{
                self.peNewAssessment.isHandMix = false
                self.inventoryView.isHidden = true
            }
        }
        else{
            self.peNewAssessment.isHandMix = false
            self.inventoryView.isHidden = true
        }
    }
    
    // MARK: - Assign Constraint
    fileprivate func handleRightConstAssignConstraintValidation(_ rightConst: Int, _ leftConst: Int) {
        switch rightConst {
        case 1:
                notesTop.constant = CGFloat((leftConst * 55 ) + 40 )
            
        case 2:
                notesTop.constant = CGFloat((leftConst * 55 ) + 20 )
            
        default:
            if heightNumberOfEggsView.constant == 94{
                notesTop.constant = CGFloat((leftConst * 55 ) + 40)
            }else{
                notesTop.constant = CGFloat((leftConst * 55 ) + 60)
            }
        }
    }
    
    fileprivate func handleRightConstAssignConstraintValidationCase2(_ rightConst: Int, _ leftConst: Int) {
        switch rightConst {
            
        case 1:
         
                notesTop.constant = CGFloat((leftConst * 55 ) + 20 )
            
        case 2:
         
                notesTop.constant = CGFloat((leftConst * 55 ) - 50)
            
        default:
            if heightNumberOfEggsView.constant == 94{
                notesTop.constant = CGFloat((leftConst * 55 ) + 20)
            }else{
                notesTop.constant = CGFloat((leftConst * 55 ) + 50)
            }
        }
    }
    
    fileprivate func handleRightConstAssignConstraintValidationCase3(_ rightConst: Int, _ leftConst: Int) {
        switch rightConst {
            
        case 1:
           
                notesTop.constant = CGFloat((leftConst * 55 ) - 30)
            
        case 2:
        
                notesTop.constant = CGFloat((leftConst * 55 ) - 75)
            
        default:
            if heightNumberOfEggsView.constant == 94{
                notesTop.constant = CGFloat(leftConst * 55 )
            }else{
                notesTop.constant = CGFloat((leftConst * 55 ) + 20)
            }
        }
    }
    
    func assignConstraint(otherEgg:Int = 0){
        let leftConst = leftConstraint()
        var rightConst = rightConstraint()
        if rightConst == 3 {
            rightConst = 2
        }
        
        switch leftConst {
        case 0:
            handleRightConstAssignConstraintValidation(rightConst, leftConst)
        case 1:
            handleRightConstAssignConstraintValidationCase2(rightConst, leftConst)
        case 2:
            handleRightConstAssignConstraintValidationCase3(rightConst, leftConst)
            
        default:
            break;
        }
        
    }
    
    // MARK: - Setup Left Constraint
    func leftConstraint() -> Int{
        var otherCount = 0
        if peNewAssessment.breedOfBird == "Other"{
            otherCount += 1
        }
        if peNewAssessment.evaluationID != nil && peNewAssessment.evaluationID == 1{
            otherCount += 1
        }
        return otherCount
    }
    // MARK: - Setup Right Constraint
    func rightConstraint()-> Int{
        var otherCount = 0
        
        if let manufacturerText = self.txtManufacturer.text?.lowercased(), manufacturerText.contains("other") || manufacturerText.contains("s") {
            otherCount += 1
        }
        
        let xx = String(self.peNewAssessment.noOfEggs ?? 000)
        if xx != "0" {
            let last3 = String(xx.suffix(3))
            if last3 ==  "000" {
                otherCount += 1
                
            }
        }
        return otherCount
    }
    
    
    // MARK: - Show Extended PE View
    func showExtendedPE(flag:Bool = false){
        extendedPELbl.isHidden = flag
        extendedPESwitch.isHidden = flag
    }
    // MARK: - Enable Extended Microbial
    func enableExtendedPE(flag:Bool = true){
        extendedPELbl.isUserInteractionEnabled = flag
        extendedPESwitch.isUserInteractionEnabled = flag
    }
    
    // MARK: - Hide Manufacturer Other View
    func hideManufacturerOthers(){
        assignConstraint()
        heightManufacturerView.constant = 45
        manfacturerOtherBtn.isHidden = true
        manfacturerOtherTxt.isHidden = true
        self.view.layoutIfNeeded()
    }
    // MARK: - Show Manufacturer Other View
    func showManufacturerOthers(){
        assignConstraint()
        heightManufacturerView.constant = 94
        manfacturerOtherBtn.isHidden = false
        manfacturerOtherTxt.isHidden = false
        self.view.layoutIfNeeded()
    }
    // MARK: - Hide Egg Other View
    func hideEggsOthers(){
        heightNumberOfEggsView.constant = 45
        assignConstraint()
        eggsOtherBtn.isHidden = true
        eggsOtherTxt.isHidden = true
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Show Egg Other View
    func showEggsOthers(){
        
        heightNumberOfEggsView.constant = 94
        assignConstraint()
        eggsOtherBtn.isHidden = false
        eggsOtherTxt.isHidden = false
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Hide Flock View
    func hideFlockView(){
        flockView.isHidden = true
        heightFlockAge.constant = 0
    }
    // MARK: - Show Flock View
    func showFlockView(){
        flockView.isHidden = false
    }

    // MARK: - Setup UI Method
    fileprivate func handleNavigation(_ superviewCurrent: UIView?) {
        for view in superviewCurrent!.subviews {
            if view.isKind(of:UIButton.self) {
                if view == evaluationDateButton{
                    view.setDropdownStartAsessmentView(imageName:"calendarIconPE")
                } else{
                    view.setDropdownStartAsessmentView(imageName:"dd")
                }
            }
        }
    }
    
    func setupUI(){
        btnNext.setNextButtonUI()
        syncWebBtn.setSyncWebButtonUI()
        viewForGradient.setGradientThreeColors(topGradientColor: UIColor.getGradientUpperColorStartAssessment(),midGradientColor:UIColor.getGradientUpperColorStartAssessmentMid(), bottomGradientColor: UIColor.getGradientUpperColorStartAssessmentLast())
        containerView.setCornerRadiusFloat(radius: 23)
        viewForGradient.setCornerRadiusFloat(radius: 23)
        let btns = [customerButton,siteButton,evaluatorButton,visitButton,evaluationTypeButton,tsrButton,evaluationDateButton,btnBreed,btnBreedOthers,btnIncubation,btnIncubationOthers,manufacturerButton,numberOfEggsButton]
        customerButton.isUserInteractionEnabled = false
        siteButton.isUserInteractionEnabled = false
        customerButton.isEnabled = false
        customerButton.alpha = 0.6
        siteButton.isEnabled = false
        siteButton.alpha = 0.6
        
        for btn in btns{
            let superviewCurrent =  btn?.superview
            if superviewCurrent != nil{
                handleNavigation(superviewCurrent)
            }
        }
        notesTextView.layer.cornerRadius = 12
        notesTextView.layer.masksToBounds = true
        notesTextView.layer.borderColor = UIColor.getTextViewBorderColorStartAssessment().cgColor
        notesTextView.layer.borderWidth = 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.btn_MoveToDraft.isHidden = true
        let allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsWithAssIDFor(entityName: "PE_AssessmentInOffline", assId: peNewAssessment.serverAssessmentId ?? "")
        let carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "dataToSubmitNumber") as? NSArray ?? []
        
        
        var carColIdArrayDraft : [Int] = []
        
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArrayDraft.contains(obj as? Int ?? 0){
                carColIdArrayDraft.append(obj as? Int ?? 0)
            }
        }
        
        navigationController?.navigationBar.isHidden = true
        if self.peNewAssessment.hatcheryAntibiotics == 1{
            self.hatcherySwitch.isOn = true//hatcherySwitch.isOn
        } else{
            self.hatcherySwitch.isOn = false
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ZoetisDropdownShared.sharedInstance.sharedPEOnGoingSession[0].peNewAssessment = peNewAssessment
    }
    
    // MARK: - Get All Drafted Assessments Stored in DB
    private func getAllDateArrayStored() -> [String]{
        let drafts  = CoreDataHandlerPE().getDraftAssessmentArrayPEObject()
        var dates : [String] = []
        var coustomers : [String] = []
        var sites : [String] = []
        for obj in drafts {
            dates.append(obj.evaluationDate ?? "")
            coustomers.append(obj.customerName ?? "")
            sites.append(obj.siteName ?? "")
        }
        let syncData =  CoreDataHandlerPE().getOfflineAssessmentArrayPEObject()
        for obj in syncData {
            dates.append(obj.evaluationDate ?? "")
            coustomers.append(obj.customerName ?? "")
            sites.append(obj.siteName ?? "")
        }
        return dates
    }
    // MARK: - Get All Customer's Stored in DB
    private func getAllCustomerArrayStored() -> [String]{
        let drafts  = CoreDataHandlerPE().getDraftAssessmentArrayPEObject()
        var dates : [String] = []
        var coustomers : [String] = []
        var sites : [String] = []
        for obj in drafts {
            dates.append(obj.evaluationDate ?? "")
            coustomers.append(obj.customerName ?? "")
            sites.append(obj.siteName ?? "")
        }
        let syncData =  CoreDataHandlerPE().getOfflineAssessmentArrayPEObject()
        for obj in syncData {
            dates.append(obj.evaluationDate ?? "")
            coustomers.append(obj.customerName ?? "")
            sites.append(obj.siteName ?? "")
        }
        return coustomers
    }
    // MARK: - Get All Sites Stored in DB
    private func getAllSitesArrayStored() -> [String]{
        let drafts  = CoreDataHandlerPE().getDraftAssessmentArrayPEObject()
        var dates : [String] = []
        var coustomers : [String] = []
        var sites : [String] = []
        for obj in drafts {
            dates.append(obj.evaluationDate ?? "")
            coustomers.append(obj.customerName ?? "")
            sites.append(obj.siteName ?? "")
        }
        let syncData =  CoreDataHandlerPE().getOfflineAssessmentArrayPEObject()
        for obj in syncData {
            dates.append(obj.evaluationDate ?? "")
            coustomers.append(obj.customerName ?? "")
            sites.append(obj.siteName ?? "")
        }
        return sites
    }
    
    @IBAction func btnAction(_ sender: Any) {
        print(appDelegateObj.testFuntion())
    }
    // MARK: - Hide Breed Other
    func hideBreedOthers(){
        heightBreed.constant = 45
        btnBreedOthers.isHidden = true
        txtBreedOfBirdsOthers.isHidden = true
    }
    // MARK: - Show Breed Other
    func showBreedOthers(){
        heightBreed.constant = 104
        btnBreedOthers.isHidden = false
        txtBreedOfBirdsOthers.isHidden = false
    }
    // MARK: - Hide Incubation Other
    func hideIncubationOthers(){
        heightIncubation.constant = 45
        btnIncubationOthers.isHidden = true
        txtIncubationOthers.isHidden = true
    }
    // MARK: - Show Incubatio Other
    func showIncubationOthers(){
        heightIncubation.constant = 104
        btnIncubationOthers.isHidden = false
        txtIncubationOthers.isHidden = false
    }
    
    
    func hideTreeOthers(){
        heightManufacturerView.constant = 45
        btnIncubationOthers.isHidden = true
        txtIncubationOthers.isHidden = true
    }
    
    func showTreeOthers(){
        heightManufacturerView.constant = 94
        btnIncubationOthers.isHidden = false
        txtIncubationOthers.isHidden = false
    }
    // MARK: - Get Draft Count
    func getDraftCountFromDb() -> Int {
        var allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsWithUserIDForAny(entityName: "PE_AssessmentInDraft")
        _  = allAssesmentDraftArr.value(forKey: "draftNumber") as? NSArray ?? []
        _  = allAssesmentDraftArr.value(forKey: "serverAssessmentId") as? NSArray ?? []
        var carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "draftID") as? NSArray ?? []
        var carColIdArray : [String] = []
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArray.contains(obj as? String ?? ""){
                carColIdArray.append(obj as? String ?? "")
            }
        }
        return carColIdArray.count
    }
    // MARK: - Draft Button Action
    @IBAction func action_MoveToDraft(_ sender: Any) {
        print(appDelegateObj.testFuntion())
    }
    
    // MARK: - Next Button Action
    @IBAction func nextBtnAction(_ sender: Any) {
        Constants.isPPmValueChanged = false
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PEViewAssesmentFinalize") as! PEViewAssesmentFinalize
        vc.peNewAssessment = self.peNewAssessment
        self.navigationController?.pushViewController(vc, animated: true)
        return
        
    }
    
    func saveAssessmentInProgressDataInDB()  {
        print(appDelegateObj.testFuntion())
    }
    
  
    // MARK: - Evaluation Date Button Action
    @IBAction func evaluationDateClicked(_ sender: Any) {
        let superviewCurrent =  evaluationDateButton.superview
        if superviewCurrent != nil{
            for view in superviewCurrent!.subviews {
                if view.isKind(of:UIButton.self) {
                    view.layer.borderColor = UIColor.getTextViewBorderColorStartAssessment().cgColor
                    view.layer.borderWidth = 2.0
                }}
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Selection", bundle:nil)
        let datePickerPopupViewController = storyBoard.instantiateViewController(withIdentifier: "DatePickerPopupViewController") as! DatePickerPopupViewController
        datePickerPopupViewController.delegate = self
        datePickerPopupViewController.canSelectPreviousDate = true
        navigationController?.present(datePickerPopupViewController, animated: false, completion: nil)
        
        
    }
    
    // MARK: - Customer Button Action
    @IBAction func customerClicked(_ sender: Any) {
        let superviewCurrent =  customerButton.superview
        if superviewCurrent != nil{
            for view in superviewCurrent!.subviews {
                if view.isKind(of:UIButton.self) {
                    view.layer.borderColor = UIColor.getTextViewBorderColorStartAssessment().cgColor
                    view.layer.borderWidth = 2.0
                }}
        }
       
        var customerDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Customer")
        var customerNamesArray = customerDetailsArray.value(forKey: "customerName") as? NSArray ?? NSArray()
        var customerIDArray = customerDetailsArray.value(forKey: "customerID") as? NSArray ?? NSArray()
        if  customerNamesArray.count > 0 {
            self.dropDownVIewNew(arrayData: customerNamesArray as? [String] ?? [String](), kWidth: customerButton.frame.width, kAnchor: customerButton, yheight: customerButton.bounds.height) { [unowned self] selectedVal, index  in
                self.selectedCustomerText.text = selectedVal
                self.selectedSiteText.text = ""
                let indexOfItem = customerNamesArray.index(of: selectedVal)
                self.peNewAssessment.customerName = selectedVal
                self.peNewAssessment.siteName = ""
                self.peNewAssessment.customerId = customerIDArray[indexOfItem] as? Int
                
            }
            self.dropHiddenAndShow()
        }
    }
    
    // MARK: - Complex Site Button Clicked
    @IBAction func siteClicked(_ sender: Any) {
        
        let superviewCurrent =  siteButton.superview
        if superviewCurrent != nil{
            for view in superviewCurrent!.subviews {
                if view.isKind(of:UIButton.self) {
                    view.layer.borderColor = UIColor.lightGray.cgColor
                    view.layer.borderWidth = 2.0
                }}
        }
        
        guard let customer = self.peNewAssessment.customerName, customer.count > 0 else {
            return
        }

        var complexDetailsArray = CoreDataHandlerPE().fetchSitesWithCustId( self.peNewAssessment.customerId as NSNumber? ?? 0)
        var complexNamesArray = complexDetailsArray.value(forKey: "siteName") as? NSArray ?? NSArray()
        var complexIDArray = complexDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        
        if  complexNamesArray.count > 0 {
            self.dropDownVIewNew(arrayData: complexNamesArray as? [String] ?? [String](), kWidth: siteButton.frame.width, kAnchor: siteButton, yheight: siteButton.bounds.height) { [unowned self] selectedVal, index in
                self.selectedSiteText.text = selectedVal
                self.peNewAssessment.siteName = selectedVal
                let indexOfItem = complexNamesArray.index(of: selectedVal)
                self.peNewAssessment.siteId = complexIDArray[indexOfItem] as? Int
                self.saveAssessmentInProgressDataInDB()
            }
            self.dropHiddenAndShow()
        } else{
            print(appDelegateObj.testFuntion())
        }
    }
    // MARK: - Evaluator Button Clicked
    @IBAction func evaluatorClicked(_ sender: Any) {
        let superviewCurrent =  evaluatorButton.superview
        if superviewCurrent != nil{
            for view in superviewCurrent!.subviews {
                if view.isKind(of:UIButton.self) {
                    view.layer.borderColor = UIColor.getTextViewBorderColorStartAssessment().cgColor
                    view.layer.borderWidth = 2.0
                }}
        }
        
        var evaluatorIDArray = NSArray()
        var evaluatorNameArray = NSArray()
        var evaluatorDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Evaluator")
        evaluatorNameArray = evaluatorDetailsArray.value(forKey: "evaluatorName") as? NSArray ?? NSArray()
        evaluatorIDArray = evaluatorDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        if  evaluatorNameArray.count > 0 {
            self.dropDownVIewNew(arrayData: evaluatorNameArray as? [String] ?? [String](), kWidth: evaluatorButton.frame.width, kAnchor: evaluatorButton, yheight: evaluatorButton.bounds.height) { [unowned self] selectedVal, index  in
                self.selectedEvaluatorText.text = selectedVal
                self.peNewAssessment.evaluatorName = selectedVal
                let indexOfItem = evaluatorNameArray.index(of: selectedVal)
                self.peNewAssessment.evaluatorID = evaluatorIDArray[indexOfItem] as? Int
                self.saveAssessmentInProgressDataInDB()
            }
            self.dropHiddenAndShow()
        }
    }
    // MARK: - Visit Button Clicked
    @IBAction func visitClicked(_ sender: Any) {
        let superviewCurrent =  visitButton.superview
        if superviewCurrent != nil{
            for view in superviewCurrent!.subviews {
                if view.isKind(of:UIButton.self) {
                    view.layer.borderColor = UIColor.getTextViewBorderColorStartAssessment().cgColor
                    view.layer.borderWidth = 2.0
                }}
        }
        var visitIDArray = NSArray()
        var visitNameArray = NSArray()
        var visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VisitTypes")
        visitNameArray = visitDetailsArray.value(forKey: "visitName") as? NSArray ?? NSArray()
        visitIDArray = visitDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        if  visitNameArray.count > 0 {
            self.dropDownVIewNew(arrayData: visitNameArray as? [String] ?? [String](), kWidth: visitButton.frame.width, kAnchor: visitButton, yheight: visitButton.bounds.height) { [unowned self] selectedVal, index  in
                self.selectedVisitText.text = selectedVal
                self.peNewAssessment.visitName = selectedVal
                let indexOfItem = visitNameArray.index(of: selectedVal)
                self.peNewAssessment.visitID = visitIDArray[indexOfItem] as? Int
                self.saveAssessmentInProgressDataInDB()
            }
            self.dropHiddenAndShow()
        }
    }
    // MARK: - Evaluation Type Button Action
    @IBAction func evaluationClicked(_ sender: Any) {
        
        let superviewCurrent =  evaluationTypeButton.superview
        if superviewCurrent != nil{
            for view in superviewCurrent!.subviews {
                if view.isKind(of:UIButton.self) {
                    view.layer.borderColor = UIColor.getTextViewBorderColorStartAssessment().cgColor
                    view.layer.borderWidth = 2.0
                }}
        }
        
        var evaluationIDArray = NSArray()
        var evaluationNameArray = NSArray()
        var evaluationDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_EvaluationType")
        evaluationNameArray = evaluationDetailsArray.value(forKey: "evaluationName") as? NSArray ?? NSArray()
        evaluationIDArray = evaluationDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        if  evaluationNameArray.count > 0 {
            self.dropDownVIewNew(arrayData: evaluationNameArray as? [String] ?? [String](), kWidth: evaluationTypeButton.frame.width, kAnchor: evaluationTypeButton, yheight: evaluationTypeButton.bounds.height) { [unowned self] selectedVal, index  in
                self.selectedEvaluationType.text = selectedVal
                self.isFlockAgeGreaterTheAllProd = false
                self.isFlockAgeGreaterThen50Weeks  = false
                self.btnFlockAgeGreater.setImage(UIImage(named: "uncheckIconPE"), for: .normal)
                self.btnFlockImageLower.setImage(UIImage(named: "uncheckIconPE"), for: .normal)
                self.showFlockView()
                
                if selectedVal.contains("Non")  {
                    self.heightFlockAge.constant = 51
                    self.flockAgeLower.isHidden = true
                    self.btnFlockImageLower.isHidden = true
                } else {
                    self.heightFlockAge.constant = 78
                    self.flockAgeLower.isHidden = false
                    self.btnFlockImageLower.isHidden = false
                }
                
                self.peNewAssessment.evaluationName = selectedVal
                let indexOfItem = evaluationNameArray.index(of: selectedVal)
                self.peNewAssessment.evaluationID = evaluationIDArray[indexOfItem] as? Int
                self.saveAssessmentInProgressDataInDB()
            }
            self.dropHiddenAndShow()
        }
    }
    // MARK: - Flock Image Greater Action
    @IBAction func flockImageGreaterSlected(_ sender: Any) {
        self.peNewAssessment.isFlopSelected = 2
        if isFlockAgeGreaterTheAllProd {
            isFlockAgeGreaterTheAllProd = false
            btnFlockAgeGreater.setImage(UIImage(named: "uncheckIconPE"), for: .normal)
            isFlockAgeGreaterThen50Weeks = true
            btnFlockImageLower.setImage(UIImage(named: "checkIconPE"), for: .normal)
        } else {
            isFlockAgeGreaterTheAllProd = true
            btnFlockAgeGreater.setImage(UIImage(named: "checkIconPE"), for: .normal)
            isFlockAgeGreaterThen50Weeks = false
            btnFlockImageLower.setImage(UIImage(named: "uncheckIconPE"), for: .normal)
        }
        self.saveAssessmentInProgressDataInDB()
    }
    // MARK: - Flock Image Lower Action
    @IBAction func flockImageLowerSelected(_ sender: Any) {
        self.peNewAssessment.isFlopSelected = 3
        if isFlockAgeGreaterThen50Weeks {
            isFlockAgeGreaterTheAllProd = true
            btnFlockAgeGreater.setImage(UIImage(named: "checkIconPE"), for: .normal)
            isFlockAgeGreaterThen50Weeks = false
            btnFlockImageLower.setImage(UIImage(named: "uncheckIconPE"), for: .normal)
        } else {
            isFlockAgeGreaterTheAllProd = false
            btnFlockAgeGreater.setImage(UIImage(named: "uncheckIconPE"), for: .normal)
            isFlockAgeGreaterThen50Weeks = true
            btnFlockImageLower.setImage(UIImage(named: "checkIconPE"), for: .normal)
        }
        self.saveAssessmentInProgressDataInDB()
    }
    
    // MARK: - Button TSR Action
    @IBAction func tsrClicked(_ sender: Any) {
  
        let superviewCurrent =  tsrButton.superview
        if superviewCurrent != nil{
            for view in superviewCurrent!.subviews {
                if view.isKind(of:UIButton.self) {
                    view.layer.borderColor = UIColor.getTextViewBorderColorStartAssessment().cgColor
                    view.layer.borderWidth = 2.0
                }}
        }
        var visitIDArray = NSArray()
        var visitNameArray = NSArray()
        var visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Approvers")
        visitNameArray = visitDetailsArray.value(forKey: "username") as? NSArray ?? NSArray()
        visitIDArray = visitDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        if  visitNameArray.count > 0 {
            self.dropDownVIewNew(arrayData: visitNameArray as? [String] ?? [String](), kWidth: tsrButton.frame.width, kAnchor: tsrButton, yheight: tsrButton.bounds.height) { [unowned self] selectedVal, index  in
                self.selectedTSR.text = selectedVal
                self.peNewAssessment.selectedTSR = selectedVal
                let indexOfItem = visitNameArray.index(of: selectedVal)
                self.peNewAssessment.selectedTSRID = visitIDArray[indexOfItem] as? Int
                self.saveAssessmentInProgressDataInDB()
                
            }
            self.dropHiddenAndShow()
        }
    }
  
    // MARK: - Switch Action
    @IBAction func switchClicked(_ sender: Any) {
        if cameraSwitch.isOn {
            peNewAssessment.camera = 1
        } else {
            peNewAssessment.camera = 0
        }
        if hatcherySwitch.isOn {
            peNewAssessment.hatcheryAntibiotics = 1
        } else {
            peNewAssessment.hatcheryAntibiotics = 0
        }
        self.saveAssessmentInProgressDataInDB()
    }

    // MARK: - Button Breed Action
    @IBAction func btnBreedClicked(_ sender: Any) {
        self.dropDownVIewNew(arrayData: ["Breed1","Breed2","Breed3","Other"], kWidth: btnBreed.frame.width, kAnchor: btnBreed, yheight: btnBreed.bounds.height) { [unowned self] selectedVal, index  in
            self.txtBreedOfBird.text = selectedVal
            if selectedVal == "Other"{
                self.showBreedOthers()
            } else {
                self.hideBreedOthers()
            }
            if selectedVal == "Other"{
                self.txtBreedOfBird.text = selectedVal
                self.txtBreedOfBirdsOthers.text = ""
            }
            self.saveAssessmentInProgressDataInDB()
        }
        self.dropHiddenAndShow()
        
    }
    
    // MARK: - Button Incubation Action
    @IBAction func btnIncubationClicked(_ sender: Any) {
        self.dropDownVIewNew(arrayData: ["Style1","Style2","Style3","Other"], kWidth: btnIncubation.frame.width, kAnchor: btnIncubation, yheight: btnIncubation.bounds.height) { [unowned self] selectedVal, index  in
            self.peNewAssessment.selectedTSR = selectedVal
            
            self.txtIncubation.text = selectedVal
            if selectedVal == "Other"{
                self.peNewAssessment.breedOfBird = "Other"
                self.showIncubationOthers()
            } else {
                self.peNewAssessment.breedOfBird = selectedVal
                self.hideIncubationOthers()
            }
            self.saveAssessmentInProgressDataInDB()
        }
        self.dropHiddenAndShow()
        
    }
        
    // MARK: - DROP DOWN HIDDEN AND SHOW
    func dropHiddenAndShow(){
        if dropDown.isHidden{
            let _ = dropDown.show()
        } else {
            dropDown.hide()
        }
    }
}

// MARK: - Other Delegates
extension PEViewStartNewAssessment: DatePickerPopupViewControllerProtocol{
    func doneButtonTappedWithDate(string: String, objDate: Date) {
        let datesStored =  getAllDateArrayStored()
        let customerStored = getAllCustomerArrayStored()
        let sitesStored = getAllSitesArrayStored()
        if datesStored.contains(string) && customerStored.contains(self.peNewAssessment.customerName ?? "") && sitesStored.contains(self.peNewAssessment.siteName ?? "") {
            let superviewCurrent =  evaluationDateButton.superview
            if superviewCurrent != nil{
                for view in superviewCurrent!.subviews {
                    if view.isKind(of:UIButton.self) {
                        view.layer.borderColor = UIColor.red.cgColor
                        view.layer.borderWidth = 2.0
                    }}
            }
            showAlert(title: Constants.alertStr, message: "Assessment Data already Exists for this Customer, Site & Date combination", owner: self)
            return
        }  else {
            selectedEvaluationDateText.text = string
            self.peNewAssessment.evaluationDate = string
            saveAssessmentInProgressDataInDB()
        }
    }
    
    func doneButtonTapped(string:String){
        print(appDelegateObj.testFuntion())
    }
}

// MARK: - Other Delegates
extension PEViewStartNewAssessment{
    
    func getEvaluationFromBackend(){
        print(appDelegateObj.testFuntion())
    }
    
    // MARK: - Ok Button tabbed
    func okButtonTapped() {
        
        getEvaluationFromBackend()
        saveAssessmentInProgressDataInDB()
        jsonRe = (getJSON("QuestionAns") ?? JSON())
        pECategoriesAssesmentsResponse =  PECategoriesAssesmentsResponse(jsonRe)
        let categoryCount = filterCategoryCount()
        if categoryCount > 0 {

            let peNewAssessmentWas = self.peNewAssessment ?? PENewAssessment()
            
            CoreDataHandler().deleteAllData("PE_AssessmentInProgress",predicate: NSPredicate(format: "userID == %d AND serverAssessmentId = %@", peNewAssessmentWas.userID ?? 0, peNewAssessmentWas.serverAssessmentId ?? ""))
            CoreDataHandler().deleteAllData("PE_Refrigator")
            
            for  cat in  pECategoriesAssesmentsResponse.peCategoryArray {
                for (index, ass) in cat.assessmentQuestions.enumerated(){
                    
                    let peNewAssessmentNew = peNewAssessmentWas ?? PENewAssessment()
                    
                    peNewAssessmentNew.cID = index
                    peNewAssessmentNew.catID = cat.id
                    peNewAssessmentNew.catName = cat.categoryName
                    peNewAssessmentNew.catMaxMark = cat.maxMark
                    peNewAssessmentNew.sequenceNo = cat.sequenceNo
                    peNewAssessmentNew.sequenceNoo = cat.sequenceNo
                    peNewAssessmentNew.catResultMark = cat.maxMark
                    peNewAssessmentNew.catEvaluationID = cat.evaluationID
                    peNewAssessmentNew.catISSelected = cat.isSelected ? 1:0
                    peNewAssessmentNew.assID = ass.id
                    peNewAssessmentNew.assDetail1 = ass.assessment
                    peNewAssessmentNew.evaluationID = cat.evaluationID
                    peNewAssessmentNew.assDetail2 = ass.assessment2
                    peNewAssessmentNew.assMinScore = ass.minScore
                    peNewAssessmentNew.assMaxScore = ass.maxScore
                    peNewAssessmentNew.assCatType = ass.cateType
                    peNewAssessmentNew.assModuleCatID = ass.moduleCatId
                    peNewAssessmentNew.assModuleCatName = ass.moduleCatName
                    peNewAssessmentNew.assStatus = 1
                    peNewAssessmentNew.informationImage = ass.informationImage
                    peNewAssessmentNew.informationText = ass.informationText
                    peNewAssessmentNew.isNA = ass.isNA
                    peNewAssessmentNew.isAllowNA = ass.isAllowNA
                    peNewAssessmentNew.qSeqNo = ass.qSeqNo
                    peNewAssessmentNew.rollOut = ass.rollOut
                    CoreDataHandlerPE().saveNewAssessmentInProgressInDB(newAssessment:self.peNewAssessment)
                }
            }
            let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PEAssesmentFinalize") as! PEAssesmentFinalize
            vc.peNewAssessment = self.peNewAssessment
            self.navigationController?.pushViewController(vc, animated: true)
            return
        } else {
            print(appDelegateObj.testFuntion())
        }
    }
    // MARK: - Filter Category Count
    func filterCategoryCount() -> Int {
        var peCategoryFilteredArray: [PECategory] =  []
        for object in pECategoriesAssesmentsResponse.peCategoryArray{
            if peNewAssessment.evaluationID == object.evaluationID{
                peCategoryFilteredArray.append(object)
            }
        }
        pECategoriesAssesmentsResponse.peCategoryArray = peCategoryFilteredArray
        return pECategoriesAssesmentsResponse.peCategoryArray.count ?? 0
    }

}

// MARK: - Extension & Textview Delegates
extension PEViewStartNewAssessment:UITextViewDelegate{
    //MARK...
    
    func textViewShouldBeginEditing(_ _textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView == notesTextView ) {
            saveAssessmentInProgressDataInDB()
        }
    }
}

// MARK: - WebServices
extension PEViewStartNewAssessment {
    
    internal func fetchtAssessmentCategoriesResponse(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PEAssesmentFinalize") as! PEAssesmentFinalize
        vc.peNewAssessment = self.peNewAssessment
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
// MARK: - Extension Textfield Deletgates
extension PEViewStartNewAssessment : UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.txtBreedOfBird.text = constantToSave + (textField.text ?? "")
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}

extension PEViewStartNewAssessment{
    
    
    
    
    
    func convertDateFormat(inputDate: String) -> String {
        
        return convertFormat(inputDate: inputDate)
    }
    
    
    // MARK: - Date Formatter
    func convertSign_DateFormat(inputDate: String) -> String {
        return convertFormat(inputDate: inputDate)
    }
    
    func convertFormat(inputDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = appDelegateObj.mmddyyStr

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = Constants.yyyyMMddStr

        if let date = inputFormatter.date(from: inputDate) {
            return outputFormatter.string(from: date)
        }
        return ""
    }
    
    // MARK: - Create Sync request
    func createSyncRequest(dict: PENewAssessment, certificationData: [PECertificateData]) -> JSONDictionary {
        let udid = UserDefaults.standard.string(forKey: "ApplicationIdentifier") ?? ""
        var uniID = dict.dataToSubmitID?.nonEmpty ?? dict.draftID ?? ""
        let assessmentId = dict.dataToSubmitNumber ?? dict.draftNumber ?? 0
        let isDraft = dict.dataToSubmitNumber == nil
        let deviceId = getDeviceId(dict: dict, uniID: uniID, udid: udid, isDraft: isDraft)

        let certSignature = certificationData.first?.fsrSign ?? ""
        let tsrId = resolveTSRId(dict: dict)
        let manufacturerInfo = resolveManufacturer(dict: dict)
        let eggInfo = resolveEggInfo(dict: dict)
        let breedInfo = resolveBreedInfo(dict: dict)
        let incubationId = resolveIncubationId(name: dict.incubation)
        let roleId = resolveRoleId(roleName: dict.sig_EmpID)
        let roleId2 = resolveRoleId(roleName: dict.sig_EmpID2)
        let base64Str = imageBase64(for: dict.sig)
        let base64Str2 = imageBase64(for: dict.sig2)
        let evalDateStr = formattedEvaluationDate(from: dict.evaluationDate)
        let dateSig = dict.sig_Date.flatMap(convertDateFormat) ?? ""

        let userInfo = PEInfoDAO.sharedInstance.fetchInfoVMObj(
            userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "",
            assessmentId: dict.serverAssessmentId ?? ""
        )

        return [
            "AppAssessmentId": "\(assessmentId)",
            "DisplayId": "C-\(uniID)".prefix(22),
            "VisitId": dict.visitID,
            "CustomerId": dict.customerId,
            "SiteId": dict.siteId,
            "IncubationStyle": incubationId,
            "EvaluationId": dict.evaluationID,
            "BreedBirds": breedInfo.id,
            "EvaluationDate": evalDateStr,
            "EvaulaterId": dict.evaluatorID ?? 0,
            "TSRId": tsrId,
            "Camera": dict.camera == 1,
            "ManufacturerId": manufacturerInfo.id,
            "EggsPerFlat": eggInfo.id,
            "Notes": dict.notes ?? "",
            "FlockAgeId": dict.isFlopSelected,
            "SaveType": isDraft ? 0 : 1,
            "UserId": dict.userID,
            "DeviceId": deviceId,
            "RepresentativeName": dict.sig_Name,
            "RepresentativeName2": dict.sig_Name2,
            "RepresentativeNotes": dict.sig_Phone,
            "FSTSignatureImage": certSignature,
            "SignatureImage": base64Str,
            "SignatureImage2": base64Str2,
            "ManufacturerOther": manufacturerInfo.other,
            "BreedOfBirdsOther": breedInfo.other,
            "EggsPerFlatOther": eggInfo.other,
            "RoleId": roleId,
            "RoleId2": roleId2,
            "EvaluationTypeText": dict.evaluationName,
            "AppCreationTime": uniID.prefix(22),
            "SignatureDate": dateSig,
            "AssessmentId": Int64(dict.serverAssessmentId ?? "") ?? 0,
            "DoubleSanitation": dict.hatcheryAntibiotics == 1,
            "SanitationEmbrex": dict.sanitationValue ?? false,
            "HasChlorineStrips": dict.isChlorineStrip ?? false,
            "IsAutomaticFail": dict.isAutomaticFail ?? false,
            "RefrigeratorNote": dict.refrigeratorNote ?? "",
            "RegionId": UserDefaults.standard.integer(forKey: "Regionid"),
            "IsInterMicrobial": userInfo?.isExtendedPE ?? false,
            "CountryId": UserDefaults.standard.integer(forKey: "nonUScountryId"),
            "IsInovoFluids": false,
            "IsBasicTrfAssessment": false,
            "Handmix": dict.isHandMix ?? false,
            "Chlorine_Value": dict.ppmValue ?? ""
        ]
    }
    private func getDeviceId(dict: PENewAssessment, uniID: String, udid: String, isDraft: Bool) -> String {
        if let detail = dict.assDetail2?.lowercased(), detail.contains("_1_ios") {
            return dict.assDetail2 ?? "\(uniID)_1_iOS_\(udid)"
        }
        return "\(uniID)_1_iOS_\(udid)"
    }

    private func resolveTSRId(dict: PENewAssessment) -> Int {
        guard let selectedTSR = dict.selectedTSR else { return dict.selectedTSRID ?? 0 }
        let visitData = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Approvers")
        let names = visitData.value(forKey: "username") as? [String] ?? []
        let ids = visitData.value(forKey: "id") as? [Int] ?? []
        return names.firstIndex(of: selectedTSR).flatMap { ids[safe: $0] } ?? dict.selectedTSRID ?? 0
    }

    private func resolveManufacturer(dict: PENewAssessment) -> (id: Any, other: String) {
        guard var man = dict.manufacturer else { return ("", "") }
        if man.hasPrefix("S") {
            return ("Other", man.replacingOccurrences(of: "S", with: ""))
        }
        let data = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Manufacturer")
        let names = data.value(forKey: "mFG_Name") as? [String] ?? []
        let ids = data.value(forKey: "mFG_Id") as? [Int] ?? []
        return names.firstIndex(of: man).flatMap { (ids[safe: $0], "") } ?? ("", "")
    }

    private func resolveEggInfo(dict: PENewAssessment) -> (id: Any, other: String) {
        let countStr = String(dict.noOfEggs ?? 0)
        if countStr.hasSuffix("000") {
            return ("Other", countStr.replacingOccurrences(of: "000", with: ""))
        }
        let data = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Eggs")
        let names = data.value(forKey: "eggCount") as? [String] ?? []
        let ids = data.value(forKey: "eggId") as? [Int] ?? []
        return names.firstIndex(of: countStr).flatMap { (ids[safe: $0], "") } ?? ("", "")
    }

    private func resolveBreedInfo(dict: PENewAssessment) -> (id: Any, other: String) {
        guard var breed = dict.breedOfBird else { return ("", dict.breedOfBirdOther ?? "") }
        if breed.hasPrefix("S") {
            return ("Other", breed.replacingOccurrences(of: "S", with: ""))
        }
        let data = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_BirdBreed")
        let names = data.value(forKey: "birdBreedName") as? [String] ?? []
        let ids = data.value(forKey: "birdId") as? [Int] ?? []
        return names.firstIndex(of: breed).flatMap { (ids[safe: $0], dict.breedOfBirdOther ?? "") } ?? ("", dict.breedOfBirdOther ?? "")
    }

    private func resolveIncubationId(name: String?) -> Int {
        guard let name = name else { return 0 }
        let data = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_IncubationStyle")
        let names = data.value(forKey: "incubationStylesName") as? [String] ?? []
        let ids = data.value(forKey: "incubationId") as? [Int] ?? []
        return names.firstIndex(of: name).flatMap { ids[safe: $0] } ?? 0
    }

    private func resolveRoleId(roleName: String?) -> Int {
        guard let name = roleName else { return 0 }
        let data = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Roles")
        let names = data.value(forKey: "roleName") as? [String] ?? []
        let ids = data.value(forKey: "roleId") as? [Int] ?? []
        return names.firstIndex(of: name).flatMap { ids[safe: $0] } ?? 0
    }

    private func imageBase64(for id: Int?) -> String {
        guard let id = id, id != 0 else { return "" }
        return CoreDataHandlerPE().getImageBase64ByImageID(idArray: id)
    }

    private func formattedEvaluationDate(from dateStr: String?) -> String {
        guard let dateStr = dateStr else { return "" }
        let inputFormatter = DateFormatter()
        let regionId = UserDefaults.standard.integer(forKey: "Regionid")
        inputFormatter.dateFormat = regionId == 3 ? Constants.MMddyyyyStr : Constants.ddMMyyyStr

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = Constants.yyyyMMddStr

        guard let date = inputFormatter.date(from: dateStr) else {
            print(appDelegateObj.invalidDateStr)
            return ""
        }

        return outputFormatter.string(from: date)
    }

    
    // MARK: - Create Sync request for Inovoject
    fileprivate func manageDilManOther(_ doaDilManOther: String, _ json: inout [String : Any], _ ManufacturerId: Int) {
        if doaDilManOther == "" {
            json.removeValue(forKey: "DiluentsMfgOtherName")
        }
        if ManufacturerId == 0  {
            json["ManufacturerId"] =  ManufacturerId == 0 ? "" : ManufacturerId
            json.removeValue(forKey: "ManufacturerId")
        }
    }
    
    func createSyncRequestForInvoject(dictArray: PENewAssessment,inovojectData :InovojectData) -> JSONDictionary{
        
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }
        
        var score = 0
        var serverAssessmentId:Int64 = 0
        
        if let id = dictArray.serverAssessmentId{
            serverAssessmentId = Int64(id ?? "") ?? 0
        }
        

        var DisplayId = "C-" + UniID
        
        let  HatcheryAntibioticsInt = inovojectData.invoHatchAntibiotic
        var HatcheryAntibiotics = false
        if HatcheryAntibioticsInt == 1 {
            HatcheryAntibiotics = true
        }
        
        var x = 0
   
        var ampleSizeDetailArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
        var ampleSizeesNameArray = ampleSizeDetailArray.value(forKey: "size") as? NSArray ?? NSArray()
        var ampleSizeIDArray = ampleSizeDetailArray.value(forKey: "id") as? NSArray ?? NSArray()
        if inovojectData.ampuleSize != "" {
            let xx = inovojectData.ampuleSize?.replacingOccurrences(of: " ", with: "")
            let indexOfe =  ampleSizeesNameArray.index(of: xx)
            x = ampleSizeIDArray[indexOfe] as? Int  ?? 0
        }
        
        var otherVaccine = ""
        var ManufacturerId = 0

        var VaccineId = 0
        var vNameDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VManufacturer")
        var vNameArray = vNameDetailsArray.value(forKey: "mfgName") as? NSArray ?? NSArray()
        var vNameIDArray = vNameDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        
        VaccineId = 0
        if vNameArray.contains(inovojectData.vaccineMan){
            let indexOfe = vNameArray.index(of: inovojectData.vaccineMan) // 3
            VaccineId = vNameIDArray[indexOfe] as? Int ?? 0
        }

        var vNameDetailsArrayIS = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VNames")
        var vNameArrayIS = vNameDetailsArrayIS.value(forKey: "name") as? NSArray ?? NSArray()
        var vNameIDArrayIS = vNameDetailsArrayIS.value(forKey: "id") as? NSArray ?? NSArray()
        var vNameMfgIdArrayIS = vNameDetailsArrayIS.value(forKey: "mfgId") as? NSArray ?? NSArray()
        
        if vNameArrayIS.contains(inovojectData.name){
            let indexOfe = vNameArrayIS.index(of: inovojectData.name) // 3
            VaccineId = vNameIDArrayIS[indexOfe] as? Int ?? 0
            ManufacturerId = vNameMfgIdArrayIS[indexOfe] as? Int ?? 0
        } else if (inovojectData.name != ""){
            otherVaccine = inovojectData.name ?? ""
        }
        
        let DManufacturerId = 0
       
        var dManufacture = 0
                
        let unique = "\(deviceIDFORSERVER)_\(inovojectData.id)_iOS_"
        
        let ampulePerBag = Int(inovojectData.ampulePerBag ?? "0")
        var AntibioticInformation  =  ""
        if HatcheryAntibiotics {
            AntibioticInformation =  inovojectData.invoHatchAntibioticText ?? ""
        }
        var json = [
            "VaccineId":  VaccineId == 0 ? "" : VaccineId,
            "AmpulePerbag":ampulePerBag == 0 ? "" : ampulePerBag,
            "AmpuleSize":  x == 0 ? "" : x,
            "AppAssessmentId": String(AssessmentId),
            "BagSizeType":inovojectData.bagSizeType,
            "Device_Id": deviceIDFORSERVER,
            "DiluentMfg": inovojectData.vaccineMan,
            "DisplayId": DisplayId.prefix(22),
            "HatcheryAntibiotics": HatcheryAntibiotics,
            "ManufacturerId":  ManufacturerId == 0 ? "" : ManufacturerId,
            "ModuleAssessmentCatId": dictArray.catID,
            "Dosage": inovojectData.dosage,
            "StrUniqueId":unique,
            "OtherText":otherVaccine,
            "SecquenceId":0,
            "AntibioticInformation": AntibioticInformation,
            "DiluentsMfgOtherName":inovojectData.doaDilManOther,
            "ProgramName": inovojectData.invoProgramName,
            "AssessmentId":serverAssessmentId
            
        ] as JSONDictionary
        let doaDilManOther =  inovojectData.doaDilManOther ?? ""
        
        manageDilManOther(doaDilManOther, &json, ManufacturerId)
        return json
        
    }
    // MARK: - Create Sync request for DOA Data
    func createSyncRequestForDOA(dictArray: PENewAssessment,dayOfAgeData :InovojectData) -> JSONDictionary{
        
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }
      
        var DisplayId = "C-" + UniID
        
        let  HatcheryAntibioticsInt = dictArray.hatcheryAntibioticsDoa
        var HatcheryAntibiotics = false
        if HatcheryAntibioticsInt == 1  {
            HatcheryAntibiotics = true
        }
        
        var x = 0

        var ampleSizeDetailArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
        var ampleSizeesNameArray = ampleSizeDetailArray.value(forKey: "size") as? NSArray ?? NSArray()
        var ampleSizeIDArray = ampleSizeDetailArray.value(forKey: "id") as? NSArray ?? NSArray()
        
        if dayOfAgeData.ampuleSize != "" {
            let xx = dayOfAgeData.ampuleSize?.replacingOccurrences(of: " ", with: "")
            let indexOfe =  ampleSizeesNameArray.index(of: xx)
            x = ampleSizeIDArray[indexOfe] as? Int  ?? 0
        }
        
        var VaccineId = 0
        var otherVaccine = ""
        var ManufacturerId = 0
        var vNameDetailsArray = CoreDataHandlerPE().fetchDetailsForVaccineNames(typeId: 1)
        var vNameArray = vNameDetailsArray.value(forKey: "name") as? NSArray ?? NSArray()
        var vNameIDArray = vNameDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        var vNameMfgIdArray = vNameDetailsArray.value(forKey: "mfgId") as? NSArray ?? NSArray()
        
        if vNameArray.contains(dayOfAgeData.name){
            let indexOfe =  vNameArray.index(of: dayOfAgeData.name)
            VaccineId = vNameIDArray[indexOfe] as? Int ?? 0
            ManufacturerId = vNameMfgIdArray[indexOfe] as? Int ?? 0
        }
        else if (dayOfAgeData.name != ""){
            otherVaccine = dayOfAgeData.name ?? ""
        }
        
        var vManufacutrerDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VManufacturer")
        var vManufacutrerNameArray = vManufacutrerDetailsArray.value(forKey: "mfgName") as? NSArray ?? NSArray()
        var vManufacutrerIDArray = vManufacutrerDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        
        if vManufacutrerNameArray.contains(dayOfAgeData.vaccineMan){
            let indexOfe =  vManufacutrerNameArray.index(of: dayOfAgeData.vaccineMan) //
            ManufacturerId = vManufacutrerIDArray[indexOfe] as? Int ?? 0
        }
        
        let unique = "\(deviceIDFORSERVER)_\(dayOfAgeData.id)_iOS_"
        let ampulePerBag = Int(dayOfAgeData.ampulePerBag ?? "0")
        var AntibioticInformation  =  ""
        
        if HatcheryAntibiotics {
            AntibioticInformation =  dictArray.hatcheryAntibioticsDoaText ?? ""
        }
        
        var serverAssessmentId:Int64 = 0
        if let id = dictArray.serverAssessmentId{
            serverAssessmentId = Int64(id ?? "") ?? 0
        }
        
        let json = [
            "AppAssessmentId": String(AssessmentId),
            "DayOfAgeAmpulePerbag": ampulePerBag == 0 ? "" : ampulePerBag,
            "DayOfAgeAmpuleSize":  x == 0 ? "" : x,
            "DayOfAgeBagSizeType": dictArray.dDT,
            "DayOfAgeMfgId":  ManufacturerId == 0 ? "" : ManufacturerId,
            "DayOfAgeMfgNameId":  VaccineId == 0 ? "" : VaccineId,
            "DayOfBagHatcheryAntibiotics": HatcheryAntibiotics,
            "Device_Id": deviceIDFORSERVER,
            "DiluentMfg": dictArray.dCS,
            "DisplayId": DisplayId.prefix(22),
            "ModuleAssessmentCatId": dictArray.catID,
            "DayOfAgeDosage": dayOfAgeData.dosage,
            "StrUniqueId":unique,
            "OtherText":otherVaccine,
            "SecquenceId":0,
            "AntibioticInformation":AntibioticInformation,
            "AssessmentId":serverAssessmentId
            
        ] as JSONDictionary
        return json
    }
    
    // MARK: - Create Sync request for DOAS
    func createSyncRequestForDOAS(dictArray: PENewAssessment,dayOfAgeData :InovojectData) -> JSONDictionary{
        
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var serverAssessmentId:Int64 = 0
        if let id = dictArray.serverAssessmentId{
            serverAssessmentId = Int64(id ?? "") ?? 0
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }

        var DisplayId = "C-" + UniID
        
        let  HatcheryAntibioticsInt = dictArray.hatcheryAntibioticsDoaS
        
        var HatcheryAntibiotics = false
        if HatcheryAntibioticsInt == 1  {
            HatcheryAntibiotics = true
        }
        
        var x = 0
       
       
        var ampleSizeDetailArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
        var ampleSizeesNameArray = ampleSizeDetailArray.value(forKey: "size") as? NSArray ?? NSArray()
        var ampleSizeIDArray = ampleSizeDetailArray.value(forKey: "id") as? NSArray ?? NSArray()
        if dayOfAgeData.ampuleSize != "" {
            let xx = dayOfAgeData.ampuleSize?.replacingOccurrences(of: " ", with: "")
            let indexOfe =  ampleSizeesNameArray.index(of: xx)
            x = ampleSizeIDArray[indexOfe] as? Int  ?? 0
        }
        var VaccineId = 0
        var otherVaccine = ""
        var ManufacturerId = 0

        var vNameDetailsArray = CoreDataHandlerPE().fetchDetailsForVaccineNames(typeId: 2)
        var  vNameArray = vNameDetailsArray.value(forKey: "name") as? NSArray ?? NSArray()
        var vNameIDArray = vNameDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        var vNameMfgIdArray = vNameDetailsArray.value(forKey: "mfgId") as? NSArray ?? NSArray()
        if vNameArray.contains(dayOfAgeData.name){
            let indexOfe =  vNameArray.index(of: dayOfAgeData.name) //
            VaccineId = vNameIDArray[indexOfe] as? Int ?? 0
            ManufacturerId = vNameMfgIdArray[indexOfe] as? Int ?? 0
        } else if (dayOfAgeData.name != ""){
            otherVaccine = dayOfAgeData.name ?? ""
        }

        var vManufacutrerDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VManufacturer")
        var vManufacutrerNameArray = vManufacutrerDetailsArray.value(forKey: "mfgName") as? NSArray ?? NSArray()
        var vManufacutrerIDArray = vManufacutrerDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        
        if vManufacutrerNameArray.contains(dayOfAgeData.vaccineMan){
            let indexOfe =  vManufacutrerNameArray.index(of: dayOfAgeData.vaccineMan) //
            ManufacturerId = vManufacutrerIDArray[indexOfe] as? Int ?? 0
        }
        let unique = "\(deviceIDFORSERVER)_\(dayOfAgeData.id)_iOS_"
        var AntibioticInformation  =  ""
        
        if HatcheryAntibiotics {
            AntibioticInformation =  dictArray.hatcheryAntibioticsDoaSText ?? ""
        }
        let ampulePerBag = Int(dayOfAgeData.ampulePerBag ?? "0")
        var json = [
            
            "DayAgeSubcutaneousBagSizeType": dictArray.dDDT,
            "Device_Id": deviceIDFORSERVER,
            "DisplayId": DisplayId.prefix(22),
            "ModuleAssessmentCatId":  dictArray.catID ?? "",
            "StrUniqueId":unique,
            "SecquenceId": 0,
            "AppAssessmentId":  String(AssessmentId)] as JSONDictionary
        
        json["DayAgeSubcutaneousHatcheryAntibiotics"] = HatcheryAntibiotics
        json["DayAgeSubcutaneousMfgId"] =  ManufacturerId == 0 ? "" : ManufacturerId
        json["DayAgeSubcutaneousDosage"] = dayOfAgeData.dosage ?? ""
        json["DayAgeSubcutaneousMfgNameId"] =  VaccineId == 0 ? "" : VaccineId;
        json["OtherText"] =  otherVaccine
        json["DayAgeSubcutaneousDiluentMfg"] =   dictArray.dDCS
        json["DayAgeSubcutaneousAmpuleSize"] =   x == 0 ? "" : x
        json["DayAgeSubcutaneousAmpulePerbag"] =  ampulePerBag == 0 ? "" : (ampulePerBag ?? 0)
        json["AntibioticInformation"] =  AntibioticInformation
        json["AssessmentId"] = serverAssessmentId
        return json
        
    }
    // MARK: - Create Sync request for Certificate Data.
    func createSyncRequestForCertificateData(dictArray: PENewAssessment,peCertificateData :PECertificateData) -> JSONDictionary{
        
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }
        var serverAssessmentId:Int64 = 0
        if let id = dictArray.serverAssessmentId{
            serverAssessmentId = Int64(id ?? "") ?? 0
        }

        var DisplayId = "C-" + UniID
        
        let unique = "\(deviceIDFORSERVER)_\(peCertificateData.id)_iOS_"
        var resultString = String()
        if(regionID != 3){
            let dateFormatter = DateFormatter()
//            dateFormatter.calendar = Calendar(identifier: .gregorian)
//            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = Constants.ddMMyyyStr
            let date = dateFormatter.date(from: peCertificateData.certificateDate ?? "")
            dateFormatter.dateFormat = Constants.yyyyMMddStr
            resultString = dateFormatter.string(from: date ?? Date())
        }
        else{
            resultString = peCertificateData.certificateDate ?? ""
        }
        
        let json = [
            "Id": AssessmentId,
            "AssessmentId": serverAssessmentId,//AssessmentId,
            "AssessmentDetailId": AssessmentId,
            "ModuleAssessmentId": 0,
            "Name": peCertificateData.name,
            "CertificationDate": resultString,
            "AlternateName": "string",
            "CertificationDate2": appDelegateObj.date2020_05_23,
            "ModuleAssessmentCatId":  dictArray.catID,
            "userId": dictArray.userID,
            "DeviceId": deviceIDFORSERVER,
            "ResidueName": dictArray.residue,
            "MicroSamplesName": dictArray.micro,
            "EvaluationTypeId": 1,
            "AppAssessmentId": String(AssessmentId),
            "DisplayId": DisplayId.prefix(22),
            "StrUniqueId":unique,
            "VacOperatorId": peCertificateData.vacOperatorId ?? 0,
            "IsCertiExpired": peCertificateData.isCertExpired,
            "IsRecert": peCertificateData.isReCert,
            "SignatureImg": peCertificateData.signatureImg ?? ""
        ] as JSONDictionary
        return json
        
    }
    // MARK: - Create Sync request for Residue Data
    func createSyncRequestForResidueData(dictArray: PENewAssessment) -> JSONDictionary{
        
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }
        var serverAssessmentId: Int64 = 0
        if let id = dictArray.serverAssessmentId{
            serverAssessmentId = Int64(id ?? "") ?? 0
        }

        var DisplayId = "C-" + UniID
        
        let unique = "\(deviceIDFORSERVER)_\(dictArray.residue)_iOS_"
        
        let json = [
            "AssessmentId": serverAssessmentId,
            "AssessmentDetailId": dictArray.assID ?? 0,
            "StrUniqueId": unique,
            "ModuleAssessmentId": dictArray.catID,
            "ResidueName":dictArray.residue,
            "MicroSamplesName": dictArray.micro,
            "EvaluationTypeId": 1,
            "AppAssessmentId": String(AssessmentId),
            "DisplayId": DisplayId.prefix(22),
            "UserId": dictArray.userID,
            "CreatedAt": "2020-06-11T12:53:38.930Z",
            "DeviceId": deviceIDFORSERVER,
            "ModuleAssessmentCatId": dictArray.catID
        ] as JSONDictionary
        return json
        
    }
    
    // MARK: - Create Sync request for Micro Data
    func createSyncRequestForMicroData(dictArray: PENewAssessment) -> JSONDictionary{
        
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }
        
        var serverAssessmentId:Int64 = 0
        if let id = dictArray.serverAssessmentId{
            serverAssessmentId = Int64(id ?? "") ?? 0
        }
  
        let DisplayId = "C-" + UniID
        
        let unique = "\(deviceIDFORSERVER)_\(dictArray.micro)_iOS_"
        
        let json = [
            "Id": AssessmentId,
            "AssessmentId": serverAssessmentId,
            "AssessmentDetailId": dictArray.assID ?? 0,
            "ModuleAssessmentId": 0,
            "Name": "",
            "CertificationDate": "",
            "AlternateName": "string",
            "CertificationDate2": appDelegateObj.date2020_05_23,
            "ModuleAssessmentCatId":  dictArray.catID,
            "userId": dictArray.userID,
            "DeviceId": deviceIDFORSERVER,
            "ResidueName": dictArray.residue,
            "MicroSamplesName": dictArray.micro,
            "EvaluationTypeId": 1,
            "AppAssessmentId": String(AssessmentId),
            "DisplayId": DisplayId.prefix(22),
            "StrUniqueId":unique
        ] as JSONDictionary
        return json
    }
    // MARK: - Check Assessment Stauts
    func getAssessmentStatusCheck(assessmentId: String){
        
        ZoetisWebServices.shared.checkAssessment(controller: self, assessmentId: assessmentId, parameters: [:], completion: { [weak self] (json, error) in
            let data = json["Data"].arrayValue.map {  PEStatus($0) }
            let status = data[0].IsStatus
            if status ?? false{
                self?.showAlert(title: "Already approved", message: "Assessment can not be updated as its already approved", owner: self!)
            }else{
                self?.syncBtnTapped(showHud: true)
            }
        })
    }
    // MARK: - Sync Button Action
    fileprivate func createVaxineMixtureData() {
        var idArr : [Int] = []
        for objn in  peNewAssessment.vMixer {
            let data = CoreDataHandlerPE().getCertificateData(doaId: objn)
            if idArr.contains(data!.id ?? 0){
                debugPrint("vaccine mixture id")
            }else{
                idArr.append(data!.id ?? 0)
                if data != nil{
                    certificateData.append(data!)
                    
                }
            }
        }
    }
    
    fileprivate func createDayOfAgeSubcData() {
        var idArr : [Int] = []
        for objn in  peNewAssessment.doaS {
            let data = CoreDataHandlerPE().getPEDOAData(doaId: objn)
            if data != nil {
                if idArr.contains(data!.id ?? 0){
                    debugPrint("Day of SUB id")
                }else{
                    idArr.append(data!.id ?? 0)
                    if data != nil{
                        dayOfAgeSData.append(data!)
                    }
                }
            }
        }
    }
    
    fileprivate func createDayOfAgeData() {
        var idArr : [Int] = []
        for objn in  peNewAssessment.doa {
            let data = CoreDataHandlerPE().getPEDOAData(doaId: objn)
            if data != nil {
                if idArr.contains(data!.id ?? 0){
                    debugPrint("AGE of DAY id")
                }else{
                    idArr.append(data!.id ?? 0)
                    if data != nil{
                        dayOfAgeData.append(data!)
                    }
                }
            }
        }
    }
    
    fileprivate func createInovojectData() {
        var idArr : [Int] = []
        for objn in  peNewAssessment.inovoject {
            let data = CoreDataHandlerPE().getPEDOAData(doaId: objn)
            if data != nil {
                if idArr.contains(data!.id ?? 0){
                    debugPrint("Inovo id")
                }else{
                    idArr.append(data!.id ?? 0)
                    if data != nil{
                        inovojectData.append(data!)
                    }
                }
            }
        }
    }
    
	private func prepareAssessmentData() {
		certificateData.removeAll()
		dayOfAgeSData.removeAll()
		dayOfAgeData.removeAll()
		inovojectData.removeAll()
		
		if !peNewAssessment.vMixer.isEmpty {
			createVaxineMixtureData()
		}
		
		if !peNewAssessment.doaS.isEmpty {
			createDayOfAgeSubcData()
		}
		
		if !peNewAssessment.doa.isEmpty {
			createDayOfAgeData()
		}
		
		if !peNewAssessment.inovoject.isEmpty {
			createInovojectData()
		}
	}
	
	private func createDOAInovojectParam(
		inovoject: [JSONDictionary],
		doa: [JSONDictionary],
		doaSub: [JSONDictionary],
		certificates: [JSONDictionary],
		residueMolds: [JSONDictionary],
		microSamples: [JSONDictionary]
	) -> JSONDictionary {
		return [
			"InovojectData": inovoject,
			"DayOfAgeData": doa,
			"DayAgeSubcutaneousDetailsData": doaSub,
			"VaccineMixerObservedData": certificates,
			"VaccineResidueMoldsData": residueMolds,
			"VaccineMicroSamplesData": microSamples,
			"DeviceId": deviceIDFORSERVER
		]
	}
	
	private func extractAssessmentIds(from dataArray: [JSONDictionary]) -> [String] {
		return dataArray.compactMap { data in
			guard let id = data["AssessmentId"] as? Int64, id != 0 else { return nil }
			return "\(id)"
		}
	}
	

	// For data arrays that are [CustomStruct], not [JSONDictionary]
	private func appendSyncPayloadsFromStructs<T>(
		to targetArray: inout [JSONDictionary],
		from sourceArray: [T],
		using creator: (PENewAssessment, T) -> JSONDictionary
	) {
		for item in sourceArray {
			let json = creator(peNewAssessment, item)
			targetArray.append(json)
		}
	}
	
	func syncBtnTapped(showHud: Bool) {
		guard ConnectionManager.shared.hasConnectivity() else { return }
		
		showGlobalProgressHUDWithTitle(self.view, title: "Data syncing...")
		
		var mainSyncData: [JSONDictionary] = []
		var inovojectDataArr: [JSONDictionary] = []
		var dayOfAgeDataArr: [JSONDictionary] = []
		var dayOfAgeSDataArr: [JSONDictionary] = []
		var certificateDataArr: [JSONDictionary] = []
		var vaccineMicroSamplesDataArr: [JSONDictionary] = []
		var vaccineResidueMoldsDataArr: [JSONDictionary] = []
		
		prepareAssessmentData()
		
		let mainJson = createSyncRequest(dict: peNewAssessment, certificationData: certificateData)
		mainSyncData.append(mainJson)
		
		appendSyncPayloadsFromStructs(to: &inovojectDataArr, from: inovojectData, using: createSyncRequestForInvoject)
		appendSyncPayloadsFromStructs(to: &dayOfAgeDataArr, from: dayOfAgeData, using: createSyncRequestForDOA)
		appendSyncPayloadsFromStructs(to: &dayOfAgeSDataArr, from: dayOfAgeSData, using: createSyncRequestForDOAS)
		appendSyncPayloadsFromStructs(to: &certificateDataArr, from: certificateData, using: createSyncRequestForCertificateData)

		if peNewAssessment.evaluationID == 2 {
			vaccineResidueMoldsDataArr.append(createSyncRequestForResidueData(dictArray: peNewAssessment))
			vaccineMicroSamplesDataArr.append(createSyncRequestForMicroData(dictArray: peNewAssessment))
		}
		
		let paramForDoaInnovoject = createDOAInovojectParam(
			inovoject: inovojectDataArr,
			doa: dayOfAgeDataArr,
			doaSub: dayOfAgeSDataArr,
			certificates: certificateDataArr,
			residueMolds: vaccineResidueMoldsDataArr,
			microSamples: vaccineMicroSamplesDataArr
		)
				
		let finalParams: JSONDictionary = [
			"AssessmentData": mainSyncData,
			"appVersion": Bundle.main.versionNumber,
			"IsSendEmail": "false"
		]
		
		convertDictToJson(dict: finalParams, apiName: "add assessment")
		
		ZoetisWebServices.shared.sendPostDataToServer(controller: self, parameters: finalParams) { [weak self] (json, error) in
			guard let self = self else { return }
			
            if error != nil {
				self.dismissGlobalHUD(self.view)
				return
			}
			
			if json["StatusCode"] as? Int == 200 {
				self.callRequest2(paramForDoaInnovoject: paramForDoaInnovoject, json: json)
			} else {
				self.dismissGlobalHUD(self.view)
				self.showAlert(title: "Error", message: "Error in first api sync", owner: self)
			}
		}
	}

	
    // MARK: - Sync Button Action
    @IBAction func syncBtnAction(_ sender: Any) {
        if ConnectionManager.shared.hasConnectivity(){
            let errorMSg = "Are you sure, you want to sync the data?"
            let alertController = UIAlertController(title: Constants.dataAvailableStr, message: errorMSg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                _ in
                self.syncBtnTapped(showHud: true)
                // As per discussion with Imran and binu we have commented this code so that client can submit their assessment
               // self.getAssessmentStatusCheck(assessmentId: self.peNewAssessment.serverAssessmentId ?? "")
            }
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel) 
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            Helper.showAlertMessage(self, titleStr: NSLocalizedString(Constants.alertStr, comment: ""), messageStr: NSLocalizedString(Constants.offline, comment: ""))
        }
    }
    // MARK: - Create Sync request for Score
    fileprivate func populateParams(_ dictArray: PENewAssessment, _ QCCount: inout String, _ TextAmPm: inout String, _ PPMValue: inout String, _ PersonName: inout String, _ FrequencyValue: inout Int) {
        if dictArray.rollOut == "Y" && dictArray.sequenceNoo == 3 && dictArray.qSeqNo == 12 {
            QCCount =  dictArray.qcCount ?? ""
        } else if  dictArray.rollOut == "Y" && dictArray.sequenceNoo == 6 {
            TextAmPm =  dictArray.ampmValue ?? ""
        } else if  dictArray.rollOut == "Y" && dictArray.sequenceNoo == 5  && dictArray.qSeqNo == 5 {
            PPMValue =  dictArray.ppmValue ?? ""
        } else if  dictArray.rollOut == "Y" && dictArray.sequenceNoo == 3 && dictArray.qSeqNo == 1 {
            PersonName =  dictArray.personName ?? ""
            let visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Frequency")
            let visitNameArray = visitDetailsArray.value(forKey: "frequencyName") as? NSArray ?? NSArray()
            let visitIDArray = visitDetailsArray.value(forKey: "frequencyId") as? NSArray ?? NSArray()
            
            if let frequency = dictArray.frequency, frequency.count > 0, visitNameArray.contains(frequency) {
                let indexOfe =  visitNameArray.index(of: dictArray.frequency ?? "")
                FrequencyValue = visitIDArray[indexOfe] as? Int ?? 0
            }

        }
    }
    
    fileprivate func manageAssStatus(_ dictArray: PENewAssessment, _ score: inout Int) {
        if dictArray.assStatus == 1 {
            score = dictArray.assMaxScore ?? 0
        } else {
            score = dictArray.assMinScore ?? 0
        }
    }
    
    func createSyncRequestForScore(dictArray: PENewAssessment) -> JSONDictionary{
        var UniID = dictArray.dataToSubmitID ?? ""
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }
        var score = 0
 
        var DisplayId = "C-" + UniID
        manageAssStatus(dictArray, &score)
        var TextAmPm = ""
        var PersonName = ""
        var FrequencyValue = 32
        var QCCount = ""
        var PPMValue = ""
        populateParams(dictArray, &QCCount, &TextAmPm, &PPMValue, &PersonName, &FrequencyValue)
        
        var serverAssessmentId:Int64 = 0
        if let id = dictArray.serverAssessmentId{
            serverAssessmentId = Int64(id ?? "") ?? 0
        }
        let regionId = UserDefaults.standard.integer(forKey: "Regionid")
        if regionId == 3 {
            let json = [
                "DisplayId":DisplayId.prefix(22) ?? "",
                "AppAssessmentId": String(AssessmentId),
                "ModuleAssessmentId": dictArray.assID ??  0,
                "AssessmentScore": score,
                "UserId": dictArray.userID ?? 0,
                "Device_Id": deviceIDFORSERVER,
                "QCCount":QCCount,
                "PersonName":PersonName,
                "FrequencyValue": FrequencyValue == 32 ? "" : FrequencyValue,
                "TextAmPm":TextAmPm,
                "AssessmentId": serverAssessmentId,
                "SequenceNo":dictArray.sequenceNoo ?? 0,
                "MaxScore":dictArray.assMaxScore ?? 0,
                "Chlorine_Value": PPMValue,
                "isNA":dictArray.isNA ?? false
            ] as JSONDictionary
            return json
        } else {
            let json = [
                "DisplayId":DisplayId.prefix(22),
                "AppAssessmentId": String(AssessmentId),
                "ModuleAssessmentId": dictArray.assID ??  0,
                "AssessmentScore": score,
                "UserId": dictArray.userID ?? 0,
                "Device_Id": deviceIDFORSERVER,
                "QCCount":QCCount,
                "PersonName":PersonName,
                "FrequencyValue": FrequencyValue == 32 ? "" : FrequencyValue,
                "TextAmPm":TextAmPm,
                "AssessmentId": serverAssessmentId,
                "SequenceNo":dictArray.sequenceNoo ?? 0,
                "MaxScore":dictArray.assMaxScore ?? 0,
                "isNA":dictArray.isNA ?? false
            ] as JSONDictionary
            return json
        }
    }
    
    // MARK: - Create Sync request for Comment
    func createSyncRequestForComment(dictArray: PENewAssessment) -> JSONDictionary{
        
    
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }

        var DisplayId = "C-" + UniID
        
        var serverAssessmentId:Int64 = 0
        if let id = dictArray.serverAssessmentId{
            serverAssessmentId = Int64(id ?? "") ?? 0
        }
        
        let json = [
            "DisplayId":DisplayId.prefix(22),
            "AppAssessmentId":  String(AssessmentId),
            "ModuleAssessmentId": dictArray.assID ?? 0,
            "Comment": dictArray.note ?? "",
            "UserId": dictArray.userID ?? 0,
            "ModuleId": 1,
            "DeviceId":deviceIDFORSERVER,
            "AssessmentId":serverAssessmentId
        ] as JSONDictionary
        return json
        
    }
    
    // MARK: -  Handle Sync Responce
    fileprivate func manageOfflineArray(_ getOfflineArray: [PENewAssessment]) {
        if getOfflineArray.count > 0 {
            var carColIdArray : [Int] = []
            var catArray : [PENewAssessment] = []
            var catAllRowArray : [PENewAssessment] = []
            for cat in getOfflineArray {
                if !carColIdArray.contains(cat.sequenceNo ?? 0){
                    carColIdArray.append(cat.sequenceNo ?? 0)
                    catArray.append(cat)
                }
            }
            for objCt in catArray{
                let catArrayForTableIs = CoreDataHandlerPE().fetchCustomerForSyncWithCatID(objCt.sequenceNo as NSNumber? ?? 0,dataToSubmitNumber:peNewAssessment.dataToSubmitNumber as NSNumber? ?? 0) as? [PENewAssessment] ?? []
                
                catAllRowArray.append(contentsOf: catArrayForTableIs)
            }
            var tempArr : [JSONDictionary]  = []
            var comntArray : [JSONDictionary]  = []
            var imgArray : [JSONDictionary]  = []
            imgArray.removeAll()
            for objCtIs in catAllRowArray {
                let json = createSyncRequestForScore(dictArray: objCtIs)
                let jsonComment = createSyncRequestForComment(dictArray: objCtIs)
                tempArr.append(json)
                comntArray.append(jsonComment)
            }
            let param = ["AssessmentCommentsData":comntArray,"AssessmentScoreData":tempArr] as JSONDictionary
            self.callRequest3(param:param)
        }
    }
    
    private func handleSyncResponse(_ json: JSON) {
        let sNumber = peNewAssessment.dataToSubmitNumber ?? 0
        let dNumber = peNewAssessment.draftNumber ?? 0
        var  getOfflineArray : [PENewAssessment] = []
        var  getDraftArray : [PENewAssessment] = []
        if sNumber != 0 {
            getOfflineArray = CoreDataHandlerPE().getOfflineAssessmentArray(id:peNewAssessment.dataToSubmitID ?? "" )
        }
        if dNumber != 0 {
            getDraftArray = CoreDataHandlerPE().getDraftAssessmentArray(id:peNewAssessment.draftNumber ?? 0)
        }
        callRequest4Int = 0
        
        totalImageToSync = []
        
        manageOfflineArray(getOfflineArray)
        
        if getDraftArray.count > 0 {
            var carColIdArray : [Int] = []
            var catArray : [PENewAssessment] = []
            var catAllRowArray : [PENewAssessment] = []
            for cat in getDraftArray {
                if !carColIdArray.contains(cat.sequenceNo ?? 0){
                    carColIdArray.append(cat.sequenceNo ?? 0)
                    catArray.append(cat)
                }
            }
            for objCt in catArray{
                var catArrayForTableIs = CoreDataHandlerPE().fetchCustomerForSyncWithCatIDDraft(objCt.sequenceNo as NSNumber? ?? 0,draftNumber:peNewAssessment  .draftNumber as? NSNumber ?? 0) as? [PENewAssessment] ?? []
                
                catAllRowArray.append(contentsOf: catArrayForTableIs)
            }
            var tempArr : [JSONDictionary]  = []
            var comntArray : [JSONDictionary]  = []
            for objCtIs in catAllRowArray {
                let json = createSyncRequestForScore(dictArray: objCtIs)
                let jsonComment = createSyncRequestForComment(dictArray: objCtIs)
                tempArr.append(json)
                comntArray.append(jsonComment)
            }
            let param = ["AssessmentCommentsData":comntArray,"AssessmentScoreData":tempArr] as JSONDictionary
            self.callRequest3(param:param)
        }
        
    }
    // MARK: - Call Request 2
    func callRequest2(paramForDoaInnovoject:JSONDictionary,json:JSON){
        let mjson = json
        self.convertDictToJson(dict: paramForDoaInnovoject,apiName: "add inovoject and day of age")
        ZoetisWebServices.shared.sendAddDayOfAgeAndInvoject(controller: self, parameters: paramForDoaInnovoject, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            guard let self = self, error == nil else { return }
            
            if json["StatusCode"]  == 200{
                self.handleSyncResponse(mjson)
                
            }
        })
    }
    // MARK: - Call Request 3
    func callRequest3(param:JSONDictionary){
        self.convertDictToJson(dict: param,apiName: "add score")
        ZoetisWebServices.shared.sendScoresDataToServer(controller: self, parameters: param, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            guard let self = self, error == nil else { return }
            if json["StatusCode"]  == 200{
                self.CalculateImageCount()
            } else {
                self.dismissGlobalHUD(self.view)
                self.showAlert(title: "Error", message: "Error in sync score", owner: self)
            }
        })
    }
    // MARK: - Create Sync Request for Images
    func createSyncRequestForImage(dictArray: PENewAssessment,img:Int) -> JSONDictionary{
        
        let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier")!
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }
        
        let deviceIdForServer = "\(UniID)_\(AssessmentId)_iOS_\(udid)"
    
        let siteId = String(dictArray.siteId ?? 0)

        var DisplayId = "C-" + UniID
        let base64Str = CoreDataHandlerPE().getImageBase64ByImageID(idArray:img)
        totalImageToSync.append(img)
        let imageName = "ImgName-" + siteId + String(img ?? 0)
        let unique = "\(deviceIDFORSERVER)_\(String(img ?? 0))_iOS_"

        let json = [
            "DisplayId":DisplayId,
            "Id": AssessmentId,
            "AssessmentDetailId": AssessmentId,
            "ModuleAssessmentId": dictArray.assID ?? 0,
            "Comment": dictArray.note,
            "UserId": dictArray.userID ?? 0,
            "CreatedAt": "2020-05-08T13:51:26.02701Z",
            "ModuleId": 1,
            "CommentTypeId": 1,
            "DeviceId":deviceIDFORSERVER,
            "ImageBase64String":base64Str,
            "FolderPath": "",
            "ImageName": imageName,
            "StrUniqueId":unique,
            "AssessmentId":deviceIdForServer
        ] as JSONDictionary
        return json
        
    }
    // MARK: - Calculate Images Count
    func CalculateImageCount() {
        callRequest4Int = 0
        totalImageToSync = []

        if let sNumber = peNewAssessment.dataToSubmitNumber, sNumber != 0 {
            handleAssessmentSync(
                array: CoreDataHandlerPE().getOfflineAssessmentArray(id: peNewAssessment.dataToSubmitID ?? ""),
                isDraft: false
            )
            CoreDataHandlerPE().updateOfflineStatus(assessment: peNewAssessment)
        }

        if let dNumber = peNewAssessment.draftNumber, dNumber != 0 {
            handleAssessmentSync(
                array: CoreDataHandlerPE().getDraftAssessmentArray(id: dNumber),
                isDraft: true
            )
        }
    }
    
    private func handleAssessmentSync(array: [PENewAssessment], isDraft: Bool) {
        let grouped = groupByUniqueSequence(array)
        let allRows = grouped.flatMap {
            fetchAssessmentRows(sequenceNo: $0.sequenceNo ?? 0, isDraft: isDraft)
        }

        var scores: [JSONDictionary] = []
        var comments: [JSONDictionary] = []
        var images: [JSONDictionary] = []

        for item in allRows {
            scores.append(createSyncRequestForScore(dictArray: item))
            comments.append(createSyncRequestForComment(dictArray: item))
            images.append(contentsOf: unsyncedImages(for: item))
        }

        sendImagesInBatches(images)
    }

    private func groupByUniqueSequence(_ array: [PENewAssessment]) -> [PENewAssessment] {
        var seen: Set<Int> = []
        return array.filter {
            guard let seq = $0.sequenceNo else { return false }
            return seen.insert(seq).inserted
        }
    }

    private func fetchAssessmentRows(sequenceNo: Int, isDraft: Bool) -> [PENewAssessment] {
        if isDraft {
            return CoreDataHandlerPE().fetchCustomerForSyncWithCatIDDraft(
                sequenceNo as NSNumber,
                draftNumber: peNewAssessment.draftNumber as? NSNumber ?? 0
            )
        } else {
            return CoreDataHandlerPE().fetchCustomerForSyncWithCatID(
                sequenceNo as NSNumber,
                dataToSubmitNumber: peNewAssessment.dataToSubmitNumber as? NSNumber ?? 0
            )
        }
    }

    private func unsyncedImages(for item: PENewAssessment) -> [JSONDictionary] {
        return item.images.compactMap { imageId in
            let isSynced = CoreDataHandlerPE().imageAlreadySyncStatus(imageId: imageId)
            return isSynced ? nil : createSyncRequestForImage(dictArray: item, img: imageId)
        }
    }
    
    private func sendImagesInBatches(_ images: [JSONDictionary]) {
        let batchSize = 3
        for batch in stride(from: 0, to: images.count, by: batchSize) {
            let slice = Array(images[batch..<min(batch + batchSize, images.count)])
            let payload = ["AssessmentImages": slice]
            self.callRequest4(paramForImages: payload)
        }
    }
    
    // MARK: -  Get Offline Assessments
    func getAssessmentInOfflineFromDb() -> Int {
        let allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsWithUserIDFor(entityName: "PE_AssessmentInOffline")
        let carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "dataToSubmitNumber") as? NSArray ?? []
        
        var carColIdArrayDraft : [Int] = []
        
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArrayDraft.contains(obj as? Int ?? 0){
                carColIdArrayDraft.append(obj as? Int ?? 0)
            }
        }
        let allAssesmentOffArr = CoreDataHandlerPE().fetchDetailsWithUserIDFor(entityName: "PE_AssessmentInDraft")
        let carColIdArrayOffNumbers  = allAssesmentOffArr.value(forKey: "draftNumber") as? NSArray ?? []
        var carColIdArrayOff : [Int] = []
        for obj in carColIdArrayOffNumbers {
            if !carColIdArrayOff.contains(obj as? Int ?? 0){
                carColIdArrayOff.append(obj as? Int ?? 0)
            }
        }
        let syncCount = carColIdArrayOff.count
        let syncCount2 = carColIdArrayDraft.count
        return syncCount + syncCount2
    }
    // MARK: - Call sync request for Images (4)
    fileprivate func handleImageSaveSyncExtendedMicroData(_ self: PEViewStartNewAssessment) {
        guard ConnectionManager.shared.hasConnectivity() else { return }
        guard self.callRequest4Int == 0 else { return }

        if peNewAssessment.IsEMRequested! {
            if regionID == 3 {
                self.syncExtendedMicrobial()
            }
            return
        }

        let syncArr = self.getAssessmentInOfflineFromDb()
        if syncArr > 0 {
            self.syncBtnTapped(showHud: false)
        } else {
            self.totalImageToSync.forEach {
                CoreDataHandlerPE().setImageStatusTrue(idArray: $0)
            }
            self.showtoast(message: Constants.dataSyncSuccess)
            NotificationCenter.default.post(name: Notification.Name("UpdateComplexOnDashboardPE"), object: nil)
            self.dismissGlobalHUD(self.view)
        }
    }
    
    fileprivate func handleAPIResponseSendMultipleImagesBase64ToServer(_ json: JSON, _ self: PEViewStartNewAssessment) {
        if json["StatusCode"]  == 200 {
            if self.saveTypeString.contains(11) {
                if self.saveTypeString.contains(00) {
                    _ = CoreDataHandlerPE().updateDraftStatus(assessment: self.peNewAssessment)
                }
                _ = CoreDataHandlerPE().updateOfflineStatus(assessment: self.peNewAssessment)
            } else {
                _ = CoreDataHandlerPE().updateDraftStatus(assessment: self.peNewAssessment)
            }
            handleImageSaveSyncExtendedMicroData(self)
        } else {
            self.dismissGlobalHUD(self.view)
        }
    }
    
    func callRequest4(paramForImages:JSONDictionary){
        callRequest4Int = callRequest4Int + 1
        ZoetisWebServices.shared.sendMultipleImagesBase64ToServer(controller: self, parameters: paramForImages, completion: { [weak self] (json, error) in
            self?.callRequest4Int = self!.callRequest4Int - 1
            
            if error != nil {
                let syncArr = self?.getAssessmentInOfflineFromDb()
                if syncArr ?? 0 > 0 {
                    self?.syncBtnTapped(showHud: false)
                } else {
                    self?.showtoast(message: Constants.dataSyncSuccess)
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateComplexOnDashboardPE"),object: nil))
                }
            }
            guard let self = self, error == nil else { return }
            handleAPIResponseSendMultipleImagesBase64ToServer(json, self)
        })
    }
    

    // MARK:
    // MARK: ------------ Extended Micro Create Sync Request --------------
    // MARK:
    func createSyncRequestForExtendedMicro(dict: PENewAssessment ,certificationData : [PECertificateData]) -> JSONDictionary{
        
        let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier")!
        var UniID = dict.dataToSubmitID ?? ""
        var arr = [PESanitationDTO]()
        let ExtendedPEArr = SanitationEmbrexQuestionMasterDAO.sharedInstance.sendExtendedPEFilledDTO(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", assessmentId: peNewAssessment?.serverAssessmentId ?? "")
        arr.append(contentsOf: ExtendedPEArr)
        
        var extendedData : [[String: Any]]?
        let jsonEncoder = JSONEncoder()
        let jsonDataArr = try? jsonEncoder.encode(arr)
        if jsonDataArr != nil{
            extendedData = try? JSONSerialization.jsonObject(with: jsonDataArr!, options: []) as? [[String: Any]]
        }
        
        let evaluationDate = dict.evaluationDate
        if UniID == "" {
            UniID = dict.draftID ?? ""
        }
        
        saveTypeString.append(11)
        
        let deviceIdForServer = "\(UniID)_1_iOS_\(udid)"
        deviceIDFORSERVER = deviceIdForServer
        
        if dict.assDetail2?.lowercased().contains("_1_ios") ?? false{
            deviceIDFORSERVER = dict.assDetail2 ?? ""
        }
        var serverAssessmentId:Int64 = 0
        if dict.serverAssessmentId != nil{
            serverAssessmentId = Int64( dict.serverAssessmentId ?? "") ?? 0
        }
        
      
        let EvaluationId = dict.evaluationID
        
        let UserId = dict.userID
      
        let dateFormatter = DateFormatter()
        let regionId = UserDefaults.standard.integer(forKey: "Regionid")
        
        dateFormatter.dateFormat=Constants.MMddyyyyStr
        
        
        var dateSig = ""
        let ddd = dict.sig_Date ?? ""
        if ddd != "" {
            dateSig = self.convertDateFormat(inputDate: ddd)
        }
        
        if dateSig != ""{
            dict.evaluationDate = dateSig
        }else{
            let convertDateFormatter = DateFormatter()

            convertDateFormatter.dateFormat = Constants.yyyyMMddStr
            convertDateFormatter.locale = Calendar.current.locale
        }
    
        if regionId == 3 {
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = Constants.MMddyyyyStr

            if let date = inputFormatter.date(from: evaluationDate ?? "") {
                
                debugPrint(date)
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = Constants.yyyyMMddStr
                dict.evaluationDate = evaluationDate
            } else {
                print(appDelegateObj.invalidDateStr)
            }
        }
        else
        {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = Constants.ddMMyyyStr

            if let date = inputFormatter.date(from: evaluationDate ?? "") {
                debugPrint(date)
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = Constants.yyyyMMddStr
                dict.evaluationDate = evaluationDate
            } else {
                print(appDelegateObj.invalidDateStr)
            }
        }
       

        
        let isEMRequested = dict.IsEMRequested ?? false
     
        let appVersion = "\(Bundle.main.versionNumber)"
        
        var saveType = 0
        if dict.IsEMRequested == true
        {
            saveType = 1
        }
        else
        {
            saveType = 0
        }
        
        var json: JSONDictionary = [
            "AssessmentId":serverAssessmentId,
            "DeviceId": deviceIDFORSERVER,
            "UserId": UserId,
            "EvaluationId": EvaluationId ?? 0,
            "SaveType":saveType,
            "Status_Type": 0,
            "IsEMRequested" : isEMRequested,
            "IsSendEmail": true,
            "appVersion": appVersion,
            "SanitationEmbrexScoresDataModel":extendedData
        ] as JSONDictionary
        
        return json
        
    }

    // MARK: ------------ Call Extended Micro Sync API --------------
    // MARK:
    
    func callExtendedMicro(param:JSONDictionary){
        
        ZoetisWebServices.shared.sendExtendedMicroToServer(controller: self, parameters: param, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            
            guard let self = self, error == nil else { return }
            if json["StatusCode"]  == 200{
                
                self.dismissGlobalHUD(self.view)
                
            }
            else {
                self.dismissGlobalHUD(self.view)
                self.showAlert(title: "Error", message: "Error in Extended Micro data sync", owner: self)
            }
        })
    }
    
    // MARK: - Sync Extended Microbial
    func syncExtendedMicrobial ()
    {
        var extendedMicroArr : [JSONDictionary]  = []
        
        certificateData.removeAll()
        if peNewAssessment.vMixer.count > 0 {
            var idArr : [Int] = []
            for objn in  peNewAssessment.vMixer {
                let data = CoreDataHandlerPE().getCertificateData(doaId: objn)
                if idArr.contains(data!.id ?? 0){
                    debugPrint("extended Microbial..")
                }else{
                    idArr.append(data!.id ?? 0)
                    if data != nil{
                        certificateData.append(data!)
                        
                    }
                }
            }
        }
        
        let jsonExtendedMicro = self.createSyncRequestForExtendedMicro(dict: peNewAssessment, certificationData: self.certificateData)
        extendedMicroArr.append(jsonExtendedMicro)
        let ExtendedMicroparam = ["ExtendedMicrobialData":extendedMicroArr] as JSONDictionary
        self.convertDictToJson(dict: ExtendedMicroparam,apiName: "Assessment_AddEMAssessment")
        self.callExtendedMicro(param: ExtendedMicroparam)
    }
    
}

public struct PEStatus {
    
    let StatusType: String?
    let IsStatus: Bool?
    
    init(_ json: JSON) {
        StatusType = json["StatusType"].stringValue
        IsStatus = json["IsStatus"].boolValue
    }
}

extension String {
    var nonEmpty: String? {
        self.isEmpty ? nil : self
    }
}

extension Optional where Wrapped == String {
    var nonEmpty: String? {
        self?.nonEmpty
    }
}
