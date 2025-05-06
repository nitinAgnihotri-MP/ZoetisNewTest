//
//  PEAssesmentFinalize.swift
//  Zoetis -Feathers
//
//  Created by "" ""on 13/12/19.
//  Copyright © 2019  . All rights reserved.
//

import UIKit
import SwiftyJSON


class PEViewAssesmentFinalize: BaseViewController , DatePickerPopupViewControllerProtocol {
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var switchA = 0
    var switchB = 0
    var deviceIDFORSERVER = ""
    var saveTypeString : [Int] = []
    var totalImageToSync : [Int] = []
    var callRequest4Int = 0
    var isFromEditMicro : Bool = false
    var peHeaderViewController:PEHeaderViewController!
    var peNewAssessment:PENewAssessment!
    var dropdownManager = ZoetisDropdownShared.sharedInstance
    var delegate: PECategorySelectionDelegate? = nil
    var currentArr : [AssessmentQuestions] = []
    var selectedCategory : PENewAssessment?
    var collectionviewIndexPath = IndexPath(row: 0, section: 0)
    var jsonRe : JSON = JSON()
    var pECategoriesAssesmentsResponse =  PECategoriesAssesmentsResponse(nil)
    var tableviewIndexPath = IndexPath(row: 0, section: 0)
    var catArrayForCollectionIs : [PENewAssessment] = []
    var catArrayForTableIs = NSArray()
    var certificateData : [PECertificateData] = []
    var inovojectData : [InovojectData] = []
    var dayOfAgeData : [InovojectData] = []
    var dayOfAgeSData : [InovojectData] = []
    var showExtendedPE:Bool = false
    var fsrSign = ""
    var sanitationQuesArr = [PE_ExtendedPEQuestion]()
    var refriCamerAssesment =  [PE_AssessmentInProgress]()
    var refrigtorProbeArray  : [PE_Refrigators] = []
    var refrigator_Selected_NA_QuestionArray = [Int:Int]()
    var selctedNACategoryArray = [Int]()
    var regionID = Int()
    var submitExtend : Bool = false
    var categoarylabelText : String = ""
    var textValue  : Int?
    var tempArr : [JSONDictionary]  = []
    
