

//
//  PEDashboardViewController.swift
//  Zoetis -Feathers
//
//  Created by "" ""on 05/12/19.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import SwiftyJSON
import Charts
import Reachability
import CoreData
import Gigya
import GigyaTfa
import GigyaAuth

class PEDashboardViewController: BaseViewController , ChartViewDelegate{
    // MARK: - OUTLETS
    let gigya = Gigya.sharedInstance(GigyaAccount.self)
    @IBOutlet weak var btn_Training: UIButton!
    @IBOutlet weak var dashboardTblVw: UITableView!
    @IBOutlet weak var draftCountImg: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var extendedLbl: UILabel!
    @IBOutlet weak var extendedLblDash: UILabel!
    @IBOutlet weak var graphHeaderImage: UIImageView!
    @IBOutlet weak var date2Label: UILabel!
    @IBOutlet weak var date1Label: UILabel!
    @IBOutlet weak var barChartViewFirst: BarChartView!
    @IBOutlet weak var barChartViewSecond: BarChartView!
    @IBOutlet weak var startassessmentButton: UIButton!
    @IBOutlet weak var draftView: UIView!
    @IBOutlet weak var barChart2: BarChartView!
    @IBOutlet weak var barChart1: BarChartView!
    @IBOutlet weak var selectedSiteLabel: PEFormLabel!
    @IBOutlet weak var selectedCustomerLabel: PEFormLabel!
    @IBOutlet weak var barGraph1: UIView!
    @IBOutlet weak var barGraph2: UIView!
    @IBOutlet weak var labelDraftCount: UILabel!
    @IBOutlet weak var gradientViewBelowGraph: GradientButton!
    @IBOutlet weak var operatorCertVw: UIView!
    @IBOutlet weak var viewAssessmentBtn: UIButton!
    @IBOutlet weak var popupVw: UIView!
    @IBOutlet weak var titleVw: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var popupHeaderVw: UIView!
    @IBOutlet weak var rejectedBGView: UIImageView!
    @IBOutlet weak var popupTblVw: UITableView!
    @IBOutlet weak var sectionHeaderVw: UIView!
    @IBOutlet weak var popupSectionHeaderVw: UIView!
    @IBOutlet weak var popupHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rejectedListBtn: UIButton!
    @IBOutlet weak var popupBackgroundVw: UIView!
    @IBOutlet weak var tableHeaderVw: UIView!
    @IBOutlet weak var rejectedListCount: UILabel!
    
    // MARK: - VARIABLES
    var sanitationQuesArr = [PE_ExtendedPEQuestion]()
    var upcomingCertificationsArr:[PENewAssessment] = [PENewAssessment]()
    var rejectedVM: RejectedAssessmentViewModel?
    var scheduleAssessmentIdArray : [String] = []
    var lastTwoAssessmentsDate : [String] = []
    var lastTwoAssessmentsSubmitId : [String] = []
    var resultCatfirstAssessment : [PE_AssessmentInProgress] = []
    var resultCatSecondAssessment : [PE_AssessmentInProgress] = []
    var peHeaderViewController:PEHeaderViewController!
    var deviceIDFORSERVER = ""
    var inovojectData : [InovojectData] = []
    var dayOfAgeData : [InovojectData] = []
    var dayOfAgeSData : [InovojectData] = []
    var certificateData : [PECertificateData] = []
    var saveTypeString : [Int] = []
    var peAssessmentSyncArray : [PENewAssessment] = []
    var objAssessment : PENewAssessment = PENewAssessment()
    var peNewAssessment:PENewAssessment?
    var callRequest4Int = 0
    var totalImageToSync : [Int] = []
    var syncAndLogout : Bool = false
    var isGotResponse : Bool = false
    var isfromSync : Bool = false
    var jsonRe : JSON = JSON()
    var pECategoriesAssesmentsResponse =  PECategoriesAssesmentsResponse(nil)
    var infoImageDataResponse = InfoImageDataResponse(nil)
    var deletedAssessmentIdArray = [String]()
    var i = 0, j = 0, k = 0
    var isSync : Bool = false
    var syncResponse : Bool = false
    var assessID : Int?
    let group = DispatchGroup()
    var  regionID = Int()
    var tempArr : [JSONDictionary]  = []
    