    @IBOutlet weak var constraintConstantHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonFinishAssessment: PESubmitButton!
    @IBOutlet weak var buttonSaveAsDraft: PESubmitButton!
    @IBOutlet weak var constraintTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewForMultiSignature: UIView!
    @IBOutlet weak var buttonSaveAsDraftInitial: PESubmitButton!
    @IBOutlet weak var synWebBtn: PESubmitButton!
    @IBOutlet weak var assessmentDateText: PEFormTextfield!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var sig_Name: UILabel!
    @IBOutlet weak var lblNA: UILabel!
    @IBOutlet weak var btnNA: UIButton!
    @IBOutlet weak var viewForSignature: UIView!
    @IBOutlet weak var sig_EmployeeID: UITextField!
    @IBOutlet weak var scoreParentView: UIView!
    @IBOutlet weak var sig_Date: UITextField!
    @IBOutlet weak var sig_Phone: UITextView!
    @IBOutlet weak var lblRepresentative2: UILabel!
    @IBOutlet weak var imgSignature2: UIImageView!
    @IBOutlet weak var lblTitle2: UITextField!
    @IBOutlet weak var sig_imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var extendedMicroSwitch: UISwitch!
    @IBOutlet weak var lblextenderMicro: UILabel!
    @IBOutlet weak var collectionViewSignature: UICollectionView!
    @IBOutlet weak var tableViewSignature: UITableView!
    @IBOutlet weak var resultScoreLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet fileprivate weak var tableview: UITableView!
    @IBOutlet weak var selectedCustomer: PEFormLabel!
    @IBOutlet weak var selectedComplex: PEFormLabel!
    @IBOutlet weak var scoreGradientView: UIView!
    @IBOutlet weak var customerGradientView: UIView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var coustomerView: UIView!
    @IBOutlet weak var bckButton: PESubmitButton!
    let date2020_05_23 = "2020-05-23T06:36:50.915Z"
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
        
    }
    // MARK:  Back Button Action
    @IBAction func backButton(_ sender: Any) {
        if isFromEditMicro {
            isFromEditMicro = false
            self.navigationController?.popViewController(animated: true)
        }else {
            cleanSessionAndMoveTOStart()
            
        }
    }
    
    private func cleanSessionAndMoveTOStart(){
        if(regionID == 3){
            let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PEViewStartNewAssessment") as? PEViewStartNewAssessment
            vc?.peNewAssessment = self.peNewAssessment
            if vc != nil {
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PEViewStartNewAssesmentINT") as? PEViewStartNewAssesmentINT
            vc?.peNewAssessment = self.peNewAssessment
            if vc != nil {
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
        
    }
    // MARK: Extended Micro Switch
    @IBAction func extendedMicroSwitch(_ sender: UISwitch) {
        if extendedMicroSwitch.isOn {
            self.submitExtend = true
            UserDefaults.standard.set(true, forKey:"ExtendedMicro")
            UserDefaults.standard.setValue(true, forKey: "extendedAvailable")
            self.synWebBtn.isEnabled = true
            self.synWebBtn.alpha = 1.0
        } else {
            self.submitExtend = false
            UserDefaults.standard.setValue(false, forKey: "extendedAvailable")
            UserDefaults.standard.set(false, forKey:"ExtendedMicro")
            self.synWebBtn.isEnabled = false
            self.synWebBtn.alpha = 0.3
        }
    }
    
    fileprivate func handleCatArrayForCollectionIsDOAViewDidLoad() {
        var processedIds = Set<Int>()
        
        for cat in catArrayForCollectionIs where !cat.doa.isEmpty {
            for doaId in cat.doa {
                guard let data = CoreDataHandlerPE().getPEDOAData(doaId: doaId),
                      let id = data.id else { continue }
                
                if processedIds.insert(id).inserted {
                    dayOfAgeData.append(data)
                } else {
                    debugPrint("Id \(id) is already in array")
                }
            }
        }
    }
    
    fileprivate func handleCatArrayForCollectionIsDoasViewDidLoad() {
        var processedIds = Set<Int>()
        
        for cat in catArrayForCollectionIs where !cat.doaS.isEmpty {
            for doaId in cat.doaS {
                guard let data = CoreDataHandlerPE().getPEDOAData(doaId: doaId),
                      let id = data.id else { continue }
                
                if processedIds.insert(id).inserted {
                    dayOfAgeSData.append(data)
                } else {
                    debugPrint("Day of Age Sub Id \(id) is already in array")
                }
            }
        }
    }
    
    fileprivate func handleCatArrayForCollectionIsInovojectViewDidLoad() {
        for cat in catArrayForCollectionIs{
            if cat.inovoject.count > 0 {
                var idArr : [Int] = []
                for obj in  cat.inovoject {
                    let data = CoreDataHandlerPE().getPEDOAData(doaId: obj)
                    if idArr.contains(data!.id ?? 0){
                        debugPrint("Inovo Id's already in array")
                    } else{
                        idArr.append(data!.id ?? 0)
                        inovojectData.append(data!)
                    }
                }
            }
        }
    }
    
    fileprivate func handleCatArrayForCollectionIsVMixerViewDidLoad() {
        for cat in catArrayForCollectionIs{
            if cat.vMixer.count > 0 {
                var idArr : [Int] = []
                for obj in  cat.vMixer {
                    let data = CoreDataHandlerPE().getCertificateData(doaId: obj)
                    if idArr.contains(data!.id ?? 0){
                        debugPrint("certificate data already in array")
                    }else{
                        idArr.append(data!.id ?? 0)
                        certificateData.append(data!)
                    }
                }
            }
        }
    }
    
    fileprivate func handlePeNewAssessmentArrayValidation() {
        let peNewAssessmentArray1 = CoreDataHandlerPE().getOfflineAssessmentArray(id:peNewAssessment.dataToSubmitID ?? "")
        let seq_Number : NSArray = NSArray()
        for obj in peNewAssessmentArray1 {
            seq_Number.adding(obj.sequenceNo)
        }
        
        var carColIdArray : [Int] = []
        for cat in peNewAssessmentArray1 {
            if !carColIdArray.contains(cat.sequenceNo ?? 0){
                carColIdArray.append(cat.sequenceNo ?? 0)
                if(cat.catName == "Refrigerator"){
                    cat.catName = Constants.refrigeratorNitrogenStr
                }
                catArrayForCollectionIs.append(cat)
            }
        }
    }
    
    fileprivate func handleisFromEditMicroValidationManageUserIneration(_ row: inout Int) {
        if !(isFromEditMicro) {
            row = 0
            collectionviewIndexPath = IndexPath(row: row, section: 0)
            lblextenderMicro.isHidden = true
            extendedMicroSwitch.isHidden = true
            extendedMicroSwitch.isUserInteractionEnabled = false
            tableview.isUserInteractionEnabled = true
        } else {
            if self.peNewAssessment.IsEMRequested == false {
                self.extendedMicroSwitch.isOn = false
                self.synWebBtn.isEnabled = false
                self.synWebBtn.alpha = 0.3
                UserDefaults.standard.setValue(false, forKey: "extendedAvailable")
                UserDefaults.standard.set(false, forKey:"ExtendedMicro")
                
            } else {
                synWebBtn.setTitle(Constants.syncToWebStr, for: .normal)
                self.synWebBtn.isEnabled = true
                self.synWebBtn.alpha = 1.0
            }
            
            lblextenderMicro.isHidden = false
            extendedMicroSwitch.isHidden = false
            extendedMicroSwitch.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func registerTableViewCellsAndUIValidations() {
        if selectedCategory?.sig2 ?? 0 > 0 {
            let data2 = CoreDataHandlerPE().getImageByImageID(idArray:(selectedCategory?.sig2)!)
            DispatchQueue.main.async() {
                self.imgSignature2.image = UIImage(data: data2)
            }
        }
        if regionID == 3 {
            if showExtendedPE {
                if(catArrayForCollectionIs.last?.catName == "Sanitation and Embrex Evaluation"){
                    catArrayForCollectionIs.remove(at: catArrayForCollectionIs.count-1)
                }
                
                let catObjectPE = PENewAssessment()
                catObjectPE.catName = Constants.extendedMicrobialStr
                catObjectPE.sequenceNo = 12
                catObjectPE.sequenceNoo = 12
                catArrayForCollectionIs.append(catObjectPE)
                tableview.register(UINib(nibName: "PlateInfoCell", bundle: nil), forCellReuseIdentifier: "PlateInfoCell")
                let nibPlateInfoHeader = UINib(nibName: "PlateInfoHeader", bundle: nil)
                tableview.register(nibPlateInfoHeader, forHeaderFooterViewReuseIdentifier: "PlateInfoHeader")
            } else {
                if(catArrayForCollectionIs.last?.catName == "Sanitation and Embrex Evaluation"){
                    catArrayForCollectionIs.remove(at: catArrayForCollectionIs.count-1)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        print("<<<<",self)
        self.navigationController?.navigationBar.isHidden = true
        viewForSignature.isHidden = true
        peHeaderViewController = PEHeaderViewController()
        peHeaderViewController.titleOfHeader = "View Assessment"
        peHeaderViewController.assId = "C-\(peNewAssessment.dataToSubmitID!)"
        self.headerView.addSubview(peHeaderViewController.view)
        self.topviewConstraint(vwTop: peHeaderViewController.view)
        
        viewForMultiSignature.isHidden = true
        regionID = UserDefaults.standard.integer(forKey: "Regionid")
        
        sanitationQuesArr = SanitationEmbrexQuestionMasterDAO.sharedInstance.fetchAssessmentSanitationQuestions(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", assessmentId: peNewAssessment?.serverAssessmentId ?? "")
        
        showExtendedPE = peNewAssessment.sanitationValue ?? false
        handlePeNewAssessmentArrayValidation()
        
        var row = 0
        handleCatArrayForCollectionIsDOAViewDidLoad()
        handleCatArrayForCollectionIsDoasViewDidLoad()
        handleCatArrayForCollectionIsInovojectViewDidLoad()
        handleCatArrayForCollectionIsVMixerViewDidLoad()
        
        if certificateData.count > 0 {
            self.certificateData =  self.certificateData.sorted(by: {
                let id1 = $0.id as? Int ?? 0
                let id2 = $1.id as? Int ?? 0
                return id1 < id2
            })
        }
        for cat in catArrayForCollectionIs {
            if cat.catISSelected == 1 {
                row = cat.sequenceNo ?? 0 - 1
                selectedCategory = cat
            }
        }
        if selectedCategory?.evaluationDate?.count == nil {
            selectedCategory = catArrayForCollectionIs.first
        }
        
        catArrayForTableIs = CoreDataHandlerPE().fetchViewAssessmentCustomerWithCatID(selectedCategory?.sequenceNo as NSNumber? ?? 0,dataToSubmitNumber: peNewAssessment.dataToSubmitNumber ?? 0)
        
        super.viewDidLoad()
        tableview.register(PEQuestionTableViewCell.nib, forCellReuseIdentifier: PEQuestionTableViewCell.identifier)
        tableview.register(CrewInformationCell.nib, forCellReuseIdentifier: CrewInformationCell.identifier)
        tableview.register(InovojectCell.nib, forCellReuseIdentifier: InovojectCell.identifier)
        tableview.register(InovojectNewTableViewCell.nib, forCellReuseIdentifier: InovojectNewTableViewCell.identifier)
        tableview.register(RefrigatorQuesCell.nib, forCellReuseIdentifier: RefrigatorQuesCell.identifier)
        tableview.register(SetFrezzerPointCell.nib, forCellReuseIdentifier: SetFrezzerPointCell.identifier)
        let refrigatorTempProbeCell = UINib(nibName: "RefrigatorTempProbeCell", bundle: nil)
        tableview.register(refrigatorTempProbeCell, forHeaderFooterViewReuseIdentifier: "RefrigatorTempProbeCell")
        let frezerFooterViewCell = UINib(nibName: "FrezerFooterViewCell", bundle: nil)
        tableview.register(frezerFooterViewCell, forHeaderFooterViewReuseIdentifier: "FrezerFooterViewCell")
        let frezerHeaderViewCell = UINib(nibName: "SetFrezzerPointCell", bundle: nil)
        tableview.register(frezerHeaderViewCell, forHeaderFooterViewReuseIdentifier: "SetFrezzerPointCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        handleisFromEditMicroValidationManageUserIneration(&row)
        
        selectedCategory = catArrayForCollectionIs[0]
        selectinitialCell()
        
        selectedComplex.text = catArrayForCollectionIs.first?.siteName
        selectedCustomer.text = catArrayForCollectionIs.first?.customerName
        assessmentDateText.text =  catArrayForCollectionIs.first?.evaluationDate
        chechForLastCategory()
        setupUI()
        sig_Date.text = selectedCategory?.sig_Date
        fsrSign = selectedCategory?.FSTSignatureImage ?? ""
        sig_Name.text = selectedCategory?.sig_Name
        lblRepresentative2.text = selectedCategory?.sig_Name2
        sig_Phone.text = selectedCategory?.sig_Phone
        sig_EmployeeID.text = selectedCategory?.sig_EmpID
        lblTitle2.text = selectedCategory?.sig_EmpID2
        let data = CoreDataHandlerPE().getImageByImageID(idArray:(selectedCategory?.sig)!)
        DispatchQueue.main.async() {
            self.sig_imageView.image = UIImage(data: data)
        }
        
        registerTableViewCellsAndUIValidations()
        collectionView.reloadData()
        tableview.reloadData()
        collectionView(collectionView, didSelectItemAt: collectionviewIndexPath)
        self.collectionView.selectItem(at: self.collectionviewIndexPath, animated: false, scrollPosition: .left)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshScores(_:)), name: NSNotification.Name.init(rawValue: "RefreshExtendedPEScores") , object: nil)
        collectionViewSignature.reloadData()
        synWebBtn.isHidden = false
        bckButton.isHidden = isFromEditMicro
        lblNA.isHidden = regionID == 3
        btnNA.isHidden = regionID == 3

        if(regionID != 3) {
            showHideNA(sequenceNoo: self.selectedCategory?.sequenceNoo ?? 0, catName: self.selectedCategory?.catName ?? "")
        }
    }
    
    @objc func  refreshScores(_ notification: NSNotification){
        let sanitationIndex =  notification.userInfo?["index"]  as? Int
        refreshScore(sanitationIndex ?? -1)
    }
    
    func refreshScore(_ sanitationIndex:Int){
        self.sanitationQuesArr = SanitationEmbrexQuestionMasterDAO.sharedInstance.fetchAssessmentSanitationQuestions(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", assessmentId: self.peNewAssessment?.serverAssessmentId ?? "")
        let score = sanitationQuesArr.map({($0.currentScore ?? 0)}).reduce(0,+)
        
        resultScoreLabel.text = "\(score)"
        totalScoreLabel.text = "100"
     
    }
    
    func setupUI(){
        synWebBtn.setSyncWebButtonUI()
        let nibCatchers = UINib(nibName: "PETableviewHeaderFooterView", bundle: nil)
        tableview.register(nibCatchers, forHeaderFooterViewReuseIdentifier: "PETableviewHeaderFooterView")
        let nibCas = UINib(nibName: "PEInovojectHeaderFooterView", bundle: nil)
        tableview.register(nibCas, forHeaderFooterViewReuseIdentifier: "PEInovojectHeaderFooterView")
        let nibCasa = UINib(nibName: "PEHeaderDayOfAge", bundle: nil)
        tableview.register(nibCasa, forHeaderFooterViewReuseIdentifier: "PEHeaderDayOfAge")
        let peTableviewConsumerQualityHeader = UINib(nibName: "PETableviewConsumerQualityHeader", bundle: nil)
        tableview.register(peTableviewConsumerQualityHeader, forHeaderFooterViewReuseIdentifier: "PETableviewConsumerQualityHeader")
        
        coustomerView.setCornerRadiusFloat(radius: 24)
        customerGradientView.setCornerRadiusFloat(radius: 24)
        DispatchQueue.main.async {
            self.customerGradientView.setGradient(topGradientColor: UIColor.getGradientUpperColor(), bottomGradientColor: UIColor.getGradientLowerColor())
        }
        
        scoreParentView.backgroundColor =  UIColor.cellAlternateBlueCOlor()
    }
    
    
    func refreshTableView(){
        catArrayForTableIs = CoreDataHandlerPE().fetchViewAssessmentCustomerWithCatID(selectedCategory?.sequenceNo as NSNumber? ?? 0,dataToSubmitNumber: peNewAssessment.dataToSubmitNumber ?? 0)
        tableview.reloadData()
    }
    
    func refreshArray(){
        catArrayForTableIs = CoreDataHandlerPE().fetchViewAssessmentCustomerWithCatID(selectedCategory?.sequenceNo as NSNumber? ?? 0,dataToSubmitNumber: peNewAssessment.dataToSubmitNumber ?? 0)
    }
    
    func filterCategory()  {
        var peCategoryFilteredArray: [PECategory] =  []
        for object in pECategoriesAssesmentsResponse.peCategoryArray{
            if peNewAssessment.evaluationID == object.evaluationID{
                peCategoryFilteredArray.append(object)
            }
        }
        pECategoriesAssesmentsResponse.peCategoryArray = peCategoryFilteredArray
    }
    
    func getRandomNumber(maxNumber: Int, listSize: Int)-> Int {
        var randomNumbers = Set<Int>()
        var sum = 0
        while randomNumbers.count < listSize {
            let randomNumber = Int(arc4random_uniform(UInt32(maxNumber+1)))
            sum = sum + randomNumber
            randomNumbers.insert(randomNumber)
        }
        return sum
    }
    
    
    private func updateScore()  {
       
        resultScoreLabel.text = String(selectedCategory?.catResultMark ?? 0)
        totalScoreLabel.text = String(selectedCategory?.catMaxMark ?? 0)
        let finalResult = CoreDataHandlerPE().fetchCustomerWithCatIDCount(Int64(selectedCategory?.sequenceNo ?? 0))
        if  finalResult != 0{
            resultScoreLabel.text = String(finalResult ?? 0)
        }
        
    }
    
    private func selectinitialCell() {
        collectionView.selectItem(at: collectionviewIndexPath, animated: false, scrollPosition: .left)
        updateScore()
    }
    
    // MARK: Finalize Button Action
    @IBAction func finalizeButtonClicked(_ sender: Any) {
        
        let errorMSg = Constants.areYouSureAssessmentStr
        let alertController = UIAlertController(title: "Alert", message: errorMSg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            _ in
            self.saveFinalizedData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    // MARK:  Draft Button Action
    @IBAction func draftBtnClicked(_ sender: Any) {
        self.draftAction()
    }
    
    @IBAction func draftButtonClickedInitial(_ sender: Any) {
        self.draftAction()
    }
    
    func draftAction()
    {
        let errorMSg = "Are you sure you want to save assessment in Draft?"
        let alertController = UIAlertController(title: "Alert", message: errorMSg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            _ in
            self.saveDraftData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK:  Save Finalize Data
    private func saveFinalizedData(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PEFinishPopupViewController") as! PEFinishPopupViewController
        vc.validationSuccessFull = {[unowned self] ( error) in
            self.finishSession()
        }
        self.navigationController?.present(vc, animated: false, completion: nil)
        
    }
    
    // MARK:  Get Offline Assessment's From DB
    func getAssessmentInOfflineFromDb() -> Int {
        var allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInOffline")
        var carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "dataToSubmitNumber") as? NSArray ?? []
        var carColIdArray : [Int] = []
        
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArray.contains(obj as? Int ?? 0){
                carColIdArray.append(obj as? Int ?? 0)
            }
        }
        return carColIdArray.count
    }
    // MARK:  Get Drafted Assessment's Count
    func getDraftCountFromDb() -> Int {
        var allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsWithUserIDForAny(entityName: "PE_AssessmentInDraft")
        var carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "draftNumber") as? NSArray ?? []
        var carColIdArray : [Int] = []
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArray.contains(obj as? Int ?? 0){
                carColIdArray.append(obj as? Int ?? 0)
            }
        }
        return carColIdArray.last ?? 0
    }
    // MARK:  Save Draft Data
    private func saveDraftData(){
        var allAssesmentArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInProgress")
        let draftNumber = getDraftCountFromDb()
        var count = 0
        CoreDataHandlerPE().saveDraftPEInDB(newAssessmentArray: allAssesmentArr as? [PENewAssessment] ?? [], draftNumber: draftNumber + 1)
        finishSession()
    }
    // MARK:  Finish Session
    func finishSession()  {
        cleanSession()
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateComplexOnDashboardPE"),object: nil))
    }
    // MARK:  Clean Session
    private func cleanSession(){
        
        let peNewAssessmentSurrentIs =  CoreDataHandlerPE().getSavedOnGoingAssessmentPEObject()
        let peNewAssessmentNew = PENewAssessment()
        peNewAssessmentNew.siteId = peNewAssessmentSurrentIs.siteId
        peNewAssessmentNew.customerId = peNewAssessmentSurrentIs.customerId
        peNewAssessmentNew.complexId = peNewAssessmentSurrentIs.complexId
        peNewAssessmentNew.siteName = peNewAssessmentSurrentIs.siteName
        peNewAssessmentNew.userID = peNewAssessmentSurrentIs.userID
        peNewAssessmentNew.customerName = peNewAssessmentSurrentIs.customerName
        peNewAssessmentNew.firstname = peNewAssessmentSurrentIs.firstname
        peNewAssessmentNew.username = peNewAssessmentSurrentIs.username
        peNewAssessmentNew.evaluatorName = peNewAssessmentSurrentIs.evaluatorName
        peNewAssessmentNew.evaluationDate = peNewAssessmentSurrentIs.evaluationDate
        self.navigationController?.popToViewController(ofClass: PEDashboardViewController.self)
    }
    
}
// MARK:  Table View delegate's
extension PEViewAssesmentFinalize: UITableViewDelegate, UITableViewDataSource{
    
    func checkForTraning()-> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let assessment = catArrayForTableIs.first as? PE_AssessmentInProgress else {
            return sectionCountForSelectedCategory()
        }

        switch assessment.sequenceNoo {
        case 1:
            return checkForTraning() ? 5 : 4

        case 3:
            if regionID != 3 || peNewAssessment.evaluationID == 1 {
                return 1
            } else {
                return 2
            }

        default:
            return sectionCountForSelectedCategory()
        }
    }
    
    private func sectionCountForSelectedCategory() -> Int {
        if selectedCategory?.sequenceNoo == 12,
           selectedCategory?.catName != Constants.refrigeratorNitrogenStr {
            return 1
        }

        if selectedCategory?.sequenceNoo == 11,
           selectedCategory?.catName == Constants.refrigeratorNitrogenStr {
            return 3
        }

        return 2
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if checkForTraning() {
            // Case: Training Mode
            if selectedCategory?.sequenceNoo == 12,
               selectedCategory?.catName != Constants.refrigeratorNitrogenStr,
               section == 0 {
                return sanitationQuesArr.count
            }
            
            if selectedCategory?.sequenceNoo == 11,
               selectedCategory?.catName == Constants.refrigeratorNitrogenStr {
                return 2
            }
            
            switch section {
            case 1: return certificateData.count
            case 2: return inovojectData.count
            case 3: return dayOfAgeData.count
            case 4: return dayOfAgeSData.count
            default: return catArrayForTableIs.count
            }
            
        } else {
            // Case: Non-training mode
            guard catArrayForTableIs.count > 0,
                  let assessment = catArrayForTableIs[0] as? PE_AssessmentInProgress else {
                return catArrayForTableIs.count
            }
            
            if assessment.sequenceNoo == 3 {
                return section == 0 ? catArrayForTableIs.count : 1
            }

            switch section {
            case 1: return inovojectData.count
            case 2: return dayOfAgeData.count
            case 3: return dayOfAgeSData.count
            default: return catArrayForTableIs.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if checkForTraning(), selectedCategory?.catName != Constants.refrigeratorNitrogenStr {
            switch indexPath.section {
            case 1:
                return 130
            case 2:
                return 200
            default:
                break
            }
        }

        if selectedCategory?.sequenceNoo == 12,
           selectedCategory?.catName != Constants.refrigeratorNitrogenStr {
            return 70
        }

        if selectedCategory?.sequenceNoo == 11,
           selectedCategory?.catName == Constants.refrigeratorNitrogenStr {
            return 80
        }

        if selectedCategory?.sequenceNoo == 3, indexPath.section == 0 {
            if let assessment = catArrayForTableIs[indexPath.row] as? PE_AssessmentInProgress {
                if assessment.rollOut == "Y", assessment.qSeqNo == 1 {
                    return 120
                } else {
                    return 70
                }
            }
            return 70
        }

        if selectedCategory?.catName != Constants.refrigeratorNitrogenStr,
           indexPath.section > 0 {
            return 130
        }

        // Default case – only access assessment safely
        if let assessment = catArrayForTableIs[indexPath.row] as? PE_AssessmentInProgress {
            return estimatedHeightOfLabel(text: assessment.assDetail1 ?? "") + 50
        }

        return 70
    }

    
    func estimatedHeightOfLabel(text: String) -> CGFloat {
        
        let size = CGSize(width: view.frame.width - 16, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let font = UIFont(name: "HelveticaNeue-Bold", size: 20)//font type and size
        
        let attributes = [NSAttributedString.Key.font: font]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
    }
    
    
    fileprivate func handlePlateTypeCompletionCellForRow(_ cell: PlateInfoCell, _ indexPath: IndexPath) {
        cell.plateTypeCompletion = {
            [unowned self] ( error) in
            self.tableviewIndexPath = indexPath
            
            
            let plateTypes = PlateTypesDAO.sharedInstance.fetchPlateTypes(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "")
            let arr = plateTypes.map{ $0.value}
            self.dropDownVIewNew(arrayData: arr as! [String], kWidth: cell.plateTypeBtn.frame.width, kAnchor: cell.plateTypeBtn, yheight: cell.plateTypeBtn.bounds.height) {
                [unowned self] selectedVal, index  in
                if indexPath.row > -1 && self.sanitationQuesArr.count > indexPath.row{
                    let quesObj = self.sanitationQuesArr[indexPath.row]
                    if index > -1 && plateTypes.count > index{
                        self.sanitationQuesArr = SanitationEmbrexQuestionMasterDAO.sharedInstance.fetchAssessmentSanitationQuestions(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", assessmentId: self.peNewAssessment?.serverAssessmentId ?? "")
                        
                        quesObj.plateTypeDescription = plateTypes[index].value
                        quesObj.plateTypeId =  plateTypes[index].id
                        
                        self.sanitationQuesArr[indexPath.row] = quesObj
                        SanitationEmbrexQuestionMasterDAO.sharedInstance.updateAssessmentQuestion(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", assessmentId: self.peNewAssessment?.serverAssessmentId ?? "", questionId: Int64(quesObj.questionId ?? "") ?? 0, questionVM: quesObj)
                        
                    }
                    self.tableview.beginUpdates()
                    self.tableview.reloadRows(at: [indexPath], with: .none)
                    self.tableview.endUpdates()
                    
                }
            }
            
            self.dropHiddenAndShow()
        }
    }
    
    fileprivate func handleCommentsCompletionCellForRow(_ cell: PlateInfoCell, _ indexPath: IndexPath, _ tableView: UITableView) {
        cell.commentsCompletion = {[unowned self] ( error) in
            self.tableviewIndexPath = indexPath
            
            self.sanitationQuesArr = SanitationEmbrexQuestionMasterDAO.sharedInstance.fetchAssessmentSanitationQuestions(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", assessmentId: self.peNewAssessment?.serverAssessmentId ?? "")
            var comments = self.sanitationQuesArr[indexPath.row].userComments ?? ""
            var questionObj = self.sanitationQuesArr[indexPath.row]
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "CommentPopupViewController") as! CommentPopupViewController
            vc.textOfTextView = comments
            if peNewAssessment.IsEMRequested == false {
                vc.editable = true
            }
            else {
                vc.editable = false
            }
            vc.commentCompleted = {[unowned self] ( note) in
                if note == "" {
                    let image = UIImage(named: Constants.peCommentImageStr)
                    cell.noteBtn.setImage(image, for: .normal)
                    
                } else {
                    let image = UIImage(named: Constants.peCommentSelectedStr)
                    cell.noteBtn.setImage(image, for: .normal)
                }
                
                questionObj.userComments = note ?? ""
                self.sanitationQuesArr[indexPath.row] = questionObj
                if questionObj != nil{
                    SanitationEmbrexQuestionMasterDAO.sharedInstance.updateAssessmentQuestion(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", assessmentId: self.peNewAssessment?.serverAssessmentId ?? "", questionId: Int64(questionObj.questionId ?? "") ?? 0, questionVM: questionObj)
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath.init(row: indexPath.row, section: 0)], with: .automatic)
                    tableView.endUpdates()
                }
            }
            if vc.editable{
                self.navigationController?.present(vc, animated: false, completion: nil)
            }else{
                if comments != nil && comments != ""{
                    self.navigationController?.present(vc, animated: false, completion: nil)
                }
            }
        }
    }
    
    private func handleCellForRowCheckForTrainingTrue(indexPath:IndexPath,tableView:UITableView,isExtendedMicrobial:Bool,isRefrigeratorNitrogen:Bool) -> UITableViewCell? {
        if indexPath.section == 0 && isExtendedMicrobial {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlateInfoCell", for: indexPath) as? PlateInfoCell else {
                return nil
            }

            cell.currentIndex = indexPath.row
            cell.plateTypeBtn.isUserInteractionEnabled = false
            cell.blueGreenMoldTxtField.isUserInteractionEnabled = !peNewAssessment.IsEMRequested!
            cell.bacteriaTxtField.isUserInteractionEnabled = !peNewAssessment.IsEMRequested!
            cell.noteBtn.isUserInteractionEnabled = !peNewAssessment.IsEMRequested!

            if sanitationQuesArr.count > indexPath.row {
                cell.setValues(quesObj: sanitationQuesArr[indexPath.row], index: indexPath.row)
            }

            handlePlateTypeCompletionCellForRow(cell, indexPath)
            handleCommentsCompletionCellForRow(cell, indexPath, tableView)
            refreshScore(indexPath.row)
            cell.assessmentId = peNewAssessment?.serverAssessmentId
            return cell
        }

        // Section 0 – Refrigerator cell
        if isRefrigeratorNitrogen {
            return setUpRerigatorQuesCell(tableView, cellForRowAt: indexPath)
        }

        // Other sections – based on section index
        switch indexPath.section {
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: CrewInformationCell.identifier) as? CrewInformationCell,
               certificateData.count > indexPath.row {
                cell.config(data: certificateData[indexPath.row])
                cell.isUserInteractionEnabled = false
                return cell
            }
        case 2:
            return setupInovojectCell(tableView, cellForRowAt: indexPath)
        case 3:
            return setupDayOfAgeCell(tableView, cellForRowAt: indexPath)
        case 4:
            return setupDayOfAgeSCell(tableView, cellForRowAt: indexPath)
        default:
            return setupPEQuestionTableViewCell(tableView, cellForRowAt: indexPath)
        }
        
        return nil
    }
    
    
    fileprivate func handleCheckForTrainingFalseCaseSeqNot12(_ indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        switch indexPath.section {
        case 1:
            return setupInovojectCell(tableView, cellForRowAt: indexPath)
        case 2:
            return setupDayOfAgeCell(tableView, cellForRowAt: indexPath)
        case 3:
            return setupDayOfAgeSCell(tableView, cellForRowAt: indexPath)
        default:
            return setupPEQuestionTableViewCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let isExtendedMicrobial = selectedCategory?.sequenceNoo == 12 &&
                                  selectedCategory?.catName == Constants.extendedMicrobialStr

        let isRefrigeratorNitrogen = selectedCategory?.catName == Constants.refrigeratorNitrogenStr
        
        if checkForTraning() {
            
            // Section 0 – Extended Microbial Cell
            if let tableCell = self.handleCellForRowCheckForTrainingTrue(indexPath: indexPath, tableView: tableView, isExtendedMicrobial: isExtendedMicrobial, isRefrigeratorNitrogen: isRefrigeratorNitrogen) {
                return tableCell
            }
        } else {
            guard catArrayForTableIs.count > 0,
                  let assessment = catArrayForTableIs.object(at: 0) as? PE_AssessmentInProgress else {
                return UITableViewCell()
            }

            let catName = assessment.catName?.lowercased() ?? ""

            if assessment.sequenceNoo == 3 && catName != "miscellaneous" {
                if indexPath.section == 0 {
                    return setupPEQuestionTableViewCell(tableView, cellForRowAt: indexPath)
                } else {
                    return UITableViewCell()
                }
            }

            if assessment.sequenceNoo == 12 && catName != "refrigator\n/fridger\n/liquid nitriogen" {
                if indexPath.section == 1 {
                    return setupInovojectCell(tableView, cellForRowAt: indexPath)
                }
            } else {
                return handleCheckForTrainingFalseCaseSeqNot12(indexPath, tableView)
            }
        }

        return UITableViewCell()
    }

    // MARK:  Setup PE  Rerigator questions data */
    
    func setUpRerigatorQuesCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> RefrigatorQuesCell {
        catArrayForTableIs = CoreDataHandlerPE().fetchViewAssessmentCustomerWithCatID(selectedCategory?.sequenceNo as NSNumber? ?? 0, dataToSubmitNumber: peNewAssessment.dataToSubmitNumber ?? 0)
        let (assesmentArray, assessment) = getAssessmentArrays(for: indexPath)
        self.refriCamerAssesment = assesmentArray
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RefrigatorQuesCell.identifier) as? RefrigatorQuesCell else {
            return RefrigatorQuesCell()
        }
        configureCell(cell, with: assesmentArray, assessment: assessment, indexPath: indexPath)
        setupNAButton(cell, assesmentArray: assesmentArray, assessment: assessment, indexPath: indexPath)
        setupImageCompletion(cell, assessment: assessment)
        setupInfoCompletion(cell, assessment: assessment, indexPath: indexPath)
        return cell
    }

    // Helper 1: Get assessment arrays and current assessment
    private func getAssessmentArrays(for indexPath: IndexPath) -> ([PE_AssessmentInProgress], PE_AssessmentInProgress?) {
        var assesmentArray = [PE_AssessmentInProgress]()
        var assessment: PE_AssessmentInProgress?
        var arrayRefri = [PE_AssessmentInProgress]()
        var arrayFreezer = [PE_AssessmentInProgress]()
        var arrayLiquid = [PE_AssessmentInProgress]()
        arrayRefri.append(catArrayForTableIs[0] as! PE_AssessmentInProgress)
        arrayRefri.append(catArrayForTableIs[1] as! PE_AssessmentInProgress)
        arrayFreezer.append(catArrayForTableIs[5] as! PE_AssessmentInProgress)
        arrayFreezer.append(catArrayForTableIs[6] as! PE_AssessmentInProgress)
        arrayLiquid.append(catArrayForTableIs[11] as! PE_AssessmentInProgress)
        arrayLiquid.append(catArrayForTableIs[12] as! PE_AssessmentInProgress)
        if indexPath.section == 0 {
            assesmentArray = arrayRefri
        } else if indexPath.section == 1 {
            assesmentArray = arrayFreezer
        } else if indexPath.section == 2 {
            assesmentArray = arrayLiquid
        }
        assessment = assesmentArray[indexPath.row]
        return (assesmentArray, assessment)
    }

    // Helper 2: Configure cell UI and state
    private func configureCell(_ cell: RefrigatorQuesCell, with assesmentArray: [PE_AssessmentInProgress], assessment: PE_AssessmentInProgress?, indexPath: IndexPath) {
        configureCellNAState(cell, assesmentArray: assesmentArray, indexPath: indexPath)
        cell.lblQuestion.text = assesmentArray[indexPath.row].assDetail1
        configureCellBackground(cell, indexPath: indexPath)
        configureCameraButton(cell, assessment: assessment)
        configureImageCount(cell, assessment: assessment)
        configureCommentButton(cell, assessment: assessment)
        cell.btn_NA.isUserInteractionEnabled = false
    }

    // Helper 3: Configure NA state
    private func configureCellNAState(_ cell: RefrigatorQuesCell, assesmentArray: [PE_AssessmentInProgress], indexPath: IndexPath) {
		if refrigtorProbeArray.count > 0 {
			for refri in refrigtorProbeArray {
				if refri.id == assesmentArray[indexPath.row].assID {
					let refNaStatus = refri.isNA ?? false
					cell.btn_NA.isSelected = refNaStatus
					cell.contentView.alpha = 0.3
					cell.btn_Switch.isUserInteractionEnabled = !refNaStatus
					cell.btn_Info.isUserInteractionEnabled = !refNaStatus
					cell.btn_Camera.isUserInteractionEnabled = !refNaStatus
					cell.btn_Comment.isUserInteractionEnabled = !refNaStatus
					cell.switchClicked(status: refNaStatus)
					cell.btn_Switch.setOn(refNaStatus, animated: false)
				}
			}
		}
    }

    // Helper 4: Configure cell background
    private func configureCellBackground(_ cell: RefrigatorQuesCell, indexPath: IndexPath) {
        if indexPath.section == 0 {
            cell.contentView.backgroundColor = (indexPath.row == 0) ? .clear : .white
        } else if indexPath.section == 1 {
            cell.contentView.backgroundColor = (indexPath.row == 0) ? .clear : .white
        } else {
            cell.contentView.backgroundColor = (indexPath.row == 0) ? .white : .clear
        }
    }

    // Helper 5: Configure camera button
    private func configureCameraButton(_ cell: RefrigatorQuesCell, assessment: PE_AssessmentInProgress?) {
        if assessment?.camera == 1 {
            cell.btn_Camera.isEnabled = true
            cell.btn_Camera.alpha = 1
        } else {
            cell.btn_Camera.isEnabled = false
            cell.btn_Camera.alpha = 0.3
        }
    }

    // Helper 6: Configure image count
    private func configureImageCount(_ cell: RefrigatorQuesCell, assessment: PE_AssessmentInProgress?) {
        let imageCount = assessment?.images as? [Int]
        let cnt = imageCount?.count
        let ttle = String(cnt ?? 0)
        cell.btn_ImageCount.setTitle(ttle, for: .normal)
        cell.btn_ImageCount.isHidden = (ttle == "0")
    }

    // Helper 7: Configure comment button
    private func configureCommentButton(_ cell: RefrigatorQuesCell, assessment: PE_AssessmentInProgress?) {
        let image1 = UIImage(named: Constants.peCommentImageStr)
        let image2 = UIImage(named: Constants.peCommentSelectedStr)
        if assessment?.note == "" || assessment?.note == nil {
            cell.btn_Comment.setImage(image1, for: .normal)
        } else {
            cell.btn_Comment.setImage(image2, for: .normal)
        }
    }

    // Helper 8: Setup NA button completion
    private func setupNAButton(_ cell: RefrigatorQuesCell, assesmentArray: [PE_AssessmentInProgress], assessment: PE_AssessmentInProgress?, indexPath: IndexPath) {
        cell.btnNA = { [unowned self] in
            handleNAButton(cell, assesmentArray: assesmentArray, assessment: assessment, indexPath: indexPath)
        }
    }

    // Helper 9: Handle NA button logic
    private func handleNAButton(_ cell: RefrigatorQuesCell, assesmentArray: [PE_AssessmentInProgress], assessment: PE_AssessmentInProgress?, indexPath: IndexPath) {
        var switchisCheck = false
        let refri = catArrayForTableIs[0] as! PE_AssessmentInProgress
        refrigtorProbeArray = CoreDataHandlerPE().getOfflineREfriData(id: Int(refri.serverAssessmentId ?? "0") ?? 0)
        if refrigtorProbeArray.count > 0 {
            for refrii in refrigtorProbeArray {
                if refrii.id == assesmentArray[indexPath.row].assID {
                    switchisCheck = refrii.isCheck ?? false
                }
            }
        }
        if cell.btn_NA.isSelected {
            if self.refrigator_Selected_NA_QuestionArray[indexPath.section] == indexPath.row {
                self.refrigator_Selected_NA_QuestionArray[indexPath.section] = nil
            }
            cell.contentView.alpha = 1
            cell.btn_Switch.isUserInteractionEnabled = true
            cell.btn_Info.isUserInteractionEnabled = true
            cell.btn_Camera.isUserInteractionEnabled = true
            cell.btn_Comment.isUserInteractionEnabled = true
            assessment?.isNA = false
            updateDraftRefrigatorDB(assessment: assessment, switchisCheck: switchisCheck, isNA: false)
        } else {
            assessment?.isAllowNA = true
            self.refrigator_Selected_NA_QuestionArray[indexPath.section] = indexPath.row
            cell.contentView.alpha = 0.3
            cell.btn_Switch.isUserInteractionEnabled = false
            cell.btn_Info.isUserInteractionEnabled = false
            cell.btn_Camera.isUserInteractionEnabled = false
            cell.btn_Comment.isUserInteractionEnabled = false
            assessment?.isNA = true
            updateDraftRefrigatorDB(assessment: assessment, switchisCheck: switchisCheck, isNA: true)
        }
        cell.btn_NA.isSelected = !cell.btn_NA.isSelected
        refrigtorProbeArray = CoreDataHandlerPE().getOfflineREfriData(id: Int(refri.serverAssessmentId ?? "0") ?? 0)
    }

    // Helper 10: Update DraftRefrigator DB
    private func updateDraftRefrigatorDB(assessment: PE_AssessmentInProgress?, switchisCheck: Bool, isNA: Bool) {
        guard let assID = assessment?.assID as? Int else { return }
        let labelText = assessment?.assDetail1 ?? ""
        let catID = assessment?.catID as! NSNumber
        let serverAssessmentId = Int(self.selectedCategory?.serverAssessmentId ?? "0") ?? 0
        if switchisCheck {
            if CoreDataHandlerPE().someDraftRefriEntityExists(id: assID) {
                CoreDataHandlerPE().updateDraftRefrigatorInDB(assID, labelText: labelText, rollOut: "Y", unit: "", value: 0, catID: catID, isCheck: true, isNA: isNA, serverAssessmentId: serverAssessmentId)
            } else {
                CoreDataHandlerPE().saveDraftRefrigatorInDB(assID as NSNumber, labelText: labelText, rollOut: "Y", unit: "", value: 0, catID: catID, isCheck: true, isNA: isNA, schAssmentId: serverAssessmentId)
            }
        } else {
            if CoreDataHandlerPE().someDraftRefriEntityExists(id: assID) {
                CoreDataHandlerPE().updateDraftRefrigatorInDB(assID, labelText: labelText, rollOut: "Y", unit: "", value: 0, catID: catID, isCheck: false, isNA: isNA, serverAssessmentId: serverAssessmentId)
            } else {
                CoreDataHandlerPE().saveDraftRefrigatorInDB(assID as NSNumber, labelText: labelText, rollOut: "Y", unit: "", value: 0, catID: catID, isCheck: false, isNA: isNA, schAssmentId: serverAssessmentId)
            }
        }
    }

    // Helper 11: Setup image completion
    private func setupImageCompletion(_ cell: RefrigatorQuesCell, assessment: PE_AssessmentInProgress?) {
        cell.imagesCompletion = { [unowned self] error in
            let storyBoard = UIStoryboard(name: "PEStoryboard", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "GroupImagesPEViewController") as! GroupImagesPEViewController
            self.refreshArray()
            vc.imagesArray = assessment?.images as? [Int] ?? [0]
            self.navigationController?.present(vc, animated: false, completion: nil)
        }
    }

    // Helper 12: Setup info completion
    private func setupInfoCompletion(_ cell: RefrigatorQuesCell, assessment: PE_AssessmentInProgress?, indexPath: IndexPath) {
        cell.infoCompletion = { [unowned self] error in
            self.tableviewIndexPath = indexPath
            let storyBoard = UIStoryboard(name: "PEStoryboard", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "InfoPEViewController") as! InfoPEViewController
            let maxMarksIs = assessment?.assMaxScore as? Int ?? 0
            let str = "(\(maxMarksIs)) \(assessment?.assDetail1 ?? "")"
            vc.questionDescriptionIs = str
            // ... (rest of your info completion logic)
        }
    }
    // MARK:  Setup Cell for Inovoject Questioner
    func setupInovojectCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> InovojectNewTableViewCell {
        if let cell =  tableView.dequeueReusableCell(withIdentifier: InovojectNewTableViewCell.identifier) as? InovojectNewTableViewCell{
            cell.config(data:inovojectData[indexPath.row])
            if inovojectData[indexPath.row].invoHatchAntibiotic == 1 {
                cell.showHatcheryAnitibiotics()
            } else {
                cell.hideHatcheryAntibiotics()
            }
            if inovojectData[indexPath.row].vaccineMan?.lowercased().containsCaseInsensitive(string: "other") ?? false {
                cell.showOthersConstraint()
            } else {
                cell.hideOthersConstraint()
            }
            if indexPath.row % 2 == 0{
                cell.contentView.backgroundColor = UIColor.white
            } else{
                cell.contentView.backgroundColor = UIColor.getHeaderTopGradient()
            }
            cell.hatcheryAntibioticsSwitch.isUserInteractionEnabled = false
            cell.tfProgramName.isUserInteractionEnabled = false
            cell.tfAntibioticText.isUserInteractionEnabled = false
            cell.tfOtherManText.isUserInteractionEnabled = false
            return cell
        }
        return UITableViewCell() as! InovojectNewTableViewCell
    }
    
    // MARK:  Set up cell for Day Of Age Questioner
    func setupDayOfAgeCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> InovojectCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: InovojectCell.identifier) as? InovojectCell{
            cell.config(data:dayOfAgeData[indexPath.row])
            cell.isUserInteractionEnabled = false
            cell.gradientVIew.setGradient(topGradientColor: UIColor.getGradientUpperColor(), bottomGradientColor: UIColor.getGradientLowerColor())
            return cell
        }
        return UITableViewCell() as! InovojectCell
    }
    
    // MARK:  Set up cell for Day Of Age Sub Questioner
    func setupDayOfAgeSCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> InovojectCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: InovojectCell.identifier) as? InovojectCell{
            cell.config(data:dayOfAgeSData[indexPath.row])
            cell.isUserInteractionEnabled = false
            
            DispatchQueue.main.async {
                cell.gradientVIew.setGradient(topGradientColor: UIColor.getGradientUpperColor(), bottomGradientColor: UIColor.getGradientLowerColor())
            }
            return cell
        }
        return UITableViewCell() as! InovojectCell
    }
    
    
    // MARK:  Set up Customer Vaccine View
    func setCustomerVaccineView(_ tableView: UITableView , section:Int) -> PETableviewConsumerQualityHeader {
        if selectedCategory?.sequenceNoo == 3 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PETableviewConsumerQualityHeader" ) as! PETableviewConsumerQualityHeader
            
            headerView.nameMicro.text =  self.peNewAssessment.micro
            headerView.nameResidue.text =  self.peNewAssessment.residue
            headerView.isUserInteractionEnabled = false
            
            headerView.microComplete =
            {[unowned self] ( error) in
                self.peNewAssessment.micro  = error ?? ""
                CoreDataHandlerPE().updateDraftInDoGInProgressInDB(newAssessment: self.peNewAssessment)
            }
            headerView.residueComplete =
            {[unowned self] ( error) in
                self.peNewAssessment.residue  = error ?? ""
                
                CoreDataHandlerPE().updateDraftInDoGInProgressInDB(newAssessment: self.peNewAssessment)
            }
            return headerView
        }
        return UIView() as! PETableviewConsumerQualityHeader
    }
    
    // MARK:  Set up cell for PE Questioner
    func setupPEQuestionTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> PEQuestionTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PEQuestionTableViewCell.identifier) as? PEQuestionTableViewCell,
              let assessment = catArrayForTableIs[indexPath.row] as? PE_AssessmentInProgress else {
            return UITableViewCell() as! PEQuestionTableViewCell
        }

        configureNAOptions(cell, with: assessment)
        configureInteraction(for: cell, isNA: assessment.isNA)
        configureSpecialFields(cell, with: assessment)
        configureAssessmentLabel(cell, with: assessment)
        configureCellAppearance(cell, indexPath: indexPath, assessment: assessment)
        configureSwitchState(cell, assessment: assessment)
        configureImageAndNoteButtons(cell, assessment: assessment)
        setupCallbacks(for: cell, at: indexPath, with: assessment)

        return cell
    }

    // MARK: - Helper Methods

    private func configureNAOptions(_ cell: PEQuestionTableViewCell, with assessment: PE_AssessmentInProgress) {
        let showNA = (regionID != 3 && assessment.isAllowNA)
        cell.btn_NA.isHidden = !showNA
        cell.lbl_NA.isHidden = !showNA

        guard showNA else { return }

        let isNA = assessment.isNA
        cell.btn_NA.isSelected = isNA

        let needsSpecialField = assessment.rollOut == "Y" && (assessment.sequenceNoo == 3 || assessment.catName == "Miscellaneous")

        if isNA {
            cell.txtQCCount.text = "NA"
        } else if needsSpecialField {
            cell.txtQCCount.text = ""
        }

        cell.txtQCCount.isUserInteractionEnabled = needsSpecialField
    }

    private func configureInteraction(for cell: PEQuestionTableViewCell, isNA: Bool) {
        let alpha: CGFloat = isNA ? 0.3 : 1
        cell.contentView.alpha = alpha

        let isEnabled = !isNA
        [cell.btnImageCount, cell.noteBtn, cell.cameraBTn,
         cell.assessmentLbl, cell.switchBtn, cell.btnInfo,
         cell.txtQCCount].forEach { $0?.isUserInteractionEnabled = isEnabled }

        cell.btn_NA.isSelected = isNA
    }

    private func configureSpecialFields(_ cell: PEQuestionTableViewCell, with assessment: PE_AssessmentInProgress) {
        switch (assessment.rollOut, assessment.sequenceNoo, assessment.qSeqNo, assessment.catName) {
        case ("Y", 3, 12, _):
            cell.txtQCCount.text = assessment.qcCount ?? ""
            cell.showQcCountextField()
        case ("Y", _, 1, "Miscellaneous"):
            cell.txtQCCount.text = assessment.ampmValue ?? ""
            cell.showAMPMValuetextField()
        case ("Y", 3, 1, _):
            cell.txtPersonName.text = assessment.personName ?? ""
            cell.txtFrequency.text = assessment.frequency ?? ""
            cell.showFrequencytextField()
        case ("Y", 5, 5, _):
            cell.txtQCCount.text = assessment.ppmValue ?? ""
            cell.showPPMField()
            peNewAssessment.ppmValue = cell.txtQCCount.text
            CoreDataHandlerPE().updateInDoGInProgressInDB(newAssessment: peNewAssessment)
        default:
            cell.hideAMPMValuetextField()
            cell.hideQcCountextField()
        }

        cell.setGraddientAndLayerQcCountextFieldView()
        cell.txtPersonName.isUserInteractionEnabled = false
        cell.txtFrequency.isUserInteractionEnabled = false
        cell.txtQCCount.isUserInteractionEnabled = false
    }

    private func configureAssessmentLabel(_ cell: PEQuestionTableViewCell, with assessment: PE_AssessmentInProgress) {
        let maxMarks = assessment.assMaxScore as? Int ?? 0
        let markText = "(\(maxMarks)) "
        let fullText = markText + (assessment.assDetail1 ?? "")
        cell.assessmentLbl.text = fullText
        cell.assessmentLbl.attributedText = fullText.withBoldText(text: markText)
    }

    private func configureCellAppearance(_ cell: PEQuestionTableViewCell, indexPath: IndexPath, assessment: PE_AssessmentInProgress) {
        cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.cellAlternateBlueCOlor() : .white
        let cameraEnabled = assessment.camera == 1
        cell.cameraBTn.isEnabled = cameraEnabled
        cell.cameraBTn.alpha = cameraEnabled ? 1 : 0.3
    }

    private func configureSwitchState(_ cell: PEQuestionTableViewCell, assessment: PE_AssessmentInProgress) {
        cell.switchBtn.setOn(assessment.assStatus == 1, animated: false)
        cell.switchBtn.isUserInteractionEnabled = false
    }

    private func configureImageAndNoteButtons(_ cell: PEQuestionTableViewCell, assessment: PE_AssessmentInProgress) {
        let imageCount = (assessment.images as? [Int])?.count ?? 0
        cell.btnImageCount.setTitle("\(imageCount)", for: .normal)
        cell.btnImageCount.isHidden = (imageCount == 0)

        let image = UIImage(named: (assessment.note?.isEmpty ?? true) ? Constants.peCommentImageStr : Constants.peCommentSelectedStr)
        cell.noteBtn.setImage(image, for: .normal)
    }

    private func setupCallbacks(for cell: PEQuestionTableViewCell, at indexPath: IndexPath, with assessment: PE_AssessmentInProgress) {
        cell.completion = { [unowned self] status, _ in
            self.tableviewIndexPath = indexPath
            guard let maxMarks = assessment.assMaxScore as? Int else { return }
            var result = Int(self.resultScoreLabel.text ?? "0") ?? 0
            result += (status ?? false) ? maxMarks : -maxMarks
            self.selectedCategory?.catResultMark = result
            assessment.catResultMark = result as NSNumber
            self.resultScoreLabel.text = String(result)
            assessment.assStatus = (status ?? false) ? 1 : 0
            self.updateAssessmentInDb(assessment: assessment)
            self.refreshTableView()
            self.updateScore()
            self.chechForLastCategory()
        }

        cell.imagesCompletion = { [unowned self] _ in
            let vc = UIStoryboard(name: "PEStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GroupImagesPEViewController") as! GroupImagesPEViewController
            self.refreshArray()
            let updatedAssessment = self.catArrayForTableIs[indexPath.row] as? PE_AssessmentInProgress
            vc.imagesArray = updatedAssessment?.images as? [Int] ?? [0]
            self.navigationController?.present(vc, animated: false)
        }

        cell.commentCompletion = { [unowned self] _ in
            self.tableviewIndexPath = indexPath
            self.refreshArray()
            guard let updatedAssessment = self.catArrayForTableIs[indexPath.row] as? PE_AssessmentInProgress else { return }
            let vc = UIStoryboard(name: "PEStoryboard", bundle: nil).instantiateViewController(withIdentifier: "CommentPopupViewController") as! CommentPopupViewController
            vc.textOfTextView = updatedAssessment.note ?? ""
            vc.infoText = updatedAssessment.informationText ?? ""
            vc.editable = false
            if !vc.editable && !(updatedAssessment.note?.isEmpty ?? true) {
                self.navigationController?.present(vc, animated: false)
            }
        }

        cell.cameraCompletion = { [unowned self] _ in
            self.tableviewIndexPath = indexPath
        }

        cell.infoCompletion = { [unowned self] _ in
            self.tableviewIndexPath = indexPath
            let vc = UIStoryboard(name: "PEStoryboard", bundle: nil).instantiateViewController(withIdentifier: "InfoPEViewController") as! InfoPEViewController
            let maxMarks = assessment.assMaxScore as? Int ?? 0
            vc.questionDescriptionIs = "(\(maxMarks)) " + (assessment.assDetail1 ?? "")
            vc.imageDataBase64 = assessment.informationImage ?? ""
            vc.infotextIs = assessment.informationText ?? ""
            self.navigationController?.present(vc, animated: false)
        }
    }
    
    // MARK: DROP DOWN HIDDEN AND SHOW
    func dropHiddenAndShow(){
        if dropDown.isHidden{
            let _ = dropDown.show()
        } else {
            dropDown.hide()
        }
    }
    // MARK:  Done Button Tabbed with Date
    func doneButtonTappedWithDate(string: String, objDate: Date) {
        
        certificateData[tableviewIndexPath.row].certificateDate = string
        CoreDataHandlerPE().updateVMixerInDB(peCertificateData:  self.certificateData[tableviewIndexPath.row], id:  self.certificateData[tableviewIndexPath.row].id ?? 0)
        tableview.reloadData()
    }
    
    func doneButtonTapped(string:String){
        certificateData[tableviewIndexPath.row].certificateDate = string
        CoreDataHandlerPE().updateVMixerInDB(peCertificateData:  self.certificateData[tableviewIndexPath.row], id:  self.certificateData[tableviewIndexPath.row].id ?? 0)
        tableview.reloadData()
    }
    
    // MARK:  Show Date Picker
    func showDatePicker(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Selection", bundle:nil)
        let datePickerPopupViewController = storyBoard.instantiateViewController(withIdentifier: "DatePickerPopupViewController") as! DatePickerPopupViewController
        datePickerPopupViewController.delegate = self
        datePickerPopupViewController.canSelectPreviousDate = false
        navigationController?.present(datePickerPopupViewController, animated: false, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSanitationHeader(section) {
            return setupSanitationHeader(tableView)
        }
        if isRefrigeratorHeader(section) {
            return setupRefrigeratorHeader(tableView)
        }
        if catArrayForTableIs.count > 0 {
            if checkForTraning() {
                return setupTrainingHeaders(tableView, section: section)
            } else {
                return setupNonTrainingHeaders(tableView, section: section)
            }
        }
        return UIView()
    }

    // Helper 1: Check if this is the sanitation header
    private func isSanitationHeader(_ section: Int) -> Bool {
        return selectedCategory?.sequenceNoo == 12 && section == 0
    }

    // Helper 2: Setup sanitation header
    private func setupSanitationHeader(_ tableView: UITableView) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PlateInfoHeader") as! PlateInfoHeader
        headerView.isUserInteractionEnabled = false
        headerView.contentView.alpha = btnNA.isSelected ? 0.3 : 1.0
        return headerView
    }

    // Helper 3: Check if this is the refrigerator header
    private func isRefrigeratorHeader(_ section: Int) -> Bool {
        return selectedCategory?.sequenceNoo == 11 && section == 2 && selectedCategory?.catName == Constants.refrigeratorNitrogenStr
    }

    // Helper 4: Setup refrigerator header
    private func setupRefrigeratorHeader(_ tableView: UITableView) -> UIView? {
        let array = CoreDataHandlerPE().fetchViewAssessmentCustomerWithCatID(selectedCategory?.sequenceNo as NSNumber? ?? 0, dataToSubmitNumber: peNewAssessment.dataToSubmitNumber ?? 0)
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SetFrezzerPointCell") as! SetFrezzerPointCell
        headerView.isUserInteractionEnabled = false
        headerView.contentView.alpha = (btnNA.isSelected && self.selctedNACategoryArray.contains(78)) ? 0.3 : 1.0
        headerView.setGraddientAndLayerQcCountextFieldView()
        var assessment = array[2] as? PE_AssessmentInProgress
        var unitValue = ""
        var valueText = ""
        refrigtorProbeArray = CoreDataHandlerPE().getOfflineREfriData(id: Int(self.selectedCategory?.serverAssessmentId ?? "0") ?? 0)
        if self.refrigtorProbeArray.count > 0 {
            fillRefrigeratorHeaderFields(headerView, array: array as! [Any])
            unitValue = headerView.unitTxtFld.text ?? ""
            valueText = headerView.valueTxtFld.text ?? ""
        }
        setupRefrigeratorHeaderUnitCompletion(headerView, array: array as! [Any], assessment: assessment, unitValue: unitValue, valueText: valueText)
        setupRefrigeratorHeaderValueCompletion(headerView, array: array as! [Any], assessment: assessment, unitValue: unitValue, valueText: valueText)
        return headerView
    }

    private func fillRefrigeratorHeaderFields(_ headerView: SetFrezzerPointCell, array: [Any]) {
        var ar = array[10] as? PE_AssessmentInProgress
        for j in 0..<self.refrigtorProbeArray.count {
            if ar?.assID == self.refrigtorProbeArray[j].id {
                headerView.unitTxtFld.text = self.refrigtorProbeArray[j].unit ?? ""
                headerView.valueTxtFld.text = "\(self.refrigtorProbeArray[j].value ?? 0.0)"
            }
        }
    }

    private func setupRefrigeratorHeaderUnitCompletion(
        _ headerView: SetFrezzerPointCell,
        array: [Any],
        assessment: PE_AssessmentInProgress?,
        unitValue: String,
        valueText: String
    ) {
        
        var assessmentCopy = assessment
        var valueTextCopy = valueText
        var unitValueCopy = unitValue
        
        headerView.unitCompletion = { sender, txtfld, textLabel in
            let unitArray = ["Fahrenheit", "Celsius"]
            if !unitArray.isEmpty {
                self.dropDownVIewNew(arrayData: unitArray, kWidth: (sender ?? UIButton()).frame.width, kAnchor: sender ?? UIButton(), yheight: (sender ?? UIButton()).bounds.height) { selectedVal, index in
                    txtfld.text = selectedVal
                    unitValueCopy = txtfld.text ?? ""
                    if textLabel == "Frezzer" {
                        assessmentCopy = array[10] as? PE_AssessmentInProgress
                        valueTextCopy = headerView.valueTxtFld.text ?? ""
                    }
                    let assID = assessmentCopy?.assID
                    if CoreDataHandlerPE().someDraftRefriEntityExists(id: assID as! Int) {
                        CoreDataHandlerPE().updateDraftRefrigatorInDB(assID as! Int, labelText: textLabel, rollOut: "Y", unit: unitValueCopy, value: Double(valueTextCopy) ?? 0.0, catID: assessmentCopy?.catID as! NSNumber, isCheck: true, isNA: false, serverAssessmentId: Int(self.selectedCategory?.serverAssessmentId ?? "0") ?? 0)
                    } else {
                        CoreDataHandlerPE().saveDraftRefrigatorInDB(assID as! NSNumber, labelText: textLabel, rollOut: "Y", unit: unitValueCopy, value: Double(valueTextCopy) ?? 0.0, catID: assessmentCopy?.catID as! NSNumber, isCheck: true, isNA: false, schAssmentId: self.selectedCategory?.assID ?? 0)
                    }
                }
                self.dropHiddenAndShow()
            }
        }
    }

    private func setupRefrigeratorHeaderValueCompletion(_ headerView: SetFrezzerPointCell,array: [Any],assessment: PE_AssessmentInProgress?,unitValue: String,valueText: String) {
        var assessmentCopy = assessment
        var valueTextCopy = valueText
        var unitValueCopy = unitValue
        
        headerView.valueCompletion = { value, textLabel in
            if textLabel == "Frezzer" {
                unitValueCopy = headerView.unitTxtFld.text ?? ""
                assessmentCopy = array[10] as? PE_AssessmentInProgress
            }
            valueTextCopy = value?.text ?? ""
            let assID = assessmentCopy?.assID
            if CoreDataHandlerPE().someDraftRefriEntityExists(id: assID as! Int) {
                CoreDataHandlerPE().updateDraftRefrigatorInDB(assID as! Int, labelText: textLabel, rollOut: "Y", unit: unitValueCopy, value: Double(valueTextCopy) ?? 0.0, catID: 1, isCheck: true, isNA: false, serverAssessmentId: Int(self.selectedCategory?.serverAssessmentId ?? "0") ?? 0)
            } else {
                CoreDataHandlerPE().saveDraftRefrigatorInDB(assID as! NSNumber, labelText: textLabel, rollOut: "Y", unit: unitValueCopy, value: Double(valueTextCopy) ?? 0.0, catID: 1, isCheck: true, isNA: false, schAssmentId: self.selectedCategory?.assID ?? 0)
            }
        }
    }

    // Helper 5: Setup headers for training mode
    private func setupTrainingHeaders(_ tableView: UITableView, section: Int) -> UIView? {
        if selectedCategory?.sequenceNoo == 1 {
            switch section {
            case 1:
                return setupVaccineMixerHeader(tableView)
            case 2:
                return self.setPEInovojectHeaderFooterView(tableView, section: section)
            case 3:
                return self.setPEHeaderDayOfAge(tableView, section: section)
            case 4:
                return self.setPEHeaderDayOfAgeS(tableView, section: section)
            default:
                return UIView()
            }
        } else if selectedCategory?.sequenceNoo == 3 {
            if section == 1 {
                return self.setCustomerVaccineView(tableView, section: section)
            } else {
                return UIView()
            }
        }
        return UIView()
    }

    // Helper 6: Setup headers for non-training mode
    private func setupNonTrainingHeaders(_ tableView: UITableView, section: Int) -> UIView? {
        if selectedCategory?.sequenceNoo == 3 {
            if section == 1 {
                return self.setCustomerVaccineView(tableView, section: section)
            } else {
                return UIView()
            }
        }
        switch section {
        case 1:
            return self.setPEInovojectHeaderFooterView(tableView, section: section)
        case 2:
            return self.setPEHeaderDayOfAge(tableView, section: section)
        case 3:
            return self.setPEHeaderDayOfAgeS(tableView, section: section)
        default:
            return UIView()
        }
    }

    // Helper 7: Setup Vaccine Mixer header
    private func setupVaccineMixerHeader(_ tableView: UITableView) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PETableviewHeaderFooterView") as! PETableviewHeaderFooterView
        headerView.isUserInteractionEnabled = false
        headerView.lblTitle.text = "Vaccine Mixer Observer"
        headerView.lblSubTitle.text = "Crew Information"
        headerView.addCompletion = { [unowned self] error in
            let certificateData = PECertificateData(id: 0, name: "", date: "", isCertExpired: false, isReCert: false, vacOperatorId: 0, signatureImg: "", fsrSign: "")
            let id = self.saveVMixerInPEModule(peCertificateData: certificateData)
            certificateData.id = id
            self.certificateData.append(certificateData)
            DispatchQueue.main.async {
                self.reloadTableViewWithoutAnimation()
            }
        }
        headerView.minusCompletion = { [unowned self] error in
            if self.certificateData.count > 0 {
                self.certificateData.removeLast()
            }
            if self.certificateData.count > 1 {
                UIView.performWithoutAnimation {
                    self.tableview.reloadData()
                    self.scrollToBottom(section: 1)
                }
            } else {
                UIView.performWithoutAnimation {
                    self.tableview.reloadData()
                }
            }
        }
        return headerView
    }
    
    private func reloadTableViewWithoutAnimation() {
        UIView.performWithoutAnimation {
            self.tableview.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isRefrigeratorFooter(section) {
            let refri = catArrayForTableIs[0] as! PE_AssessmentInProgress
            refrigtorProbeArray = CoreDataHandlerPE().getOfflineREfriData(id: Int(refri.serverAssessmentId ?? "0") ?? 0)
            let array = CoreDataHandlerPE().fetchViewAssessmentCustomerWithCatID(selectedCategory?.sequenceNo as NSNumber? ?? 0, dataToSubmitNumber: peNewAssessment.dataToSubmitNumber ?? 0)
            if section == 0 {
                return setupRefrigeratorFooter(tableView, array: array as! [Any])
            } else if section == 1 {
                return setupFreezerFooter(tableView, array: array as! [Any])
            } else {
                return setupNoteFooter(tableView)
            }
        }
        return UIView()
    }

    // Helper 1: Check if this is the refrigerator footer
    private func isRefrigeratorFooter(_ section: Int) -> Bool {
        return selectedCategory?.sequenceNoo == 11 && selectedCategory?.catName == Constants.refrigeratorNitrogenStr
    }

    // Helper 2: Setup refrigerator footer (section 0)
    private func setupRefrigeratorFooter(_ tableView: UITableView, array: [Any]) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RefrigatorTempProbeCell.identifier) as! RefrigatorTempProbeCell
        footerView.isUserInteractionEnabled = false
        footerView.contentView.alpha = (btnNA.isSelected && self.selctedNACategoryArray.contains(78)) ? 0.3 : 1.0
        fillRefrigeratorFooterFields(footerView, array: array, range: 2...4)
        if refrigtorProbeArray.count > 0 {
            for i in refrigtorProbeArray {
                let refri = i as! PE_Refrigators
                if refri.unit != "" {
                    footerView.main_UnitTextFld.text = refri.unit ?? ""
                }
            }
        }
        footerView.setGraddientAndLayerQcCountextFieldView()
        return footerView
    }

    // Helper 3: Setup freezer footer (section 1)
    private func setupFreezerFooter(_ tableView: UITableView, array: [Any]) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: RefrigatorTempProbeCell.identifier) as! RefrigatorTempProbeCell
        footerView.isUserInteractionEnabled = false
        footerView.mainTempUnit.isHidden = true
        footerView.contentView.alpha = (btnNA.isSelected && self.selctedNACategoryArray.contains(78)) ? 0.3 : 1.0
        fillRefrigeratorFooterFields(footerView, array: array, range: 7...9)
        footerView.setGraddientAndLayerQcCountextFieldView()
        return footerView
    }

    // Helper 4: Fill refrigerator/freezer footer fields
    private func fillRefrigeratorFooterFields(
        _ footerView: RefrigatorTempProbeCell,
        array: [Any],
        range: ClosedRange<Int>
    ) {
        if self.refrigtorProbeArray.count > 0 {
            for i in range {
                let ar = array[i] as? PE_AssessmentInProgress
                for j in 0..<self.refrigtorProbeArray.count {
                    if ar?.assID == self.refrigtorProbeArray[j].id {
                        updateFooterTextFields(footerView, probe: self.refrigtorProbeArray[j], index: i, range: range)
                    }
                }
            }
        }
    }

    private func updateFooterTextFields(
        _ footerView: RefrigatorTempProbeCell,
        probe: PE_Refrigators,
        index: Int,
        range: ClosedRange<Int>
    ) {
        if index == range.lowerBound {
            setTopFields(footerView, probe: probe)
        }
        if index == range.lowerBound + 1 {
            setMiddleFields(footerView, probe: probe)
        }
        if index == range.upperBound {
            setBottomFields(footerView, probe: probe)
        }
    }

    private func setTopFields(_ footerView: RefrigatorTempProbeCell, probe: PE_Refrigators) {
        footerView.topTxtFld.text = probe.unit ?? ""
        footerView.topValueTxtFld.text = "\(probe.value ?? 0.0)"
    }

    private func setMiddleFields(_ footerView: RefrigatorTempProbeCell, probe: PE_Refrigators) {
        footerView.middleTxtFld.text = probe.unit ?? ""
        footerView.middleValueTxtFld.text = "\(probe.value ?? 0.0)"
    }

    private func setBottomFields(_ footerView: RefrigatorTempProbeCell, probe: PE_Refrigators) {
        footerView.bottomTxtFld.text = probe.unit ?? ""
        footerView.bottomValueTxtFld.text = "\(probe.value ?? 0.0)"
    }

    // Helper 5: Setup note footer (section 2+)
    private func setupNoteFooter(_ tableView: UITableView) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: FrezerFooterViewCell.identifier) as! FrezerFooterViewCell
        footerView.isUserInteractionEnabled = false
        footerView.contentView.alpha = (btnNA.isSelected && self.selctedNACategoryArray.contains(78)) ? 0.3 : 1.0
        footerView.textFieldView.text = self.peNewAssessment.refrigeratorNote ?? ""
        footerView.setGraddientAndLayerQcCountextFieldView()
        return footerView
    }
    // MARK:  Set up PE Inovoject Header Footer View
    func setPEInovojectHeaderFooterView(_ tableView: UITableView , section:Int) -> PEInovojectHeaderFooterView {
        if selectedCategory?.sequenceNoo == 1 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PEInovojectHeaderFooterView" ) as! PEInovojectHeaderFooterView
            headerView.isUserInteractionEnabled = false
            headerView.lblTitle.text = "In Ovo"
            headerView.txtCSize.text = peNewAssessment.iCS
            headerView.txtDType.text = peNewAssessment.iDT
            headerView.txtAntiBiotic.text = peNewAssessment.hatcheryAntibioticsText
            
            headerView.setDropdownStartAsessmentBtn(imageName: "dd",btn:headerView.btn1)
            headerView.setDropdownStartAsessmentBtn(imageName: "dd",btn:headerView.btn2)
            headerView.setGraddientAndLayerAntibioticTextView()
            headerView.isUserInteractionEnabled = false
            
            return headerView
        } else {
            return UIView() as! PEInovojectHeaderFooterView
        }
    }
    
    
    // MARK:  Set up PE Header for Day Of Age Cell
    func setPEHeaderDayOfAge(_ tableView: UITableView , section:Int) -> PEHeaderDayOfAge {
        if selectedCategory?.sequenceNoo == 1 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PEHeaderDayOfAge" ) as! PEHeaderDayOfAge
            headerView.isUserInteractionEnabled = false
            headerView.lblTitle.text = "Day of Age Spray Application"
            headerView.txtCSize.text = peNewAssessment.dDT
            headerView.txtDType.text = peNewAssessment.dCS
            headerView.setDropdownStartAsessmentBtn(imageName: "dd",btn:headerView.btn1)
            headerView.setDropdownStartAsessmentBtn(imageName: "dd",btn:headerView.btn2)
            headerView.txtAntiBiotic.text = peNewAssessment.hatcheryAntibioticsDoaText
         
            headerView.setGraddientAndLayerAntibioticTextView()
            if peNewAssessment.hatcheryAntibioticsDoa == 1 {
                headerView.switchHatchery.setOn(true, animated: false)
                headerView.showAntiBioticTextView()
            } else {
                headerView.hideAntiBioticTextView()
            }
            headerView.isUserInteractionEnabled = false
            
            return headerView
        } else {
            return UIView() as! PEHeaderDayOfAge
        }
    }
    
    
    // MARK:  Set up Header for Day Of Age Sub
    func setPEHeaderDayOfAgeS(_ tableView: UITableView , section:Int) -> PEHeaderDayOfAge {
        if selectedCategory?.sequenceNoo == 1 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PEHeaderDayOfAge" ) as! PEHeaderDayOfAge
            headerView.lblTitle.text = "Day of Age Subcutaneous"
            headerView.txtCSize.text = peNewAssessment.dDDT
            headerView.txtDType.text = peNewAssessment.dDCS
            headerView.txtAntiBiotic.text = peNewAssessment.hatcheryAntibioticsDoaSText
            headerView.setDropdownStartAsessmentBtn(imageName: "dd",btn:headerView.btn1)
            headerView.setDropdownStartAsessmentBtn(imageName: "dd",btn:headerView.btn2)
            headerView.setGraddientAndLayerAntibioticTextView()
            if peNewAssessment.hatcheryAntibioticsDoaS == 1 {
                headerView.switchHatchery.setOn(true, animated: false)
                headerView.showAntiBioticTextView()
            } else {
                headerView.hideAntiBioticTextView()
            }
            headerView.setDropdownStartAsessmentBtn(imageName: "dd",btn:headerView.btn1)
            headerView.setDropdownStartAsessmentBtn(imageName: "dd",btn:headerView.btn2)
            headerView.isUserInteractionEnabled = false
            
            return headerView
        } else {
            return UIView() as! PEHeaderDayOfAge
        }
    }
    
    func refreshTableviewAndScrolToBottom(section:Int){
        self.tableview.reloadData()
        scrollToBottom(section:section)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(selectedCategory?.sequenceNoo == 11 && selectedCategory?.catName == Constants.refrigeratorNitrogenStr){
            if(section == 2) {
                return 100
            }
        }
        else{
            if section > 0 {
                if selectedCategory?.sequenceNoo == 1{
                    return 95.0
                }
                if selectedCategory?.sequenceNoo == 3{
                    return 95.0
                }
            }else{
                if  selectedCategory?.sequenceNoo == 12{
                    if section == 0 {
                        return 70.0
                    }else{
                        return 0.0
                    }
                }
            }
            return 0.0
        }
        return 0.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(selectedCategory?.sequenceNoo == 11 && selectedCategory?.catName == Constants.refrigeratorNitrogenStr){
            if ((  section == 0) || ( section == 1)) {
                return 350
            }
            else{
                return 200
            }
        }
        
        return 0
    }
    func scrollToBottom(section:Int){
        
        var indexPathOfTab = IndexPath(row: 0, section: 0)
        DispatchQueue.main.async {
            if self.checkForTraning(){
                if section == 1 {
                    indexPathOfTab = IndexPath(
                        row: self.certificateData.count - 1 ,
                        section:1)
                }
                if section == 2 {
                    indexPathOfTab = IndexPath(
                        row: self.inovojectData.count - 1 ,
                        section:2)
                }
                if section == 3 {
                    indexPathOfTab = IndexPath(
                        row: self.dayOfAgeData.count - 1 ,
                        section:3)
                }
            } else {
                if section == 1 {
                    indexPathOfTab = IndexPath(
                        row: self.inovojectData.count - 1 ,
                        section:1)
                }
                if section == 2 {
                    indexPathOfTab = IndexPath(
                        row: self.dayOfAgeData.count - 1 ,
                        section:2)
                }
            }
            self.tableview.scrollToRow(at: indexPathOfTab, at: .none, animated: false)
        }
    }
    
    func updateAssessmentInDb(assessment:PE_AssessmentInProgress) {
        CoreDataHandlerPE().updateCatDetailsForStatus(assessment:assessment)
    }
    
    func updateNoteAssessmentInProgressPE(assessment:PE_AssessmentInProgress)  {
        CoreDataHandlerPE().updateNoteAssessmentInProgress(assessment:assessment)
    }
    func updateCategoryInDb(assessment:PENewAssessment) {
        CoreDataHandlerPE().updateCategortIsSelcted(assessment:assessment)
    }
}
// MARK:  Extension & Collection view Delegate's
extension PEViewAssesmentFinalize : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView  == collectionViewSignature {
            return certificateData.count + 1
        }
        else {
            
            return catArrayForCollectionIs.count + 1 ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView  == collectionViewSignature {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SignaturesCollectionViewCell", for: indexPath as IndexPath) as! SignaturesCollectionViewCell
            if certificateData.count > indexPath.row {
                cell.imgSignature.contentMode = .scaleAspectFit
                cell.imgSignature.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[indexPath.row].signatureImg)
                cell.lblSignatureName.text = "Vaccination Mixer Operator Name : \(certificateData[indexPath.row].name ?? "")"
            }
         
            
            if certificateData.count == indexPath.row && certificateData.count > 0  {
                let data = CodeHelper.sharedInstance.convertToImage(base64: certificateData[0].fsrSign)
                DispatchQueue.main.async {
                    cell.imgSignature.contentMode = .scaleAspectFit
                    cell.imgSignature.image = data
                    cell.lblSignatureName.text = "FSR Sign"
                }
            }

            
            
            return cell
        }
        else {
            if indexPath.row == catArrayForCollectionIs.count  {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewIDPE", for: indexPath as IndexPath) as! PECategoryCell
                // let category = catArrayForCollectionIs[indexPath.row]
                cell.imageview.image = UIImage(named: "tabUnselect")!
                if tableview.isHidden{
                    cell.imageview.image =  UIImage(named: "tabSelect")!
                }
                
                cell.categoryLabel.text = "Final"
                
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewIDPE", for: indexPath as IndexPath) as! PECategoryCell
                cell.imageview.image = UIImage(named: "tabUnselect")!
                let category = catArrayForCollectionIs[indexPath.row]
            
                
                if let isSelected = selectedCategory?.catISSelected, selectedCategory?.sequenceNo == category.sequenceNo, isSelected == 1 {
                    cell.imageview.image = UIImage(named: "tabSelect")!
                }
                
                cell.categoryLabel.text = category.catName ?? ""
                return cell
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == collectionViewSignature {
            
            return CGSize(width: collectionViewSignature.frame.width, height: collectionViewSignature.frame.height)
        }
        else {
            if catArrayForCollectionIs.count == 6{
                if indexPath.row == 3{
                    return CGSize(width: 146, height: 68)
                } else if indexPath.row == 4{
                    return CGSize(width: 126, height: 68)
                }else{
                    return CGSize(width: 136, height: 68)
                }
            }
            
            else{
                if indexPath.row == 3{
                    return CGSize(width: 171, height: 68)
                } else if indexPath.row == 4{
                    return CGSize(width: 151, height: 68)
                }else{
                    return CGSize(width: 161, height: 68)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        resetInitialUI()

        updateTabSelection(at: indexPath)

        if indexPath.row == catArrayForCollectionIs.count {
            handleSignatureView(for: indexPath)
        } else {
            handleCategorySelection(at: indexPath)
        }
        
        synWebBtn.isHidden = false
    }

    // MARK: - Refactored Helper Methods

    private func resetInitialUI() {
        categoarylabelText = ""
        synWebBtn.isEnabled = true
        synWebBtn.alpha = 1.0
        bckButton.isHidden = true
        synWebBtn.setTitle(Constants.syncToWebStr, for: .normal)
        tableview.isUserInteractionEnabled = true
    }

    private func updateTabSelection(at indexPath: IndexPath) {
        for cell in collectionView.visibleCells {
            guard let categoryCell = cell as? PECategoryCell else { continue }
            let isSelected = categoryCell == collectionView.cellForItem(at: indexPath)
            categoryCell.imageview.image = UIImage(named: isSelected ? "tabSelect" : "tabUnselect")
        }
    }

    private func handleSignatureView(for indexPath: IndexPath) {
        tableview.isHidden = true
        scoreParentView.isHidden = true
        viewForSignature.isHidden = true
        viewForMultiSignature.isHidden = false
        lblextenderMicro.isHidden = true
        extendedMicroSwitch.isHidden = true
        extendedMicroSwitch.isUserInteractionEnabled = false

        if peNewAssessment.evaluationID == 2 {
            scoreParentView.isHidden = true
            viewForSignature.isHidden = true
            viewForMultiSignature.isHidden = false
            constraintConstantHeight.constant = 0
        }

        collectionView.reloadItems(at: [indexPath])
    }

    private func handleCategorySelection(at indexPath: IndexPath) {
        guard catArrayForCollectionIs.indices.contains(indexPath.row) else { return }

        tableview.isHidden = false
        scoreParentView.isHidden = false
        viewForSignature.isHidden = true
        viewForMultiSignature.isHidden = true

        selectedCategory?.catISSelected = 0
        updateCategoryInDb(assessment: selectedCategory!)

        selectedCategory = catArrayForCollectionIs[indexPath.row]
        selectedCategory?.catISSelected = 1
        updateCategoryInDb(assessment: selectedCategory!)

        chechForLastCategory()
        collectionviewIndexPath = indexPath

        let sequenceNo = selectedCategory?.sequenceNo as? NSNumber ?? 0
        catArrayForTableIs = CoreDataHandlerPE().fetchViewAssessmentCustomerWithCatID(sequenceNo, dataToSubmitNumber: peNewAssessment.dataToSubmitNumber ?? 0)

        totalScoreLabel.text = String(selectedCategory?.catMaxMark ?? 0)
        resultScoreLabel.text = "0"

        switch selectedCategory?.catName {
        case Constants.refrigeratorNitrogenStr:
            handleRefrigeratorCategory()

        case Constants.extendedMicrobialStr:
            handleExtendedMicrobialCategory()

        default:
            handleStandardCategory()
        }

        tableview.reloadData()
        updateScore()

        if regionID != 3 {
            showHideNA(sequenceNoo: selectedCategory?.sequenceNoo ?? 0, catName: selectedCategory?.catName ?? "")
        }

        refreshTableView()
    }

    private func handleRefrigeratorCategory() {
        lblextenderMicro.isHidden = true
        extendedMicroSwitch.isHidden = true
        extendedMicroSwitch.isUserInteractionEnabled = false

        if let refri = catArrayForTableIs.first as? PE_AssessmentInProgress {
            let id = Int(refri.serverAssessmentId ?? "0") ?? 0
            refrigtorProbeArray = CoreDataHandlerPE().getOfflineREfriData(id: id)
        }
    }

    private func handleExtendedMicrobialCategory() {
        categoarylabelText = Constants.extendedMicrobialStr
        selectedCategory?.sequenceNoo = 12
        extendedMicroSwitch.isUserInteractionEnabled = true

        let isRequested = peNewAssessment.IsEMRequested!
        let shouldSubmit = submitExtend

        if !isRequested {
            extendedMicroSwitch.isOn = shouldSubmit
            synWebBtn.isEnabled = shouldSubmit
            synWebBtn.alpha = shouldSubmit ? 1.0 : 0.3

            UserDefaults.standard.setValue(shouldSubmit, forKey: "extendedAvailable")
            UserDefaults.standard.set(shouldSubmit, forKey: "ExtendedMicro")

            lblextenderMicro.isHidden = false
            extendedMicroSwitch.isHidden = false
            synWebBtn.setTitle("Finish Extended Microbial", for: .normal)
        } else {
            extendedMicroSwitch.isHidden = true
            lblextenderMicro.isHidden = true
            synWebBtn.setTitle(Constants.syncToWebStr, for: .normal)
            synWebBtn.isEnabled = true
            synWebBtn.alpha = 1.0

            UserDefaults.standard.setValue(true, forKey: "extendedAvailable")
            UserDefaults.standard.set(true, forKey: "ExtendedMicro")
        }
    }

    private func handleStandardCategory() {
        categoarylabelText = ""
        tableview.isUserInteractionEnabled = true
        lblextenderMicro.isHidden = true
        extendedMicroSwitch.isHidden = true
        extendedMicroSwitch.isUserInteractionEnabled = false

        let sequenceNo = selectedCategory?.sequenceNo as? NSNumber ?? 0
        catArrayForTableIs = CoreDataHandlerPE().fetchCustomerWithCatID(sequenceNo)

        btnNA.isSelected = checkCategoryisNA()
    }

    
    // MARK:  Show Hide is NA
    func showHideNA(sequenceNoo:Int,catName:String){
        
        if( sequenceNoo == 11 && catName == Constants.refrigeratorNitrogenStr ){
            lblNA.isHidden = true
            btnNA.isHidden = true
            scoreParentView.isHidden = true
        }
        else if(sequenceNoo == 1 || sequenceNoo == 2){
            lblNA.isHidden = true
            btnNA.isHidden = true
            scoreParentView.isHidden = false
        }
        else{
            lblNA.isHidden = false
            btnNA.isHidden = false
            scoreParentView.isHidden = false
        }
    }
    // MARK: Check Category Is NA
    func checkCategoryisNA() -> Bool {
        self.refreshArray()
        for  obj in catArrayForTableIs {
            let assessment = obj as? PE_AssessmentInProgress
            if assessment?.isNA == false {
                return false
            }
        }
        return true
    }
    
    // MARK:  Check for Last Category
    func chechForLastCategory(){
        var peNewAssessmentArray = CoreDataHandlerPE().getOnGoingAssessmentArrayPEObject(serverAssessmentId: peNewAssessment.serverAssessmentId ?? "")
        var catArrayForCollectionIsAre : [PENewAssessment] = []
        var carColIdArray : [Int] = []
        for cat in peNewAssessmentArray {
            if !carColIdArray.contains(cat.sequenceNo ?? 0){
                carColIdArray.append(cat.sequenceNo ?? 0)
                catArrayForCollectionIsAre.append(cat)
            }
        }
        
        let count = catArrayForCollectionIs.count - 1
        if count > 0 {
            bckButton.isHidden = true
            if let cat = catArrayForCollectionIs[0] as? PENewAssessment {
                if cat.sequenceNo == selectedCategory?.sequenceNo{
                    bckButton.isHidden = false
                }  else {
                    bckButton.isHidden = true
                }
            }
            
            for cat in catArrayForCollectionIsAre {
                if cat.catResultMark == 0 {
                    return
                }
            }
        }
    }
}

// MARK:  Extension
extension PEViewAssesmentFinalize{
    
    func anyCategoryContainValueOrNot() -> Bool{
        let peNewAssessmentSurrentIs = ZoetisDropdownShared.sharedInstance.sharedPEOnGoingSession[0]
        for obj in peNewAssessmentSurrentIs.peCategoryArray{
            if obj.resultMark ?? 0 > 0 {
                return true
            }
            return false
        }
        return false
    }
    
    func getCategoryAlreadyDone() -> PECategory{
        let peNewAssessmentSurrentIs = ZoetisDropdownShared.sharedInstance.sharedPEOnGoingSession[0]
        for obj in peNewAssessmentSurrentIs.peCategoryArray{
            if obj.isSelected {
                return obj
            }
        }
        return PECategory(nil)
    }
    
    
}

// MARK:  ************** Camera Button Action ***************************************/
extension PEViewAssesmentFinalize: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    // MARK: ************* Alert View Methods ***********************************/
    
    func postAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /**************************************************************************************************/
    
    // MARK: ******************************  Image Picker Delegate Methods ***************************************/
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        if let pickedImage: UIImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]) as? UIImage {
            
            let imageData = pickedImage.jpegData(compressionQuality: 0.5)
            
            saveImageInPEModule(imageData:imageData!)
            self.refreshArray()
            let assessment = self.catArrayForTableIs[tableviewIndexPath.row] as? PE_AssessmentInProgress
            if let cell = tableview.cellForRow(at: tableviewIndexPath) as? PEQuestionTableViewCell {
                let imageCount = assessment?.images as? [Int]
                let cnt = imageCount?.count
                let ttle = String(cnt ?? 0)
                cell.btnImageCount.setTitle(ttle,for: .normal)
                if ttle == "0"{
                    cell.btnImageCount.isHidden = true
                } else {
                    cell.btnImageCount.isHidden = false
                }
            }
        }
        imagePicker.dismiss(animated: true)
    }
    /******************************************************************************************************/
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true)
    }
    // MARK:  Save Image in PE Module
    private func saveImageInPEModule(imageData:Data){
        let imageCount = getImageCountInPEModule()
        var assessment = catArrayForTableIs[tableviewIndexPath.row] as? PE_AssessmentInProgress
        CoreDataHandlerPE().saveImageInPEModule(assessment: assessment!, imageId: imageCount+1, imageData: imageData)
    }
    
    // MARK: Get Image Count In PE Module
    func getImageCountInPEModule() -> Int {
        let allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_ImageEntity")
        let carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "imageId") as? NSArray ?? []
        var carColIdArray : [Int] = []
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArray.contains(obj as? Int ?? 0){
                carColIdArray.append(obj as? Int ?? 0)
            }
        }
        return carColIdArray.count
    }

  
    // MARK:  Save vaccine Mixture in PE Module
    private func saveVMixerInPEModule(peCertificateData:PECertificateData) -> Int{
        let imageCount = getVMixerCountInPEModule()
        var assessment = catArrayForTableIs[tableviewIndexPath.row] as? PE_AssessmentInProgress
        CoreDataHandlerPE().saveVMixerPEModule(assessment: assessment!, id: imageCount+1, peCertificateData: peCertificateData)
        return imageCount+1
        
    }
    
    // MARK:  get DOA Count in PE Module
    func getDOACountInPEModule() -> Int {
        let allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_DayOfAge")
        let carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "doaId") as? NSArray ?? []
        var carColIdArray : [Int] = []
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArray.contains(obj as? Int ?? 0){
                carColIdArray.append(obj as? Int ?? 0)
            }
        }
        return carColIdArray.count
    }
    // MARK:  Get Vaccine Mixture Count in PE Module
    func getVMixerCountInPEModule() -> Int {
        let allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VMixer")
        let carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "vmid") as? NSArray ?? []
        var carColIdArray : [Int] = []
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArray.contains(obj as? Int ?? 0){
                carColIdArray.append(obj as? Int ?? 0)
            }
        }
        return carColIdArray.count
    }
 
    
}


// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}


extension PEViewAssesmentFinalize{
    // MARK: Change date Fromate
    func convertDateFormat(inputDate: String) -> String {
        self.convertDateFormat(inputDateIs: inputDate)
    }
    
    // MARK: - Date Formatter
    func convertSign_DateFormat(inputDate: String) -> String {
        self.convertDateFormat(inputDateIs: inputDate)
    }
    
    
    
    func convertDateFormat(inputDateIs: String) -> String {
        let olDateFormatter = DateFormatter()
        olDateFormatter.dateFormat = "MMM d, yyyy"
        if let oldDate = olDateFormatter.date(from: inputDateIs) {
            let convertDateFormatter = DateFormatter()
            convertDateFormatter.dateFormat = Constants.yyyyMMddStr
            return convertDateFormatter.string(from: oldDate)
        }
        return ""
    }
    
    
    
    // MARK:  Create Sync Request for Refregerator Data
    func createSyncRequestRefrigator(dictArray: PE_Refrigators) -> JSONDictionary{
        let userId = UserDefaults.standard.integer(forKey: "Id")
        let f = dictArray.value
        let s = NSString(format: "%.2f", f ?? "")
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        let value = Double((s ) as Substring) as? NSNumber
        let json = [
            "Id": 0,
            "AssessmentId": dictArray.schAssmentId ?? 0 ,
            "AssessmentDetailId": dictArray.id ?? 0 ,
            "RefValue": value ?? 0.0,
            "RefUnit": dictArray.unit ?? "",
            "IsNa": dictArray.isNA ?? false,
            "IsCheck": dictArray.isCheck ?? false,
            "UserId": userId ?? 0,
            "CreatedAt": "2023-01-31T14:57:39.582Z"
        ] as JSONDictionary
        return json
    }
    