    var HaveToCallExtendedMicro : Bool = false
    @IBOutlet weak var alertLbl: UILabel!
    var fileDetailArray = NSArray()
    // MARK: - VIEW LIFE CYCLE
    let noIdFound = Constants.noIdFoundStr
    let yyymmdd = Constants.yyyyMMddStr
    let userIdStr = " userID == %d AND serverAssessmentId == %@"
    let noteStr = Constants.noMinimizeWhileSyncing
    override func viewDidLoad() {
        print("<<<<",self)
        super.viewDidLoad()
        getBlankAssessmentFiles()
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBar.isHidden = true
        
        regionID = UserDefaults.standard.integer(forKey: "Regionid")
        if( regionID != 3) {
            btn_Training.alpha = 0.3
            btn_Training.alpha = 0.3
            btn_Training.isUserInteractionEnabled = false
        }
        else{
            btn_Training.alpha = 1
            btn_Training.alpha = 1
            btn_Training.isUserInteractionEnabled = true
        }
        DispatchQueue.main.async {
            self.gradientViewBelowGraph.setGradient(topGradientColor: UIColor.getGradientUpperColorStartAssessmentMid(), bottomGradientColor: UIColor.getGradientLowerColor())
        }
        self.selectedCustomerLabel.text   = ""
        self.selectedSiteLabel.text =  ""
        NotificationCenter.default.addObserver(self, selector: #selector(self.navToGlobalDashboard(notification:)), name: Notification.Name("NavToGlobalDashboard"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.dashboardRefresh(notification:)), name: Notification.Name("UpdateComplexOnDashboardPE"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToStartAssessment(notification:)), name: Notification.Name("MoveToStartAssessment"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToViewAssessment(notification:)), name: Notification.Name("MoveToViewAssessment"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToScheduledAssessments(notification:)), name: Notification.Name("NavigateToScheduledAssesments"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToPlacards(notification:)), name: Notification.Name("MoveToOpenPlacards"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.syncBtnTappedNoti(notification:)), name: Notification.Name("peSyncDataNoti"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.navToGlobalDashboardAfterSync(notification:)), name: Notification.Name("MoveToDashBoard"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishSessionClicked(notification:)), name: Notification.Name("FinishSessionPEClicked"), object: nil)
        
        registerTblVwCells()
        setUI()
        if regionID == 3 {
            extendedLbl.text = Constants.extendedMicrobialStr
            extendedLblDash.text = Constants.extendedMicrobialStr
        } else {
            extendedLbl.text = "Country"
            extendedLblDash.text = "Country"
        }
        let PE_Selected_Customer_Name = UserDefaults.standard.string(forKey: "PE_Selected_Customer_Name") ?? ""
        let PE_Selected_Site_Name = UserDefaults.standard.string(forKey: "PE_Selected_Site_Name") ?? ""
        
        self.selectedCustomerLabel.text   = PE_Selected_Customer_Name + " - " + PE_Selected_Site_Name
        date1Label.isHidden = true
        date2Label.isHidden = true
        getPlateTypes()
        loadPopupUI()
        hidePopup()
        operatorCertVw.setGradient(topGradientColor: UIColor.getUpcomingCertUpperGradColor(), bottomGradientColor: UIColor.getUpcomingCertLowerGradColor())
        operatorCertVw.roundVsCorners(corners: [.topLeft, .topRight], radius: 18.5)
        tableHeaderVw.setGradient(topGradientColor: UIColor.getDashboardTableHeaderLowerGradColor(), bottomGradientColor:UIColor.getDashboardTableHeaderUpperGradColor())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.isSync = false
        hideDraftCount()
        hideRejectedCount()
        peAssessmentSyncArray.removeAll()
        peAssessmentSyncArray = getAllDateArrayStored()
        if peAssessmentSyncArray.count < 1 {
            addOperations()
        }
        setupHeader()
        hidePopup()
        let userDefault = UserDefaults.standard
        self.checkDataForSyncViewDidAppear()
        self.upcomingCertificationsArr =  PEAssessmentsDAO.sharedInstance.getVMObj(userId:UserContext.sharedInstance.userDetailsObj?.userId ?? "")
        
        alertLbl.isHidden = upcomingCertificationsArr.count > 0
        self.popupTblVw.reloadData()
        self.dashboardTblVw.reloadData()
        
        userDefault.set(nil, forKey: "PE_Selected_Customer_Id")
        userDefault.set(nil, forKey: "PE_Selected_Customer_Name")
        userDefault.set(nil, forKey: "PE_Selected_Site_Id")
        userDefault.set(nil, forKey: "PE_Selected_Site_Name")
        let allAssesmentDraftArr = getAllDateArrayStoredDraft()
        if allAssesmentDraftArr.count  > 0 {
            let count = allAssesmentDraftArr.count//getDraftCountFromDb()
            labelDraftCount.text = String(count)
            showDraftCount()
            if count == 0 {
                hideDraftCount()
            }
        } else {
            labelDraftCount.text  = "0"
            hideDraftCount()
        }
        
        let rejectedCountIS =  UserDefaults.standard.value(forKey: "rejectedCountIS") as? Int ?? 0
        if rejectedCountIS  > 0 {
            rejectedListCount.text = String(rejectedCountIS)
            showRejectedCount()
            if rejectedCountIS == 0 {
                hideRejectedCount()
            }
        } else {
            rejectedListCount.text  = "0"
            hideRejectedCount()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewAssessmentBtn.isUserInteractionEnabled = true
    }
    
    // MARK: - INITIAL UI METHODS
    func registerTblVwCells() {
        popupTblVw.delegate = self
        popupTblVw.dataSource = self
        dashboardTblVw.delegate = self
        dashboardTblVw.dataSource = self
        
        popupTblVw.register(VaccinationCertificationsTableViewCell.nib, forCellReuseIdentifier: VaccinationCertificationsTableViewCell.identifier)
        dashboardTblVw.register(VaccinationCertificationsTableViewCell.nib, forCellReuseIdentifier: VaccinationCertificationsTableViewCell.identifier)
    }
    
    private func getPlateTypes() {
        PEDataService.sharedInstance.getPlateTypes(loginuserId: UserContext.sharedInstance.userDetailsObj?.userId ?? noIdFound, viewController: self, completion: { (status, error) in
            guard error == nil else { return }
        })
    }
    // MARK: - Load Popup
    private func loadPopupUI(){
        setGradientToTblVw(tableView:popupTblVw)
        popupHeaderVw.setGradient(topGradientColor: UIColor.getDashboardTableHeaderLowerGradColor(), bottomGradientColor:UIColor.getDashboardTableHeaderUpperGradColor())
        popupSectionHeaderVw.backgroundColor = UIColor.getPopupSectionHeaderColor()
    }
    // MARK: - Hide Popup
    private func hidePopup(){
        popupBackgroundVw.isHidden = true
        
        popupSectionHeaderVw.isHidden = true
        popupHeightConstraint.constant = 0
        titleVw.isHidden = true
        sectionHeaderVw.isHidden = true
    }
    // MARK: - Hide Draft Count
    func hideDraftCount(){
        labelDraftCount.isHidden = true
        draftCountImg.isHidden = true
    }
    // MARK: - Hide Reject Count
    func hideRejectedCount(){
        rejectedListCount.isHidden = true
        rejectedBGView.isHidden = true
    }
    // MARK: - Setup Header
    private func setupHeader() {
        _ =  CoreDataHandlerPE().getSavedOnGoingAssessmentPEObject()
        let PE_Selected_Customer_Name = UserDefaults.standard.string(forKey: "PE_Selected_Customer_Name") ?? ""
        let PE_Selected_Site_Name = UserDefaults.standard.string(forKey: "PE_Selected_Site_Name") ?? ""
        
        self.selectedCustomerLabel.text   = PE_Selected_Customer_Name + " - " + PE_Selected_Site_Name
        
        if peNewAssessment?.customerName != nil {
            _ = ZoetisDropdownShared.sharedInstance.sharedPEOnGoingSession[0].peNewAssessment
            _ = Date().string(format: yyymmdd)
            
        } else {
            peNewAssessment = PENewAssessment()
            ZoetisDropdownShared.sharedInstance.sharedPEOnGoingSession.append(PECategoriesAssesmentsResponse(jsonRe))
        }
        peHeaderViewController = PEHeaderViewController()
        peHeaderViewController.titleOfHeader = "Process Evaluation"
        peHeaderViewController.showSession = checkCurrentAssessmentData()
        peHeaderViewController.delegatePE = self
        let assessmentInOfflineFromDb = getAssessmentInOfflineFromDb()
        if assessmentInOfflineFromDb > 0 {
            peHeaderViewController.titleofSync = String(assessmentInOfflineFromDb)
        } else {
            peHeaderViewController.titleofSync = "0"
        }
        
        let allAssesmentDraftArr = getAllDateArrayStoredDraft()//CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInDraft")
        
        if allAssesmentDraftArr.count  > 0 {
            let count = allAssesmentDraftArr.count//getDraftCountFromDb()
            labelDraftCount.text = String(count)
            showDraftCount()
            if count == 0 {
                hideDraftCount()
            }
        } else {
            labelDraftCount.text  = "0"
            hideDraftCount()
        }
        
        self.headerView.addSubview(peHeaderViewController.view)
        self.topviewConstraint(vwTop: peHeaderViewController.view)
    }
    
    // MARK: - Check Data for Sync
    private func checkDataForSyncViewDidAppear(){
        
        let syncArr = getAssessmentInOfflineFromDb()
        if ConnectionManager.shared.hasConnectivity(){
            if syncArr > 0{
                let errorMSg = "Data available for sync, Do you want to sync now?"
                let alertController = UIAlertController(title: Constants.dataAvailableStr, message: errorMSg, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    _ in
                    self.getVaccinationServiceResponse(showHud: true)
                }
                let cancelAction = UIAlertAction(title: Constants.noStr, style: UIAlertAction.Style.cancel) {
                    _ in
                    self.popupTblVw.reloadData()
                    self.dashboardTblVw.reloadData()
                }
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                
            }
        }
    }
    // MARK: - Show Draft Count
    func showDraftCount(){
        labelDraftCount.isHidden = false
        draftCountImg.isHidden = false
    }
    
    // MARK: - Set Gradient Colour to Table View.
    private func setGradientToTblVw(tableView:UITableView){
        let gradientColors = [UIColor.white, UIColor.getPopupTblGradientColor()]
        let gradientLocations = [0.0, 1.0]
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]
        gradientLayer.frame = popupTblVw.bounds
        let backgroundVw = UIView.init(frame: popupTblVw.bounds)
        backgroundVw.layer.insertSublayer(gradientLayer, at: 0)
        popupTblVw.backgroundView = backgroundVw
    }
    // MARK: - Load popup
    private func loadPopupVw(){
        popupBackgroundVw.isHidden = false
        popupSectionHeaderVw.isHidden = false
        popupHeightConstraint.constant = 360
        titleVw.isHidden = false
        sectionHeaderVw.isHidden = false
        DispatchQueue.main.async {
            self.popupTblVw.reloadData()
        }
    }
    // MARK: - Set UI
    func setUI(){
        DispatchQueue.main.async {
            self.draftView.setCornerRadiusFloat(radius: 32)
        }
    }
    // MARK: - Set Charts
    func setChart(values: [Double],dataPoints:[String],barChart:BarChartView) {
        
        barChart.noDataText = "You need to provide data for the chart."
        let chartData = BarChartDataSet()
        for (key, value) in values.enumerated() {
            _ = chartData.addEntry(BarChartDataEntry(x: Double(key), y: value))
        }
        chartData.label = "Assessments Result"
        let myBlueColor =   NSUIColor(red: 64/255.0, green: 126/255.0, blue: 201/255.0, alpha: 1.0)
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        formatter.multiplier = 1.0
        chartData.valueFormatter = DefaultValueFormatter(formatter: formatter)
        chartData.setColor(myBlueColor)
        barChart.delegate = self
        barChart.xAxis.valueFormatter = self
        barChart.xAxis.labelPosition = .bottom
        barChart.leftAxis.axisMinimum = 0
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        barChart.data = BarChartData(dataSet: chartData)
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        barChart.xAxis.labelFont = UIFont.systemFont(ofSize: 6)
        barChart.chartDescription?.text = ""
        barChart.legend.enabled = false
        barChart.rightAxis.enabled = false
        barChart.xAxis.gridColor = .clear
        barChart.leftAxis.gridColor = .clear
        barChart.rightAxis.gridColor = .clear
        barChart.extraBottomOffset = 20
        barChart.fitScreen()
    }
    
    // MARK: - Convert JSON to String
    func jsonToString(json: JSON)->String{
        do {
            let data1 =  self.getDataFrom(JSON: json)
            let convertedString = String(data: data1 ?? Data(), encoding: String.Encoding.utf8)
            return convertedString!
            
        } catch let myJSONError {
            print(appDelegateObj.testFuntion())
        }
        
        return ""
    }
    
    func getDataFrom(JSON json: JSON) -> Data? {
        do {
            return try json.rawData(options: .prettyPrinted)
        } catch _ {
            return nil
        }
    }
    
    // MARK: - Convert Date Formatter
    func convertDateFormatter(date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.yyyyMMddHHmmss
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        dateFormatter.locale = Locale(identifier: "your_loc_id")
        let convertedDate = dateFormatter.date(from: date)
        
        guard dateFormatter.date(from: date) != nil else {
            return ""
        }
        
        if regionID == 3
        {
            dateFormatter.dateFormat = appDelegateObj.MMddyyyStr
        }
        else{
            dateFormatter.dateFormat = Constants.ddMMyyyStr
        }
        
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        let timeStamp = dateFormatter.string(from: convertedDate ?? Date())
        
        return timeStamp

    }
    // MARK: - Save Image In PE Module
    private func saveImageInPEModule(imageData:Data)->Int{
        _ = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_ImageEntity")
        let imageCount = getImageCountInPEModule()
        CoreDataHandlerPE().saveImageInPEFinishModule(imageId: imageCount+1, imageData: imageData)
        return imageCount+1
    }
    // MARK: - Get Image Count In PE Module
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
    
    // MARK: -  Navigate to Start Assessment
    @objc private func moveToStartAssessment(notification: NSNotification){
        self.startNewSessionClicked(self.startassessmentButton!)
    }
    // MARK: - Navigate to View Assessment
    @objc private func moveToViewAssessment(notification: NSNotification){
        navigateToViewAssessment()
    }
    // MARK: - Navigate to Schedule Assessment
    @objc private func navigateToScheduledAssessments(notification: NSNotification){
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PEScheduleVC") as? PEScheduleVC
        if vc != nil{
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    // MARK: - Navigate to Placards
    @objc private func moveToPlacards(notification: NSNotification){
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PEPlacardsViewController") as? PEPlacardsViewController
        if vc != nil{
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    // MARK: - Navigate to Global Dashboard
    @objc private func navToGlobalDashboard(notification: NSNotification){
        self.navigationController?.popToViewController(ofClass: HatcherySelectionViewController.self)
    }
    
    @objc private func navToGlobalDashboardAfterSync(notification: NSNotification){
        self.navigationController?.popToViewController(ofClass: HatcherySelectionViewController.self)
    }
    
    @objc private func finishSessionClicked(notification: NSNotification){
        addComplexPopupWithoutDataCheck(isFromSyncDel: true)
        setupHeader()
    }
    
    // MARK: - Refresh DashBoard
    @objc private func dashboardRefresh(notification: NSNotification) {
        date1Label.isHidden = true
        date2Label.isHidden = true
        self.upcomingCertificationsArr =  PEAssessmentsDAO.sharedInstance.getVMObj(userId:UserContext.sharedInstance.userDetailsObj?.userId ?? "")
        if anyCategoryContainCustomerOrNot() {
            let peNewAssessmentSurrentIs = ZoetisDropdownShared.sharedInstance.sharedPEOnGoingSession[0].peNewAssessment
            if peNewAssessmentSurrentIs?.customerName == nil {
                peNewAssessment = PENewAssessment()
            }
        } else {
            addComplexPopup(isFromSyncDel: true)
        }
        setupHeader()
    }
    // MARK: - Check Current Assessment Data
    private func checkCurrentAssessmentData() -> Bool{
        let peNewAssessmentSurrentIs = CoreDataHandlerPE().getSavedOnGoingAssessmentPEObject()
        let customerName = peNewAssessmentSurrentIs.customerName ?? ""
        let evaluationName = peNewAssessmentSurrentIs.siteName  ?? ""
        let camera = peNewAssessmentSurrentIs.camera  ?? 0
        let hatcheryAntibiotics = peNewAssessmentSurrentIs.hatcheryAntibiotics  ?? 0
        let visitName = peNewAssessmentSurrentIs.visitName  ?? ""
        let notes = peNewAssessmentSurrentIs.notes  ?? ""
        if customerName.count > 0 || evaluationName.count > 0 || camera > 0 || hatcheryAntibiotics > 0  || visitName.count > 0 || notes.count > 0  {
            return true
        }
        return false
    }
    // MARK: - Set Chart for Assessment Submitted Offline
    fileprivate func extractedFunc1() {
        let date = resultCatfirstAssessment[0].evaluationDate ?? ""
        var resultInAssessment : [Double] = []
        date1Label.text = date
        date1Label.isHidden = false
        var dataPoints : [String] = []
        if resultCatfirstAssessment.count > 0 {
            for obj in resultCatfirstAssessment {
                resultInAssessment.append(Double(truncating: obj.catResultMark ?? 0))
                let name = obj.catName ?? ""
                var data = changeStringToArrayLevel3(name:name)
                data = data + "(" + (obj.catMaxMark?.stringValue ?? "") + ")"
                dataPoints.append(data )
            }
        }
        setChart(values: resultInAssessment,dataPoints:dataPoints,barChart: barChart1 )
    }
    
    private func setChartForAssesmentSubmittedOffline(count:Int){
        if count  > 0 {
            if count > 2 || count == 2 {
                let date = resultCatSecondAssessment[0].evaluationDate ?? ""
                date2Label.text = date
                date2Label.isHidden = false
                var resultInAssessment1 : [Double] = []
                var dataPoints1 : [String] = []
                if resultCatSecondAssessment.count > 0 {
                    for obj in resultCatSecondAssessment {
                        resultInAssessment1.append(Double(truncating: obj.catResultMark ?? 0))
                        let name = obj.catName ?? ""
                        var data = changeStringToArrayLevel3(name:name)
                        data = data + "(" + (obj.catMaxMark?.stringValue ?? "") + ")"
                        dataPoints1.append(data )
                    }
                }
                let unitsSold1 = resultInAssessment1
                setChart(values: unitsSold1,dataPoints:dataPoints1,barChart: barChart2 )
            }
            if count == 1 {
                extractedFunc1()
            }
        }
    }
    
    func changeStringToArrayLevel3(name:String) -> String {
        let tempName = name.replacingOccurrences(of: "&", with: "")
        let fullNameArr = tempName.split{$0 == " "}.map(String.init)
        var fullName1 = ""
        var fullName3 = ""
        var fullName2 = ""
        if 0 < fullNameArr.count {
            fullName1 = fullNameArr[0]
        }
        if 1 < fullNameArr.count {
            fullName2 = fullNameArr[1]
        }
        if 2 < fullNameArr.count {
            fullName3 = fullNameArr[2]
        }
        let data =  fullName1 + "\n" + fullName2 + "\n" + fullName3
        return data
        
    }
    
    // MARK: - Show Rejected Count
    func showRejectedCount(){
        rejectedListCount.isHidden = false
        rejectedBGView.isHidden = false
    }
    
    private func addComplexPopup(isFromSyncDel:Bool = false) {
        appDelegateObj.testFuntion()
    }
    
    private func addComplexPopupWithoutDataCheck(isFromSyncDel:Bool = false) {
        appDelegateObj.testFuntion()
    }
    // MARK: - Navigate to View Assessment.
    func navigateToViewAssessment(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PESessionViewController") as? PESessionViewController
        Constants.isFromRejected = false
        if vc != nil{
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    // MARK: - Navigate to Rejected Assessment
    func navigateToRejectedAssessment(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PESessionViewController") as? PESessionViewController
        Constants.isFromRejected = true
        if vc != nil{
            vc!.navigationController?.navigationBar.isHidden = true
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    // MARK: - Filter Categoty Count
    func filterCategoryCount(peNewAssessmentOf:PENewAssessment) -> Int {
        var peCategoryFilteredArray: [PECategory] =  []
        for object in pECategoriesAssesmentsResponse.peCategoryArray{
            if peNewAssessmentOf.evaluationID == object.evaluationID{
                peCategoryFilteredArray.append(object)
            }
        }
        pECategoriesAssesmentsResponse.peCategoryArray = peCategoryFilteredArray
        return pECategoriesAssesmentsResponse.peCategoryArray.count ?? 0
    }
    // MARK: - Save Inovoject Data In PE Module
    private func saveInovojectInPEModule(inovojectData:InovojectData,assessment: PE_AssessmentInProgress) -> Int{
        let imageCount = getDOACountInPEModule()
        CoreDataHandlerPE().saveInovojectPEModule(assessment: assessment ?? PE_AssessmentInProgress(), doaId: imageCount+1,inovojectData: inovojectData)
        return imageCount+1
        
    }
    // MARK: - Save DOA Data In PE Module
    private func saveDOAInPEModule(inovojectData:InovojectData,assessment: PE_AssessmentInProgress,fromDoaS:Bool?=false) -> Int{
        let imageCount = getDOACountInPEModule()
        CoreDataHandlerPE().saveDOAPEModule(assessment: assessment, doaId: imageCount+1,inovojectData: inovojectData,fromDoaS: fromDoaS)
        return imageCount+1
    }
    // MARK: - Dismiss Loader
    func dismissHUD(){
        let mainQueue = OperationQueue.main
        mainQueue.addOperation{
            self.dismissGlobalHUD(self.view)
        }
    }
    // MARK: - Get All Data of Drafted Assessment.
    private func getAllDateArrayStoredDraft() -> [PENewAssessment]{
        var peAssessmentArray : [PENewAssessment] = []
        
        let drafts  = CoreDataHandlerPE().getDraftAssessmentArrayPEObject(ofCurrentAssessment:true)
        var carColIdArray : [String] = []
        for obj in drafts {
            if !carColIdArray.contains(obj.draftID ?? ""){
                carColIdArray.append(obj.draftID ?? "")
                peAssessmentArray.append(obj)
            }
        }
        return peAssessmentArray
    }
    // MARK: - Get Last two Assessment from Data Base
    fileprivate func handleDataCatIDToSubmitNumberIdArray(_ dataCatIDToSubmitNumberIdArray: inout [Int], _ fetchRequestNew: NSFetchRequest<any NSFetchRequestResult>, _ evaluationDateLatestAssessment: String, _ evaluationDateLatestSubmitId: String, _ managedContext: NSManagedObjectContext) {
        for index in 0...dataCatIDToSubmitNumberIdArray.count-1 {
            fetchRequestNew.predicate = NSPredicate(format: "evaluationDate == %@ AND catID == %d AND dataToSubmitID == %@", argumentArray: [ evaluationDateLatestAssessment,dataCatIDToSubmitNumberIdArray[index],evaluationDateLatestSubmitId])
            fetchRequestNew.returnsObjectsAsFaults = false
            
            do {
                let results = try managedContext.fetch(fetchRequestNew) as? [NSManagedObject]
                if results?.count != 0,results?.count ?? 0 > 1 {
                    resultCatfirstAssessment.append(results?[0] as? PE_AssessmentInProgress ?? PE_AssessmentInProgress())
                }
            } catch {
            }
        }
    }
    
    fileprivate func handleDataToSubmitNumberIdArrayValidations(_ dataToSubmitNumberIdArray: [Int], _ catColIdArrayDraftNumbers: NSArray, _ evaluationDateLatestAssessment: String, _ managedContext: NSManagedObjectContext) {
        if dataToSubmitNumberIdArray.count > 0 {
            var dataCatIDToSubmitNumberIdArray : [Int] = []
            for obj in catColIdArrayDraftNumbers {
                if !dataCatIDToSubmitNumberIdArray.contains((obj as? Int) ?? 0) {
                    dataCatIDToSubmitNumberIdArray.append((obj as? Int) ?? 0)
                }
            }
            let fetchRequestNew  = NSFetchRequest<NSFetchRequestResult>(entityName: "PE_AssessmentInOffline")
            fetchRequestNew.returnsObjectsAsFaults = false
            if  resultCatSecondAssessment.count > 0 {
                resultCatSecondAssessment.removeAll()
            }
            if  resultCatfirstAssessment.count > 0 {
                resultCatfirstAssessment.removeAll()
            }
            let evaluationDateLatestSubmitId = lastTwoAssessmentsSubmitId[0] as? String ?? ""
            handleDataCatIDToSubmitNumberIdArray(&dataCatIDToSubmitNumberIdArray, fetchRequestNew, evaluationDateLatestAssessment, evaluationDateLatestSubmitId, managedContext)
            
            if resultCatfirstAssessment.count > 0 {
                setChartForAssesmentSubmittedOffline(count: 1)
            }
        }
    }
    
    fileprivate func handleDataToSubmitNumberValidations(_ managedContext: NSManagedObjectContext, _ fetchRequest: NSFetchRequest<any NSFetchRequestResult>, _ allAssesmentDraftArr: inout [PE_AssessmentInOffline], _ carColIdArrayDraftNumbers: inout NSArray, _ dataToSubmitNumberIdArray: inout [Int], _ catColIdArrayDraftNumbers: inout NSArray, _ submitIDArray: inout NSArray) {
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                let tempArrResultsPEOffline = results as NSArray? ?? []
                allAssesmentDraftArr = results as? [PE_AssessmentInOffline] ?? []
                carColIdArrayDraftNumbers = tempArrResultsPEOffline.value(forKey: "dataToSubmitNumber") as? NSArray ?? []
                
                for obj in carColIdArrayDraftNumbers {
                    if (!dataToSubmitNumberIdArray.contains((obj as? Int) ?? 0) && dataToSubmitNumberIdArray.count < 2) {
                        dataToSubmitNumberIdArray.append((obj as? Int) ?? 0)
                    }
                }
                catColIdArrayDraftNumbers = tempArrResultsPEOffline.value(forKey: "catID") as? NSArray ?? []
                submitIDArray = tempArrResultsPEOffline.value(forKey: "dataToSubmitID") as? NSArray ?? []
            }
        } catch {
        }
        if resultCatfirstAssessment.count > 0 {
            resultCatfirstAssessment.removeAll()
        }
        if resultCatSecondAssessment.count > 0 {
            resultCatSecondAssessment.removeAll()
        }
    }
    
    func getAssessmentOfflineLastTwoFromDb() {
        var peAssessmentDraftArray = getAllDateArrayStoredOffline()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = Constants.ddMMyyyStr

        if(regionID == 3) {
            dateFormatter.dateFormat = appDelegateObj.MMddyyyStr
        }
        
        let sortedArray = peAssessmentDraftArray.sorted {
            let evalDate1 = $0.evaluationDate ?? ""
            let evalDate2 = $1.evaluationDate ?? ""
            let evalDateObj1 = dateFormatter.date(from: evalDate1)
            let evalDateObj2 = dateFormatter.date(from: evalDate2)
            
            if evalDateObj1 != nil && evalDateObj2 != nil{
                return  evalDateObj1! > evalDateObj2!
            }
            return false
        }
        peAssessmentDraftArray = sortedArray
        lastTwoAssessmentsDate.removeAll()
        lastTwoAssessmentsSubmitId.removeAll()
        
        for assessment in peAssessmentDraftArray {
            if !lastTwoAssessmentsSubmitId.contains(assessment.dataToSubmitID ?? "" ){
                lastTwoAssessmentsDate.append(assessment.evaluationDate ?? "")
                lastTwoAssessmentsSubmitId.append(assessment.dataToSubmitID ?? "")
            }
        }
        
        if lastTwoAssessmentsDate.count > 0 {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate!.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PE_AssessmentInOffline")
            fetchRequest.returnsObjectsAsFaults = false
            let userID = UserDefaults.standard.value(forKey:"Id") as? Int ?? 0
            let evaluationDateLatestSubmitId = lastTwoAssessmentsSubmitId[0] as? String ?? ""
            let evaluationDateLatestAssessment = lastTwoAssessmentsDate[0] as? String ?? ""
            
            let customerId = UserDefaults.standard.integer(forKey: "PE_Selected_Customer_Id") ?? 0
            let siteId = UserDefaults.standard.integer(forKey: "PE_Selected_Site_Id") ?? 0
            
            
            fetchRequest.predicate = NSPredicate(format: "customerId == %@ AND siteId == %d AND userID == %d AND evaluationDate == %@ AND dataToSubmitID == %@", argumentArray: [customerId, siteId,userID,evaluationDateLatestAssessment,evaluationDateLatestSubmitId])
            
            
            var carColIdArrayDraftNumbers : NSArray = NSArray()
            var catColIdArrayDraftNumbers : NSArray = NSArray()
            var submitIDArray : NSArray = NSArray()
            var allAssesmentDraftArr : [PE_AssessmentInOffline] = []
            var dataToSubmitNumberIdArray : [Int] = []
            
            handleDataToSubmitNumberValidations(managedContext, fetchRequest, &allAssesmentDraftArr, &carColIdArrayDraftNumbers, &dataToSubmitNumberIdArray, &catColIdArrayDraftNumbers, &submitIDArray)
            var dataSubmitIdArray : [String] = []
            for obj in submitIDArray {
                if !dataSubmitIdArray.contains((obj as? String) ?? ""){
                    dataSubmitIdArray.append((obj as? String) ?? "")
                }
            }
            handleDataToSubmitNumberIdArrayValidations(dataToSubmitNumberIdArray, catColIdArrayDraftNumbers, evaluationDateLatestAssessment, managedContext)
        } else {
            barChart1.clearValues()
            barChart2.clearValues()
            barChart1.clear()
            barChart2.clear()
        }
        if lastTwoAssessmentsDate.count > 1 {
            getAssessmentSecondFromDb()
        }
        
    }
    
    fileprivate func manageDataAtIdArray(_ dataCatIDToSubmitNumberIdArray: inout [Int], _ fetchRequestNew: NSFetchRequest<any NSFetchRequestResult>, _ evaluationDateLatestAssessment: String, _ evaluationDateLatestSubmitId: String, _ managedContext: NSManagedObjectContext) {
        for index in 0...dataCatIDToSubmitNumberIdArray.count-1 {
            fetchRequestNew.predicate = NSPredicate(format: "evaluationDate == %@ AND catID == %d AND dataToSubmitID == %@", argumentArray: [ evaluationDateLatestAssessment,dataCatIDToSubmitNumberIdArray[index],evaluationDateLatestSubmitId])
            fetchRequestNew.returnsObjectsAsFaults = false
            
            do {
                let results = try managedContext.fetch(fetchRequestNew) as? [NSManagedObject]
                if results?.count != 0,results?.count ?? 0 > 1 {
                    resultCatSecondAssessment.append(results?[0] as? PE_AssessmentInProgress ?? PE_AssessmentInProgress())
                }
            } catch {
            }
        }
    }
    
    fileprivate func handleDataSubmitArray(_ dataToSubmitNumberIdArray: [Int], _ catColIdArrayDraftNumbers: NSArray, _ evaluationDateLatestAssessment: String, _ managedContext: NSManagedObjectContext) {
        if dataToSubmitNumberIdArray.count > 0 {
            var dataCatIDToSubmitNumberIdArray : [Int] = []
            for obj in catColIdArrayDraftNumbers {
                if !dataCatIDToSubmitNumberIdArray.contains((obj as? Int) ?? 0) {
                    dataCatIDToSubmitNumberIdArray.append((obj as? Int) ?? 0)
                }
            }
            let fetchRequestNew  = NSFetchRequest<NSFetchRequestResult>(entityName: "PE_AssessmentInOffline")
            fetchRequestNew.returnsObjectsAsFaults = false
            if  resultCatSecondAssessment.count > 0 {
                resultCatSecondAssessment.removeAll()
            }
            let evaluationDateLatestSubmitId = lastTwoAssessmentsSubmitId[1]
            manageDataAtIdArray(&dataCatIDToSubmitNumberIdArray, fetchRequestNew, evaluationDateLatestAssessment, evaluationDateLatestSubmitId, managedContext)
            
            if resultCatSecondAssessment.count > 0 {
                setChartForAssesmentSubmittedOffline(count: 2)
            }
        }
    }
    
    fileprivate func handleManagedContext(_ managedContext: NSManagedObjectContext, _ fetchRequest: NSFetchRequest<any NSFetchRequestResult>, _ allAssesmentDraftArr: inout [PE_AssessmentInOffline], _ carColIdArrayDraftNumbers: inout NSArray, _ dataToSubmitNumberIdArray: inout [Int], _ catColIdArrayDraftNumbers: inout NSArray, _ submitIDArray: inout NSArray) {
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                let tempArrDataToSubmitOffline = results as NSArray? ?? []
                allAssesmentDraftArr = results as? [PE_AssessmentInOffline] ?? []
                carColIdArrayDraftNumbers  = tempArrDataToSubmitOffline.value(forKey: "dataToSubmitNumber") as? NSArray ?? []
                
                for obj in carColIdArrayDraftNumbers {
                    if (!dataToSubmitNumberIdArray.contains((obj as? Int) ?? 0) && dataToSubmitNumberIdArray.count < 2){
                        dataToSubmitNumberIdArray.append((obj as? Int) ?? 0)
                    }
                }
                catColIdArrayDraftNumbers  = tempArrDataToSubmitOffline.value(forKey: "catID") as? NSArray ?? []
                submitIDArray  = tempArrDataToSubmitOffline.value(forKey: "dataToSubmitID") as? NSArray ?? []
            }
        } catch {
        }
    }
    
    func getAssessmentSecondFromDb() {
        
        if lastTwoAssessmentsDate.count > 1 {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedContext = appDelegate!.managedObjectContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PE_AssessmentInOffline")
            fetchRequest.returnsObjectsAsFaults = false
            let userID = UserDefaults.standard.value(forKey:"Id") as? Int ?? 0
            let evaluationDateLatestSubmitId = lastTwoAssessmentsSubmitId[1]
            let evaluationDateLatestAssessment = lastTwoAssessmentsDate[1]
            
            let customerId = UserDefaults.standard.integer(forKey: "PE_Selected_Customer_Id")
            let siteId = UserDefaults.standard.integer(forKey: "PE_Selected_Site_Id")
            
            fetchRequest.predicate = NSPredicate(format: "customerId == %@ AND siteId == %d AND userID == %d AND evaluationDate == %@ AND dataToSubmitID == %@", argumentArray: [customerId,siteId,userID,evaluationDateLatestAssessment,evaluationDateLatestSubmitId])
            
            var carColIdArrayDraftNumbers : NSArray = NSArray()
            var catColIdArrayDraftNumbers : NSArray = NSArray()
            var submitIDArray : NSArray = NSArray()
            var allAssesmentDraftArr : [PE_AssessmentInOffline] = []
            
            var dataToSubmitNumberIdArray : [Int] = []
            
            handleManagedContext(managedContext, fetchRequest, &allAssesmentDraftArr, &carColIdArrayDraftNumbers, &dataToSubmitNumberIdArray, &catColIdArrayDraftNumbers, &submitIDArray)
            var dataSubmitIdArray : [String] = []
            for obj in submitIDArray {
                if !dataSubmitIdArray.contains((obj as? String) ?? ""){
                    dataSubmitIdArray.append((obj as? String) ?? "")
                }
            }
            handleDataSubmitArray(dataToSubmitNumberIdArray, catColIdArrayDraftNumbers, evaluationDateLatestAssessment, managedContext)
        }else {
            barChart2.clearValues()
            barChart2.clear()
        }
        
    }
    // MARK: - Get Offine Assessment from Database
    func getAssessmentInOfflineFromDb() -> Int {
        getAssessmentOfflineLastTwoFromDb()
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
    
    func getDraftCountFromDb() -> Int {
        
        let allAssesmentDraftArr = CoreDataHandlerPE().fetchDetailsWithUserIDForAny(entityName: "PE_AssessmentInDraft")
        let carColIdArrayDraftNumbers  = allAssesmentDraftArr.value(forKey: "draftID") as? NSArray ?? []
        var carColIdArray : [String] = []
        
        for obj in carColIdArrayDraftNumbers {
            if !carColIdArray.contains(obj as? String ?? ""){
                carColIdArray.append(obj as? String ?? "")
            }
        }
        return carColIdArray.count
    }
    // MARK: - Get Latest Marks of Assessment
    private func GetLatestMarkOfAss(assID:Int) -> Int{
        let allAssesmentArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInProgress")
        for ass in allAssesmentArr{
            let objMark = ass as? PE_AssessmentInProgress ?? PE_AssessmentInProgress()
            if Int(objMark.assID ?? 0) == assID{
                return  objMark.catResultMark as? Int ?? 0
            }
        }
        return 0
    }
    // MARK: - Get total Marks of Assessment
    private func GetLatestTotalMarkOfAss(assID:Int) -> Int{
        let allAssesmentArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInProgress")
        for ass in allAssesmentArr{
            let objMark = ass as? PE_AssessmentInProgress ?? PE_AssessmentInProgress()
            if Int(objMark.assID ?? 0) == assID{
                return  objMark.catMaxMark as? Int ?? 0
            }
        }
        return 0
    }
    // MARK: - Get DOA Count In PE Module
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
    // MARK: - Get Vaccine Mixture Count In PE Module
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
    
    // MARK: - IBACTIONS
    // MARK: - Rejection Button Action
    @IBAction func btnRejectionListOpen(_ sender: Any) {
        navigateToRejectedAssessment()
    }
    // MARK: - Close Button Action
    @IBAction func closeBtnAction(_ sender: UIButton) {
        hidePopup()
    }
    // MARK: - Start New Session Button Action
    @IBAction func startNewSessionClicked(_ sender: Any) {
        loadPopupVw()
    }
    // MARK: - Open Existing Button Action
    @IBAction func openExistingSessionClicked(_ sender: Any) {
        self.viewAssessmentBtn.isUserInteractionEnabled = false
        navigateToViewAssessment()
    }
    // MARK: - Tranning & Education Button Action
    @IBAction func trainingEducationClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PEPlacardsViewController") as? PEPlacardsViewController
        if vc != nil{
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    // MARK: - Assessment Finalize Button Action
    @IBAction func btnDraftClicked(_ sender: Any) {
        if peNewAssessment?.peCategoriesAssesmentsResponseDraft?.peCategoryArray.count ?? 0 > 0 {
            let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PEAssesmentFinalize") as? PEAssesmentFinalize
            vc?.peNewAssessment = self.peNewAssessment
            if vc != nil{
                vc!.navigationController?.navigationBar.isHidden = true
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
    }
    // MARK: - Draft Button Action
    @IBAction func draftTapped(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PEDraftViewController") as? PEDraftViewController
        if vc != nil{
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    // MARK: - Blank PDF Button Action
    @IBAction func blankPDFBtnAction(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "pdfOptionsViewController") as! pdfOptionsViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.view.backgroundColor = .clear
        self.present(vc, animated: true, completion: nil)
    }
    
}


extension PEDashboardViewController: IAxisValueFormatter{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let sharedPEQueueArray = ZoetisDropdownShared.sharedInstance.sharedPEQueue
        let count = sharedPEQueueArray?.count ?? 0
        
        if count > 0,count == 1 {
            barChart1.delegate = self
            barChart1.xAxis.valueFormatter = self
            let peCategoriesAssesmentsResponse = sharedPEQueueArray?[0]
            let categoriesArray = peCategoriesAssesmentsResponse?.peCategoryArray as? [PECategory]
            var resultInAssessment : [Double] = []
            var dataPoints : [String] = []
            if categoriesArray?.count ?? 0 > 0 {
                for obj in categoriesArray ?? [] {
                    resultInAssessment.append(Double(obj.resultMark ?? 0))
                    let name = obj.categoryName ?? ""
                    var data = changeStringToArrayLevel3(name:name)
                    data = data + "(" + String(obj.maxMark ?? 0) + ")"
                    dataPoints.append(data)
                }
            }
            let maxMrk = categoriesArray?[ Int(value) % (categoriesArray?.count ?? 0)].maxMark ?? 0
            return String(maxMrk)
        }
        return ""
    }
}

// MARK: - CHECK SESSION DATA

extension PEDashboardViewController{
    
    func anyCategoryContainValueOrNot(serverAssessmentId:String) -> Bool{
        let peNewAssessmentInDB = CoreDataHandlerPE().getOnGoingAssessmentArrayPEObject(serverAssessmentId: serverAssessmentId ?? "")
        if peNewAssessmentInDB.count > 1 {
            return true
        }
        return false
    }
    
    func anyCategoryContainCustomerOrNot() -> Bool{
        
        let PE_Selected_Customer_Id = UserDefaults.standard.integer(forKey: "PE_Selected_Customer_Id") as? Int ?? 0
        
        if  PE_Selected_Customer_Id != 0 {
            return true
        }
        return false
    }
    
}

// MARK: - EXTENSION FOR MANAGING THE SYNC

extension PEDashboardViewController:  SyncBtnDelegatePE {
    
    @objc private func moveToDashBoard(notification: NSNotification){
        print(appDelegateObj.testFuntion())
    }
    // MARK: - Sync Button Notification
    @objc private func syncBtnTappedNoti(notification: NSNotification){
        
        let syncArr = getAssessmentInOfflineFromDb()
        if ConnectionManager.shared.hasConnectivity() {
            if syncArr > 0{
                let errorMSg = Constants.informDataSync
                let alertController = UIAlertController(title: "Alert!", message: errorMSg, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    _ in
                    self.askForDataSync()
                }
                let cancelAction = UIAlertAction(title: Constants.noStr, style: UIAlertAction.Style.cancel) {
                    _ in
                    self.forceSyncMessage()
                }
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                self.logoutAction()
            }
        } else {
            Helper.showAlertMessage(self, titleStr: NSLocalizedString(Constants.alertStr, comment: ""), messageStr: NSLocalizedString(Constants.offline, comment: ""))
        }
        
    }
    // MARK: - get offine Data Array Data
    private func getAllDateArrayStoredOffline() -> [PENewAssessment]{
        var peAssessmentArray : [PENewAssessment] = []
        
        let drafts  = CoreDataHandlerPE().getSessionForViewAssessmentArrayPEObject(ofCurrentAssessment:true)
        var carColIdArray : [Int] = []
        for obj in drafts {
            if !carColIdArray.contains(obj.dataToSubmitNumber ?? 0){
                carColIdArray.append(obj.dataToSubmitNumber ?? 0)
                peAssessmentArray.append(obj)
            }
        }
        return peAssessmentArray
    }
    // MARK: - Ask for data Sync
    func askForDataSync(){
        let errorMSg = Constants.askForDataSync
        let alertController = UIAlertController(title: Constants.dataAvailableStr, message: errorMSg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            _ in
            self.getVaccinationServiceResponse(showHud: true)
        }
        let cancelAction = UIAlertAction(title: Constants.noStr, style: UIAlertAction.Style.cancel) {
            _ in
            self.forceSyncMessage()
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Force Sync Message
    func forceSyncMessage(){
        let errorMSg = Constants.forceSyncMessage
        let alertController = UIAlertController(title: "Alert!", message: errorMSg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            _ in
            self.popupTblVw.reloadData()
            self.dashboardTblVw.reloadData()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Get All Assessment Array.
    private func getAllDateArrayStored() -> [PENewAssessment]{
        var peAssessmentArray : [PENewAssessment] = []
        
        var drafts  = CoreDataHandlerPE().getSessionAssessmentArrayPEObject(ofCurrentAssessment:true)
        
        let draftsNew  = CoreDataHandlerPE().getSessionAssessmentArrayPEObjectDraft(ofCurrentAssessment:true)
        
        
        var carColIdArray : [Int] = []
        for obj in drafts {
            if !carColIdArray.contains(obj.dataToSubmitNumber ?? 0){
                carColIdArray.append(obj.dataToSubmitNumber ?? 0)
                peAssessmentArray.append(obj)
            }
        }
        
        var carColIdArrayraft : [Int] = []
        for obj in draftsNew {
            if !carColIdArrayraft.contains(obj.draftNumber ?? 0){
                carColIdArrayraft.append(obj.draftNumber ?? 0)
                peAssessmentArray.append(obj)
            }
        }
        return peAssessmentArray
    }
    
    private func getAllDateArrayStoredNew() -> [PENewAssessment]{
        var peAssessmentArray : [PENewAssessment] = []
        
        var drafts  = CoreDataHandlerPE().getSessionAssessmentArrayPEObject(ofCurrentAssessment:true)
        
        var carColIdArray : [Int] = []
        for obj in drafts {
            if !carColIdArray.contains(obj.dataToSubmitNumber ?? 0){
                carColIdArray.append(obj.dataToSubmitNumber ?? 0)
                peAssessmentArray.append(obj)
            }
        }
        
        return peAssessmentArray
    }
    
    func getDataFrom(json: JSON) -> Data? {
        do {
            return try json.rawData(options: .prettyPrinted)
        } catch _ {
            return nil
        }
    }
    
    // MARK: - Sync Extended Microbial
    fileprivate func extractedFunc2(_ obj: PENewAssessment) {
        if obj.vMixer.count > 0 {
            var idArr : [Int] = []
            for objn in  obj.vMixer {
                let data = CoreDataHandlerPE().getCertificateData(doaId: objn)
                if idArr.contains(data!.id ?? 0) == false {
                    idArr.append(data!.id ?? 0)
                    if data != nil {
                        self.certificateData.append(data!)
                    }
                }
            }
        }
    }
    
    func syncExtendedMicrobial (saveType: Int , statusType: Int) {
        var extendedMicroArr : [JSONDictionary]  = []
        
        if peAssessmentSyncArray.count > 0 {
            for obj in self.peAssessmentSyncArray{
                self.assessID = Int(obj.serverAssessmentId ?? "")
                self.objAssessment = obj
                self.checkDataDuplicacy(obj: obj)
                self.certificateData.removeAll()
                extractedFunc2(obj)
                
                let jsonExtendedMicro =  self.createSyncRequestForExtendedMicro(dict: obj , certificationData : self.certificateData, saveType: saveType )
                extendedMicroArr.append(jsonExtendedMicro)
                
                let ExtendedMicroparam = ["ExtendedMicrobialData":extendedMicroArr] as JSONDictionary
                self.convertDictToJson(dict: ExtendedMicroparam,apiName: "Assessment_AddEMAssessment")
                self.callExtendedMicro(param: ExtendedMicroparam)
                
            }
        }
    }
    
    // MARK: - Sync button Tabbed
    func syncBtnTapped(showHud:Bool) {
        peAssessmentSyncArray.removeAll()
        peAssessmentSyncArray = getAllDateArrayStored()
        if peAssessmentSyncArray.count > 0 {
            if ConnectionManager.shared.hasConnectivity() {
                self.accessPEArrayObjects()
                
            } else {
                Helper.showAlertMessage(self, titleStr: NSLocalizedString(Constants.alertStr, comment: ""), messageStr: NSLocalizedString(Constants.offline, comment: ""))
            }
        } else {
            if self.deletedAssessmentIdArray.count > 0 {
                let alertController = UIAlertController(title: Constants.alertStr, message: String(format: "%d assessment(s) has been removed from the web. App data will be updated.", self.deletedAssessmentIdArray.count), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    _ in
                    let userID =  UserDefaults.standard.value(forKey:"Id") as? Int ?? 0
                    for id in self.deletedAssessmentIdArray{
                        CoreDataHandlerPE().deleteExisitingData(entityName: "PE_AssessmentInOffline", predicate: NSPredicate(format: self.userIdStr, userID, id))
                    }
                    self.peHeaderViewController.titleofSync = "0"
                    self.peHeaderViewController.viewDidLoad()
                    self.getScheduledAssessments()
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                self.dismissGlobalHUD(self.view ?? UIView())
                let errorMSg = "Data not available for sync"
                let alertController = UIAlertController(title: "No data available", message: errorMSg, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Check Data Duplicacy
    func checkDataDuplicacy(obj: PENewAssessment) {
        self.dataDuplicacyCheck(assId: obj.serverAssessmentId!, customerId: obj.customerId!, siteId: obj.siteId!, evalDate: obj.evaluationDate!, evaulaterId: obj.evaluatorID!) { status in
            if !status {
                let alertController = UIAlertController(title: "Duplicate Data", message: "Assessment already captured with same customer and site Id on same evaluation date for same evaluator", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    self.showGlobalProgressHUDWithTitle(self.view, title: "Loading.")
                    self.getScheduledAssessments()
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
                if let index = self.peAssessmentSyncArray.firstIndex(of: obj) {
                    self.peAssessmentSyncArray.remove(at: index)
                    if self.peAssessmentSyncArray.count == 0  {
                        self.dismissGlobalHUD(self.view)
                    }
                }
            }
        }
    }
    
    
    private func dataDuplicacyCheck(assId: String, customerId: Int, siteId: Int, evalDate: String, evaulaterId: Int, _ completion: @escaping (_ status: Bool) -> Void){
        let parameter = [
            "AssessmentId":assId,
            "SiteId": siteId,
            "CustomerId": customerId,
            "EvaulaterId": evaulaterId,
            "EvaluationDate": evalDate
        ] as JSONDictionary
        ZoetisWebServices.shared.getDuplicacyCheck(controller: self, parameters: parameter, completion: { [weak self] (json, error) in
            guard let self = self, error == nil else { return }
            if json["Data"].boolValue == true{
                completion(false)
            }else{
                completion(true)
            }
        })
    }
    // MARK: - Post DOA Data to Server
    func callRequest2(paramForDoaInnovoject:JSONDictionary,json:JSON){
        let mjson = json
        self.convertDictToJson(dict: paramForDoaInnovoject,apiName: "add inovoject and day of age")
        ZoetisWebServices.shared.sendAddDayOfAgeAndInvoject(controller: self, parameters: paramForDoaInnovoject, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            guard let self = self, error == nil else { return }
            
            if json["StatusCode"]  == 200{
                self.group.enter()
                if self.isSync {
                    self.handleSyncResponse(mjson)
                    
                }
                self.group.leave()
                
            }
        })
    }
    
    // MARK: - Post Data to Server
    func callRequest3(param:JSONDictionary){
        self.convertDictToJson(dict: param,apiName: "add score")
        ZoetisWebServices.shared.sendScoresDataToServer(controller: self, parameters: param, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            guard let self = self, error == nil else { return }
            if json["StatusCode"]  == 200{
                self.group.enter()
                self.CalculateImageCount()
                self.group.leave()
                
            } else {
                self.dismissGlobalHUD(self.view)
                self.showAlert(title: "Error", message: "Error in sync score", owner: self)
            }
        })
    }
    
    // MARK: - Post Images to Server
    fileprivate func ExtendedMicroApi(_ self: PEDashboardViewController) {
        if self.regionID == 3,HaveToCallExtendedMicro == true {
            var saveType = Int()
            
            if Constants.isDraftAssessment == true {
                saveType = 0
            } else {
                saveType = 1
            }
            
            self.syncExtendedMicrobial(saveType: saveType, statusType: 0)
        }
    }
    
    fileprivate func checkSyncArr() {
        if ConnectionManager.shared.hasConnectivity(),self.callRequest4Int == 0 {
            ExtendedMicroApi(self)
            let syncArr = self.getAssessmentInOfflineFromDb()
            if syncArr > 0 {
                self.isSync = false
                self.dismissGlobalHUD(self.view)
                self.syncBtnTapped(showHud: false)
                Helper.showGlobalProgressHUDWithTitle(self.view, title: appDelegateObj.dataSyncInProgressStr + "\n" + noteStr)
            } else {
                self.dismissGlobalHUD(self.view)
                Helper.showGlobalProgressHUDWithTitle(self.view, title: appDelegateObj.dataSyncInProgressStr + "\n" + noteStr)
                for indec in self.totalImageToSync {
                    CoreDataHandlerPE().setImageStatusTrue(idArray: indec)
                }
                self.showToastWithTimer(message: Constants.dataSyncCompleted, duration: 2.0)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateComplexOnDashboardPE"),object: nil))
                self.dismissGlobalHUD(self.view)
            }
        }
    }
    
    fileprivate func handleRegionId3(_ self: PEDashboardViewController) {
        if self.regionID == 3,HaveToCallExtendedMicro == true {
            var saveType = Int()
            
            if Constants.isDraftAssessment == true {
                saveType = 0
            } else {
                saveType = 1
            }
            
            self.syncExtendedMicrobial(saveType: saveType, statusType: 0)
            
        }
    }
    
    fileprivate func handleHasconnectivityValidation(_ self: PEDashboardViewController) {
        if self.callRequest4Int == 0 {
            
            handleRegionId3(self)
            
            let syncArr = self.getAssessmentInOfflineFromDb()
            if syncArr > 0{
                self.isSync = false
                self.dismissGlobalHUD(self.view)
                self.syncBtnTapped(showHud: false)
                Helper.showGlobalProgressHUDWithTitle(self.view, title: Constants.dataSyncInProgress + "\n" + Constants.noMinimizeWhileSyncing)
            } else {
                self.dismissGlobalHUD(self.view)
                Helper.showGlobalProgressHUDWithTitle(self.view, title: Constants.dataSyncInProgress + "\n" + Constants.noMinimizeWhileSyncing)
                for index in self.totalImageToSync{
                    CoreDataHandlerPE().setImageStatusTrue(idArray: index)
                }
                self.showToastWithTimer(message: "Data Sync has been completed.", duration: 2.0)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateComplexOnDashboardPE"),object: nil))
                self.dismissGlobalHUD(self.view)
            }
        }
    }
    
    fileprivate func handleStatusCode(_ json: JSON, _ self: PEDashboardViewController) {
        if json["StatusCode"]  == 200 {
            if self.saveTypeString.contains(11) {
                if self.saveTypeString.contains(00) {
                    CoreDataHandlerPE().updateDraftStatus(assessment: self.objAssessment)
                }
                CoreDataHandlerPE().updateOfflineStatus(assessment: self.objAssessment)
            } else {
                CoreDataHandlerPE().updateDraftStatus(assessment: self.objAssessment)
            }
            
            if ConnectionManager.shared.hasConnectivity() {
                handleHasconnectivityValidation(self)
            }
        } else {
            self.dismissGlobalHUD(self.view)
        }
    }
    
    func callRequest4(paramForImages:JSONDictionary){
        self.convertDictToJson(dict: paramForImages, apiName: "Test")
        callRequest4Int = callRequest4Int + 1
        Helper.showGlobalProgressHUDWithTitle(self.view, title: Constants.dataSyncInProgress + "\n" + Constants.noMinimizeWhileSyncing)
        ZoetisWebServices.shared.sendMultipleImagesBase64ToServer(controller: self, parameters: paramForImages, completion: { [weak self] (json, error) in
            self?.callRequest4Int = self!   .callRequest4Int - 1
            
            if error != nil {
                
                let syncArr = self?.getAssessmentInOfflineFromDb()
                if syncArr ?? 0 > 0{
                    self?.syncBtnTapped(showHud: false)
                } else {
                    self?.showtoast(message: Constants.dataSyncSuccess)
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateComplexOnDashboardPE"),object: nil))
                }
                
            }
            guard let self = self, error == nil else { return }
            self.dismissGlobalHUD(self.view)
            handleStatusCode(json, self)
        })
    }
    
    // MARK: - Call Extended Micro
    fileprivate func extractedFunc3(_ self: PEDashboardViewController) {
        if self.objAssessment.IsEMRequested == true {
            CoreDataHandlerPE().updateIsEMRequestedInAssessmentSwitch(isEMRequested: false, AssessmentId: objAssessment.serverAssessmentId ?? "")
            CoreDataHandlerPE().updateIsEMRequestedInAssessmentSwitchOffline(isEMRequested: false, AssessmentId: objAssessment.serverAssessmentId ?? "")
        } else {
            if self.saveTypeString.contains(11) {
                if self.saveTypeString.contains(00) {
                    _ = CoreDataHandlerPE().updateDraftStatus(assessment: self.objAssessment)
                }
                _ = CoreDataHandlerPE().updateOfflineStatus(assessment: self.objAssessment)
            } else {
                _ = CoreDataHandlerPE().updateDraftStatus(assessment: self.objAssessment)
            }
        }
    }
    
    fileprivate func extractedFunc4(_ self: PEDashboardViewController) {
        if self.saveTypeString.contains(11) {
            if self.saveTypeString.contains(00) {
                _ = CoreDataHandlerPE().updateDraftStatus(assessment: self.objAssessment)
            }
            _ = CoreDataHandlerPE().updateOfflineStatus(assessment: self.objAssessment)
        } else {
            _ = CoreDataHandlerPE().updateDraftStatus(assessment: self.objAssessment)
        }
    }
    
    func callExtendedMicro(param:JSONDictionary) {
        
        ZoetisWebServices.shared.sendExtendedMicroToServer(controller: self, parameters: param, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            guard let self = self, error == nil else { return }
            if json["StatusCode"]  == 200 {
                extractedFunc4(self)
                self.dismissGlobalHUD(self.view)
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "UpdateComplexOnDashboardPE"),object: nil))
                
            } else {
                extractedFunc3(self)
                self.dismissGlobalHUD(self.view)
            }
        })
    }
    
    // MARK: - Handle Sync Responce
    fileprivate func handleGetDraftArrayValidations(_ getDraftArray: [PENewAssessment], _ obj: PENewAssessment) {
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
            for objCt in catArray {
                var catArrayForTableIs = CoreDataHandlerPE().fetchCustomerForSyncWithCatIDDraft(objCt.sequenceNo as NSNumber? ?? 0,draftNumber:obj.draftNumber as? NSNumber ?? 0) as? [PENewAssessment] ?? []
                
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
            if self.isSync {
                self.callRequest3(param:param)
                self.syncResponse = false
            }
            
        }
    }
    
    fileprivate func handleCatArrSyncResponseValidations(_ catArray: [PENewAssessment], _ obj: PENewAssessment, _ catAllRowArray: inout [PENewAssessment]) {
        for objCt in catArray {
            let catArrayForTableIs = CoreDataHandlerPE().fetchCustomerForSyncWithCatID(objCt.sequenceNo as NSNumber? ?? 0,dataToSubmitNumber:obj.dataToSubmitNumber as NSNumber? ?? 0) as? [PENewAssessment] ?? []
            
            catAllRowArray.append(contentsOf: catArrayForTableIs)
        }
    }
    
    fileprivate func handleCatAllRowArraySyncResponseValidations(_ catAllRowArray: [PENewAssessment], _ tempArr: inout [[String : Any]], _ comntArray: inout [[String : Any]]) {
        for objCtIs in catAllRowArray {
            let json = createSyncRequestForScore(dictArray: objCtIs)
            let jsonComment = createSyncRequestForComment(dictArray: objCtIs)
            tempArr.append(json)
            comntArray.append(jsonComment)
        }
    }
    
    fileprivate func updateDraftArraySyncRespose(_ dNumber: Int, _ getDraftArray: inout [PENewAssessment], _ obj: PENewAssessment) {
        if dNumber != 0 {
            getDraftArray = CoreDataHandlerPE().getDraftAssessmentArray(id:obj.draftNumber ?? 0)
        }
    }
    
    fileprivate func manageOfflineArrayIteration(_ getOfflineArray: [PENewAssessment], _ carColIdArray: inout [Int], _ catArray: inout [PENewAssessment]) {
        for cat in getOfflineArray {
            if !carColIdArray.contains(cat.sequenceNo ?? 0){
                carColIdArray.append(cat.sequenceNo ?? 0)
                catArray.append(cat)
            }
        }
    }
    
    fileprivate func handleSyncResponseValidations(_ sNumber: Int, _ getOfflineArray: inout [PENewAssessment], _ obj: PENewAssessment, _ dNumber: Int, _ getDraftArray: inout [PENewAssessment]) {
        if syncResponse {
            if sNumber != 0 {
                getOfflineArray = CoreDataHandlerPE().getOfflineAssessmentArray(id:obj.dataToSubmitID ?? "" )
            }
            updateDraftArraySyncRespose(dNumber, &getDraftArray, obj)
            callRequest4Int = 0
            
            totalImageToSync = []
            
            if getOfflineArray.count > 0 {
                var carColIdArray : [Int] = []
                var catArray : [PENewAssessment] = []
                var catAllRowArray : [PENewAssessment] = []
                var tempArr : [JSONDictionary]  = []
                var comntArray : [JSONDictionary]  = []
                var imgArray : [JSONDictionary]  = []
                
                manageOfflineArrayIteration(getOfflineArray, &carColIdArray, &catArray)
                handleCatArrSyncResponseValidations(catArray, obj, &catAllRowArray)
                imgArray.removeAll()
                handleCatAllRowArraySyncResponseValidations(catAllRowArray, &tempArr, &comntArray)
                let param = ["AssessmentCommentsData":comntArray,"AssessmentScoreData":tempArr] as JSONDictionary
                if self.isSync {
                    self.callRequest3(param:param)
                    self.syncResponse = false
                }
            }
            
            handleGetDraftArrayValidations(getDraftArray, obj)
        }
    }
    
    private func handleSyncResponse(_ json: JSON) {
        if self.isSync {
            self.syncResponse = true
        }
        
        for obj in peAssessmentSyncArray{
            let sNumber = obj.dataToSubmitNumber ?? 0
            let dNumber = obj.draftNumber ?? 0
            var  getOfflineArray : [PENewAssessment] = []
            var  getDraftArray : [PENewAssessment] = []
            handleSyncResponseValidations(sNumber, &getOfflineArray, obj, dNumber, &getDraftArray)
        }
    }
    
    // MARK: - Calculate Image Count
    fileprivate func handleImgArrCountValidations(_ imgArray: [JSONDictionary], _ arrayCount: inout Int, _ imgDic: inout [[String : Any]]) {
        if imgArray.count > 3 {
            for objimgr in imgArray{
                arrayCount  = arrayCount + 1
                imgDic.append(objimgr)
                if arrayCount == 3  {
                    let ss  = imgDic as?  [JSONDictionary]  ?? []
                    var  paramForImages  = ["AssessmentImages":ss] as JSONDictionary
                    arrayCount  = 0
                    imgDic.removeAll()
                    self.group.enter()
                    self.callRequest4(paramForImages:paramForImages)
                    self.syncResponse = false
                    self.group.leave()
                    
                }
            }
            if  arrayCount > 0 {
                let ss  = imgDic as?  [JSONDictionary]  ?? []
                var  paramForImages  = ["AssessmentImages":ss] as JSONDictionary
                arrayCount  = 0
                imgDic.removeAll()
                self.group.enter()
                self.callRequest4(paramForImages:paramForImages)
                self.syncResponse = false
                self.group.leave()
            }
        } else {
            var  paramForImages  = ["AssessmentImages":imgArray] as JSONDictionary
            self.group.enter()
            self.callRequest4(paramForImages:paramForImages)
            self.syncResponse = false
            self.group.leave()
        }
    }
    
    fileprivate func handleCatAllRowArrayValidations(_ catAllRowArray: [PENewAssessment], _ imgArray: inout [[String : Any]], _ tempArr: inout [[String : Any]], _ comntArray: inout [[String : Any]]) {
        for objCtIs in catAllRowArray {
            let json = createSyncRequestForScore(dictArray: objCtIs)
            let jsonComment = createSyncRequestForComment(dictArray: objCtIs)
            for index in objCtIs.images {
                if CoreDataHandlerPE().imageAlreadySyncStatus(imageId: index) == false {
                    let jsonIMages = createSyncRequestForImage(dictArray: objCtIs,img:index)
                    imgArray.append(jsonIMages)
                }
            }
            tempArr.append(json)
            comntArray.append(jsonComment)
        }
    }
    
    fileprivate func handleCatAllRowArrayInGetDraftArrayValidations(_ catAllRowArray: [PENewAssessment], _ imgArray: inout [[String : Any]], _ tempArr: inout [[String : Any]], _ comntArray: inout [[String : Any]]) {
        for objCtIs in catAllRowArray {
            let json = createSyncRequestForScore(dictArray: objCtIs)
            let jsonComment = createSyncRequestForComment(dictArray: objCtIs)
            for index in objCtIs.images{
                let status = CoreDataHandlerPE().imageAlreadySyncStatus(imageId: index)
                if status == false {
                    let jsonIMages = createSyncRequestForImage(dictArray: objCtIs,img:index)
                    imgArray.append(jsonIMages)
                }
            }
            tempArr.append(json)
            comntArray.append(jsonComment)
            
        }
    }
    
    fileprivate func handleGetDraftArrayCarColIdArrValidations(_ getDraftArray: [PENewAssessment], _ carColIdArray: inout [Int], _ catArray: inout [PENewAssessment], _ obj: PENewAssessment, _ catAllRowArray: inout [PENewAssessment]) {
        for cat in getDraftArray {
            if !carColIdArray.contains(cat.sequenceNo ?? 0){
                carColIdArray.append(cat.sequenceNo ?? 0)
                catArray.append(cat)
            }
        }
        for objCt in catArray {
            var catArrayForTableIs = CoreDataHandlerPE().fetchCustomerForSyncWithCatIDDraft(objCt.sequenceNo as NSNumber? ?? 0,draftNumber:obj.draftNumber as? NSNumber ?? 0) as? [PENewAssessment] ?? []
            
            catAllRowArray.append(contentsOf: catArrayForTableIs)
        }
    }
    
    fileprivate func handleImageCountArrGetDraftArrayValidations(_ imgArray: [JSONDictionary], _ arrayCount: inout Int, _ imgDic: inout [[String : Any]]) {
        if imgArray.count > 3 {
            for objimgr in imgArray{
                arrayCount  = arrayCount + 1
                imgDic.append(objimgr)
                if arrayCount == 3  {
                    let ss  = imgDic as?  [JSONDictionary]  ?? []
                    var  paramForImages  = ["AssessmentImages":ss] as JSONDictionary
                    arrayCount  = 0
                    imgDic.removeAll()
                    self.group.enter()
                    self.callRequest4(paramForImages:paramForImages)
                    self.syncResponse = false
                    self.group.leave()
                }
            }
            if  arrayCount > 0 {
                let ss  = imgDic as?  [JSONDictionary]  ?? []
                var  paramForImages  = ["AssessmentImages":ss] as JSONDictionary
                arrayCount  = 0
                imgDic.removeAll()
                self.group.enter()
                self.callRequest4(paramForImages:paramForImages)
                self.syncResponse = false
                self.group.leave()
            }
        } else {
            var  paramForImages  = ["AssessmentImages":imgArray] as JSONDictionary
            self.group.enter()
            self.callRequest4(paramForImages:paramForImages)
            self.syncResponse = false
            self.group.leave()
        }
    }
    
    fileprivate func handleGetOfflineArrayValidations(_ getOfflineArray: [PENewAssessment], _ obj: PENewAssessment) {
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
            for objCt in catArray {
                let catArrayForTableIs = CoreDataHandlerPE().fetchCustomerForSyncWithCatID(objCt.sequenceNo as NSNumber? ?? 0,dataToSubmitNumber:obj.dataToSubmitNumber as NSNumber? ?? 0) as? [PENewAssessment] ?? []
                
                catAllRowArray.append(contentsOf: catArrayForTableIs)
            }
            var tempArr : [JSONDictionary] = []
            var comntArray : [JSONDictionary] = []
            var imgArray : [JSONDictionary] = []
            
            handleCatAllRowArrayValidations(catAllRowArray, &imgArray, &tempArr, &comntArray)
            var arrayCount  = 0
            var imgDic :  [JSONDictionary] = []
            
            handleImgArrCountValidations(imgArray, &arrayCount, &imgDic)
        }
    }
    
    func CalculateImageCount() {
        if self.isSync {
            self.syncResponse = true
        }
        for obj in peAssessmentSyncArray {
            let sNumber = obj.dataToSubmitNumber ?? 0
            let dNumber = obj.draftNumber ?? 0
            var getOfflineArray : [PENewAssessment] = []
            var getDraftArray : [PENewAssessment] = []
            if self.syncResponse {
                if sNumber != 0 {
                    getOfflineArray = CoreDataHandlerPE().getOfflineAssessmentArray(id:obj.dataToSubmitID ?? "" )
                    CoreDataHandlerPE().updateOfflineStatus(assessment: obj)
                }
                if dNumber != 0 {
                    getDraftArray = CoreDataHandlerPE().getDraftAssessmentArray(id:obj.draftNumber ?? 0)
                }
                callRequest4Int = 0
                totalImageToSync = []
                handleGetOfflineArrayValidations(getOfflineArray, obj)
                
                if getDraftArray.count > 0 {
                    var carColIdArray : [Int] = []
                    var catArray : [PENewAssessment] = []
                    var catAllRowArray : [PENewAssessment] = []
                    handleGetDraftArrayCarColIdArrValidations(getDraftArray, &carColIdArray, &catArray, obj, &catAllRowArray)
                    var tempArr : [JSONDictionary] = []
                    var comntArray : [JSONDictionary] = []
                    var imgArray : [JSONDictionary] = []
                    
                    handleCatAllRowArrayInGetDraftArrayValidations(catAllRowArray, &imgArray, &tempArr, &comntArray)
                    var arrayCount = 0
                    var imgDic : [JSONDictionary] = []
                    
                    handleImageCountArrGetDraftArrayValidations(imgArray, &arrayCount, &imgDic)
                }
            }
        }
    }
    // MARK: - Create Sync Request for Score Data
    fileprivate func extractedFunc5(_ dictArray: PENewAssessment, _ QCCount: inout String, _ TextAmPm: inout String, _ PPMValue: inout String, _ PersonName: inout String, _ FrequencyValue: inout Int) {
        if dictArray.rollOut == "Y" && dictArray.sequenceNoo == 3 && dictArray.qSeqNo == 12 {
            QCCount =  dictArray.qcCount ?? ""
        } else if dictArray.rollOut == "Y" && dictArray.catName == "Miscellaneous" {
            TextAmPm =  dictArray.ampmValue ?? ""
        } else if  dictArray.rollOut == "Y" && dictArray.sequenceNoo == 5  && dictArray.qSeqNo == 5 {
            PPMValue =  dictArray.ppmValue ?? ""
        } else if dictArray.rollOut == "Y" && dictArray.sequenceNoo == 3 && dictArray.qSeqNo == 1 {
            PersonName =  dictArray.personName ?? ""
            let visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Frequency")
            let visitNameArray = visitDetailsArray.value(forKey: "frequencyName") as? NSArray ?? NSArray()
            let visitIDArray = visitDetailsArray.value(forKey: "frequencyId") as? NSArray ?? NSArray()
            if dictArray.frequency?.count ?? 0 > 0,
               visitNameArray.contains(dictArray.frequency ?? "") {
                let indexOfe = visitNameArray.index(of: dictArray.frequency ?? "")
                FrequencyValue = visitIDArray[indexOfe] as? Int ?? 0
            }
        }
    }
    
    fileprivate func extractedFunc6(_ dictArray: PENewAssessment, _ score: inout Int) {
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
        let DisplayId = "C-" + UniID
        extractedFunc6(dictArray, &score)
        var TextAmPm = ""
        var PersonName = ""
        var FrequencyValue = 32
        var QCCount = ""
        var PPMValue = ""
        extractedFunc5(dictArray, &QCCount, &TextAmPm, &PPMValue, &PersonName, &FrequencyValue)
        
        var serverAssessmentId:Int64 = 0
        if let id = dictArray.serverAssessmentId {
            serverAssessmentId = Int64(id) ?? 0
        }
        
        let regionId = UserDefaults.standard.integer(forKey: "Regionid")
        if regionId == 3 {
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
    // MARK: - Create Sync Request for Comment's
    func createSyncRequestForComment(dictArray: PENewAssessment) -> JSONDictionary {
        
        var UniID = dictArray.dataToSubmitID ?? ""
        
        if UniID == "" {
            UniID = dictArray.draftID ?? ""
        }
        
        var AssessmentId = dictArray.dataToSubmitNumber ?? 0
        if AssessmentId == 0 {
            AssessmentId = dictArray.draftNumber ?? 0
        }
        let DisplayId = "C-" + UniID
        
        var serverAssessmentId:Int64 = 0
        if let id = dictArray.serverAssessmentId {
            serverAssessmentId = Int64(id) ?? 0
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
    
    // MARK: - Create Sync Request for Image's
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
        let DisplayId = "C-" + UniID
        let base64Str = CoreDataHandlerPE().getImageBase64ByImageID(idArray:img)
        totalImageToSync.append(img)
        let imageName = "ImgName-" + siteId + String(img)
        let unique = "\(deviceIDFORSERVER)_\(String(img))_iOS_"
        
        let json = [
            "DisplayId":DisplayId.prefix(22),
            "Id": AssessmentId,
            "AssessmentDetailId": AssessmentId,
            "ModuleAssessmentId": dictArray.assID ?? 0,
            "Comment": dictArray.note ?? "",
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
    
    // MARK: - Create Sync Request for Inovoject's Data
    fileprivate func extractedFunc7(_ vNameArrayIS: NSArray, _ inovojectData: InovojectData, _ VaccineId: inout Int, _ vNameIDArrayIS: NSArray, _ ManufacturerId: inout Int, _ vNameMfgIdArrayIS: NSArray, _ otherVaccine: inout String) {
        if vNameArrayIS.contains(inovojectData.name) {
            let indexOfe = vNameArrayIS.index(of: inovojectData.name)
            VaccineId = vNameIDArrayIS[indexOfe] as? Int ?? 0
            ManufacturerId = vNameMfgIdArrayIS[indexOfe] as? Int ?? 0
        } else if (inovojectData.name != ""){
            otherVaccine = inovojectData.name ?? ""
        }
    }
    
    fileprivate func extractedFunc8(_ dictArray: PENewAssessment, _ score: inout Int) {
        if dictArray.assStatus == 1 {
            score = dictArray.assMaxScore ?? 0
        } else {
            score = dictArray.assMinScore ?? 0
        }
    }
    
    func createSyncRequestForInvoject(dictArray: PENewAssessment, inovojectData: InovojectData) -> JSONDictionary {
        let udid = UserDefaults.standard.string(forKey: "ApplicationIdentifier") ?? ""
        
        // Unique IDs
        let uniID = dictArray.dataToSubmitID?.isEmpty == false ? dictArray.dataToSubmitID! : (dictArray.draftID ?? "")
        let assessmentId = dictArray.dataToSubmitNumber != 0 ? dictArray.dataToSubmitNumber! : (dictArray.draftNumber ?? 0)
        let deviceIdForServer = "\(uniID)_\(assessmentId)_iOS_\(udid)"
        let displayId = "C-\(uniID)"
        
        var score = 0
        extractedFunc8(dictArray, &score)
        
        // Server Assessment ID
        let serverAssessmentId = Int64(dictArray.serverAssessmentId ?? "") ?? 0
        
        // Hatchery Antibiotics
        let hatcheryAntibiotics = inovojectData.invoHatchAntibiotic == 1
        let antibioticInformation = hatcheryAntibiotics ? (inovojectData.invoHatchAntibioticText ?? "") : ""
        
        // Ampule Size
        let ampleSizes = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
        let ampleSizeNames = ampleSizes.value(forKey: "size") as? [String] ?? []
        let ampleSizeIDs = ampleSizes.value(forKey: "id") as? [Int] ?? []
        
        var ampuleSizeId = 0
        if let ampuleSize = inovojectData.ampuleSize?.replacingOccurrences(of: " ", with: ""),
           let index = ampleSizeNames.firstIndex(of: ampuleSize) {
            ampuleSizeId = ampleSizeIDs[safe: index] ?? 0
        }
        
        // Vaccine Info
        let manufacturerData = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VManufacturer")
        let manufacturerNames = manufacturerData.value(forKey: "mfgName") as? [String] ?? []
        let manufacturerIDs = manufacturerData.value(forKey: "id") as? [Int] ?? []
        
        var vaccineId = 0
        if let vaccineMan = inovojectData.vaccineMan, let index = manufacturerNames.firstIndex(of: vaccineMan) {
            vaccineId = manufacturerIDs[safe: index] ?? 0
        }
        
        let vaccineNameData = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VNames")
        let vaccineNames = vaccineNameData.value(forKey: "name") as? [String] ?? []
        let vaccineIDs = vaccineNameData.value(forKey: "id") as? [Int] ?? []
        let vaccineMfgIDs = vaccineNameData.value(forKey: "mfgId") as? [Int] ?? []
        
        var manufacturerId = 0
        var otherVaccine = ""
        
        extractedFunc7(vaccineNames as NSArray, inovojectData, &vaccineId, vaccineIDs as NSArray, &manufacturerId, vaccineMfgIDs as NSArray, &otherVaccine)
        
        // Unique ID for this
        let unique = "\(deviceIdForServer)_\(inovojectData.id ?? 0)_iOS_"
        let ampulePerBag = Int(inovojectData.ampulePerBag ?? "0") ?? 0
        
        // JSON Output
        var json: JSONDictionary = [
            "VaccineId": vaccineId == 0 ? "" : vaccineId,
            "AmpulePerbag": ampulePerBag == 0 ? "" : ampulePerBag,
            "AmpuleSize": ampuleSizeId == 0 ? "" : ampuleSizeId,
            "AppAssessmentId": "\(assessmentId)",
            "BagSizeType": inovojectData.bagSizeType ?? "",
            "Device_Id": deviceIdForServer,
            "DiluentMfg": inovojectData.vaccineMan ?? "",
            "DisplayId": displayId.prefix(22),
            "HatcheryAntibiotics": hatcheryAntibiotics,
            "ManufacturerId": manufacturerId == 0 ? "" : manufacturerId,
            "ModuleAssessmentCatId": dictArray.catID ?? 0,
            "Dosage": inovojectData.dosage ?? "",
            "StrUniqueId": unique,
            "OtherText": otherVaccine,
            "SecquenceId": 0,
            "AntibioticInformation": antibioticInformation,
            "DiluentsMfgOtherName": inovojectData.doaDilManOther ?? "",
            "ProgramName": inovojectData.invoProgramName ?? "",
            "AssessmentId": serverAssessmentId
        ]
        
        // Remove empty fields
        if (inovojectData.doaDilManOther ?? "").isEmpty {
            json.removeValue(forKey: "DiluentsMfgOtherName")
        }
        if manufacturerId == 0 {
            json.removeValue(forKey: "ManufacturerId")
        }
        
        return json
    }
    
    
    // MARK: - Create Sync Request for DOA's Data
    func createSyncRequestForDOA(dictArray: PENewAssessment, dayOfAgeData: InovojectData) -> JSONDictionary {
        let udid = UserDefaults.standard.string(forKey: "ApplicationIdentifier") ?? ""
        
        // Unique IDs
        let uniID = dictArray.dataToSubmitID?.isEmpty == false ? dictArray.dataToSubmitID! : (dictArray.draftID ?? "")
        let assessmentId = dictArray.dataToSubmitNumber != 0 ? dictArray.dataToSubmitNumber! : (dictArray.draftNumber ?? 0)
        let deviceIdForServer = "\(uniID)_\(assessmentId)_iOS_\(udid)"
        
        let displayId = "C-\(uniID)"
        
        // Hatchery Antibiotics
        let hatcheryAntibiotics = dictArray.hatcheryAntibioticsDoa == 1
        let antibioticInformation = hatcheryAntibiotics ? (dictArray.hatcheryAntibioticsDoaText ?? "") : ""
        
        // Ampule Size
        let ampleSizes = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
        let ampleSizeNames = ampleSizes.value(forKey: "size") as? [String] ?? []
        let ampleSizeIDs = ampleSizes.value(forKey: "id") as? [Int] ?? []
        
        var ampuleSizeId = 0
        if let ampuleSize = dayOfAgeData.ampuleSize?.replacingOccurrences(of: " ", with: ""),
           let index = ampleSizeNames.firstIndex(of: ampuleSize) {
            ampuleSizeId = ampleSizeIDs[safe: index] ?? 0
        }
        
        // Vaccine Info
        let vaccineData = CoreDataHandlerPE().fetchDetailsForVaccineNames(typeId: 1)
        let vaccineNames = vaccineData.value(forKey: "name") as? [String] ?? []
        let vaccineIDs = vaccineData.value(forKey: "id") as? [Int] ?? []
        let vaccineMfgIDs = vaccineData.value(forKey: "mfgId") as? [Int] ?? []
        
        var vaccineId = 0
        var manufacturerId = 0
        var otherVaccine = ""
        
        if let name = dayOfAgeData.name, let index = vaccineNames.firstIndex(of: name) {
            vaccineId = vaccineIDs[safe: index] ?? 0
            manufacturerId = vaccineMfgIDs[safe: index] ?? 0
        } else if let name = dayOfAgeData.name, !name.isEmpty {
            otherVaccine = name
        }
        
        // Manufacturer override (based on vaccine manufacturer field)
        let manufacturerData = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VManufacturer")
        let manufacturerNames = manufacturerData.value(forKey: "mfgName") as? [String] ?? []
        let manufacturerIDs = manufacturerData.value(forKey: "id") as? [Int] ?? []
        
        if let vaccineMan = dayOfAgeData.vaccineMan, let index = manufacturerNames.firstIndex(of: vaccineMan) {
            manufacturerId = manufacturerIDs[safe: index] ?? manufacturerId
        }
        
        // Final ID
        let uniqueId = "\(deviceIdForServer)_\(dayOfAgeData.id ?? 0)_iOS_"
        
        // Assessment ID
        let serverAssessmentId = Int64(dictArray.serverAssessmentId ?? "") ?? 0
        
        // JSON Output
        let json: JSONDictionary = [
            "AppAssessmentId": "\(assessmentId)",
            "DayOfAgeAmpulePerbag": Int(dayOfAgeData.ampulePerBag ?? "0") ?? 0,
            "DayOfAgeAmpuleSize": ampuleSizeId == 0 ? "" : ampuleSizeId,
            "DayOfAgeBagSizeType": dictArray.dDT ?? "",
            "DayOfAgeMfgId": manufacturerId == 0 ? "" : manufacturerId,
            "DayOfAgeMfgNameId": vaccineId == 0 ? "" : vaccineId,
            "DayOfBagHatcheryAntibiotics": hatcheryAntibiotics,
            "Device_Id": deviceIdForServer,
            "DiluentMfg": dictArray.dCS ?? "",
            "DisplayId": displayId.prefix(22),
            "ModuleAssessmentCatId": dictArray.catID ?? 0,
            "DayOfAgeDosage": dayOfAgeData.dosage ?? "",
            "StrUniqueId": uniqueId,
            "OtherText": otherVaccine,
            "SecquenceId": 0,
            "AntibioticInformation": antibioticInformation,
            "AssessmentId": serverAssessmentId
        ]
        
        return json
    }
    
    
    func createSyncRequestForDOAS(dictArray: PENewAssessment, dayOfAgeData: InovojectData) -> JSONDictionary {
        let udid = UserDefaults.standard.string(forKey: "ApplicationIdentifier") ?? ""
        
        // IDs
        let uniID = dictArray.dataToSubmitID?.isEmpty == false ? dictArray.dataToSubmitID! : (dictArray.draftID ?? "")
        let assessmentId = dictArray.dataToSubmitNumber != 0 ? dictArray.dataToSubmitNumber! : (dictArray.draftNumber ?? 0)
        let serverAssessmentId = Int64(dictArray.serverAssessmentId ?? "") ?? 0
        let deviceIdForServer = "\(uniID)_\(assessmentId)_iOS_\(udid)"
        let displayId = "C-\(uniID)"
        
        // Hatchery Antibiotics
        let hatcheryAntibiotics = dictArray.hatcheryAntibioticsDoaS == 1
        let antibioticInformation = hatcheryAntibiotics ? (dictArray.hatcheryAntibioticsDoaSText ?? "") : ""
        
        // Ampule Size
        let ampleSizes = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
        let ampleSizeNames = ampleSizes.value(forKey: "size") as? [String] ?? []
        let ampleSizeIDs = ampleSizes.value(forKey: "id") as? [Int] ?? []
        
        var ampuleSizeId = 0
        if let ampuleSize = dayOfAgeData.ampuleSize?.replacingOccurrences(of: " ", with: ""),
           let index = ampleSizeNames.firstIndex(of: ampuleSize) {
            ampuleSizeId = ampleSizeIDs[safe: index] ?? 0
        }
        
        // Vaccine Info
        let vaccineData = CoreDataHandlerPE().fetchDetailsForVaccineNames(typeId: 2)
        let vaccineNames = vaccineData.value(forKey: "name") as? [String] ?? []
        let vaccineIDs = vaccineData.value(forKey: "id") as? [Int] ?? []
        let vaccineMfgIDs = vaccineData.value(forKey: "mfgId") as? [Int] ?? []
        
        var vaccineId = 0
        var manufacturerId = 0
        var otherVaccine = ""
        
        if let name = dayOfAgeData.name, let index = vaccineNames.firstIndex(of: name) {
            vaccineId = vaccineIDs[safe: index] ?? 0
            manufacturerId = vaccineMfgIDs[safe: index] ?? 0
        } else if let name = dayOfAgeData.name, !name.isEmpty {
            otherVaccine = name
        }
        
        // Manufacturer override
        let mfgData = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VManufacturer")
        let mfgNames = mfgData.value(forKey: "mfgName") as? [String] ?? []
        let mfgIDs = mfgData.value(forKey: "id") as? [Int] ?? []
        
        if let vaccineMan = dayOfAgeData.vaccineMan, let index = mfgNames.firstIndex(of: vaccineMan) {
            manufacturerId = mfgIDs[safe: index] ?? manufacturerId
        }
        
        // Ampule/bag
        let ampulePerBag = Int(dayOfAgeData.ampulePerBag ?? "0") ?? 0
        let unique = "\(deviceIdForServer)_\(dayOfAgeData.id ?? 0)_iOS_"
        
        // JSON Output
        var json: JSONDictionary = [
            "DayAgeSubcutaneousBagSizeType": dictArray.dDDT ?? "",
            "Device_Id": deviceIdForServer,
            "DisplayId": displayId.prefix(22),
            "ModuleAssessmentCatId": dictArray.catID ?? "",
            "StrUniqueId": unique,
            "SecquenceId": 0,
            "AppAssessmentId": "\(assessmentId)",
            "DayAgeSubcutaneousHatcheryAntibiotics": hatcheryAntibiotics,
            "DayAgeSubcutaneousMfgId": manufacturerId == 0 ? "" : manufacturerId,
            "DayAgeSubcutaneousDosage": dayOfAgeData.dosage ?? "",
            "DayAgeSubcutaneousMfgNameId": vaccineId == 0 ? "" : vaccineId,
            "OtherText": otherVaccine,
            "DayAgeSubcutaneousDiluentMfg": dictArray.dDCS ?? "",
            "DayAgeSubcutaneousAmpuleSize": ampuleSizeId == 0 ? "" : ampuleSizeId,
            "DayAgeSubcutaneousAmpulePerbag": ampulePerBag == 0 ? "" : ampulePerBag,
            "AntibioticInformation": antibioticInformation,
            "AssessmentId": serverAssessmentId
        ]
        
        return json
    }
    
    // MARK: - Create Sync Request for Certificate's
    func createSyncRequestForCertificateData(dictArray: PENewAssessment, peCertificateData: PECertificateData) -> JSONDictionary {
        
        let udid = UserDefaults.standard.string(forKey: "ApplicationIdentifier") ?? ""
        let uniID = dictArray.dataToSubmitID?.isEmpty == false ? dictArray.dataToSubmitID! : (dictArray.draftID ?? "")
        let assessmentId = dictArray.dataToSubmitNumber != 0 ? dictArray.dataToSubmitNumber! : (dictArray.draftNumber ?? 0)
        let serverAssessmentId = Int64(dictArray.serverAssessmentId ?? "") ?? 0
        let deviceIdForServer = "\(uniID)_\(assessmentId)_iOS_\(udid)"
        let displayId = "C-" + uniID
        let unique = "\(deviceIdForServer)_\(peCertificateData.id)_iOS_"
        
        // Format certification date
        let formattedDate: String = {
            if regionID != 3 {
                let formatter = DateFormatter()
                formatter.dateFormat = Constants.ddMMyyyStr
                if let rawDate = formatter.date(from: peCertificateData.certificateDate ?? "") {
                    formatter.dateFormat = yyymmdd
                    return formatter.string(from: rawDate)
                }
                return ""
            } else {
                return peCertificateData.certificateDate ?? ""
            }
        }()
        
        // Common JSON fields
        var json: JSONDictionary = [
            "Id": assessmentId,
            "AssessmentId": serverAssessmentId,
            "AssessmentDetailId": assessmentId,
            "ModuleAssessmentId": 0,
            "Name": peCertificateData.name ?? "",
            "CertificationDate": formattedDate,
            "AlternateName": "string",
            "CertificationDate2": appDelegateObj.date2020_05_23,
            "ModuleAssessmentCatId": dictArray.catID ?? 0,
            "userId": dictArray.userID ?? 0,
            "DeviceId": deviceIdForServer,
            "ResidueName": dictArray.residue ?? "",
            "MicroSamplesName": dictArray.micro ?? "",
            "EvaluationTypeId": 1,
            "AppAssessmentId": "\(assessmentId)",
            "DisplayId": displayId.prefix(22),
            "StrUniqueId": unique,
            "SignatureImg": peCertificateData.signatureImg ?? ""
        ]
        
        // Add region-specific fields
        if regionID == 3 {
            json["IsCertiExpired"] = peCertificateData.isCertExpired
            json["VacOperatorId"] = peCertificateData.vacOperatorId ?? 0
            json["IsRecert"] = peCertificateData.isReCert
        }
        
        return json
    }
    
    // MARK: - Create Sync Request for Residue's
    func createSyncRequestForResidueData(dictArray: PENewAssessment) -> JSONDictionary {
        let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier") as! String
        let uniID = dictArray.dataToSubmitID ?? dictArray.draftID ?? ""
        let assessmentId = dictArray.dataToSubmitNumber ?? dictArray.draftNumber ?? 0
        let serverAssessmentId = Int64(dictArray.serverAssessmentId ?? "") ?? 0
        let deviceIdForServer = "\(uniID)_\(assessmentId)_iOS_\(udid)"
        let displayId = "C-\(uniID)".prefix(22)
        let unique = "\(deviceIdForServer)_\(dictArray.residue)_iOS_"
        
        return [
            "AssessmentId": serverAssessmentId,
            "AssessmentDetailId": dictArray.assID ?? 0,
            "StrUniqueId": unique,
            "ModuleAssessmentId": dictArray.catID,
            "ResidueName": dictArray.residue,
            "MicroSamplesName": dictArray.micro,
            "EvaluationTypeId": 1,
            "AppAssessmentId": String(assessmentId),
            "DisplayId": displayId,
            "UserId": dictArray.userID,
            "CreatedAt": "2020-06-11T12:53:38.930Z",
            "DeviceId": deviceIdForServer,
            "ModuleAssessmentCatId": dictArray.catID
        ]
    }
    
    // MARK: - Create Sync Request for Microbial's Data
    func createSyncRequestForMicroData(dictArray: PENewAssessment) -> JSONDictionary {
        let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier") as! String
        let uniID = dictArray.dataToSubmitID ?? dictArray.draftID ?? ""
        let assessmentId = dictArray.dataToSubmitNumber ?? dictArray.draftNumber ?? 0
        let serverAssessmentId = Int64(dictArray.serverAssessmentId ?? "") ?? 0
        let deviceIdForServer = "\(uniID)_\(assessmentId)_iOS_\(udid)"
        let displayId = "C-\(uniID)".prefix(22)
        let unique = "\(deviceIdForServer)_\(dictArray.micro ?? "")_iOS_"
        
        return [
            "Id": assessmentId,
            "AssessmentId": serverAssessmentId,
            "AssessmentDetailId": dictArray.assID ?? 0,
            "ModuleAssessmentId": 0,
            "Name": "",
            "CertificationDate": "",
            "AlternateName": "string",
            "CertificationDate2": appDelegateObj.date2020_05_23,
            "ModuleAssessmentCatId": dictArray.catID,
            "userId": dictArray.userID,
            "DeviceId": deviceIdForServer,
            "ResidueName": dictArray.residue,
            "MicroSamplesName": dictArray.micro,
            "EvaluationTypeId": 1,
            "AppAssessmentId": String(assessmentId),
            "DisplayId": displayId,
            "StrUniqueId": unique
        ]
    }
    
    // MARK: - Create Sync Request for Assessment's
    fileprivate func handleAssessmentIdValidation(_ AssessmentId: inout Int, _ dict: PENewAssessment, _ Draft: inout Int, _ Complete: inout Int, _ SaveType: inout Int) {
        if AssessmentId == 0 {
            if dict.assDetail2?.lowercased().contains("_1_ios") ?? false{
                deviceIDFORSERVER = dict.assDetail2 ?? ""
            }
            AssessmentId = dict.draftNumber ?? 0
            Draft = 1
            Complete = 0
            SaveType = 0
            saveTypeString.append(00)
        }
    }
    
    fileprivate func handleSelectedTSRValidations(_ dict: PENewAssessment, _ visitNameArray: NSArray, _ TSRId: inout Int?, _ visitIDArray: NSArray) {
        if dict.selectedTSR?.count ?? 0 > 0,visitNameArray.contains(dict.selectedTSR ?? "") {
            let indexOfe =  visitNameArray.index(of: dict.selectedTSR ?? "") //
            TSRId = visitIDArray[indexOfe] as? Int ?? 0
        }
    }
    
    fileprivate func handleManufacturerValidation(_ man: inout String, _ dict: PENewAssessment, _ manOther: inout String) {
        if man != "",
           let character = dict.manufacturer?.character(at:0),
           character == "S" {
            let str =  man.replacingOccurrences(of: "S", with: "")
            manOther = str
            man = "Other"
        }
    }
    
    fileprivate func handleNoOfEggsValidation(_ xx: String, _ egggOther: inout String, _ eggg: inout String) {
        if xx != "0" {
            let last3 = String(xx.suffix(3))
            if last3 ==  "000" {
                let str =  xx.replacingOccurrences(of: "000", with: "")
                egggOther = str
                eggg = "Other"
            } else {
                eggg = xx
            }
        }
    }
    
    fileprivate func handleBreedOfBirdValidations(_ breeedd: inout String, _ breeeddOther: inout String) {
        if breeedd != "",
           let character = breeedd.character(at:0),
           character == "S".character(at: 0) {
            let str =  breeedd.replacingOccurrences(of: "S", with: "")
            breeeddOther = str
            breeedd = "Other"
        }
    }
    
    fileprivate func handleBase64ImageEncoding(_ sigNumber: Int, _ base64Str: inout String, _ dict: PENewAssessment, _ sigNumber2: Int, _ base64Str2: inout String) {
        if sigNumber == 0 {
            print(appDelegateObj.testFuntion())
        } else {
            base64Str = CoreDataHandlerPE().getImageBase64ByImageID(idArray:(dict.sig) ?? 0)
        }
        if sigNumber2 == 0 {
            print(appDelegateObj.testFuntion())
        } else {
            base64Str2 = CoreDataHandlerPE().getImageBase64ByImageID(idArray:(dict.sig2) ?? 0)
        }
    }
    
    fileprivate func modifyJsonWithValidation(_ regionId: Int, _ saveType: Int, _ dict: PENewAssessment, _ json: inout [String : Any]) {
        if regionId == 3 && saveType == 0 && dict.statusType == 2 {
            json["Status_Type"] = dict.statusType
        }
    }
    
    func createSyncRequest(dict: PENewAssessment, certificationData: [PECertificateData]) -> JSONDictionary {
        let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier") as! String
        let uniID = dict.dataToSubmitID ?? dict.draftID ?? ""
        let evaluationDate = dict.evaluationDate ?? ""
        var assessmentId = dict.dataToSubmitNumber ?? 0
        let deviceIdForServer = dict.assDetail2?.lowercased().contains("_1_ios") ?? false ? dict.assDetail2 ?? "" : "\(uniID)_1_iOS_\(udid)"
        let serverAssessmentId = Int64(dict.serverAssessmentId ?? "") ?? 0
        let visitId = dict.visitID
        let customerId = dict.customerId
        let siteId = dict.siteId
        let incubationStyle = dict.incubation
        let evaluationId = dict.evaluationID
        let evaluatorId = dict.evaluatorID
        let hatcheryAntibiotics = dict.hatcheryAntibiotics == 1
        var tsrId = dict.selectedTSRID
        let countryId = UserDefaults.standard.integer(forKey: "nonUScountryId")
        let camera = dict.camera == 1
        let fluid = dict.fluid ?? false
        let basicTransfer = dict.basicTransfer ?? false
        let regionId = UserDefaults.standard.integer(forKey: "Regionid")
        let isEMRequested = dict.IsEMRequested ?? false
        let extndMicro = dict.extndMicro ?? false
        let isHandMix = dict.isHandMix ?? false
        
        // Handle TSR validation
        let visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Approvers")
        let visitNameArray = visitDetailsArray.value(forKey: "username") as? NSArray ?? NSArray()
        let visitIDArray = visitDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        handleSelectedTSRValidations(dict, visitNameArray, &tsrId, visitIDArray)
        
        // Handle manufacturer, eggs, and breed
        var manufacturer = dict.manufacturer ?? ""
        var manufacturerOther = ""
        handleManufacturerValidation(&manufacturer, dict, &manufacturerOther)
        
        var eggs = ""
        var eggsOther = ""
        let noOfEggs = String(dict.noOfEggs ?? 000)
        handleNoOfEggsValidation(noOfEggs, &eggsOther, &eggs)
        
        var breed = dict.breedOfBird ?? ""
        var breedOther = dict.breedOfBirdOther ?? ""
        handleBreedOfBirdValidations(&breed, &breedOther)
        
        // Fetch IDs for manufacturer, eggs, and breed
        let manufacturerDetails = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Manufacturer")
        let manufacturerNameArray = manufacturerDetails.value(forKey: "mFG_Name") as? NSArray ?? NSArray()
        let manufacturerIDArray = manufacturerDetails.value(forKey: "mFG_Id") as? NSArray ?? NSArray()
        let manufacturerId = manufacturer != "" ? manufacturerIDArray[manufacturerNameArray.index(of: manufacturer)] as? Int ?? 0 : 0
        
        let birdBreedDetails = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_BirdBreed")
        let birdBreedNameArray = birdBreedDetails.value(forKey: "birdBreedName") as? NSArray ?? NSArray()
        let birdBreedIDArray = birdBreedDetails.value(forKey: "birdId") as? NSArray ?? NSArray()
        let breedId = breed != "" ? birdBreedIDArray[birdBreedNameArray.index(of: breed)] as? Int ?? 0 : 0
        
        let eggsDetails = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Eggs")
        let eggsNameArray = eggsDetails.value(forKey: "eggCount") as? NSArray ?? NSArray()
        let eggsIDArray = eggsDetails.value(forKey: "eggId") as? NSArray ?? NSArray()
        let eggId = eggs != "" ? eggsIDArray[eggsNameArray.index(of: eggs)] as? Int ?? 0 : 0
        
        // Handle assessment validation
        var draft = 0
        var complete = 1
        var saveType = 1
        handleAssessmentIdValidation(&assessmentId, dict, &draft, &complete, &saveType)
        
        // Handle signature and date
        let sigDate = dict.sig_Date != "" ? convertDateFormat(inputDate: dict.sig_Date ?? "") : ""
        var base64Str = ""
        var base64Str2 = ""
        handleBase64ImageEncoding(dict.sig ?? 0, &base64Str, dict, dict.sig2 ?? 0, &base64Str2)
        
        // Handle incubation style
        let incubationDetails = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_IncubationStyle")
        let incubationNameArray = incubationDetails.value(forKey: "incubationStylesName") as? NSArray ?? NSArray()
        let incubationIDArray = incubationDetails.value(forKey: "incubationId") as? NSArray ?? NSArray()
        let incubationId = incubationStyle != nil ? incubationIDArray[incubationNameArray.index(of: incubationStyle ?? "")] as? Int ?? 0 : 0
        
        // Handle roles
        let roleDetails = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Roles")
        let roleNameArray = roleDetails.value(forKey: "roleName") as? NSArray ?? NSArray()
        let roleIDArray = roleDetails.value(forKey: "roleId") as? NSArray ?? NSArray()
        let roleId = dict.sig_EmpID?.count ?? 0 > 1 ? roleIDArray[roleNameArray.index(of: dict.sig_EmpID ?? "")] as? Int ?? 0 : 0
        let roleId2 = dict.sig_EmpID2?.count ?? 0 > 1 ? roleIDArray[roleNameArray.index(of: dict.sig_EmpID2 ?? "")] as? Int ?? 0 : 0
        
        // Format evaluation date
        let dateFormatter = CodeHelper.sharedInstance.getDateFormatterObj("")
        dateFormatter.dateFormat = regionId == 3 ? appDelegateObj.MMddyyyStr : Constants.ddMMyyyStr
        let evalDateObj = dateFormatter.date(from: evaluationDate)
        dateFormatter.dateFormat = "yyyyMMdd"
        let evalDateStr = dateFormatter.string(from: evalDateObj ?? Date())
        
        // Handle FSR signature
        let fsrSign = certificationData.first?.fsrSign ?? ""
        
        // Construct JSON
        var json: JSONDictionary = [
            "AppAssessmentId": String(assessmentId),
            "DisplayId": "C-\(uniID)".prefix(22),
            "VisitId": visitId,
            "CustomerId": customerId,
            "SiteId": siteId,
            "IncubationStyle": incubationId,
            "EvaluationId": evaluationId,
            "BreedBirds": breedId == 0 ? "" : breedId,
            "EvaluationDate": evalDateStr,
            "EvaulaterId": evaluatorId ?? 0,
            "TSRId": tsrId,
            "Camera": camera,
            "ManufacturerId": manufacturerId == 0 ? "" : manufacturerId,
            "EggsPerFlat": eggId == 0 ? "" : eggId,
            "Notes": dict.notes,
            "FlockAgeId": dict.isFlopSelected == 0 ? "" : dict.isFlopSelected,
            "SaveType": saveType,
            "UserId": dict.userID,
            "DeviceId": deviceIdForServer,
            "RepresentativeName": dict.sig_Name,
            "RepresentativeName2": dict.sig_Name2,
            "RepresentativeNotes": dict.sig_Phone,
            "SignatureImage": base64Str,
            "SignatureImage2": base64Str2,
            "ManufacturerOther": manufacturerOther,
            "BreedOfBirdsOther": breedOther,
            "EggsPerFlatOther": eggsOther,
            "RoleId": roleId,
            "RoleId2": roleId2 == 0 ? "" : roleId2,
            "EvaluationTypeText": dict.evaluationName,
            "AppCreationTime": uniID.prefix(22),
            "SignatureDate": sigDate,
            "AssessmentId": serverAssessmentId,
            "DoubleSanitation": hatcheryAntibiotics,
            "SanitationEmbrex": regionId == 3 ? dict.sanitationValue : false,
            "HasChlorineStrips": dict.isChlorineStrip ?? false,
            "IsAutomaticFail": dict.isAutomaticFail ?? false,
            "FSTSignatureImage": fsrSign,
            "IsEMRequested": isEMRequested,
            "RefrigeratorNote": regionId == 3 ? dict.refrigeratorNote ?? "" : UserDefaults.standard.value(forKey: "re_note") as? String ?? "",
            "RegionId": regionId,
            "IsInterMicrobial": extndMicro,
            "CountryId": countryId,
            "IsInovoFluids": fluid,
            "IsBasicTrfAssessment": basicTransfer,
            "ChlorineId": dict.clorineId,
            "Handmix": isHandMix
        ]
        
        modifyJsonWithValidation(regionId, saveType, dict, &json)
        
        return json
    }
    
    // MARK: - Post Request for Extended Microbial's
    fileprivate func extractedFunc9(_ statusType: inout Int, _ dict: PENewAssessment, _ json: inout [String : Any], _ serverAssessmentId: Int64, _ UserId: Int?, _ EvaluationId: Int?, _ saveType: Int, _ isEMRequested: Bool, _ appVersion: String, _ extendedData: [[String : Any]]?) {
        
        json = [
            "AssessmentId":serverAssessmentId,
            "DeviceId": deviceIDFORSERVER,
            "UserId": UserId,
            "EvaluationId": EvaluationId ?? 0,
            "SaveType":saveType,
            "Status_Type":statusType,
            "IsEMRequested" : isEMRequested,
            "IsSendEmail": true,
            "appVersion": appVersion,
            "SanitationEmbrexScoresDataModel":extendedData
        ] as JSONDictionary
        
        if statusType == 2 {
            if dict.isEMRejected == true  || dict.isPERejected == true {
                statusType = 0
            }
            json["Status_Type"] = statusType
        }
    }
    
    fileprivate func extractedFunc10(_ json: inout [String : Any], _ serverAssessmentId: Int64, _ UserId: Int?, _ EvaluationId: Int?, _ isEMRequested: Bool, _ appVersion: String, _ extendedData: [[String : Any]]?) {
        
        json = [
            "AssessmentId":serverAssessmentId,
            "DeviceId": deviceIDFORSERVER,
            "UserId": UserId ?? 0,
            "EvaluationId": EvaluationId ?? 0,
            "SaveType":0,
            "Status_Type":0,
            "IsEMRequested" : isEMRequested,
            "IsSendEmail": true,
            "appVersion": appVersion,
            "SanitationEmbrexScoresDataModel":extendedData
        ] as JSONDictionary
        
        if Constants.isAssessmentRejected == true {
            json["SaveType"] = 0
        } else {
            json["SaveType"] = 1
        }
    }
    
    fileprivate func extractedFunc11(_ json: inout [String : Any], _ serverAssessmentId: Int64, _ UserId: Int?, _ EvaluationId: Int?, _ isEMRequested: Bool, _ appVersion: String, _ extendedData: [[String : Any]]?) {
        
        json = [
            "AssessmentId":serverAssessmentId,
            "DeviceId": deviceIDFORSERVER,
            "UserId": UserId,
            "EvaluationId": EvaluationId ?? 0,
            "SaveType":0,
            "Status_Type":0,
            "IsEMRequested" : isEMRequested,
            "IsSendEmail": true,
            "appVersion": appVersion,
            "SanitationEmbrexScoresDataModel":extendedData
        ] as JSONDictionary
        
        if Constants.isAssessmentRejected == true {
            json["SaveType"] = 0
        } else {
            json["SaveType"] = 1
        }
    }
    
    fileprivate func extractedFunc12(_ json: inout [String : Any], _ serverAssessmentId: Int64, _ UserId: Int?, _ EvaluationId: Int?, _ isEMRequested: Bool, _ appVersion: String, _ extendedData: [[String : Any]]?) {
        json = [
            "AssessmentId":serverAssessmentId,
            "DeviceId": deviceIDFORSERVER,
            "UserId": UserId ?? 0,
            "EvaluationId": EvaluationId ?? 0,
            "SaveType":1,
            "Status_Type":0,
            "IsEMRequested" : isEMRequested,
            "IsSendEmail": true,
            "appVersion": appVersion,
            "SanitationEmbrexScoresDataModel":extendedData
        ] as JSONDictionary
    }
    
    fileprivate func assesmentIdCOnfigure(_ AssessmentId: inout Int, _ dict: PENewAssessment, _ Draft: inout Int, _ Complete: inout Int) {
        if AssessmentId == 0 {
            if dict.assDetail2?.lowercased().contains("_1_ios") ?? false{
                deviceIDFORSERVER = dict.assDetail2 ?? ""
            }
            AssessmentId = dict.draftNumber ?? 0
            Draft = 1
            Complete = 0
            saveTypeString.append(00)
        }
    }
    
    func createSyncRequestForExtendedMicro(dict: PENewAssessment ,certificationData : [PECertificateData], saveType: Int) -> JSONDictionary{
        debugPrint("dict---\(dict)")
        var idArr = [String]()
        for val in tempArr {
            let id = val["AssessmentId"] as? Int64 ?? 0
            if id != 0{
                idArr.append("\(id)")
            }
        }
        var arr = [PESanitationDTO]()
        for id in idArr {
            let tempPEArr = SanitationEmbrexQuestionMasterDAO.sharedInstance.sendExtendedPEFilledDTO(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", assessmentId: id)
            arr.append(contentsOf: tempPEArr)
        }
        var extendedData : [[String: Any]]?
        let jsonEncoder = JSONEncoder()
        let jsonDataArr = try? jsonEncoder.encode(arr)
        if jsonDataArr != nil {
            extendedData = try? JSONSerialization.jsonObject(with: jsonDataArr!, options: []) as? [[String: Any]]
        }
        var Complete = 1
        var Draft = 0
        if saveType == 1 {
            saveTypeString.append(11)
            
        }
        var AssessmentId = dict.dataToSubmitNumber ?? 0
        assesmentIdCOnfigure(&AssessmentId, dict, &Draft, &Complete)
        var serverAssessmentId:Int64 = 0
        if dict.serverAssessmentId != nil{
            serverAssessmentId = Int64( dict.serverAssessmentId ?? "") ?? 0
        }
        let EvaluationId = dict.evaluationID
        let UserId = dict.userID
        var statusType = dict.statusType ?? 0
        var json : JSONDictionary = JSONDictionary()
        
        let isEMRequested = dict.IsEMRequested ?? false
        let appVersion = "\(Bundle.main.versionNumber)"
        tempArr.removeAll()
        
        if saveType == 0 {
            extractedFunc9(&statusType, dict, &json, serverAssessmentId, UserId, EvaluationId, saveType, isEMRequested, appVersion, extendedData)
        } else {
            if dict.isPERejected == true && dict.isEMRejected == true {
                extractedFunc10(&json, serverAssessmentId, UserId, EvaluationId, isEMRequested, appVersion, extendedData)
            } else if dict.isPERejected == false && dict.isEMRejected == true {
                extractedFunc11(&json, serverAssessmentId, UserId, EvaluationId, isEMRequested, appVersion, extendedData)
            } else if dict.isPERejected == true && dict.isEMRejected == false {
                extractedFunc12(&json, serverAssessmentId, UserId, EvaluationId, isEMRequested, appVersion, extendedData)
            } else {
                json = [
                    "AssessmentId":serverAssessmentId,
                    "DeviceId": deviceIDFORSERVER,
                    "UserId": UserId ?? 0,
                    "EvaluationId": EvaluationId ?? 0,
                    "SaveType":saveType,
                    "Status_Type":statusType,
                    "IsEMRequested" : isEMRequested,
                    "IsSendEmail": true,
                    "appVersion": appVersion,
                    "SanitationEmbrexScoresDataModel":extendedData
                ] as JSONDictionary
            }
            Constants.isAssessmentRejected = false
        }
        return json
    }
    
    // MARK: - Logout Action
    func logoutAction() {
        self.ssologoutMethod()
        UserDefaults.standard.set(false, forKey: "newlogin")
        UserDefaults.standard.set(false, forKey: "hasPEDataLoaded")
        for controller in (self.navigationController?.viewControllers ?? []) as Array {
            if controller.isKind(of: ViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    // MARK:  /*********** Logout SSO Account **************/
    func ssologoutMethod() {
        gigya.logout() { result in
            switch result {
            case .success(let data):
                debugPrint(data)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    //    // MARK: - Date Formatter
    
    
    
    // MARK: - Date Formatter
    func convertDateFormat(inputDate: String) -> String {
        let olDateFormatter = DateFormatter()
        olDateFormatter.dateFormat = appDelegateObj.mmddyyStr
        let oldDate = olDateFormatter.date(from: inputDate)
        let convertDateFormatter = DateFormatter()
        convertDateFormatter.dateFormat = yyymmdd
        
        if oldDate != nil {
            return convertDateFormatter.string(from: oldDate!)
        }
        return ""
    }
    
    
    // MARK: - Date Formatter
    func convertSign_DateFormat(inputDate: String) -> String {
        let olDateFormatter = DateFormatter()
        olDateFormatter.dateFormat = appDelegateObj.mmddyyStr
        let oldDate = olDateFormatter.date(from: inputDate)
        let convertDateFormatter = DateFormatter()
        convertDateFormatter.dateFormat = yyymmdd
        
        let regionId = UserDefaults.standard.integer(forKey: "Regionid")
        if regionId != 3 {
            convertDateFormatter.calendar = Calendar(identifier: .gregorian)
            convertDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            convertDateFormatter.dateFormat = yyymmdd
        } else {
            convertDateFormatter.dateFormat = appDelegateObj.MMddyyyStr
        }
        
        if oldDate != nil {
            return convertDateFormatter.string(from: oldDate!)
        }
        return ""
    }
}

// MARK: - EXTENSION FOR STRING TO DATE

extension String {
    
    func toDate(withFormat format: String = Constants.MMddYYYYHHmmss)-> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: appDelegateObj.asiaTehran)
        dateFormatter.locale = Locale(identifier: "fa-IR")
      //  dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
}

// MARK: - EXTENSION FOR DATE TO STRING

extension Date {
    
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    func toString(withFormat format: String = Constants.MMddYYYYHHmmss) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "fa-IR")
        dateFormatter.timeZone = TimeZone(identifier: appDelegateObj.asiaTehran)
        dateFormatter.calendar = Calendar(identifier: .persian)
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        return str
    }
    
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
}

// MARK: - EXTENSION FOR TABLE VIEW DATA SOURCE AND DELEGATES

extension PEDashboardViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingCertificationsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: VaccinationCertificationsTableViewCell.identifier, for: indexPath) as? VaccinationCertificationsTableViewCell{
            cell.removeBtnVw()
            if upcomingCertificationsArr.count > 0 && indexPath.row < upcomingCertificationsArr.count{
                
                cell.setPEValues(vaccinationCertificatonObj:upcomingCertificationsArr[indexPath.row] )
                if upcomingCertificationsArr.count - 1 == indexPath.row{
                    cell.layer.masksToBounds = true
                    cell.contentView.roundVsCorners(corners: [.bottomLeft, .bottomRight], radius: 18.5)
                } else{
                    cell.contentView.roundVsCorners(corners: [.bottomLeft, .bottomRight], radius: 0)
                }
            }else{
                
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    fileprivate func extractedFunc13(_ assessment: PENewAssessment, _ assessmentId: String) {
        let delete = CoreDataHandlerPE().deleteDraftAndMoveToSessionInProgress(assessment.draftNumber!)
        if delete {
            if self.anyCategoryContainValueOrNot(serverAssessmentId:assessmentId){
                let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "PEDraftAssesmentFinalize") as! PEDraftAssesmentFinalize
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                
                if regionID == 3 {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "PEDraftStartNewAssessment") as! PEDraftStartNewAssessment
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "PEDraftStartNewAssesmentINT") as! PEDraftStartNewAssesmentINT
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    fileprivate func extractedFunc14(_ indexPath: IndexPath) {
        if regionID == 3 {
            let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PEStartNewAssessment") as! PEStartNewAssessment
            vc.navigationController?.navigationBar.isHidden = true
            vc.scheduledAssessment = upcomingCertificationsArr[indexPath.row]
            vc.scheduledAssessment?.scheduledDate = Date()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PEStartNewAssessmentINT") as! PEStartNewAssessmentINT
            vc.scheduledAssessment = upcomingCertificationsArr[indexPath.row]
            vc.scheduledAssessment?.scheduledDate = Date()
            let pervioudAssesID = UserDefaults.standard.value(forKey: "assIID") as? String ?? ""
            if(pervioudAssesID  != upcomingCertificationsArr[indexPath.row].serverAssessmentId){
                UserDefaults.standard.set(upcomingCertificationsArr[indexPath.row].refrigeratorNote ?? "", forKey:"re_note")
                UserDefaults.standard.set(upcomingCertificationsArr[indexPath.row].assID ,forKey:"assIID")
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Constants.isPPmValueChanged = false
        Constants.switchCount = 0
        
        if upcomingCertificationsArr.count > 0 && upcomingCertificationsArr.count > indexPath.row,
           let assessmentId = upcomingCertificationsArr[indexPath.row].serverAssessmentId {
            
                UserDefaults.standard.set(assessmentId , forKey: "currentServerAssessmentId")
                let userDefault = UserDefaults.standard
                userDefault.set(upcomingCertificationsArr[indexPath.row].customerId, forKey: "PE_Selected_Customer_Id")
                userDefault.set(upcomingCertificationsArr[indexPath.row].customerName, forKey: "PE_Selected_Customer_Name")
                userDefault.set(upcomingCertificationsArr[indexPath.row].siteId, forKey: "PE_Selected_Site_Id")
                userDefault.set(upcomingCertificationsArr[indexPath.row].siteName, forKey: "PE_Selected_Site_Name")
                
                if let assessment = PEAssessmentsDAO.sharedInstance.getDraftAssessment(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", serverAssessmentId: assessmentId) {
                    
                    extractedFunc13(assessment, assessmentId)
                } else {
                    
                    if anyCategoryContainValueOrNot(serverAssessmentId: assessmentId) {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "PEStoryboard", bundle:nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "PEAssesmentFinalize") as! PEAssesmentFinalize
                        vc.scheduledAssessment = upcomingCertificationsArr[indexPath.row]
                        vc.scheduledAssessment?.scheduledDate = Date()
                        let pervioudAssesID = UserDefaults.standard.value(forKey: "assIID") as? String ?? ""
                        if(pervioudAssesID  != upcomingCertificationsArr[indexPath.row].serverAssessmentId){
                            UserDefaults.standard.set(upcomingCertificationsArr[indexPath.row].refrigeratorNote ?? "", forKey:"re_note")
                            UserDefaults.standard.set(upcomingCertificationsArr[indexPath.row].assID ,forKey:"assIID")
                        }
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        
                        extractedFunc14(indexPath)
                    }
                }
        }
    }
}

// MARK: - EXTENSION FOR CALLING API'S

extension PEDashboardViewController{
    // MARK: - Add operations
    func addOperations(){
        
        let isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn_successful") as? Bool
        let isFromGlobalDashboard = UserDefaults.standard.value(forKey: "OnGlobalFromPE") as? Bool ?? false
        
        if isLoggedIn ?? false{
            UserDefaults.standard.setValue(false, forKey: "dontGetRejectedAssessment")
            UserDefaults.standard.set(false, forKey: "isLoggedIn_successful")
            UserDefaults.standard.setValue(false, forKey: "OnGlobalFromPE")
            UserDefaults.standard.synchronize()
            if ConnectionManager.shared.hasConnectivity() {
                self.showGlobalProgressHUDWithTitle(self.view, title: appDelegateObj.loadingStr)
                self.fetchAllCustomer()
            }else{
                self.dismissGlobalHUD(self.view ?? UIView())
            }
        } else {
            if isFromGlobalDashboard {
                
                UserDefaults.standard.setValue(true, forKey: "haveToCallGetPosting")
                UserDefaults.standard.setValue(false, forKey: "OnGlobalFromPE")
                self.showGlobalProgressHUDWithTitle(self.view, title: appDelegateObj.loadingStr)
                self.getRejectedAssessmentListByUser()
            }
        }
    }
    // MARK: - Get Blank PDF Files
    private func getBlankAssessmentFiles(){
        if CodeHelper.sharedInstance.reachability?.connection != .unavailable{
            
            let jsonDict = ["ReportType" : "1"]
            if let theJSONData = try? JSONSerialization.data( withJSONObject: jsonDict, options: .prettyPrinted),
               let theJSONText = String(data: theJSONData, encoding: String.Encoding.ascii) {
                debugPrint("SNA Json = \n\(theJSONText)")
            }
            
            ZoetisWebServices.shared.getBlankAssessmentFiles(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let self = self, error == nil else { return }
                self.handleBlankAssessmentResponse(json)
            })
            
        } else {
            Helper.showAlertMessage(self, titleStr: NSLocalizedString(Constants.alertStr, comment: ""), messageStr: NSLocalizedString("You are currently offline. Please go online to download PDF.", comment: ""))
        }
    }
    
    // MARK: - Get All Customer's List
    func fetchAllCustomer(){
        if ConnectionManager.shared.hasConnectivity() {
            let countryId = UserDefaults.standard.integer(forKey: "nonUScountryId")
            ZoetisWebServices.shared.getCustomerListForPE(controller: self, countryID: String(countryId), parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handlefetchAllCustomerResponse(json)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Customer's list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Dosages's List
    private func fetchAllDoses(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getPEDosagesListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handlefetchAllDosesResponse(json)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Dosages list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Countries List
    private func fetchAllCountries(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getCountryForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handlefetchAllCountriesResponse(json)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Countries list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Evaluator's Type List
    private func fetchEvaluator(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getEvaluatorListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handleFetchEvaluatorResponse(json)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Evaluator's list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Approver's List
    private func fetchApprovers(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getApproversListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handleFetchApproversResponse(json)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Approver's list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Visit type List
    private func fetchVisitTypes(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getVisitTypesListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handleFetchVisitTypesResponse(json)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Visit type list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Evaluation's types List
    private func fetchEvaluationTypes(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getEvaluatorTypesListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handleFetchEvaluationTypesResponse(json)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Evaluation type list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Site's List
    private func fetchSites(_ isEverytime:Bool = false){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getSitesListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handleFetchSitesResponse(json, isEverytime)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Sites list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Assessment's Category Responce
    fileprivate func handleVaccineCertificate(_ jsonData: Data?, _ jsonDecoder: JSONDecoder) {
        if let data = jsonData {
            let vaccinationCertificationObj = try? jsonDecoder.decode([ExtendedPECategoryDTO].self, from: data)
            
            if vaccinationCertificationObj != nil && vaccinationCertificationObj?.count ?? 0 > 0 {
                let index = vaccinationCertificationObj?.firstIndex(where: {
                    $0.id == 36
                })
                if index != nil {
                    let embrex =  vaccinationCertificationObj![index!]
                    SanitationEmbrexQuestionMasterDAO.sharedInstance.saveExtendedPEQuestions(userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "", plateTypeDTO: [embrex])
                }
            }
        }
    }
    
    fileprivate func handleResponseJSONDict(_ json: JSON) {
        let mainQueue = OperationQueue.main
        mainQueue.addOperation {
            if let responseJSONDict = json.dictionary,let response = responseJSONDict["Data"] {
                let jsonDecoder = JSONDecoder()
                let responseStr = response.description
                if responseStr != "" {
                    let jsonData = try? Data(responseStr.utf8)
                    self.handleVaccineCertificate(jsonData, jsonDecoder)
                }
            }
            self.handleAssessmentCategoriesResponse(json)
        }
    }
    
    internal func fetchtAssessmentCategoriesResponse(){
        if ConnectionManager.shared.hasConnectivity() {
            var evalTypeId = ""
            let regionId = UserDefaults.standard.integer(forKey: "Regionid")
            evalTypeId = String(peNewAssessment?.evalType?.id ?? 1)

            if regionId == 3 {
                evalTypeId = String(peNewAssessment?.evalType?.id ?? 0)
            }
            
            ZoetisWebServices.shared.getAssessmentCategoriesDetailsPE(controller: self, evalType:evalTypeId, moduleID: "1"  , parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handleResponseJSONDict(json)
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Question's List", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Question's Info
    internal func fetchtQuestionInfo(){
        if ConnectionManager.shared.hasConnectivity(){
            let evalTypeId = String(peNewAssessment?.evalType?.id ?? 1)
            ZoetisWebServices.shared.getAssessmentQuesInfoPE(controller: self, evalType:evalTypeId, moduleID: "1"  , parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchtQuestionInfo(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Questions's info", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Manufacturer's List
    private func fetchManufacturer(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getManufacturerListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchManufacturerResponse(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Manufacturer list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Bird's List
    private func fetchBirdBreed(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getBirdBreedListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchBirdBreedResponse(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Bird Breed list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get Eggs List
    private func fetchEggs(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getEggsListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchEggsResponse(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Eggs count list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Vaccine Manufacturer's List
    private func fetchVManufacturer(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getVaccineManufacturerListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchVManufacturerResponse(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Vaccine manufacture list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Vaccine Name's List
    private func fetchVaccineNames(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getVaccineNamesListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchVaccineNamesResponse(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Vaccines list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Diluent Manufacturer's List
    private func fetchDiluentManufacturer(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getDiluentManufacturerList(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchDiluentManufacturer(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Diluent Manufacture list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    // MARK: - Get All Bag' Sizes List
    private func fetchBagSizes(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getBagSizes(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchBagSizes(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Bag size list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    private func getBagSizes(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getBagSizes(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handleGetBagSizes(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Bag size list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    // MARK: - Get All Ample Size Bag's List
    private func fetchAmplePerBag(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getAmplePerBag(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchAmplePerBag(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Ample per bag Size list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    
    private func getAmplePerBag(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getAmplePerBag(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handleGetAmplePerBag(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Ample per bag Size list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get Ample Size's List
    private func fetchAmpleSizes(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getAmpleSizes(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchAmpleSizes(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Ample Size list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    private func getAmpleSizes(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getAmpleSizes(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlegettingfetchAmpleSizes(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Ample Size list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    // MARK: - Get All Role's List
    private func fetchRoles() {
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getPERoles(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchRoles(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Role list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All DOA Diluent's Type List
    private func fetchDOADiluentType(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getPEDOADiluentType(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchDOADiluentType(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Diluent type list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Sub Vaccine's List
    private func fetchSubVaccineNames(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getVaccineSubNamesListForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchSubVaccineNamesResponse(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Sub vaccines list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All PE Frequencie's List
    private func fetchPEFrequency(){
        if ConnectionManager.shared.hasConnectivity(){
            ZoetisWebServices.shared.getPEFrequency(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchPEFrequency(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get PE Frequency list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All Incubation Style's List
    private func fetchIncubationStyle(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getPEIncubationStyle(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchIncubationStyle(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Incubation list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get All DOA Size's List
    private func fetchDOASizes(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getPEDOASizes(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlefetchDOASizes(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get DOA Size list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get Posted assessment List
    private func getPostingAssessmentListByUser(){
        self.showGlobalProgressHUDWithTitle(self.view, title: appDelegateObj.loadingStr)
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getPostedAssmntListByUser(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlGetPostingAssessmentListByUser(json)
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Posting Assessment list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - Get Images of Posted assessment
    private func getPostingAssessmentImagesListByUser(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getPostingImagesListByUser(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                let mainQueue = OperationQueue.main
                mainQueue.addOperation{
                    self?.handlGetPostingAssessmentImagesListByUser(json)
                    UserDefaults.standard.set(true, forKey: "hasPEDataLoaded")
                    UserDefaults.standard.set(true, forKey: "hasPELoadedPrevData")
                }
            })
        }else{
            self.showToastWithTimer(message: "Failed to get Posted assessment images list", duration: 3.0)
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    // MARK: - Get Rejected assessment List
    private func getRejectedAssessmentListByUser(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getRejectedAssessmentListByUser(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handlGetRejectedAssessmentListByUser(json)
            })
        }else{
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    // MARK: - Get Scheduled assessment List
    fileprivate func extractedFunc15(_ status: String?) {
        let mainQueue = OperationQueue.main
        mainQueue.addOperation{
            if status == VaccinationConstants.VaccinationStatus.COREDATA_SAVED_SUCCESSFULLY || status == VaccinationConstants.VaccinationStatus.COREDATA_FETCHED_SUCCESSFULLY {
                self.upcomingCertificationsArr = PEAssessmentsDAO.sharedInstance.getVMObj(userId:UserContext.sharedInstance.userDetailsObj?.userId ?? "")
                if self.upcomingCertificationsArr.count > 0 {
                    self.alertLbl.isHidden = true
                } else {
                    self.alertLbl.isHidden = false
                }
                self.popupTblVw.reloadData()
                self.dashboardTblVw.reloadData()
            }
        }
    }
    
    private func getScheduledAssessments() {
        if ConnectionManager.shared.hasConnectivity() {
            PEDataService.sharedInstance.getScheduledAssessments(loginuserId: UserContext.sharedInstance.userDetailsObj?.userId ?? noIdFound, viewController: self, completion: { [weak self] (status, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView());
                    return
                }
                self?.extractedFunc15(status)
                self?.peHeaderViewController.titleofSync = "0"
                self?.peHeaderViewController.viewDidLoad()
                self?.dismissGlobalHUD(self?.view ?? UIView())
                
                if self?.regionID == 3 {
                    let callGetPosting = UserDefaults.standard.value(forKey: "haveToCallGetPosting") as? Bool
                    if callGetPosting ?? false {
                        
                        UserDefaults.standard.setValue(false, forKey: "haveToCallGetPosting")
                        UserDefaults.standard.setValue(true, forKey: "dontGetRejectedAssessment")
                        self?.getPostingAssessmentListByUser()
                    }
                }
            })
        } else {
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    
    fileprivate func handleDayOfAgeSData(_ obj: PENewAssessment) {
        self.dayOfAgeSData.removeAll()
        if obj.doaS.count > 0 {
            var idArr : [Int] = []
            for objn in  obj.doaS {
                let data = CoreDataHandlerPE().getPEDOAData(doaId: objn)
                if data != nil,!idArr.contains(data!.id ?? 0) {
                    idArr.append(data!.id ?? 0)
                    if data != nil {
                        self.dayOfAgeSData.append(data!)
                    }
                }
            }
        }
    }
    
    fileprivate func handleDayOfAgeDataValidations(_ obj: PENewAssessment) {
        self.dayOfAgeData.removeAll()
        if obj.doa.count > 0 {
            var idArr : [Int] = []
            for objn in  obj.doa {
                let data = CoreDataHandlerPE().getPEDOAData(doaId: objn)
                if data != nil,!idArr.contains(data!.id ?? 0) {
                    idArr.append(data!.id ?? 0)
                    if data != nil {
                        self.dayOfAgeData.append(data!)
                    }
                }
            }
        }
    }
    
    fileprivate func handleRegionRefrigratorDataArr(_ refrigratorDataArr: inout [[String : Any]], _ arrIDs: inout [NSNumber]) {
        // region 3 means US & Canada
        if self.regionID != 3 {
            refrigratorDataArr.removeAll()
            let refriArray = CoreDataHandlerPE().getREfriData(id: self.assessID ?? 0)
            if refriArray.count > 1 {
                arrIDs.removeAll()
                for objn in refriArray {
                    if !arrIDs.contains(objn.id!) {
                        arrIDs.append(objn.id!)
                        let data = self.createSyncRequestRefrigator(dictArray: objn)
                        refrigratorDataArr.append(data)
                    }
                }
            }
        }
    }
    
    fileprivate func handleInovojectDataValidations(_ obj: PENewAssessment) {
        self.inovojectData.removeAll()
        if obj.inovoject.count > 0 {
            var idArr : [Int] = []
            for objn in  obj.inovoject {
                let data = CoreDataHandlerPE().getPEDOAData(doaId: objn)
                if data != nil,!idArr.contains(data!.id ?? 0) {
                    idArr.append(data!.id ?? 0)
                    if data != nil{
                        self.inovojectData.append(data!)
                    }
                }
            }
        }
    }
    
    fileprivate func handleCertificateDataValidations(_ obj: PENewAssessment) {
        self.certificateData.removeAll()
        if obj.vMixer.count > 0 {
            var idArr : [Int] = []
            for objn in  obj.vMixer {
                let data = CoreDataHandlerPE().getCertificateData(doaId: objn)
                if !idArr.contains(data!.id ?? 0) {
                    idArr.append(data!.id ?? 0)
                    if data != nil {
                        self.certificateData.append(data!)
                    }
                }
            }
        }
    }
    
    fileprivate func handleInovoObjectDataArrDayOfAgeValidations(_ obj: PENewAssessment, _ inovojectDataArr: inout [[String : Any]], _ dayOfAgeDataArr: inout [[String : Any]], _ dayOfAgeSDataArr: inout [[String : Any]]) {
        if self.inovojectData.count > 0 {
            for item in self.inovojectData {
                let json = self.createSyncRequestForInvoject(dictArray: obj, inovojectData: item)
                inovojectDataArr.append(json)
                
            }
        }
        if self.dayOfAgeData.count > 0 {
            for item in self.dayOfAgeData {
                let json = self.createSyncRequestForDOA(dictArray: obj, dayOfAgeData: item)
                dayOfAgeDataArr.append(json)
                
            }
        }
        if self.dayOfAgeSData.count > 0 {
            for item in self.dayOfAgeSData {
                let json = self.createSyncRequestForDOAS(dictArray: obj, dayOfAgeData: item)
                dayOfAgeSDataArr.append(json)
                
            }
        }
    }
    
    fileprivate func handleVaccinationResdueMicroSample(_ obj: PENewAssessment, _ certificateDataArr: inout [[String : Any]], _ vaccineResidueMoldsDataArr: inout [[String : Any]], _ vaccineMicroSamplesDataArr: inout [[String : Any]], _ AssessmentId: inout Int) {
        if self.certificateData.count > 0 {
            for item in self.certificateData {
                let json = self.createSyncRequestForCertificateData(dictArray: obj, peCertificateData: item)
                certificateDataArr.append(json)
            }
        }
        if obj.evaluationID == 2 {
            let json = self.createSyncRequestForResidueData(dictArray: obj)
            vaccineResidueMoldsDataArr.append(json)
        }
        if obj.evaluationID == 2 {
            let json = self.createSyncRequestForMicroData(dictArray: obj)
            vaccineMicroSamplesDataArr.append(json)
        }
        
        if AssessmentId == 0 {
            AssessmentId = self.objAssessment.draftNumber ?? 0
        }
    }
    
    fileprivate func handleSendPostDataToServer(_ param: JSONDictionary, _ paramForDoaInnovoject: JSONDictionary) {
        //self.convertDictToJson(dict: param,apiName: "add assessment")
        ZoetisWebServices.shared.sendPostDataToServer(controller: self, parameters: param, completion: { [weak self] (json, error) in
            if error != nil {
                self?.dismissGlobalHUD(self?.view ?? UIView())
            }
            guard let self = self, error == nil else { return }
            
            if json["StatusCode"]  == 200 {
                if self.isSync {
                    self.convertDictToJson(dict: paramForDoaInnovoject,apiName: "add paramData")
                    self.callRequest2(paramForDoaInnovoject: paramForDoaInnovoject, json: json)
                }
            } else {
                self.dismissGlobalHUD(self.view)
                self.showAlert(title: "Error", message: "Error in first api sync", owner: self)
            }
        })
    }
    
    fileprivate func handleAccessPEArrObjectsValidations(_ obj: PENewAssessment, _ refrigratorDataArr: inout [[String : Any]], _ inovojectDataArr: inout [[String : Any]], _ dayOfAgeDataArr: inout [[String : Any]], _ dayOfAgeSDataArr: inout [[String : Any]], _ certificateDataArr: inout [[String : Any]], _ vaccineResidueMoldsDataArr: inout [[String : Any]], _ vaccineMicroSamplesDataArr: inout [[String : Any]]) {
        if self.isSync == false {
            self.isSync = true
            self.assessID = Int(obj.serverAssessmentId ?? "")
            self.objAssessment = obj
            self.checkDataDuplicacy(obj: obj)
            var arrIDs = [NSNumber]()
            handleRegionRefrigratorDataArr(&refrigratorDataArr, &arrIDs)
            handleDayOfAgeSData(obj)
            handleDayOfAgeDataValidations(obj)
            handleInovojectDataValidations(obj)
            handleCertificateDataValidations(obj)
            
            if obj.extndMicro == false {
                HaveToCallExtendedMicro = false
            } else {
                HaveToCallExtendedMicro = true
            }
            self.tempArr.removeAll()
            let json = self.createSyncRequest(dict: obj , certificationData : self.certificateData )
            tempArr.append(json)
            
            handleInovoObjectDataArrDayOfAgeValidations(obj, &inovojectDataArr, &dayOfAgeDataArr, &dayOfAgeSDataArr)
            var AssessmentId = self.objAssessment.dataToSubmitNumber ?? 0

            handleVaccinationResdueMicroSample(obj, &certificateDataArr, &vaccineResidueMoldsDataArr, &vaccineMicroSamplesDataArr, &AssessmentId)
            
            var paramForDoaInnovoject = JSONDictionary()
            
            if (self.regionID  != 3) {
                paramForDoaInnovoject = ["InovojectData":inovojectDataArr,"DayOfAgeData":dayOfAgeDataArr,"DayAgeSubcutaneousDetailsData":dayOfAgeSDataArr,"VaccineMixerObservedData":certificateDataArr,"VaccineResidueMoldsData":vaccineResidueMoldsDataArr,"VaccineMicroSamplesData":vaccineMicroSamplesDataArr,"RefrigeratorData":refrigratorDataArr,"DeviceId": self.deviceIDFORSERVER, "AssessmentDetailsId" :AssessmentId] as JSONDictionary
            } else {
                paramForDoaInnovoject = ["InovojectData":inovojectDataArr,"DayOfAgeData":dayOfAgeDataArr,"DayAgeSubcutaneousDetailsData":dayOfAgeSDataArr,"VaccineMixerObservedData":certificateDataArr,"VaccineResidueMoldsData":vaccineResidueMoldsDataArr,"VaccineMicroSamplesData":vaccineMicroSamplesDataArr, "DeviceId": self.deviceIDFORSERVER, "AssessmentDetailsId" :AssessmentId] as JSONDictionary
            }
            
            var idArr = [String]()
            for val in tempArr {
                let id = val["AssessmentId"] as? Int64 ?? 0
                if id != 0{
                    idArr.append("\(id)")
                }
            }
            
            let param = ["AssessmentData":tempArr,"appVersion":Bundle.main.versionNumber,"IsSendEmail":"true"] as JSONDictionary
            
            handleSendPostDataToServer(param, paramForDoaInnovoject)
        }
    }
    
    func accessPEArrayObjects(){
        
        var inovojectDataArr : [JSONDictionary]  = []
        var dayOfAgeDataArr : [JSONDictionary]  = []
        var dayOfAgeSDataArr : [JSONDictionary]  = []
        var certificateDataArr : [JSONDictionary]  = []
        var vaccineMicroSamplesDataArr : [JSONDictionary]  = []
        var vaccineResidueMoldsDataArr : [JSONDictionary]  = []
        var refrigratorDataArr : [JSONDictionary]  = []
        if peAssessmentSyncArray.count > 0 {
            for obj in self.peAssessmentSyncArray {
                // For loop for each assessment to be synced (Multiple Assessment)
                if obj.isEMRejected == true && obj.isPERejected == false {
                    self.syncExtendedMicrobial(saveType: 1, statusType: 0)
                    return
                }
                
                handleAccessPEArrObjectsValidations(obj, &refrigratorDataArr, &inovojectDataArr, &dayOfAgeDataArr, &dayOfAgeSDataArr, &certificateDataArr, &vaccineResidueMoldsDataArr, &vaccineMicroSamplesDataArr)
            }
        }
    }
    
    // MARK: - Create Sync request for Refrigrator Data
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
    
    // MARK: - Get Vaccine Service Responce
    fileprivate func handlePEAssessmentArray(_ peAssessmentArray: inout [PENewAssessment]) {
        for obj in peAssessmentArray {
            if obj.statusType ?? 0 == 3{
                if self.scheduleAssessmentIdArray.count > 0 {
                    if !(self.scheduleAssessmentIdArray.contains(obj.serverAssessmentId ?? "")) {
                        self.deletedAssessmentIdArray.append(obj.serverAssessmentId!)
                        let userID =  UserDefaults.standard.value(forKey:"Id") as? Int ?? 0
                        let index = peAssessmentArray.firstIndex(of: obj) ?? 0
                        peAssessmentArray.remove(at: index)
                        CoreDataHandlerPE().deleteExisitingData(entityName: "PE_AssessmentInOffline", predicate: NSPredicate(format: self.userIdStr, userID, obj.serverAssessmentId ?? ""))
                    }
                } else {
                    self.deletedAssessmentIdArray.append(obj.serverAssessmentId!)
                    let userID =  UserDefaults.standard.value(forKey:"Id") as? Int ?? 0
                    let index = peAssessmentArray.index(of: obj) ?? 0
                    peAssessmentArray.remove(at: index)
                    CoreDataHandlerPE().deleteExisitingData(entityName: "PE_AssessmentInOffline", predicate: NSPredicate(format: self.userIdStr, userID, obj.serverAssessmentId ?? ""))
                }
            }
        }
    }
    
    fileprivate func handlePEAssrray(_ peAssessmentNewArray: [PENewAssessment], _ peAssessmentArray: [PENewAssessment],_ showHud:Bool) {
        if peAssessmentNewArray.count > 0{
            if self.deletedAssessmentIdArray.count > 0 {
                let alertController = UIAlertController(title: Constants.alertStr, message: String(format: "%d assessment(s) has been removed from the web. App data will be updated.", self.deletedAssessmentIdArray.count ?? 0), preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    _ in
                    if peAssessmentArray.count > 0{
                        self.syncBtnTapped(showHud: showHud)
                    }else{
                        let userID =  UserDefaults.standard.value(forKey:"Id") as? Int ?? 0
                        for id in self.deletedAssessmentIdArray {
                            CoreDataHandlerPE().deleteExisitingData(entityName: "PE_AssessmentInOffline", predicate: NSPredicate(format: self.userIdStr, userID, id))
                        }
                        self.peHeaderViewController.titleofSync = "0"
                        self.peHeaderViewController.viewDidLoad()
                        self.getScheduledAssessments()
                    }
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.syncBtnTapped(showHud: showHud)
            }
         }else {
            self.syncBtnTapped(showHud: showHud)
        }
    }
    
    func getVaccinationServiceResponse(showHud:Bool){
        self.showGlobalProgressHUDWithTitle(self.view, title: appDelegateObj.dataSyncInProgressStr + "\n" + noteStr)
        let id = UserContext.sharedInstance.userDetailsObj?.userId ?? noIdFound
        let url = ZoetisWebServices.EndPoint.getPEScheduledCertifications.latestUrl + "\(id)?customerId=null&siteId=null"
        
        ZoetisWebServices.shared.getVaccinationServicesResponse(controller: self, url: url, completion: { [weak self] (json, error) in
            guard let _ = self, error == nil else{return;}
            var dataDic : [String:Any] = [:]
            if let string = json.rawString() {
                dataDic = string.convertToDictionary() ?? [:]
            }
            var dataArray = dataDic["Data"] as? [Any] ?? []
            let myTask = DispatchGroup()
            self?.scheduleAssessmentIdArray = []
            while dataArray.count != 0 {
                myTask.enter()
                let objDic = dataArray[0] as? [String:Any] ?? [:]
                dataArray.remove(at: 0)
                if !(self?.scheduleAssessmentIdArray.contains(String(objDic["Id"]! as! Int)) ?? true){
                    self?.scheduleAssessmentIdArray.append(String(objDic["Id"]! as! Int))
                    myTask.leave()
                }
            }
            self?.deletedAssessmentIdArray = []
            var peAssessmentArray = self?.getAllDateArrayStoredNew() ?? []
            let peAssessmentNewArray = self?.getAllDateArrayStored() ?? []
            self?.handlePEAssessmentArray(&peAssessmentArray)
            self?.handlePEAssrray(peAssessmentNewArray, peAssessmentArray,showHud)
        })
    }
}

// MARK: - HANDLE ALL ABOVE API RESPONSES
extension PEDashboardViewController{
    
    private func handlefetchAllCustomerResponse(_ json: JSON, isEverytime:Bool = false) {
        self.deleteAllData("PE_Customer")
        if isEverytime{
            fetchSites(isEverytime)
            dismissGlobalHUD(self.view)
        }else{
            fetchAllDoses()
        }
    }
    // MARK: - HANDLE ALL Doses API RESPONSES
    private func handlefetchAllDosesResponse(_ json: JSON) {
        self.deleteAllData("PE_Dose")
        fetchAllCountries()
    }
    // MARK: - HANDLE ALL Countries API RESPONSES
    private func handlefetchAllCountriesResponse(_ json: JSON) {
        
        self.deleteAllData("AllCountriesPE")
        fetchChlorinStripsList()
    }
    // MARK: - HANDLE ALL Blank Assessment API RESPONSES
    private func handleBlankAssessmentResponse(_ json: JSON) {
        self.deleteAllData("BlankAssessmentFiles")
    }
    // MARK: - Get Chlorine Strips List API
    private func fetchChlorinStripsList(){
        if ConnectionManager.shared.hasConnectivity() {
            ZoetisWebServices.shared.getClorineStripsForPE(controller: self, parameters: [:], completion: { [weak self] (json, error) in
                guard let _ = self, error == nil else {
                    self?.dismissGlobalHUD(self?.view ?? UIView())
                    return
                }
                self?.handleAllClorineResponse(json)
            })
        }else{
            self.dismissGlobalHUD(self.view ?? UIView())
        }
    }
    // MARK: - HANDLE Chlorine Strips List API RESPONSES
    private func handleAllClorineResponse(_ json: JSON) {
        self.deleteAllData("AllClorinePE")
        fetchEvaluator()
    }
    // MARK: - HANDLE Evaluator's List API RESPONSES
    private func handleFetchEvaluatorResponse(_ json: JSON) {
        self.deleteAllData("PE_Evaluator")
        fetchApprovers()
    }
    // MARK: - HANDLE Approvers List API RESPONSES
    private func handleFetchApproversResponse(_ json: JSON) {
        self.deleteAllData("PE_Approvers")
        fetchVisitTypes()
    }
    // MARK: - HANDLE Visit List API RESPONSES
    private func handleFetchVisitTypesResponse(_ json: JSON) {
        self.deleteAllData("PE_VisitTypes")
        fetchEvaluationTypes()
    }
    // MARK: - HANDLE Evaluation type's  API RESPONSES
    private func handleFetchEvaluationTypesResponse(_ json: JSON) {
        self.deleteAllData("PE_EvaluationType")
        fetchSites()
    }
    // MARK: - HANDLE Site List API RESPONSES
    private func handleFetchSitesResponse(_ json: JSON,_ isEverytime:Bool = false) {
        self.deleteAllData("PE_Sites")
        if isEverytime{
            dismissGlobalHUD(self.view)
        } else{
            fetchtAssessmentCategoriesResponse()
        }
    }
    // MARK: - HANDLE Assessment Categories Question Answers API RESPONSES
    private func handleAssessmentCategoriesResponse(_ json: JSON) {
        DispatchQueue.main.async {
            UserDefaults.standard.setValue(nil, forKey:"QuestionAns")
            self.saveJSON(json: json, key: "QuestionAns")
            self.fetchtQuestionInfo()
        }
    }
    // MARK: - HANDLE Assessment Categories Question Info API RESPONSES
    private func handlefetchtQuestionInfo(_ json: JSON) {
        saveJSON(json: json, key: "QuestionAnsInfo")
        fetchManufacturer()
    }
    
    // MARK: - HANDLE PE Manufacturer Lisi API RESPONSES
    private func handlefetchManufacturerResponse(_ json: JSON) {
        self.deleteAllData("PE_Manufacturer")
        fetchBirdBreed()
    }
    
    // MARK: - HANDLE PE Bird Breed List API RESPONSES
    private func handlefetchBirdBreedResponse(_ json: JSON) {
        self.deleteAllData("PE_BirdBreed")
        self.fetchEggs()
    }
    
    // MARK: - HANDLE Eggs List API RESPONSES
    private func handlefetchEggsResponse(_ json: JSON) {
        self.deleteAllData("PE_Eggs")
        fetchVManufacturer()
    }
    
    // MARK: - HANDLE PE Vaccine Manufacture List API RESPONSES
    private func handlefetchVManufacturerResponse(_ json: JSON) {
        self.deleteAllData("PE_VManufacturer")
        fetchVaccineNames()
    }
    
    // MARK: - HANDLE Vaccine Name List API RESPONSES
    private func handlefetchVaccineNamesResponse(_ json: JSON) {
        self.deleteAllData("PE_VNames")
        self.fetchDiluentManufacturer()
    }
    
    // MARK: -  Get PE Diluent Manufacturer  List API RESPONSES
    private func handlefetchDiluentManufacturer(_ json: JSON) {
        self.deleteAllData("PE_DManufacturer")
        fetchBagSizes()
    }
    
    // MARK: - Get PE BAg Size List API RESPONSES
    private func handlefetchBagSizes(_ json: JSON) {
        self.deleteAllData("PE_BagSizes")
        fetchAmplePerBag()
    }
    
    // MARK: - HANDLE PE BAg Size List API RESPONSES
    private func handleGetBagSizes(_ json: JSON) {
        self.deleteAllData("PE_BagSizes")
    }
    
    // MARK: - Get PE Ample Per Bag Size List API RESPONSES
    private func handlefetchAmplePerBag(_ json: JSON) {
        self.deleteAllData("PE_AmplePerBag")
        fetchAmpleSizes()
    }
    
    // MARK: - Handle PE Ample Per Bag Size List API RESPONSES
    private func handleGetAmplePerBag(_ json: JSON) {
        self.deleteAllData("PE_AmplePerBag")
        self.getPostingAssessmentListByUser()
    }
    
    // MARK: - Get PE Roles List API
    private func handlefetchAmpleSizes(_ json: JSON) {
        self.deleteAllData("PE_AmpleSizes")
        fetchRoles()
    }
    
    // MARK: - Handle PE Ample Size List API RESPONSES
    private func handlegettingfetchAmpleSizes(_ json: JSON) {
        self.deleteAllData("PE_AmpleSizes")
    }
    
    // MARK: - Handle PE Roles List API
    private func handlefetchRoles(_ json: JSON) {
        self.deleteAllData("PE_Roles")
        PERolesResponse(json)
        fetchDOADiluentType()
    }
    
    // MARK: - Handle PE DOA Diluent Type List API
    private func handlefetchDOADiluentType(_ json: JSON) {
        self.deleteAllData("PE_DOADiluentType")
        PEDOADiluentTypeResponce(json)
        fetchSubVaccineNames()
    }
    
    // MARK: - Handle PE Sub Vaccine List API Responce
    private func handlefetchSubVaccineNamesResponse(_ json: JSON) {
        self.deleteAllData("PE_VSubNames")
        fetchPEFrequency()
    }
    
    // MARK: - Handle PE Frequency List API Responce
    private func handlefetchPEFrequency(_ json: JSON) {
        self.deleteAllData("PE_Frequency")
        PEFrequencyResponse(json)
        fetchIncubationStyle()
    }
    
    // MARK: - Handle PE Incubation Style List API Responce
    private func handlefetchIncubationStyle(_ json: JSON) {
        self.deleteAllData("PE_IncubationStyle")
        PEIncubationStyleResponse(json)
        fetchDOASizes()
    }
    
    // MARK: - Handle PE Dose Size List API Responce
    private func handlefetchDOASizes(_ json: JSON) {
        self.deleteAllData("PE_DOASizes")
        PEDOASizesResponse(json)
        UserDefaults.standard.set(true, forKey: "hasPEDataLoaded")
        getPostingAssessmentListByUser()
    }
    
    // MARK: - Handle PE Posting Assessment List API Responce
    fileprivate func extractedFunc(_ FrequencyValueStr: String, _ QCCount: String, _ PersonName: String, _ TextAmPm: String, _ PPMValue: String, _ AssessmentScore: Int, _ isNAValue: Bool, _ filterScoreData: inout [[String : Any]], _ questionMark: [String : Any], _ isNaSelectedArray: inout [[String : Any]]) {
        if FrequencyValueStr.count > 0 {
            CoreDataHandlerPE().updateFrequencyInAssessmentInProgress(frequency:FrequencyValueStr)
        }
        if QCCount.count > 0 {
            CoreDataHandlerPE().updateQCCountInAssessmentInProgress(qcCount:QCCount)
        }
        if PersonName.count > 0 {
            CoreDataHandlerPE().updatePersonNameInAssessmentInProgress(personName: PersonName)
        }
        if TextAmPm.count > 0 {
            CoreDataHandlerPE().updateAMPMInAssessmentInProgress(ampmValue: TextAmPm)
        }
        if PPMValue.count > 0 {
            CoreDataHandlerPE().updatePPMValueInAssessmentInProgress(PpmValue: PPMValue)
        }
        if AssessmentScore  ==  0 || (isNAValue)  {
            filterScoreData.append(questionMark)
        }
        if isNAValue{
            isNaSelectedArray.append(questionMark)
        }
    }
    
    private func handlGetPostingAssessmentListByUser(_ json: JSON) {
        let dataArray = extractDataArray(from: json)
        if dataArray.count > 0 {
            deleteAllPreviousAssessmentData()
        }
        for obj in dataArray {
            handleAssessmentObject(obj)
        }
    }

    private func extractDataArray(from json: JSON) -> [Any] {
        var dataDic: [String: Any] = [:]
        if let string = json.rawString() {
            dataDic = string.convertToDictionary() ?? [:]
        }
        return dataDic["Data"] as? [Any] ?? []
    }

    private func deleteAllPreviousAssessmentData() {
        self.deleteAllDataWithUserID("PE_AssessmentInOffline")
        self.deleteAllDataWithUserID("PE_AssessmentInDraft")
    }

    private func handleAssessmentObject(_ obj: Any) {
        let objDic = obj as? [String: Any] ?? [:]
        let saveType = objDic["SaveType"] as? Int ?? 0
        UserDefaults.standard.set(true, forKey: "hasPELoadedPrevData")
        if saveType != 0 {
            let peNewAssessmentWas = parseAssessment(objDic)
            handleSanitationEmbrex(objDic, serverAssessmentId: peNewAssessmentWas.serverAssessmentId!)
            handleCategoriesAndQuestions(for: peNewAssessmentWas, objDic: objDic)
            handleScores(for: peNewAssessmentWas, objDic: objDic)
            handleComments(for: peNewAssessmentWas, objDic: objDic)
            handleInovoject(for: peNewAssessmentWas, objDic: objDic)
            handleDayOfAge(for: peNewAssessmentWas, objDic: objDic)
        }
    }

    private func parseAssessment(_ objDic: [String: Any]) -> PENewAssessment {
        let peNewAssessmentWas = PENewAssessment()
        let serverAssessmentId = objDic["AssessmentId"] as? Int ?? 0
        let EvaluationId = objDic["EvaluationId"] as? Int ?? 0

        peNewAssessmentWas.serverAssessmentId = String(serverAssessmentId)
        peNewAssessmentWas.siteId = objDic["SiteId"] as? Int ?? 0
        peNewAssessmentWas.siteName = objDic["SiteName"] as? String ?? ""
        peNewAssessmentWas.customerId = objDic["CustomerId"] as? Int ?? 0
        peNewAssessmentWas.customerName = objDic["CustomerName"] as? String ?? ""
        peNewAssessmentWas.hatcheryAntibiotics = 0
        peNewAssessmentWas.evaluationID  = EvaluationId
        peNewAssessmentWas.extndMicro = objDic["IsInterMicrobial"] as? Bool ?? false
        peNewAssessmentWas.IsEMRequested = objDic["IsEMRequested"] as? Bool ?? false
        peNewAssessmentWas.sanitationValue = objDic["SanitationEmbrex"] as? Bool ?? false
        if let doubleSanitation = objDic["DoubleSanitation"] as? Bool, doubleSanitation {
            peNewAssessmentWas.hatcheryAntibiotics = 1
        }
        peNewAssessmentWas.isHandMix = objDic["Handmix"] as? Bool ?? false
        peNewAssessmentWas.isEMRejected = objDic["IsEMRejected"] as? Bool ?? false
        peNewAssessmentWas.isPERejected = objDic["IsPERejected"] as? Bool ?? false
        peNewAssessmentWas.emRejectedComment = objDic["EMRejectedComment"] as? String ?? ""
        peNewAssessmentWas.userID = objDic["UserId"] as? Int ?? 0
        peNewAssessmentWas.evaluationDate = convertDateFormatter(date: objDic["EvaluationDate"] as? String ?? "")
        peNewAssessmentWas.visitID = objDic["VisitId"] as? Int ?? 0
        peNewAssessmentWas.visitName = objDic["VisitName"] as? String ?? ""
        peNewAssessmentWas.selectedTSRID = objDic["TSRId"] as? Int ?? 0

        // TSR Name resolution
        let visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Approvers")
        let visitNameArray = visitDetailsArray.value(forKey: "username") as? NSArray ?? NSArray()
        let visitIDArray = visitDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        if peNewAssessmentWas.selectedTSRID != 0,
           visitIDArray.contains(peNewAssessmentWas.selectedTSRID ?? 0) {
            let indexOfe = visitIDArray.index(of: peNewAssessmentWas.selectedTSRID ?? 0)
            let TSRName = visitNameArray[indexOfe] as? String ?? ""
            peNewAssessmentWas.selectedTSR = TSRName
        }

        peNewAssessmentWas.evaluatorName = objDic["UserName"] as? String ?? ""
        peNewAssessmentWas.evaluatorID = objDic["UserId"] as? Int ?? 0
        peNewAssessmentWas.evaluationName = objDic["EvaluationName"] as? String ?? ""
        peNewAssessmentWas.evaluationID = objDic["EvaluationId"] as? Int ?? 0
        peNewAssessmentWas.incubation = objDic["IncubationStyleName"] as? String ?? ""
        peNewAssessmentWas.breedOfBird = objDic["BreedBirdsName"] as? String ?? ""
        peNewAssessmentWas.breedOfBirdOther = objDic["BreedOfBirdsOther"] as? String ?? ""
        peNewAssessmentWas.dataToSubmitID = objDic["AppCreationTime"] as? String ?? ""
        peNewAssessmentWas.manufacturer = objDic["ManufacturerName"] as? String ?? ""
        peNewAssessmentWas.countryName = objDic[Constants.countryNamStr] as? String ?? ""
        peNewAssessmentWas.countryID = objDic["CountryId"] as? Int ?? 0
        peNewAssessmentWas.refrigeratorNote = objDic["RefrigeratorNote"] as? String ?? ""
        peNewAssessmentWas.fluid = objDic["IsInovoFluids"] as? Bool ?? false
        peNewAssessmentWas.basicTransfer = objDic["IsBasicTrfAssessment"] as? Bool ?? false
        peNewAssessmentWas.extndMicro = objDic["IsInterMicrobial"] as? Bool ?? false
        peNewAssessmentWas.clorineName = objDic["ChlorineText"] as? String ?? ""
        peNewAssessmentWas.clorineId = objDic["ChlorineId"] as? Int ?? 0

        let manuOthers = objDic["ManufacturerOther"] as? String ?? ""
        if manuOthers != "" {
            peNewAssessmentWas.manufacturer = "S" + manuOthers
        }
        let eggStr = objDic["EggsPerFlatName"] as? String ?? "0"
        peNewAssessmentWas.noOfEggs = Int64(eggStr)
        let eggsOthers = objDic["EggsPerFlatOther"]  as? String ?? ""
        if eggsOthers != "" {
            let txt = eggsOthers
            let str = txt + "000"
            let iii = Int64(str)
            if iii != nil {
                peNewAssessmentWas.noOfEggs = iii!
            }
        }
        let fsrSignatureImage = objDic["FSTSignatureImage"] as? String ?? ""
        peNewAssessmentWas.FSTSignatureImage = fsrSignatureImage
        let f = objDic["FlockAgeId"] as? Int ?? 0
        peNewAssessmentWas.isFlopSelected = f
        let Camera = objDic["Camera"] as? Bool ?? false
        peNewAssessmentWas.camera = Camera ? 1 : 0
        peNewAssessmentWas.notes = objDic["Notes"] as? String ?? ""

        return peNewAssessmentWas
    }

    private func handleSanitationEmbrex(_ objDic: [String: Any], serverAssessmentId: String) {
        let sanitationEmbrexValue = objDic["SanitationEmbrex"] as? Bool ?? false
        if sanitationEmbrexValue {
            PEInfoDAO.sharedInstance.saveData(
                userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "",
                isExtendedPE: sanitationEmbrexValue,
                assessmentId: serverAssessmentId,
                date: nil,
                override: false
            )
        }
        let sanitationEmbrex = objDic["SanitationEmbrexScoresPostinData"] as? [[String: Any]] ?? []
        let jsonData = try? JSONSerialization.data(withJSONObject: sanitationEmbrex, options: .prettyPrinted)
        let jsonDecoder = JSONDecoder()
        if let jsonData = jsonData,
           let dtoArr = try? jsonDecoder.decode([PESanitationDTO].self, from: jsonData) {
            SanitationEmbrexQuestionMasterDAO.sharedInstance.saveServiceResponse(
                assessmentId: serverAssessmentId,
                userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "",
                dtoArr: dtoArr
            )
        }
    }

    private func handleCategoriesAndQuestions(for assessment: PENewAssessment, objDic: [String: Any]) {
        jsonRe = (getJSON("QuestionAns") ?? JSON())
        pECategoriesAssesmentsResponse = PECategoriesAssesmentsResponse(jsonRe)
        let questionInfo = (getJSON("QuestionAnsInfo") ?? JSON())
        let infoImageDataResponse = InfoImageDataResponse(questionInfo)
        let categoryCount = filterCategoryCount(peNewAssessmentOf: assessment)
        if categoryCount > 0 {
            for cat in pECategoriesAssesmentsResponse.peCategoryArray {
                for (index, ass) in cat.assessmentQuestions.enumerated() {
                    let peNewAssessmentNew = assessment
                    peNewAssessmentNew.serverAssessmentId = assessment.serverAssessmentId
                    peNewAssessmentNew.cID = index
                    peNewAssessmentNew.catID = cat.id
                    peNewAssessmentNew.catName = cat.categoryName
                    peNewAssessmentNew.catMaxMark = cat.maxMark
                    peNewAssessmentNew.sequenceNo = cat.id
                    peNewAssessmentNew.sequenceNoo = cat.sequenceNo
                    peNewAssessmentNew.catResultMark = cat.maxMark
                    peNewAssessmentNew.catEvaluationID = cat.evaluationID
                    peNewAssessmentNew.catISSelected = cat.isSelected ? 1 : 0
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
                    peNewAssessmentNew.informationText = infoImageDataResponse.getInfoTextByQuestionId(questionID: ass.id ?? 151)
                    peNewAssessmentNew.isChlorineStrip = objDic["HasChlorineStrips"] as? Int ?? 0
                    peNewAssessmentNew.isAutomaticFail = objDic["IsAutomaticFail"] as? Int ?? 0
                    peNewAssessmentNew.isAllowNA = ass.isAllowNA
                    peNewAssessmentNew.rollOut = ass.rollOut
                    peNewAssessmentNew.isNA = ass.isNA
                    peNewAssessmentNew.qSeqNo = ass.qSeqNo
                    CoreDataHandlerPE().saveNewAssessmentInProgressInDB(newAssessment: peNewAssessmentNew)
                }
            }
        }
    }

    private func handleScores(for assessment: PENewAssessment, objDic: [String: Any]) {
        let assessmentScoresPostingData = objDic["AssessmentScoresPostingData"] as? [[String: Any]] ?? []
        let allAssesmentArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInProgress")
        var filterScoreData: [[String: Any]] = [[:]]
        var isNaSelectedArray: [[String: Any]] = [[:]]
        for questionMark in assessmentScoresPostingData {
            let AssessmentScore = questionMark["AssessmentScore"] as? Int ?? 0
            let QCCount = questionMark["QCCount"] as? String ?? ""
            let FrequencyValue = questionMark["FrequencyValue"] as? Int ?? 32
            var FrequencyValueStr = ""
            let visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Frequency")
            let visitNameArray = visitDetailsArray.value(forKey: "frequencyName") as? NSArray ?? NSArray()
            let visitIDArray = visitDetailsArray.value(forKey: "frequencyId") as? NSArray ?? NSArray()
            if FrequencyValue != 32, visitIDArray.contains(FrequencyValue) {
                let indexOfe = visitIDArray.index(of: FrequencyValue)
                FrequencyValueStr = visitNameArray[indexOfe] as? String ?? ""
            }
            let TextAmPm = questionMark["TextAmPm"] as? String ?? ""
            let PersonName = questionMark["PersonName"] as? String ?? ""
            let PPMValue = questionMark["Chlorine_Value"] as? String ?? ""
            let isNAValue = questionMark["IsNA"] as? Bool ?? false
            extractedFunc(FrequencyValueStr, QCCount, PersonName, TextAmPm, PPMValue, AssessmentScore, isNAValue, &filterScoreData, questionMark, &isNaSelectedArray)
        }

        var assArray: [Int] = []
        for cat in filterScoreData {
            let assID = cat["ModuleAssessmentId"] as? Int ?? 0
            assArray.append(assID)
        }

        var naArray: [Int] = []
        for cat in isNaSelectedArray {
            let assID = cat["ModuleAssessmentId"] as? Int ?? 0
            naArray.append(assID)
        }

        for qMark in allAssesmentArr {
            let objMark = qMark as? PE_AssessmentInProgress ?? PE_AssessmentInProgress()
            for assID in naArray {
                if (Int(truncating: objMark.assID ?? 0) == assID) {
                    var totalMark = GetLatestTotalMarkOfAss(assID: objMark.assID as? Int ?? 0)
                    let catISSelected = 0
                    let maxMarks = objMark.assMaxScore ?? 0
                    let reMark = Int(totalMark) - Int(truncating: maxMarks)
                    totalMark = Int(truncating: NSNumber(value: reMark))
                    CoreDataHandlerPE().updateChangeInTotalAnsInProgressTable(catISSelected: catISSelected, catMaxMark: Int(totalMark), catID: Int(truncating: objMark.catID ?? 0), assID: Int(truncating: objMark.assID ?? 0), userID: Int(truncating: objMark.userID ?? 0))
                }
            }
        }

        for qMark in allAssesmentArr {
            let objMark = qMark as? PE_AssessmentInProgress ?? PE_AssessmentInProgress()
            for assID in assArray {
                if (Int(truncating: objMark.assID ?? 0) == assID) {
                    var totalMark = GetLatestMarkOfAss(assID: objMark.assID as? Int ?? 0)
                    let catISSelected = 0
                    let maxMarks = objMark.assMaxScore ?? 0
                    let reMark = Int(totalMark) - Int(truncating: maxMarks)
                    totalMark = Int(truncating: NSNumber(value: reMark))
                    CoreDataHandlerPE().updateChangeInAnsInProgressTable(catISSelected: catISSelected, catResultMark: Int(totalMark), catID: Int(truncating: objMark.catID ?? 0), assID: Int(truncating: objMark.assID ?? 0), userID: Int(truncating: objMark.userID ?? 0))
                }
            }
        }

        var assNAArray: [[String: Any]] = [[:]]
        for cat in assessmentScoresPostingData {
            let isNA = cat["IsNA"] as? Bool ?? false
            if isNA {
                assNAArray.append(cat)
            }
        }

        for qMark in allAssesmentArr {
            let objMark = qMark as? PE_AssessmentInProgress ?? PE_AssessmentInProgress()
            for assID in assNAArray {
                let AssessmentId = assID["ModuleAssessmentId"] as? Int ?? 0
                if (Int(truncating: objMark.assID ?? 0) == AssessmentId) {
                    CoreDataHandlerPE().update_isNAInAssessmentInProgress(isNA: true, assID: Int(objMark.assID ?? 0))
                }
            }
        }
    }

    private func handleComments(for assessment: PENewAssessment, objDic: [String: Any]) {
        let assessmentCommentsPostingData = objDic["AssessmentCommentsPostingData"] as? [[String: Any]] ?? []
        let allAssesmentArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInProgress")
        var filterCommentData: [[String: Any]] = [[:]]
        for questionMark in assessmentCommentsPostingData {
            let AssessmentComment = questionMark["AssessmentComment"] as? String ?? ""
            if AssessmentComment.count > 0 {
                filterCommentData.append(questionMark)
            }
        }
        for qMark in allAssesmentArr {
            let objMark = qMark as? PE_AssessmentInProgress ?? PE_AssessmentInProgress()
            for assID in filterCommentData {
                let AssessmentComment = assID["AssessmentComment"] as? String ?? ""
                let AssessmentId = assID["AssessmentId"] as? Int ?? 0
                if (Int(truncating: objMark.assID ?? 0) == AssessmentId) {
                    CoreDataHandlerPE().updateNoteInProgressTable(assID: Int(truncating: objMark.assID ?? 0), text: AssessmentComment)
                }
            }
        }
    }

    private func handleInovoject(for assessment: PENewAssessment, objDic: [String: Any]) {
        let InovojectPostingData = objDic["InovojectPostingData"] as? [Any] ?? []
        let allAssesmentArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInProgress")
        for inoDic in InovojectPostingData {
            let inoDicIS = inoDic as? [String: Any] ?? [:]
            let Dosage = inoDicIS["Dosage"] as? String ?? ""
            let otherString = inoDicIS["OtherText"] as? String ?? ""
            let VaccineId = inoDicIS["VaccineId"] as? Int ?? 0
            let AmpuleSize = inoDicIS["AmpuleSize"] as? Int ?? 0
            var AmpuleSizeStr = ""
            let AntibioticInformation = inoDicIS["AntibioticInformation"] as? String ?? ""
            let ampleSizeDetailArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
            let ampleSizeesNameArray = ampleSizeDetailArray.value(forKey: "size") as? NSArray ?? NSArray()
            let ampleSizeIDArray = ampleSizeDetailArray.value(forKey: "id") as? NSArray ?? NSArray()
            if AmpuleSize != 0 {
                let indexOfe = ampleSizeIDArray.index(of: AmpuleSize)
                AmpuleSizeStr = ampleSizeesNameArray[indexOfe] as? String ?? ""
            }
            let AmpulePerbag = inoDicIS["AmpulePerbag"] as? Int ?? 0
            let HatcheryAntibiotics = inoDicIS["HatcheryAntibiotics"] as? Bool ?? false
            let BagSizeType = inoDicIS["BagSizeType"] as? String ?? ""
            let DiluentMfg = inoDicIS["DiluentMfg"] as? String ?? ""
            var VName = ""
            let ProgramName = inoDicIS["ProgramName"] as? String ?? ""
            let DiluentsMfgOtherName = inoDicIS["DiluentsMfgOtherName"] as? String ?? ""
            let vDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VNames")
            let vNameArray = vDetailsArray.value(forKey: "name") as? NSArray ?? NSArray()
            let vIDArray = vDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
            let xxxx = VaccineId
            if xxxx != 0 {
                if vIDArray.contains(xxxx) {
                    let indexOfd = vIDArray.index(of: xxxx)
                    VName = vNameArray[indexOfd] as? String ?? ""
                }
            } else {
                VName = otherString
            }
            if otherString != "" {
                VName = otherString
            }
            let peNewAssessmentInProgress = CoreDataHandlerPE().getSavedOnGoingAssessmentPEObject()
            var HatcheryAntibioticsIntVal = 0
            if HatcheryAntibiotics == true {
                HatcheryAntibioticsIntVal = 1
            } else {
                HatcheryAntibioticsIntVal = 0
            }
            peNewAssessmentInProgress.iCS = inoDicIS["BagSizeType"] as? String ?? ""
            let diluentMfg = inoDicIS["DiluentMfg"] as? String ?? ""
            peNewAssessmentInProgress.iDT = diluentMfg
            peNewAssessmentInProgress.micro = ""
            peNewAssessmentInProgress.residue = ""
            CoreDataHandlerPE().updateInDoGInProgressInDB(newAssessment: peNewAssessmentInProgress, fromInvo: true)
            let inVoDataNew = InovojectData(id: 0, vaccineMan: DiluentMfg, name: VName, ampuleSize: AmpuleSizeStr, ampulePerBag: String(AmpulePerbag), bagSizeType: BagSizeType, dosage: Dosage, dilute: DiluentMfg, invoHatchAntibiotic: HatcheryAntibioticsIntVal, invoHatchAntibioticText: AntibioticInformation, invoProgramName: ProgramName, doaDilManOther: DiluentsMfgOtherName)
            let id = self.saveInovojectInPEModule(inovojectData: inVoDataNew, assessment: allAssesmentArr[0] as? PE_AssessmentInProgress ?? PE_AssessmentInProgress())
            inVoDataNew.id = id
        }
    }

    private func handleDayOfAge(for assessment: PENewAssessment, objDic: [String: Any]) {
        let DayPostingData = objDic["DayOfAgePostingData"] as? [Any] ?? []
        let allAssesmentArr = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AssessmentInProgress")
        for inoDic in DayPostingData {
            let DayOfAgeIS = inoDic as? [String: Any] ?? [:]
            let Dosage = DayOfAgeIS["DayOfAgeDosage"] as? String ?? ""
            let otherText = DayOfAgeIS["OtherText"] as? String ?? ""
            let VaccineId = DayOfAgeIS["DayOfAgeMfgNameId"] as? Int ?? 0
            let AmpuleSize = DayOfAgeIS["DayOfAgeAmpuleSize"] as? Int ?? 0
            var AmpuleSizeStr = ""
            let ampleSizeDetailArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_AmpleSizes")
            let ampleSizeesNameArray = ampleSizeDetailArray.value(forKey: "size") as? NSArray ?? NSArray()
            let ampleSizeIDArray = ampleSizeDetailArray.value(forKey: "id") as? NSArray ?? NSArray()
            if AmpuleSize != 0 {
                let indexOfe = ampleSizeIDArray.index(of: AmpuleSize)
                AmpuleSizeStr = ampleSizeesNameArray[indexOfe] as? String ?? ""
            }
            let AmpulePerbag = DayOfAgeIS["DayOfAgeAmpulePerbag"] as? Int ?? 0
            let HatcheryAntibiotics = DayOfAgeIS["DayOfBagHatcheryAntibiotics"] as? Bool ?? false
            let ManufacturerId = DayOfAgeIS["DayOfAgeMfgId"] as? Int ?? 0
            let BagSizeType = DayOfAgeIS["DayOfAgeBagSizeType"] as? String ?? ""
            let DiluentMfg = DayOfAgeIS["DiluentMfg"] as? String ?? ""
            var VManufacturerName = ""
            var VName = ""
            let vManufacutrerDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_VManufacturer")
            let vManufacutrerNameArray = vManufacutrerDetailsArray.value(forKey: "mfgName") as? NSArray ?? NSArray()
            let vManufacutrerIDArray = vManufacutrerDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
            let xxx = ManufacturerId
            if xxx != 0 {
                let indexOfd = vManufacutrerIDArray.index(of: xxx)
                if vManufacutrerNameArray.count > indexOfd {
                    VManufacturerName = vManufacutrerNameArray[indexOfd] as? String ?? ""
                }
            }
            let vDetailsArray = CoreDataHandlerPE().fetchDetailsForVaccineNames(typeId: 1)
            let vNameArray = vDetailsArray.value(forKey: "name") as? NSArray ?? NSArray()
            let vIDArray = vDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
            let xxxx = VaccineId
            if xxxx != 0 {
                if vIDArray.contains(xxxx) {
                    let indexOfd = vIDArray.index(of: xxxx)
                    VName = vNameArray[indexOfd] as? String ?? ""
                }
            } else {
                VName = otherText
            }
            if otherText != "" {
                VName = otherText
            }
            let peNewAssessmentInProgress = CoreDataHandlerPE().getSavedOnGoingAssessmentPEObject()
            var HatcheryAntibioticsIntVal = 0
            if HatcheryAntibiotics == true {
                HatcheryAntibioticsIntVal = 1
            } else {
                HatcheryAntibioticsIntVal = 0
            }
            peNewAssessmentInProgress.iCS = DayOfAgeIS["DayOfAgeBagSizeType"] as? String ?? ""
            let diluentMfg = DayOfAgeIS["DiluentMfg"] as? String ?? ""
            peNewAssessmentInProgress.iDT = diluentMfg
            peNewAssessmentInProgress.micro = ""
            peNewAssessmentInProgress.residue = ""
            CoreDataHandlerPE().updateInDoGInProgressInDB(newAssessment: peNewAssessmentInProgress, fromInvo: true)
            let inVoDataNew = InovojectData(id: 0, vaccineMan: DiluentMfg, name: VName, ampuleSize: AmpuleSizeStr, ampulePerBag: String(AmpulePerbag), bagSizeType: BagSizeType, dosage: Dosage, dilute: DiluentMfg, invoHatchAntibiotic: HatcheryAntibioticsIntVal, invoHatchAntibioticText: "", invoProgramName: "", doaDilManOther: "")
            let id = self.saveInovojectInPEModule(inovojectData: inVoDataNew, assessment: allAssesmentArr[0] as? PE_AssessmentInProgress ?? PE_AssessmentInProgress())
            inVoDataNew.id = id
        }
    }
    // MARK: - Handle PE Posting Assessment images List API Responce
    private func handlGetPostingAssessmentImagesListByUser(_ json: JSON) {
        var dataDic : [String:Any] = [:]
        if let string = json.rawString() {
            dataDic = string.convertToDictionary() ?? [:]
        }
        let dataArray = dataDic["Data"] as? [Any] ?? []
        for obj in dataArray {
            DispatchQueue.main.async {
                let objDic = obj as? [String:Any] ?? [:]
                let base64Encoded = objDic["ImageBase64"] as? String ?? ""
                let DisplayId = objDic["DisplayId"] as? String ?? ""
                let DeviceId = objDic["Device_Id"] as? String ?? ""
                let UserId = objDic["UserId"] as? Int ?? 0
                let Assessment_Id = objDic["Assessment_Id"] as? Int ?? 0
                let Module_Assessment_Categories_Id = objDic["Module_Assessment_Categories_Id"] as? Int ?? 0
                let decodedData = Data(base64Encoded: base64Encoded) ?? Data()
                let AppCreationTime = DisplayId.replacingOccurrences(of: "C-", with: "")
                let imageCount = self.getImageCountInPEModule()
                CoreDataHandlerPE().saveImageInGetApi(imageId:imageCount+1,imageData:decodedData)
                CoreDataHandlerPE().saveImageIdGetApi(imageId:imageCount+1,userID:UserId,catID:Module_Assessment_Categories_Id,assID:Assessment_Id,dataToSubmitID:AppCreationTime)
                
                CoreDataHandlerPE().saveImageDraftIdGetApi(imageId:imageCount+1,userID:UserId,catID:Module_Assessment_Categories_Id,assID:Assessment_Id,dataToSubmitID:DeviceId)
            }
        }
        let allAssesmentDraftArr = self.getAllDateArrayStoredDraft()
        if allAssesmentDraftArr.count  > 0 {
            let count = allAssesmentDraftArr.count//getDraftCountFromDb()
            self.labelDraftCount.text = String(count)
            self.showDraftCount()
            if count == 0 {
                self.hideDraftCount()
            }
        } else {
            self.labelDraftCount.text  = "0"
            self.hideDraftCount()
        }
        self.dismissGlobalHUD(self.view)
        let dontGetRejected = UserDefaults.standard.value(forKey: "dontGetRejectedAssessment") as? Bool
        if dontGetRejected ?? false{
            print(appDelegateObj.testFuntion())
        }
        else
        {
            getRejectedAssessmentListByUser()
        }
        
    }
    // MARK: - Handle PE Rejected Assessment List API Responce
    private func handlGetRejectedAssessmentListByUser(_ json: JSON) {
        let dataArray = extractRejectedDataArray(from: json)
        if dataArray.count > 0 {
            self.deleteAllDataWithUserID("PE_AssessmentRejected")
        }
        var count = 0
        for obj in dataArray {
            count += 1
            UserDefaults.standard.setValue(count, forKey: "rejectedCountIS")
            handleRejectedAssessmentObject(obj)
        }
    }

    private func extractRejectedDataArray(from json: JSON) -> [Any] {
        var dataDic: [String: Any] = [:]
        if let string = json.rawString() {
            dataDic = string.convertToDictionary() ?? [:]
        }
        return dataDic["Data"] as? [Any] ?? []
    }

    private func handleRejectedAssessmentObject(_ obj: Any) {
        let objDic = obj as? [String: Any] ?? [:]
        let peNewAssessmentWas = parseRejectedAssessment(objDic)
        handleRejectedSanitation(objDic, serverAssessmentId: peNewAssessmentWas.serverAssessmentId!)
        self.sanitationQuesArr = SanitationEmbrexQuestionMasterDAO.sharedInstance.fetchAssessmentSanitationQuestions(
            userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "",
            assessmentId: peNewAssessmentWas.serverAssessmentId!
        )
        UserDefaults.standard.set(String(peNewAssessmentWas.serverAssessmentId!), forKey: "currentServerAssessmentId")
        handleRejectedCategoriesAndQuestions(for: peNewAssessmentWas, objDic: objDic)
        // You can add more helpers for scores, comments, etc., if needed
    }

    private func parseRejectedAssessment(_ objDic: [String: Any]) -> PENewAssessment {
        let peNewAssessmentWas = PENewAssessment()
        let serverAssessmentId = objDic["AssessmentId"] as? Int ?? 0
        let EvaluationId = objDic["EvaluationId"] as? Int ?? 0

        peNewAssessmentWas.serverAssessmentId = String(serverAssessmentId)
        peNewAssessmentWas.siteId = objDic["SiteId"] as? Int ?? 0
        peNewAssessmentWas.siteName = objDic["SiteName"] as? String ?? ""
        peNewAssessmentWas.customerId = objDic["CustomerId"] as? Int ?? 0
        peNewAssessmentWas.customerName = objDic["CustomerName"] as? String ?? ""
        peNewAssessmentWas.hatcheryAntibiotics = 0
        peNewAssessmentWas.evaluationID  = EvaluationId
        peNewAssessmentWas.isHandMix = objDic["Handmix"] as? Bool ?? false
        if let doubleSanitation = objDic["DoubleSanitation"] as? Bool, doubleSanitation {
            peNewAssessmentWas.hatcheryAntibiotics = 1
        }
        peNewAssessmentWas.userID = objDic["UserId"] as? Int ?? 0
        peNewAssessmentWas.evaluationDate = convertDateFormatter(date: objDic["EvaluationDate"] as? String ?? "")
        peNewAssessmentWas.evaluatorName = objDic["UserName"] as? String ?? ""
        peNewAssessmentWas.evaluatorID = objDic["UserId"] as? Int ?? 0
        peNewAssessmentWas.evaluationName = objDic["EvaluationName"] as? String ?? ""
        peNewAssessmentWas.evaluationID = objDic["EvaluationId"] as? Int ?? 0
        peNewAssessmentWas.incubation = objDic["IncubationStyleName"] as? String ?? ""
        peNewAssessmentWas.breedOfBird = objDic["BreedBirdsName"] as? String ?? ""
        peNewAssessmentWas.statusType = objDic["Status_Type"] as? Int ?? 0
        peNewAssessmentWas.breedOfBirdOther = objDic["BreedOfBirdsOther"] as? String ?? ""
        peNewAssessmentWas.dataToSubmitID = objDic["AppCreationTime"] as? String ?? ""
        peNewAssessmentWas.manufacturer = objDic["ManufacturerName"] as? String ?? ""
        peNewAssessmentWas.rejectionComment = objDic["RejectionComments"] as? String ?? ""
        peNewAssessmentWas.visitID = objDic["VisitId"] as? Int ?? 0
        peNewAssessmentWas.visitName = objDic["VisitName"] as? String ?? ""
        peNewAssessmentWas.selectedTSRID = objDic["TSRId"] as? Int ?? 0
        peNewAssessmentWas.countryName = objDic[Constants.countryNamStr] as? String ?? ""
        peNewAssessmentWas.countryID = objDic["CountryId"] as? Int ?? 0
        peNewAssessmentWas.clorineName = objDic["ChlorineText"] as? String ?? ""
        peNewAssessmentWas.clorineId = objDic["ChlorineId"] as? Int ?? 0
        peNewAssessmentWas.fluid = objDic["IsInovoFluids"] as? Bool ?? false
        peNewAssessmentWas.basicTransfer = objDic["IsBasicTrfAssessment"] as? Bool ?? false
        peNewAssessmentWas.extndMicro = objDic["IsInterMicrobial"] as? Bool ?? false
        peNewAssessmentWas.refrigeratorNote = objDic["RefrigeratorNote"] as? String ?? ""
        peNewAssessmentWas.IsEMRequested = objDic["IsEMRequested"] as? Bool ?? false
        peNewAssessmentWas.emRejectedComment = objDic["EMRejectedComment"] as? String ?? ""
        peNewAssessmentWas.isPERejected = objDic["IsPERejected"] as? Bool ?? false
        peNewAssessmentWas.isEMRejected = objDic["IsEMRejected"] as? Bool ?? false
        peNewAssessmentWas.sanitationValue = objDic["SanitationEmbrex"] as? Bool ?? false

        let visitDetailsArray = CoreDataHandlerPE().fetchDetailsFor(entityName: "PE_Approvers")
        let visitNameArray = visitDetailsArray.value(forKey: "username") as? NSArray ?? NSArray()
        let visitIDArray = visitDetailsArray.value(forKey: "id") as? NSArray ?? NSArray()
        if peNewAssessmentWas.selectedTSRID != 0,
           visitIDArray.contains(peNewAssessmentWas.selectedTSRID as Any) {
            let indexOfe = visitIDArray.index(of: peNewAssessmentWas.selectedTSRID as Any)
            let TSRName = visitNameArray[indexOfe] as? String ?? ""
            peNewAssessmentWas.selectedTSR = TSRName
        }

        let manuOthers = objDic["ManufacturerOther"] as? String ?? ""
        if manuOthers != "" {
            peNewAssessmentWas.manufacturer = "S" + manuOthers
        }
        let eggStr = objDic["EggsPerFlatName"] as? String ?? "0"
        peNewAssessmentWas.noOfEggs = Int64(eggStr)
        let eggsOthers = objDic["EggsPerFlatOther"]  as? String ?? ""
        if eggsOthers != "" {
            let txt = eggsOthers
            let str = txt + "000"
            let iii = Int64(str)
            if iii != nil {
                peNewAssessmentWas.noOfEggs = iii!
            }
        }
        let f = objDic["FlockAgeId"] as? Int ?? 0
        peNewAssessmentWas.isFlopSelected = f
        let Camera = objDic["Camera"] as? Bool ?? false
        peNewAssessmentWas.camera = Camera ? 1 : 0
        peNewAssessmentWas.notes = objDic["Notes"] as? String ?? ""
        let fsrSignatureImage = objDic["FSTSignatureImage"] as? String ?? ""
        peNewAssessmentWas.FSTSignatureImage = fsrSignatureImage

        return peNewAssessmentWas
    }

    private func handleRejectedSanitation(_ objDic: [String: Any], serverAssessmentId: String) {
        let sanitationEmbrexValue = objDic["SanitationEmbrex"] as? Bool ?? false
        if sanitationEmbrexValue {
            PEInfoDAO.sharedInstance.saveData(
                userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "",
                isExtendedPE: sanitationEmbrexValue,
                assessmentId: serverAssessmentId,
                date: nil,
                override: false
            )
        }
        let sanitationEmbrex = objDic["SanitationEmbrexScoresPostinData"] as? [[String: Any]] ?? []
        let jsonData = try? JSONSerialization.data(withJSONObject: sanitationEmbrex, options: .prettyPrinted)
        let jsonDecoder = JSONDecoder()
        if let jsonData = jsonData,
           let dtoArr = try? jsonDecoder.decode([PESanitationDTO].self, from: jsonData) {
            SanitationEmbrexQuestionMasterDAO.sharedInstance.saveServiceResponse(
                assessmentId: serverAssessmentId,
                userId: UserContext.sharedInstance.userDetailsObj?.userId ?? "",
                dtoArr: dtoArr
            )
        }
    }

    private func handleRejectedCategoriesAndQuestions(for assessment: PENewAssessment, objDic: [String: Any]) {
        jsonRe = (getJSON("QuestionAns") ?? JSON())
        pECategoriesAssesmentsResponse = PECategoriesAssesmentsResponse(jsonRe)
        let questionInfo = (getJSON("QuestionAnsInfo") ?? JSON())
        let infoImageDataResponse = InfoImageDataResponse(questionInfo)
        var peCategoryFilteredArray: [PECategory] = []
        for object in pECategoriesAssesmentsResponse.peCategoryArray {
            if assessment.evaluationID == object.evaluationID, object.id != 36 {
                peCategoryFilteredArray.append(object)
            }
        }
        if peCategoryFilteredArray.count > 0 {
            for cat in peCategoryFilteredArray {
                for (index, ass) in cat.assessmentQuestions.enumerated() {
                    var peNewAssessmentNew = assessment
                    peNewAssessmentNew.serverAssessmentId = assessment.serverAssessmentId
                    peNewAssessmentNew.cID = index
                    peNewAssessmentNew.catID = cat.id
                    peNewAssessmentNew.catName = cat.categoryName
                    peNewAssessmentNew.catMaxMark = cat.maxMark
                    peNewAssessmentNew.sequenceNo = cat.id
                    peNewAssessmentNew.sequenceNoo = cat.sequenceNo
                    peNewAssessmentNew.catResultMark = cat.maxMark
                    peNewAssessmentNew.catEvaluationID = cat.evaluationID
                    peNewAssessmentNew.catISSelected = cat.isSelected ? 1 : 0
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
                    peNewAssessmentNew.isChlorineStrip = objDic["HasChlorineStrips"] as? Int ?? 0
                    peNewAssessmentNew.isAutomaticFail = objDic["IsAutomaticFail"] as? Int ?? 0
                    peNewAssessmentNew.manufacturer = assessment.manufacturer
                    peNewAssessmentNew.noOfEggs = assessment.noOfEggs
                    peNewAssessmentNew.informationImage = ass.informationImage
                    peNewAssessmentNew.informationText = infoImageDataResponse.getInfoTextByQuestionId(questionID: ass.id ?? 151)
//                    CoreDataHandlerPE().saveRejectedAssessmentInDB(newAssessment: peNewAssessmentNew)
                }
            }
        }
    }
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