    func detectDateFormat(of dateString: String) -> String? {
        // List of common date formats to check
        let dateFormats = [
            Constants.yyyyMMddStr,
            Constants.ddMMyyyStr,
            Constants.MMddyyyyStr,
            "dd-MM-yyyy",
            "yyyy/MM/dd",
            "MMMM d, yyyy",
            "MMM dd, yyyy"
            
        ]
        
        for format in dateFormats {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Try to parse the string into a Date object
            if let _ = dateFormatter.date(from: dateString) {
                return format // Return the matching format
            }
        }
        
        return nil // Return nil if no format matches
    }
    
    
    // MARK: Create Sync Request for Assessement
    func createSyncRequest(dict: PENewAssessment, certificationData: [PECertificateData]) -> JSONDictionary {
        let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier")!
        let (uniID, assessmentId, saveType) = getAssessmentIdentifiers(dict)
        let deviceIdForServer = "\(uniID)_1_iOS_\(udid)"
        deviceIDFORSERVER = deviceIdForServer

        var serverAssessmentId: Int64 = 0
        if let serverId = dict.serverAssessmentId {
            serverAssessmentId = Int64(serverId) ?? 0
        }

        debugPrint(assessmentId)
        debugPrint(saveType)
        let docId = ""
        let visitId = dict.visitID
        let customerId = dict.customerId
        let countryID = dict.countryID
        let siteId = dict.siteId
        let incubationStyle = dict.incubation
        let evaluationId = dict.evaluationID
        let evaluatorId = dict.evaluatorID
        let userId = dict.userID
        let tsrId = getTSRId(dict)
        let camera = dict.camera == 1
        let (man, manOther) = getManufacturer(dict)
        let (eggg, egggOther) = getEgg(dict)
        let (breeedd, breeeddOther) = getBreed(dict)
        let (manufacturerId, eggId, breedId) = getIds(man, eggg, breeedd)
        let flockAgeId = dict.isFlopSelected
        let statusType = ""
        let representativeName = ""
        let notes = dict.notes
        let (dateSig, sigName2, sigName, sigPhone, sigEmpId, sigEmpId2, sigNumber, sigNumber2, base64Str, base64Str2) = getSignatureFields(dict)
        let displayId = "C-" + uniID
        let iStle = getIncubationStyleId(incubationStyle)
        let (rollId, rollId2) = getRoleIds(sigEmpId, sigEmpId2)

        // Compose the final sync request dictionary
        let syncRequest: JSONDictionary = [
            "deviceIDFORSERVER": deviceIDFORSERVER as AnyObject,
            "serverAssessmentId": serverAssessmentId as AnyObject,
            "docId": docId as AnyObject,
            "visitId": visitId as AnyObject,
            "customerId": customerId as AnyObject,
            "countryID": countryID as AnyObject,
            "siteId": siteId as AnyObject,
            "incubationStyle": incubationStyle as AnyObject,
            "evaluationId": evaluationId as AnyObject,
            "evaluatorId": evaluatorId as AnyObject,
            "userId": userId as AnyObject,
            "tsrId": tsrId as AnyObject,
            "camera": camera as AnyObject,
            "manufacturer": man as AnyObject,
            "manufacturerOther": manOther as AnyObject,
            "egg": eggg as AnyObject,
            "eggOther": egggOther as AnyObject,
            "breed": breeedd as AnyObject,
            "breedOther": breeeddOther as AnyObject,
            "manufacturerId": manufacturerId as AnyObject,
            "eggId": eggId as AnyObject,
            "breedId": breedId as AnyObject,
            "flockAgeId": flockAgeId as AnyObject,
            "statusType": statusType as AnyObject,
            "representativeName": representativeName as AnyObject,
            "notes": notes as AnyObject,
            "dateSig": dateSig as AnyObject,
            "sigName2": sigName2 as AnyObject,
            "sigName": sigName as AnyObject,
            "sigPhone": sigPhone as AnyObject,
            "sigEmpId": sigEmpId as AnyObject,
            "sigEmpId2": sigEmpId2 as AnyObject,
            "sigNumber": sigNumber as AnyObject,
            "sigNumber2": sigNumber2 as AnyObject,
            "base64Str": base64Str as AnyObject,
            "base64Str2": base64Str2 as AnyObject,
            "displayId": displayId as AnyObject,
            "iStle": iStle as AnyObject,
            "rollId": rollId as AnyObject,
            "rollId2": rollId2 as AnyObject,
            "certificationData": certificationData as AnyObject
        ]
        return syncRequest
    }

    // Helper 1: Get assessment identifiers
    private func getAssessmentIdentifiers(_ dict: PENewAssessment) -> (String, Int, Int) {
        var uniID = dict.dataToSubmitID ?? ""
        if uniID == "" {
            uniID = dict.draftID ?? ""
        }
        var assessmentId = dict.dataToSubmitNumber ?? 0
        var saveType = 1
        saveTypeString.append(11)
        if assessmentId == 0 {
            if dict.assDetail2?.lowercased().contains("_1_ios") ?? false {
                deviceIDFORSERVER = dict.assDetail2 ?? ""
            }
            assessmentId = dict.draftNumber ?? 0
            saveType = 0
            saveTypeString.append(00)
        }
        if dict.assDetail2?.lowercased().contains("_1_ios") ?? false {
            deviceIDFORSERVER = dict.assDetail2 ?? ""
        }
        return (uniID, assessmentId, saveType)
    }

    // Helper 2: Get TSR Id
    private func getTSRId(_ dict: PENewAssessment) -> Int? {
        var tsrId = dict.selectedTSRID
        let visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Approvers")
        let visitNameArray = visitDetailsArray.value(forKey: "username") as? NSArray ?? NSArray()
        let visitIDArray = visitDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        if dict.selectedTSR?.count ?? 0 > 0, visitNameArray.contains(dict.selectedTSR ?? "") {
            let indexOfe = visitNameArray.index(of: dict.selectedTSR ?? "")
            tsrId = visitIDArray[indexOfe] as? Int ?? 0
        }
        return tsrId
    }

    // Helper 3: Get manufacturer and other
    private func getManufacturer(_ dict: PENewAssessment) -> (String, String) {
        var man = dict.manufacturer ?? ""
        var manOther = ""
        if man != "", let character = dict.manufacturer?.character(at: 0), character == "S" {
            let str = man.replacingOccurrences(of: "S", with: "")
            manOther = str
            man = "Other"
        }
        return (man, manOther)
    }

    // Helper 4: Get egg and other
    private func getEgg(_ dict: PENewAssessment) -> (String, String) {
        var eggg = ""
        var egggOther = ""
        let xx = String(dict.noOfEggs ?? 0)
        if xx != "0" {
            let last3 = String(xx.suffix(3))
            if last3 == "000" {
                let str = xx.replacingOccurrences(of: "000", with: "")
                egggOther = str
                eggg = "Other"
            } else {
                eggg = xx
            }
        }
        return (eggg, egggOther)
    }

    // Helper 5: Get breed and other
    private func getBreed(_ dict: PENewAssessment) -> (String, String) {
        var breeedd = dict.breedOfBird ?? ""
        var breeeddOther = ""
        if breeedd != "", let character = breeedd.character(at: 0), character == "S".character(at: 0) {
            let str = breeedd.replacingOccurrences(of: "S", with: "")
            breeeddOther = str
            breeedd = "Other"
        }
        breeeddOther = dict.breedOfBirdOther ?? ""
        return (breeedd, breeeddOther)
    }

    // Helper 6: Get manufacturer, egg, and breed IDs
    private func getIds(_ man: String, _ eggg: String, _ breeedd: String) -> (Int, Int, Int) {
        var manufacturerId = 0
        var eggId = 0
        var breedId = 0
        let manufacutrerDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Manufacturer")
        let manufacutrerNameArray = manufacutrerDetailsArray.value(forKey: "mFG_Name") as? NSArray ?? NSArray()
        let manufacutrerIDArray = manufacutrerDetailsArray.value(forKey: "mFG_Id") as? NSArray ?? NSArray()
        if man != "" {
            let indexOfd = manufacutrerNameArray.index(of: man)
            manufacturerId = manufacutrerIDArray[indexOfd] as? Int ?? 0
        }
        let BirdBreedDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_BirdBreed")
        let BirdBreedNameArray = BirdBreedDetailsArray.value(forKey: "birdBreedName") as? NSArray ?? NSArray()
        let BirdBreedIDArray = BirdBreedDetailsArray.value(forKey: "birdId") as? NSArray ?? NSArray()
        if breeedd != "" {
            let indexOfe = BirdBreedNameArray.index(of: breeedd)
            breedId = BirdBreedIDArray[indexOfe] as? Int ?? 0
        }
        let EggsDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Eggs")
        let EggsNameArray = EggsDetailsArray.value(forKey: "eggCount") as? NSArray ?? NSArray()
        let EggsIDArray = EggsDetailsArray.value(forKey: "eggId") as? NSArray ?? NSArray()
        if eggg != "" {
            let indexOfp = EggsNameArray.index(of: eggg)
            eggId = EggsIDArray[indexOfp] as? Int ?? 0
        }
        return (manufacturerId, eggId, breedId)
    }

    // Helper 7: Get signature fields
    private func getSignatureFields(_ dict: PENewAssessment) -> (String, String?, String?, String?, String?, String?, Int?, Int?, String, String) {
        var dateSig = ""
        let ddd = dict.sig_Date ?? ""
        if ddd != "" {
            dateSig = self.convertDateFormat(inputDate: ddd)
        }
        let sigName2 = dict.sig_Name2
        let sigName = dict.sig_Name
        let sigPhone = dict.sig_Phone
        let sigEmpId = dict.sig_EmpID
        let sigEmpId2 = dict.sig_EmpID2
        let sigNumber = dict.sig ?? 0
        let sigNumber2 = dict.sig2 ?? 0
        var base64Str = ""
        var base64Str2 = ""
        if sigNumber != 0 {
            base64Str = CoreDataHandlerPE().getImageBase64ByImageID(idArray: dict.sig ?? 0)
        }
        if sigNumber2 != 0 {
            base64Str2 = CoreDataHandlerPE().getImageBase64ByImageID(idArray: dict.sig2 ?? 0)
        }
        return (dateSig, sigName2, sigName, sigPhone, sigEmpId, sigEmpId2, sigNumber, sigNumber2, base64Str, base64Str2)
    }

    // Helper 8: Get incubation style id
    private func getIncubationStyleId(_ incubationStyle: String?) -> Int {
        var iStle = 0
        let iStleDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_IncubationStyle")
        let iStleNameArray = iStleDetailsArray.value(forKey: "incubationStylesName") as? NSArray ?? NSArray()
        let iStleIDArray = iStleDetailsArray.value(forKey: "incubationId") as? NSArray ?? NSArray()
        if incubationStyle?.count ?? 0 > 1 {
            let indexOfe = iStleNameArray.index(of: incubationStyle ?? "")
            iStle = iStleIDArray[indexOfe] as? Int ?? 0
        }
        return iStle
    }

    // Helper 9: Get role ids
    private func getRoleIds(_ sigEmpId: String?, _ sigEmpId2: String?) -> (Int, Int) {
        var rollId = 0
        var rollId2 = 0
        let rollDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Roles")
        let rollNameArray = rollDetailsArray.value(forKey: "roleName") as? NSArray ?? NSArray()
        let rollIDArray = rollDetailsArray.value(forKey: "roleId") as? NSArray ?? NSArray()
        if sigEmpId?.count ?? 0 > 1 {
            let indexOfe = rollNameArray.index(of: sigEmpId ?? "")
            rollId = rollIDArray[indexOfe] as? Int ?? 0
        }
        if sigEmpId2?.count ?? 0 > 1 {
            let indexOfe = rollNameArray.index(of: sigEmpId2 ?? "")
            rollId2 = rollIDArray[indexOfe] as? Int ?? 0
        }
        return (rollId, rollId2)
    }
    // MARK: Create Sync request for Inovoject Data
    func createSyncRequestForInvoject(dictArray: PENewAssessment,inovojectData :InovojectData) -> JSONDictionary {
        
        
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
            serverAssessmentId = Int64(id) ?? 0
        }
    
        var DisplayId = "C-" + UniID
        
        let HatcheryAntibioticsInt = inovojectData.invoHatchAntibiotic
        var HatcheryAntibiotics = false
        if HatcheryAntibioticsInt == 1 {
            HatcheryAntibiotics = true
        }
        
        var x = 0

        var ampleSizeDetailArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
        var ampleSizeesNameArray = ampleSizeDetailArray.value(forKey: "size") as? NSArray ?? NSArray()
        var  ampleSizeIDArray = ampleSizeDetailArray.value(forKey: "id") as? NSArray ?? NSArray()
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
        if vNameArray.contains(inovojectData.vaccineMan){
            let indexOfe = vNameArray.index(of: inovojectData.vaccineMan) // 3
            VaccineId = vNameIDArray[indexOfe] as? Int ?? 0
        }
        
      
        var vNameDetailsArrayIS = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VNames")
        var vNameArrayIS = vNameDetailsArrayIS.value(forKey: "name") as? NSArray ?? NSArray()
        var vNameIDArrayIS = vNameDetailsArrayIS.value(forKey: "id") as? NSArray ?? NSArray()
        var vNameMfgIdArrayIS = vNameDetailsArrayIS.value(forKey: "mfgId") as? NSArray ?? NSArray()
        
        if vNameArrayIS.contains(inovojectData.name) {
            let indexOfe = vNameArrayIS.index(of: inovojectData.name) // 3
            VaccineId = vNameIDArrayIS[indexOfe] as? Int ?? 0
            ManufacturerId = vNameMfgIdArrayIS[indexOfe] as? Int ?? 0
        } else if (inovojectData.name != "") {
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
            "DiluentsMfgOtherName":inovojectData.doaDilManOther ?? "",
            "ProgramName": inovojectData.invoProgramName,
            "AssessmentId":serverAssessmentId
            
        ] as JSONDictionary
        let doaDilManOther =  inovojectData.doaDilManOther ?? ""
        
        if doaDilManOther == "" {
            json.removeValue(forKey: "DiluentsMfgOtherName")
        }
        if ManufacturerId == 0  {
            json["ManufacturerId"] =  ManufacturerId == 0 ? "" : ManufacturerId
            json.removeValue(forKey: "ManufacturerId")
        }
        return json
        
    }
    // MARK: Create Sync request for DOA
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
    // MARK: Create Sync Request for DOAS
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
        var vNameArray = vNameDetailsArray.value(forKey: "name") as? NSArray ?? NSArray()
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
            //            AntibioticInformation = infoObj?.subcutaneousAntibioticTxt ?? ""
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
    // MARK: Create Synce Request for Certificate Data
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
            dateFormatter.dateFormat = Constants.ddMMyyyStr
            let date = dateFormatter.date(from: peCertificateData.certificateDate ?? "")
            dateFormatter.dateFormat = Constants.yyyyMMddStr
            if date != nil {
                resultString = dateFormatter.string(from: date ?? Date())
                
            } else {
                resultString =  ""
            }
        }
        else{
            resultString = peCertificateData.certificateDate ?? ""
        }
        
        
        if regionID == 3 {
            let json = [
                "Id": AssessmentId,
                "AssessmentId": serverAssessmentId,//AssessmentId,
                "AssessmentDetailId": AssessmentId,
                "ModuleAssessmentId": 0,
                "Name": peCertificateData.name,
                "CertificationDate": resultString,
                "AlternateName": "string",
                "CertificationDate2": date2020_05_23,
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
        else
        {
            let json = [
                "Id": AssessmentId,
                "AssessmentId": serverAssessmentId,//AssessmentId,
                "AssessmentDetailId": AssessmentId,
                "ModuleAssessmentId": 0,
                "Name": peCertificateData.name,
                "CertificationDate": resultString,
                "AlternateName": "string",
                "CertificationDate2": date2020_05_23,
                "ModuleAssessmentCatId":  dictArray.catID,
                "userId": dictArray.userID,
                "DeviceId": deviceIDFORSERVER,
                "ResidueName": dictArray.residue,
                "MicroSamplesName": dictArray.micro,
                "EvaluationTypeId": 1,
                "AppAssessmentId": String(AssessmentId),
                "DisplayId": DisplayId.prefix(22),
                "StrUniqueId":unique,
                "SignatureImg": peCertificateData.signatureImg ?? ""
            ] as JSONDictionary
            return json
        }
        
    }
    // MARK: Create Sync Request for Residue Data
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

        let DisplayId = "C-" + UniID
        
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
    
    // MARK: Create Sync Request for Micro Data
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
   
        var  DisplayId = "C-" + UniID
        
        let unique = "\(deviceIDFORSERVER)_\(dictArray.micro)_iOS_"
        
        
        let json = [
            "Id": AssessmentId,
            "AssessmentId": serverAssessmentId,
            "AssessmentDetailId": dictArray.assID ?? 0,
            "ModuleAssessmentId": 0,
            "Name": "",
            "CertificationDate": "",
            "AlternateName": "string",
            "CertificationDate2": date2020_05_23,
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
    // MARK: Get Assessments Status Check
    func getAssessmentStatusCheck(assessmentId: String){
        
        if peNewAssessment.IsEMRequested == false && synWebBtn.currentTitle == "Finish Extended Microbial"
        {
            self.syncExtendedMicrobial()
        }
        else
        {
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
        
    }
    
    // MARK: Sync Functionality
    func syncBtnTapped(showHud: Bool) {
        guard validateExtendedMicrobialSync() else { return }
        updateIsEMRequestedFlag()
        guard ConnectionManager.shared.hasConnectivity() else { return }
        showGlobalProgressHUDWithTitle(view, title: "Data syncing...")

        let refrigratorDataArr = prepareRefrigeratorData()
        let dayOfAgeSData = fetchPEData(from: peNewAssessment.doaS)
        let dayOfAgeData = fetchPEData(from: peNewAssessment.doa)
        let inovojectData = fetchPEData(from: peNewAssessment.inovoject)
        let certificateData = fetchCertificateData()

        let json = createSyncRequest(dict: peNewAssessment, certificationData: certificateData)
        tempArr.append(json)

        let inovojectDataArr = inovojectData.map { createSyncRequestForInvoject(dictArray: peNewAssessment, inovojectData: $0) }
        let dayOfAgeDataArr = dayOfAgeData.map { createSyncRequestForDOA(dictArray: peNewAssessment, dayOfAgeData: $0) }
        let dayOfAgeSDataArr = dayOfAgeSData.map { createSyncRequestForDOAS(dictArray: peNewAssessment, dayOfAgeData: $0) }
        let certificateDataArr = certificateData.map { createSyncRequestForCertificateData(dictArray: peNewAssessment, peCertificateData: $0) }

        let (vaccineResidueMoldsDataArr, vaccineMicroSamplesDataArr) = prepareVaccineDataIfNeeded()

        let paramForDoaInnovoject = createDOAInnovojectParams(
            inovojectDataArr: inovojectDataArr,
            dayOfAgeDataArr: dayOfAgeDataArr,
            dayOfAgeSDataArr: dayOfAgeSDataArr,
            certificateDataArr: certificateDataArr,
            vaccineResidueMoldsDataArr: vaccineResidueMoldsDataArr,
            vaccineMicroSamplesDataArr: vaccineMicroSamplesDataArr,
            refrigratorDataArr: refrigratorDataArr
        )

        let idArr = tempArr.compactMap { "\($0["AssessmentId"] as? Int64 ?? 0)" }.filter { $0 != "0" }
        
        idArr.forEach { assessmentId in
            SanitationEmbrexQuestionMasterDAO.sharedInstance.sendExtendedPEFilledDTO(
                userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "",
                assessmentId: assessmentId
            )
        }

        let param: JSONDictionary = [
            "AssessmentData": tempArr,
            "appVersion": Bundle.main.versionNumber,
            "IsSendEmail": "false"
        ]

        convertDictToJson(dict: param, apiName: "add assessment")

        ZoetisWebServices.shared.sendPostDataToServer(controller: self, parameters: param) { [weak self] json, error in
            self?.handleSyncResponse(json: json.rawValue as! JSONDictionary, error: error, paramForDoaInnovoject: paramForDoaInnovoject)
        }
    }

    private func prepareVaccineDataIfNeeded() -> ([JSONDictionary], [JSONDictionary]) {
        var vaccineResidueMoldsDataArr: [JSONDictionary] = []
        var vaccineMicroSamplesDataArr: [JSONDictionary] = []
        if peNewAssessment.evaluationID == 2 {
            vaccineResidueMoldsDataArr.append(createSyncRequestForResidueData(dictArray: peNewAssessment))
            vaccineMicroSamplesDataArr.append(createSyncRequestForMicroData(dictArray: peNewAssessment))
        }
        return (vaccineResidueMoldsDataArr, vaccineMicroSamplesDataArr)
    }

    private func handleSyncResponse(json: JSONDictionary, error: Error?, paramForDoaInnovoject: JSONDictionary) {
        self.dismissGlobalHUD(self.view)
        if let error = error {
            print("Sync failed: \(error)")
            return
        }
        if json["StatusCode"] as? Int == 200 {
            self.callRequest2(paramForDoaInnovoject: paramForDoaInnovoject, json: JSON(rawValue: json) ?? JSON())
        } else {
            self.showAlert(title: "Error", message: "Error in first API sync", owner: self)
        }
    }

    // ... existing code ...
    private func validateExtendedMicrobialSync() -> Bool {
        if submitExtend, categoarylabelText != Constants.extendedMicrobialStr {
            let alert = UIAlertController(title: "Alert!", message: "Please finish Extended Microbial first or turn off the switch in order to sync the other data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return false
        }
        return true
    }

    private func updateIsEMRequestedFlag() {
        if !extendedMicroSwitch.isHidden {
            peNewAssessment.IsEMRequested = submitExtend
        }
        CoreDataHandlerPE().updateOfflineIsEMRequested(isEMRequested: peNewAssessment.IsEMRequested!)
    }

    private func prepareRefrigeratorData() -> [JSONDictionary] {
        guard regionID != 3 else { return [] }
        let assId = Int(UserDefaults.standard.string(forKey: "currentServerAssessmentId") ?? "") ?? 0
        return CoreDataHandlerPE().getOfflineREfriData(id: assId).compactMap {
            $0 != nil ? createSyncRequestRefrigator(dictArray: $0) : nil
        }
    }

    private func fetchPEData(from ids: [Int]) -> [InovojectData] {
        var result: [InovojectData] = []
        var idSet = Set<Int>()
        for id in ids {
            if let data = CoreDataHandlerPE().getPEDOAData(doaId: id), let dataId = data.id, !idSet.contains(dataId) {
                idSet.insert(dataId)
                result.append(data)
            }
        }
        return result
    }

    private func fetchCertificateData() -> [PECertificateData] {
        var result: [PECertificateData] = []
        var idSet = Set<Int>()
        for id in peNewAssessment.vMixer {
            if let data = CoreDataHandlerPE().getCertificateData(doaId: id), let dataId = data.id, !idSet.contains(dataId) {
                idSet.insert(dataId)
                result.append(data)
            }
        }
        return result
    }

    private func createDOAInnovojectParams(
        inovojectDataArr: [JSONDictionary],
        dayOfAgeDataArr: [JSONDictionary],
        dayOfAgeSDataArr: [JSONDictionary],
        certificateDataArr: [JSONDictionary],
        vaccineResidueMoldsDataArr: [JSONDictionary],
        vaccineMicroSamplesDataArr: [JSONDictionary],
        refrigratorDataArr: [JSONDictionary]
    ) -> JSONDictionary {
        var params: JSONDictionary = [
            "InovojectData": inovojectDataArr,
            "DayOfAgeData": dayOfAgeDataArr,
            "DayAgeSubcutaneousDetailsData": dayOfAgeSDataArr,
            "VaccineMixerObservedData": certificateDataArr,
            "VaccineResidueMoldsData": vaccineResidueMoldsDataArr,
            "VaccineMicroSamplesData": vaccineMicroSamplesDataArr,
            "DeviceId": deviceIDFORSERVER
        ]
        if regionID != 3 {
            params["RefrigeratorData"] = refrigratorDataArr
        }
        return params
    }

    
    // MARK: ------------ Extended Micro Create Sync Request --------------
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
        var AssessmentId = dict.dataToSubmitNumber ?? 0
        
        let deviceIdForServer = "\(UniID)_1_iOS_\(udid)"
        deviceIDFORSERVER = deviceIdForServer
        
        if AssessmentId == 0 {
            if dict.assDetail2?.lowercased().contains("_1_ios") ?? false{
                deviceIDFORSERVER = dict.assDetail2 ?? ""
            }
            saveTypeString.append(00)
        }
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
        }else {
            let convertDateFormatter = DateFormatter()
            convertDateFormatter.dateFormat = Constants.yyyyMMddStr
            convertDateFormatter.timeZone = Calendar.current.timeZone
            convertDateFormatter.locale = Calendar.current.locale
        }
       
        if regionId == 3 {
            
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = Constants.MMddyyyyStr
            
            // Convert the string to a Date object
            if inputFormatter.date(from: evaluationDate ?? "") != nil {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = Constants.yyyyMMddStr
                dict.evaluationDate = evaluationDate
            }
        } else {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = Constants.ddMMyyyStr
            
            if inputFormatter.date(from: evaluationDate ?? "") != nil {
                let outputFormatter = DateFormatter()
                outputFormatter.dateFormat = Constants.yyyyMMddStr
                dict.evaluationDate = evaluationDate
            }
            
        }
        
        let appVersion = "\(Bundle.main.versionNumber)"
        
        var saveType = 0
        self.peNewAssessment.IsEMRequested = false
        CoreDataHandlerPE().updateOfflineIsEMRequested(isEMRequested: false)
        if self.extendedMicroSwitch.isOn {
            saveType = 1
            self.peNewAssessment.IsEMRequested = true
            CoreDataHandlerPE().updateOfflineIsEMRequested(isEMRequested: true)
        }
        
        tempArr.removeAll()
     
        let json: JSONDictionary = [
            "AssessmentId":serverAssessmentId,
            "DeviceId": deviceIDFORSERVER,
            "UserId": UserId,
            "EvaluationId": EvaluationId ?? 0,
            "SaveType":saveType,
            "Status_Type": 0,
            "IsEMRequested" : true,
            "IsSendEmail": true,
            "appVersion": appVersion,
            "SanitationEmbrexScoresDataModel":extendedData
        ] as JSONDictionary
        
        return json
    }
    
    // MARK: ------------ Call Extended Micro Sync API --------------
    fileprivate func handlNaviationTapOfAlert() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: PEDashboardViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
            }
        }
    }
    
    func callExtendedMicro(param:JSONDictionary) {
        
        ZoetisWebServices.shared.sendExtendedMicroToServer(controller: self, parameters: param, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            
            guard let self = self, error == nil else { return }
            if json["StatusCode"]  == 200 {
                
                self.dismissGlobalHUD(self.view)
                
                if self.extendedMicroSwitch.isHidden == false {
                    let errorMSg = "Your Extended Microbial Assessment has been submitted successfully."
                    let alertController = UIAlertController(title: "Success!", message: errorMSg, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
                        _ in
                        self.handlNaviationTapOfAlert()
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            } else {
                self.dismissGlobalHUD(self.view)
                self.showAlert(title: "Error", message: "Error in Extended Micro data sync", owner: self)
            }
        })
    }
    
    // MARK: Sync Button Action
    @IBAction func syncBtnAction(_ sender: Any) {
        if ConnectionManager.shared.hasConnectivity(){
            let errorMSg = "Are you sure, you want to sync the data?"
            let alertController = UIAlertController(title: "Data available", message: errorMSg, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                _ in
                self.syncBtnTapped(showHud: true)
                // As per discussion with Imran and binu we have commented this code so that client can submit their assessment irsepective of their Assessment Approved or not.
              //  self.getAssessmentStatusCheck(assessmentId: self.peNewAssessment.serverAssessmentId ?? "")
            }
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            Helper.showAlertMessage(self, titleStr: NSLocalizedString("Alert", comment: ""), messageStr: NSLocalizedString("You are currently offline. Please go online to sync data.", comment: ""))
        }
    }
    
    // MARK: Post request for Score
    func createSyncRequestForScore(dict: PENewAssessment) -> JSONDictionary {
        let uniID = (dict.dataToSubmitID?.isEmpty == false ? dict.dataToSubmitID : dict.draftID) ?? ""
        let assessmentID = (dict.dataToSubmitNumber != 0 ? dict.dataToSubmitNumber : dict.draftNumber) ?? 0
        let displayID = "C-" + uniID

        let score = (dict.assStatus == 1 ? dict.assMaxScore : dict.assMinScore) ?? 0

        let qcCount = getQCCount(from: dict)
        let textAmPm = getAmPm(from: dict)
        let ppmValue = getPPM(from: dict)
        let personName = getPersonName(from: dict)
        let frequencyValue = getFrequencyValue(from: dict)

        let serverAssessmentId = Int64(dict.serverAssessmentId ?? "") ?? 0
        let regionId = UserDefaults.standard.integer(forKey: "Regionid")

        var json: JSONDictionary = [
            "DisplayId": String(displayID.prefix(22)),
            "AppAssessmentId": String(assessmentID),
            "ModuleAssessmentId": dict.assID ?? 0,
            "AssessmentScore": score,
            "UserId": dict.userID ?? 0,
            "Device_Id": deviceIDFORSERVER,
            "QCCount": qcCount,
            "PersonName": personName,
            "FrequencyValue": frequencyValue == 32 ? "" : frequencyValue,
            "TextAmPm": textAmPm,
            "AssessmentId": serverAssessmentId,
            "SequenceNo": dict.sequenceNoo ?? 0,
            "MaxScore": dict.assMaxScore ?? 0,
            "isNA": dict.isNA ?? false
        ]

        if regionId == 3 {
            json["Chlorine_Value"] = ppmValue
        }

        return json
    }
    
    private func getQCCount(from dict: PENewAssessment) -> String {
        if dict.rollOut == "Y", dict.sequenceNoo == 3, dict.qSeqNo == 12 {
            return dict.qcCount ?? ""
        }
        return ""
    }

    private func getAmPm(from dict: PENewAssessment) -> String {
        if dict.rollOut == "Y", dict.catName == "Miscellaneous" {
            return dict.ampmValue ?? ""
        }
        return ""
    }

    private func getPPM(from dict: PENewAssessment) -> String {
        if dict.rollOut == "Y", dict.sequenceNoo == 5, dict.qSeqNo == 5 {
            return dict.ppmValue ?? ""
        }
        return ""
    }

    private func getPersonName(from dict: PENewAssessment) -> String {
        if dict.rollOut == "Y", dict.sequenceNoo == 3, dict.qSeqNo == 1 {
            return dict.personName ?? ""
        }
        return ""
    }

    private func getFrequencyValue(from dict: PENewAssessment) -> Int {
        guard dict.rollOut == "Y", dict.sequenceNoo == 3, dict.qSeqNo == 1,
              let frequency = dict.frequency, !frequency.isEmpty else {
            return 32
        }

        let visitDetails = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Frequency")
        let names = visitDetails.value(forKey: "frequencyName") as? [String] ?? []
        let ids = visitDetails.value(forKey: "frequencyId") as? [Int] ?? []

        if let index = names.firstIndex(of: frequency), index < ids.count {
            return ids[index]
        }

        return 32
    }

    
    // MARK: Create Sync Request for Comment
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
    
    // MARK: Handle Sync Response
    fileprivate func handleOfflineArrayAndCallAPI(_ getOfflineArray: [PENewAssessment]) {
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
            var ScoreDataArr : [JSONDictionary]  = []
            var comntArray : [JSONDictionary]  = []
            var imgArray : [JSONDictionary]  = []
            imgArray.removeAll()
            for objCtIs in catAllRowArray {
                let json = createSyncRequestForScore(dict: objCtIs)
                let jsonComment = createSyncRequestForComment(dictArray: objCtIs)
                ScoreDataArr.append(json)
                comntArray.append(jsonComment)
            }
            let param = ["AssessmentCommentsData":comntArray,"AssessmentScoreData":ScoreDataArr] as JSONDictionary
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
        
        handleOfflineArrayAndCallAPI(getOfflineArray)
        
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
                let json = createSyncRequestForScore(dict: objCtIs)
                let jsonComment = createSyncRequestForComment(dictArray: objCtIs)
                tempArr.append(json)
                comntArray.append(jsonComment)
            }
            let param = ["AssessmentCommentsData":comntArray,"AssessmentScoreData":tempArr] as JSONDictionary
            self.callRequest3(param:param)
        }
    }
    
    // MARK: Post Request for DOA Data
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
                
            } else {
            }
        })
    }
    
    // MARK: Post Request for Score Data
    func callRequest3(param:JSONDictionary){
        self.convertDictToJson(dict: param,apiName: "add score")
        ZoetisWebServices.shared.sendScoresDataToServer(controller: self, parameters: param, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            guard let self = self, error == nil else { return }
            if json["StatusCode"]  == 200{
                self.calculateImageCount()
            } else {
                self.dismissGlobalHUD(self.view)
                self.showAlert(title: "Error", message: "Error in sync score", owner: self)
            }
        })
    }
    
    // MARK: Post Request for Images Data of Assessment
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
        
       
        var siteId = String(dictArray.siteId ?? 0)

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
    
    // MARK: Calculate Images Count
    func calculateImageCount() {
        callRequest4Int = 0
        totalImageToSync = []

        handleAssessmentImages(isDraft: false)
        handleAssessmentImages(isDraft: true)
    }

    private func handleAssessmentImages(isDraft: Bool) {
        let assessments = isDraft ? getDraftAssessments() : getOfflineAssessments()

        guard !assessments.isEmpty else { return }

        let groupedAssessments = groupAssessmentsBySequence(assessments)
        let allRows = fetchAllAssessmentRows(from: groupedAssessments, isDraft: isDraft)

        var imagePayloads: [JSONDictionary] = []

        for assessment in allRows {
            _ = createSyncRequestForScore(dict: assessment)
            _ = createSyncRequestForComment(dictArray: assessment)

            for imageID in assessment.images {
                if !CoreDataHandlerPE().imageAlreadySyncStatus(imageId: imageID) {
                    let imagePayload = createSyncRequestForImage(dictArray: assessment, img: imageID)
                    imagePayloads.append(imagePayload)
                }
            }
        }

        sendImagesInBatches(imagePayloads)
    }

    private func getOfflineAssessments() -> [PENewAssessment] {
        let count = peNewAssessment.dataToSubmitNumber ?? 0
        if count == 0 {
            return []
        }

        CoreDataHandlerPE().updateOfflineStatus(assessment: peNewAssessment)
        return CoreDataHandlerPE().getOfflineAssessmentArray(id: peNewAssessment.dataToSubmitID ?? "")
    }

    private func getDraftAssessments() -> [PENewAssessment] {
        let count = peNewAssessment.draftNumber ?? 0
        if count == 0 {
            return []
        }

        return CoreDataHandlerPE().getDraftAssessmentArray(id: count)
    }

    private func groupAssessmentsBySequence(_ assessments: [PENewAssessment]) -> [PENewAssessment] {
        var seen = Set<Int>()
        var unique = [PENewAssessment]()

        for assessment in assessments {
            if let seq = assessment.sequenceNo, !seen.contains(seq) {
                seen.insert(seq)
                unique.append(assessment)
            }
        }

        return unique
    }

    private func fetchAllAssessmentRows(from grouped: [PENewAssessment], isDraft: Bool) -> [PENewAssessment] {
        var allRows: [PENewAssessment] = []

        for assessment in grouped {
            let sequence = assessment.sequenceNo ?? 0
            let rows = isDraft
                ? CoreDataHandlerPE().fetchCustomerForSyncWithCatIDDraft(sequence as NSNumber, draftNumber: peNewAssessment.draftNumber as? NSNumber ?? 0) as? [PENewAssessment] ?? []
                : CoreDataHandlerPE().fetchCustomerForSyncWithCatID(sequence as NSNumber, dataToSubmitNumber: peNewAssessment.dataToSubmitNumber as? NSNumber ?? 0) as? [PENewAssessment] ?? []
            allRows.append(contentsOf: rows)
        }

        return allRows
    }

    private func sendImagesInBatches(_ images: [JSONDictionary]) {
        let batchSize = 3
        var batch: [JSONDictionary] = []

        for (index, image) in images.enumerated() {
            batch.append(image)
            if batch.count == batchSize || index == images.count - 1 {
                let param: JSONDictionary = ["AssessmentImages": batch]
                self.callRequest4(paramForImages: param)
                batch.removeAll()
            }
        }
    }

    
    // MARK: Get Off Line Saved Assessments from DB
    func getAllAssessmentInOfflineFromDb() -> Int {
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
    
    // MARK: Call Request for images
    func callRequest4(paramForImages: JSONDictionary) {
        callRequest4Int += 1

        ZoetisWebServices.shared.sendMultipleImagesBase64ToServer(controller: self, parameters: paramForImages) { [weak self] (json, error) in
            guard let self = self else { return }
            self.callRequest4Int -= 1

            if let _ = error {
                self.handleSyncError()
                return
            }

            guard json["StatusCode"] as? Int == 200 else {
                self.dismissGlobalHUD(self.view)
                return
            }

            self.updateSyncStatuses()

            if ConnectionManager.shared.hasConnectivity(), self.callRequest4Int == 0 {
                self.handlePostSync()
            }
        }
    }
    private func handleSyncError() {
        let syncCount = getAllAssessmentInOfflineFromDb()
        if syncCount > 0 {
            syncBtnTapped(showHud: false)
        } else {
            showtoast(message: Constants.dataSyncSuccess)
            notifyDashboardUpdate()
        }
    }

    private func updateSyncStatuses() {
        if saveTypeString.contains(11) {
            if saveTypeString.contains(00) {
                CoreDataHandlerPE().updateDraftStatus(assessment: peNewAssessment)
            }
            CoreDataHandlerPE().updateOfflineStatus(assessment: peNewAssessment)
        } else {
            CoreDataHandlerPE().updateDraftStatus(assessment: peNewAssessment)
        }
    }

    private func handlePostSync() {
        if regionID == 3 && peNewAssessment.IsEMRequested == true {
            syncExtendedMicrobial()
        }

        let syncCount = getAllAssessmentInOfflineFromDb()
        if syncCount > 0 {
            showtoast(message: Constants.dataSyncSuccess)
            notifyDashboardUpdate()
            dismissGlobalHUD(view)
            syncBtnTapped(showHud: true)
        } else {
            for imageGroup in totalImageToSync {
                CoreDataHandlerPE().setImageStatusTrue(idArray: imageGroup)
            }
            showtoast(message: Constants.dataSyncSuccess)
            notifyDashboardUpdate()
            dismissGlobalHUD(view)
        }
    }

    private func notifyDashboardUpdate() {
        NotificationCenter.default.post(Notification(name: Notification.Name("UpdateComplexOnDashboardPE"), object: nil))
    }

    
    // MARK: Sync Extended Microbial
    func syncExtendedMicrobial ()
    {
        var extendedMicroArr : [JSONDictionary]  = []
        self.showGlobalProgressHUDWithTitle(self.view, title: "Data syncing...")
        
        certificateData.removeAll()
        if peNewAssessment.vMixer.count > 0 {
            var idArr : [Int] = []
            for objn in  peNewAssessment.vMixer {
                let data = CoreDataHandlerPE().getCertificateData(doaId: objn)
                if idArr.contains(data!.id ?? 0){
                    debugPrint("this array contains data")
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

