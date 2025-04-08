//
//  CaptureNecropsyDataViewController.swift
//  Zoetis -Feathers
//
//  Created by "" on 8/25/16.
//  Copyright © 2016 "". All rights reserved.
//

import UIKit
import CoreData
import Reachability
import Gigya
import GigyaTfa
import GigyaAuth

class CaptureNecropsyDataViewController: BaseViewController,UICollectionViewDelegate,UICollectionViewDataSource,  UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UIScrollViewDelegate,AddFarmPop,refreshPageafterAddFeed,userLogOut , UITextFieldDelegate,openNotes,infoLinkk,summaryReportProtocol , syncApi, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - VARIABLES
    fileprivate var currentTextField: UITextField?
    var backBttnn = UIButton()
    let objApiSync = ApiSync()
    var mesureValue: String = ""
    var incrementValue  = 0
    let buttonbg = UIButton ()
    var customPopVi :UserListView!
    var photoDict = NSMutableDictionary()
    var bitdImageIndexPath  = IndexPath ()
    var nsIndexPathFromExist = Int()
    var necIdFromExist  = Int()
    var notesBGbtn = UIButton()
    var lngId = NSInteger()
    var farmName1 = String()
    var lastSelectedIndex: IndexPath?
    var bursaSelectedIndex :IndexPath?
    var arrSwichUpdate  = NSArray()
    var captureNecropsy = [NSManagedObject]()
    var buttonPopup = UIButton ()
    let buttonDroper = UIButton ()
    var btnTag = Int()
    var finalizeValue = Int()
    var isFirstTimeLaunch = Bool()
    
    var customPopView1 :SimpleCustomView!
    var isFarmClick = Bool()
    var isNewFarm = Bool()
    var isBirdClick = Bool()
    var farmRow = Int()
    var tableViewSelectedRow = Int()
    var buttonback = UIButton()
    var summaryRepo :summaryReport!
    var ageArray = NSMutableArray()
    var houseArray = NSMutableArray()
    var totalProfileArray:[CaptureNecropsyCollectionViewCellModel]!
    var editFinalizeValue = Int()
    var postingIdFromExisting = Int()
    var postingIdFromExistingNavigate = String()
    var itemsData :        NSMutableArray = NSMutableArray()
    var dataSkeltaArray :  NSMutableArray = NSMutableArray()
    var dataArrayCocoi :   NSMutableArray = NSMutableArray()
    var dataArrayGiTract : NSMutableArray = NSMutableArray()
    var dataArrayRes :     NSMutableArray = NSMutableArray()
    var dataArrayImmu :    NSMutableArray = NSMutableArray()
    var noOfBirdsArr  =    NSMutableArray()
    var captureNecdataSkeletaArray = NSArray ()
    var items = NSMutableArray ()
    var farmArray = NSMutableArray ()
    var categoryArray = NSMutableArray ()
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var activityView = UIActivityIndicatorView ()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    var activityIndicator = UIActivityIndicatorView()
    var boxView = UIView()
    var noOfBirdsArr1  = NSMutableArray()
    
    var arrayAddBirds  = NSMutableArray()
    var incremnet :Int = 5
    var button = UIButton()
    var ButtonList = NSMutableArray()
    
    var myPickerView = UIPickerView()
    
    var BirdSex = NSArray ()
    var selectedSexValue: String = "N/A"
    // MARK: - OUTLETS
    @IBOutlet weak var addBirdsScrollView: UIScrollView!
    @IBOutlet weak var syncNotiCount: UILabel!
    @IBOutlet weak var lblCustmer: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblComplex: UILabel!
    @IBOutlet weak var customerDisplayLbl: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var increaseBirdBtn: UIButton!
    @objc var traingleImageView: UIImageView!
    @IBOutlet weak var decBirdNumberBtn: UIButton!
    @IBOutlet weak var addFormBtn: UIButton!
    @IBOutlet weak var helpPopView: UIView!
    @IBOutlet weak var imageview1: UIImageView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var btnPopUp:    UIButton!
    @IBOutlet weak var btnForm: UIButton!
    @IBOutlet var longPressGestureOutlet: UILongPressGestureRecognizer!
    @IBOutlet weak var formCollectionView: UICollectionView!
    @IBOutlet weak var birdsCollectionView: UICollectionView!
//    @IBOutlet weak var MypickerView: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var neccollectionView: UICollectionView!
    
    let gigya =  Gigya.sharedInstance(GigyaAccount.self)
    var selectedBirdIndex = Int()
    let noDisposibleStr = "Non disponible."
    let noGrossLesionStr = "No gross lesions."
    let pasDeLesionStr = "Pas de lésion macroscopique."
    let noDataAvailStr = "No data available."
    let semLesMacroStr = "Sem lesões macroscópicas."
    // MARK: 🟠 - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objApiSync.delegeteSyncApi = self
        isFirstTimeLaunch = true
        
        BirdSex = ["Male", "Female" , "N/A"]
        
        if postingIdFromExistingNavigate == "Exting"{
            increaseBirdBtn.alpha = 1
            decBirdNumberBtn.alpha = 1
            addFormBtn.alpha = 1
        }
        
        if UserDefaults.standard.bool(forKey: "Unlinked") == true{
            customerDisplayLbl.isHidden = true
            lblCustmer.isHidden = true
        }
        else{
            customerDisplayLbl.isHidden = false
            lblCustmer.isHidden = false
        }
        
        Helper.showGlobalProgressHUDWithTitle(self.view, title: NSLocalizedString(appDelegateObj.loadingStr, comment: ""))
        loaderView.alpha = 1
        self.perform(#selector(CaptureNecropsyDataViewController.callFirstMethodToLoadView), with: nil, afterDelay:0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.set(finalizeValue, forKey: "finalizeValue")
        UserDefaults.standard.synchronize()
        userNameLabel.text! = UserDefaults.standard.value(forKey: "FirstName") as! String
        isNewFarm = false
        isBirdClick = false
        let isQuickLink : Bool = UserDefaults.standard.bool(forKey: "isQuickLink")
        if isQuickLink == true
        {
            Helper.showGlobalProgressHUDWithTitle(self.view, title: NSLocalizedString(appDelegateObj.loadingStr, comment: ""))
            self.perform(#selector(CaptureNecropsyDataViewController.loadformdata), with: nil, afterDelay:0)
            self.traingleImageView.frame = CGRect(x: 276, y: 229, width: 24, height: 24)
            let isQuickLink : Bool = false
            UserDefaults.standard.set(isQuickLink, forKey: "isQuickLink")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func addFarmsAction(_ sender: AnyObject) {
        appDelegateObj.testFuntion()
    }
    
    // MARK: 🟠 - METHODS AND FUNCTIONS
    fileprivate func saveImmuneCatValidation(_ status: Bool) {
        if status == true
        {
            if self.dataSkeltaArray.count > 0
            {
                self.neccollectionView.dataSource = self
                self.neccollectionView.delegate = self
                self.neccollectionView.reloadData()
            }
            if self.farmArray.count > 0
            {
                self.formCollectionView.dataSource = self
                self.formCollectionView.delegate = self
                self.formCollectionView.reloadData()
                
                if self.postingIdFromExistingNavigate == "Exting"{
                    self.formCollectionView.selectItem(at: IndexPath(item: self.nsIndexPathFromExist, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
                }
                else{
                    self.formCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
                }
            }
            
            if self.items.count > 0
            {
                self.birdsCollectionView.dataSource = self
                self.birdsCollectionView.delegate = self
                self.birdsCollectionView.reloadData()
                self.birdsCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
            }
            
            self.tableView.reloadData()
            let rowToSelect:IndexPath = IndexPath(row: 0, section: 0)
            self.tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: UITableView.ScrollPosition.none)
            self.tableView(self.tableView, didSelectRowAt: rowToSelect)
            self.loaderView.alpha = 0
            Helper.dismissGlobalHUD(self.view)
        }
    }
    
    fileprivate func saveResCatValidation(_ status: Bool) {
        if status == true {
            self.saveGiTractCat({ (status) in
                if status == true {
                    self.saveImmuneCat({ (status) in
                        saveImmuneCatValidation(status)
                    })
                }
            })
        }
    }
    
    @objc func callFirstMethodToLoadView() {
        self.callLoad { (status) in
            
            if status == true {
                self.saveSkeletonCat{ (status) in
                    if status == true {
                        self.saveCocoiCat({ (status) in
                            if status == true {
                                self.saveResCat({ (status) in
                                    saveResCatValidation(status)
                                })
                            }
                        })
                    }
                }
            }
        }
    }
    // MARK: 🟠 Call Load Method
    func callLoad(_ completion: (_ status: Bool) -> Void) {
        tableViewSelectedRow = 0
        UserDefaults.standard.set(0, forKey: "clickindex")
        UserDefaults.standard.synchronize()
        let langId = UserDefaults.standard.integer(forKey: "lngId")
        if langId == 3 {
            lblDate.text = UserDefaults.standard.value(forKey: "dateFrench") as? String
        }
        else{
            lblDate.text = UserDefaults.standard.value(forKey: "date") as? String
        }
        lblComplex.text = UserDefaults.standard.value(forKey: "complex") as? String
        lblCustmer.text = UserDefaults.standard.value(forKey: "custmer") as? String
        
        isFarmClick = false
        btnTag = 0
        var postingId = Int()
        if postingIdFromExistingNavigate == "Exting"{
            self.farmRow = nsIndexPathFromExist
            postingId = postingIdFromExisting
            self.captureNecropsy =  CoreDataHandler().FetchNecropsystep1NecId(postingId as NSNumber) as! [NSManagedObject]
        } else {
            self.farmRow = 0
            postingId = UserDefaults.standard.integer(forKey: "necId") as Int
            self.captureNecropsy =  CoreDataHandler().FetchNecropsystep1neccId(postingId as NSNumber) as! [NSManagedObject]
        }
        
        for object in captureNecropsy {
            let noOfBirds : Int = Int(object.value(forKey: "noOfBirds") as! String)!
            let noOfBirdsArr  = NSMutableArray()
            var numOfLoop = Int()
            numOfLoop = 0
            
            for i in 0..<noOfBirds {
                numOfLoop = i + 1
                if numOfLoop > 10 {
                } else {
                    noOfBirdsArr.add(i+1)
                }
            }
            
            items.add(noOfBirdsArr)
            farmArray.add(object.value(forKey: "farmName")!)
            ageArray.add(object.value(forKey: "age")!)
            houseArray.add(object.value(forKey: "houseNo")!)
            
            
        }
        categoryArray = [NSLocalizedString("Skeletal/Muscular/Integumentary", comment: ""), NSLocalizedString("Coccidiosis", comment: ""), NSLocalizedString("GI Tract", comment: ""),NSLocalizedString("Respiratory", comment: ""), NSLocalizedString("Immune/Others", comment: "")]
        
        self.addBirdInNotes()
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        imagePicker.delegate = self
        incrementValue = 0
        completion (true)
        
    }
    // MARK: 🟠 Add Birds
    func addBirdInNotes()
    {
        if isFirstTimeLaunch == false
        {
            isFirstTimeLaunch = false
        }
        
        let catArr = ["skeltaMuscular","Coccidiosis","GITract","Resp","Immune"] as NSArray
        for i in 0..<catArr.count
        {
            for j in 0..<farmArray.count
            {
                for x in 0..<(items[j] as AnyObject).count
                {
                    let numOfBird = Int((items.object(at: j) as AnyObject).object(at: x) as! NSNumber) as Int
                    var  necId = Int()
                    necId = getNecIdChicken()
                    
                    let isNotes =  CoreDataHandler().fetchNoofBirdWithNotes(catArr[i] as! String, formName: farmArray[j] as! String, birdNo: numOfBird as NSNumber , necId: necId as NSNumber)
                    
                    if isNotes.count > 0
                    {
                        let note : NotesBird = isNotes[0] as! NotesBird
                        CoreDataHandler().updateNoofBirdWithNotes(note.catName!,  formName: note.formName!, birdNo: note.noofBirds!,notes:note.notes! ,necId: necId as NSNumber,isSync :true)
                    }
                    else
                    {
                        CoreDataHandler().saveNoofBirdWithNotes(catArr[i] as! String, notes: "", formName: farmArray[j] as! String, birdNo: (items.object(at: j) as AnyObject).object(at: x) as! NSNumber, index: x , necId: necId as NSNumber, isSync :true)
                    }
                }
            }
        }
    }
    // MARK: 🟢 Save Skeleton Data to Database
    fileprivate func handleSkleta(_ skleta: Skeleta, _ i: Int, _ birdnumber: Any, _ j: Int, _ necId: Int) {
        if skleta.measure! == "Y,N" {
            
            let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "skeltaMuscular", obsName: skleta.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: 0 , index: j, obsId: Int(truncating: skleta.observationId ?? 0),measure: trimmed,quickLink:skleta.quicklinks!,necId :necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:skleta.refId!, actualText: "" )
        } else if ( skleta.measure! == "Actual"){
            
            let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "skeltaMuscular", obsName: skleta.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: 0 , index: j, obsId: Int(truncating:skleta.observationId ?? 0),measure: trimmed,quickLink:skleta.quicklinks!,necId:necId as NSNumber ,isSync:true,lngId:lngId as NSNumber,refId:skleta.refId!, actualText: "")
        } else {
            let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let array = (trimmed.components(separatedBy: ",") as [String])
            
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "skeltaMuscular", obsName: skleta.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: Int(array[0])! , index: j, obsId: Int(truncating: skleta.observationId ?? 0),measure: trimmed,quickLink:skleta.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:skleta.refId!, actualText: "")
        }
    }
    
    fileprivate func handleSkeletenArr(_ skeletenArr: NSMutableArray, _ birdnumber: Any, _ i: Int, _ necId: Int) {
        for j in 0..<skeletenArr.count {
            
            if ((skeletenArr.object(at: j) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                
                let skleta : Skeleta = skeletenArr.object(at: j) as! Skeleta
                let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(birdnumber as! NSNumber, farmname: farmArray[i] as! String, catName: "skeltaMuscular",Obsid: skleta.observationId!,necId : necId as NSNumber)
                if FetchObsArr.count > 0 {
                    
                } else {
                    handleSkleta(skleta, i, birdnumber, j, necId)
                }
            } else {
                let skleta : Skeleta = skeletenArr.object(at: j) as! Skeleta
                CoreDataHandler().deleteCaptureNecropsyViewDataWithObsID(skleta.observationId!,necId: necId as NSNumber)
            }
        }
    }
    
    func saveSkeletonCat(_ completion: (_ status: Bool) -> Void) {
        let farm = farmArray.object(at: nsIndexPathFromExist)
        UserDefaults.standard.set(farm, forKey: "farm")
        UserDefaults.standard.synchronize()
        
        let bird = (items.object(at: 0) as AnyObject).object(at: 0)
        UserDefaults.standard.set(bird, forKey: "bird")
        UserDefaults.standard.synchronize()
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        let skeletenArr =   CoreDataHandler().fetchAllSeettingdataWithLngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        var  necId = Int()
        
        if postingIdFromExistingNavigate == "Exting"{
            necId =  postingIdFromExisting
        } else {
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        for i in 0..<farmArray.count {
            for x in 0..<(items[i] as AnyObject).count {
                let birdnumber = (items.object(at: i) as AnyObject).object(at: x)
                
                handleSkeletenArr(skeletenArr, birdnumber, i, necId)
            }
        }
        
        dataSkeltaArray =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird as! NSNumber, farmname: farm as! String, catName: "skeltaMuscular",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        
        completion (true)
    }
    // MARK: 🟢 Save Coccidiosis Data to Database
    fileprivate func handleCocooiData(_ cocoii: NSMutableArray, _ j: Int, _ birdnumber: Any, _ i: Int, _ necId: Int) {
        if ((cocoii.object(at: j) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
            let cocoiDis : Coccidiosis = cocoii.object(at: j) as! Coccidiosis
            
            let FetchObsArr =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(birdnumber as! NSNumber, farmname: farmArray[i] as! String, catName: "Coccidiosis" ,Obsid: cocoiDis.observationId!,necId:necId as NSNumber)
            if FetchObsArr.count > 0 {
            } else {
                if cocoiDis.measure! == "Y,N" {
                    let trimmed = cocoiDis.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Coccidiosis", obsName: cocoiDis.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: 0 , index: j, obsId: Int(truncating:cocoiDis.observationId ?? 0),measure: trimmed,quickLink: cocoiDis.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:cocoiDis.refId!, actualText: "" )
                } else if ( cocoiDis.measure! == "Actual"){
                    let trimmed = cocoiDis.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Coccidiosis", obsName: cocoiDis.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: 0 , index: j, obsId: Int(truncating: cocoiDis.observationId!),measure: trimmed,quickLink: cocoiDis.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:cocoiDis.refId!, actualText: "")
                } else {
                    let trimmed = cocoiDis.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let array = (trimmed.components(separatedBy: ",") as [String])
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Coccidiosis", obsName: cocoiDis.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: Int(array[0])! , index: j, obsId: Int(truncating: cocoiDis.observationId ?? 0),measure: trimmed,quickLink: cocoiDis.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:cocoiDis.refId!, actualText: "")
                }
            }
        } else {
            let cocoiDis : Coccidiosis = cocoii.object(at: j) as! Coccidiosis
            CoreDataHandler().deleteCaptureNecropsyViewDataWithObsID(cocoiDis.observationId!, necId: necId as NSNumber)
            
        }
    }
    
    func saveCocoiCat(_ completion: (_ status: Bool) -> Void) {
        let farm = farmArray.object(at: nsIndexPathFromExist)
        UserDefaults.standard.set(farm, forKey: "farm")
        UserDefaults.standard.synchronize()
        let bird = (items.object(at: 0) as AnyObject).object(at: 0)
        UserDefaults.standard.set(bird, forKey: "bird")
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        UserDefaults.standard.synchronize()
        let cocoii = CoreDataHandler().fetchAllCocoiiDataUsinglngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        var necId = Int()
        
        if postingIdFromExistingNavigate == "Exting" {
            necId = postingIdFromExisting
        } else {
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        for i in 0..<farmArray.count {
            for x in 0..<(items[i] as AnyObject).count {
                let birdnumber = (items.object(at: i) as AnyObject).object(at: x)
                for j in 0..<cocoii.count {
                    handleCocooiData(cocoii, j, birdnumber, i, necId)
                }
            }
        }
        
        dataArrayCocoi = CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird as! NSNumber, farmname: farm as! String, catName: "Coccidiosis",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        completion (true)
        
    }
    // MARK: 🟢 Save GiTract Data to Database
    fileprivate func handleFetchObsArr(_ FetchObsArr: NSArray, _ gitract: GITract, _ i: Int, _ birdnumber: Any, _ j: Int, _ necId: Int) {
        if FetchObsArr.count > 0 {
            
        } else {
            if gitract.measure! == "Y,N" {
                let trimmed = gitract.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "GITract", obsName: gitract.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: 0 , index: j, obsId: Int(truncating:gitract.observationId!),measure: trimmed,quickLink: gitract.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:gitract.refId!, actualText: "")
            } else if ( gitract.measure! == "Actual") {
                let trimmed = gitract.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "GITract", obsName: gitract.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: 0 , index: j, obsId: Int(truncating:gitract.observationId!),measure: trimmed,quickLink: gitract.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:gitract.refId!, actualText: "")
            } else {
                let trimmed = gitract.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let array = (trimmed.components(separatedBy: ",") as [String])
                
                CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "GITract", obsName: gitract.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: Int(array[0])! , index: j, obsId: Int(truncating:gitract.observationId!),measure: trimmed,quickLink: gitract.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:gitract.refId!, actualText: "" )
            }
        }
    }
    
    fileprivate func handleBirdNumber(_ gitract: NSMutableArray, _ birdnumber: Any, _ i: Int, _ necId: Int) {
        for j in 0..<gitract.count {
            if ((gitract.object(at: j) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                
                let gitract : GITract = gitract.object(at: j) as! GITract
                let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(birdnumber as! NSNumber, farmname: farmArray[i] as! String, catName: "GITract",Obsid: gitract.observationId!,necId: necId as NSNumber)
                self.handleFetchObsArr(FetchObsArr, gitract, i, birdnumber, j, necId)
            } else {
                let gitract : GITract = gitract.object(at: j) as! GITract
                CoreDataHandler().deleteCaptureNecropsyViewDataWithObsID(gitract.observationId!,necId: necId as NSNumber)
            }
        }
    }
    
    func saveGiTractCat(_ completion: (_ status: Bool) -> Void) {
        let farm = farmArray.object(at: nsIndexPathFromExist)
        UserDefaults.standard.set(farm, forKey: "farm")
        UserDefaults.standard.synchronize()
        let bird = (items.object(at: 0) as AnyObject).object(at: 0)
        UserDefaults.standard.set(bird, forKey: "bird")
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        UserDefaults.standard.synchronize()
        let gitract =  CoreDataHandler().fetchAllGITractDataUsingLngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        var  necId = Int()
        
        if postingIdFromExistingNavigate == "Exting" {
            necId = postingIdFromExisting
        } else {
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        for i in 0..<farmArray.count {
            for x in 0..<(items[i] as AnyObject).count {
                let birdnumber = (items.object(at: i) as AnyObject).object(at: x)
                self.handleBirdNumber(gitract, birdnumber, i, necId)
            }
        }
        
        dataArrayGiTract =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird as! NSNumber, farmname: farm as! String, catName: "GITract",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        
        completion (true)
        
    }
    // MARK: 🟢 Save Respiratory Data to Database
    fileprivate func handleRespiratoryValidation(_ resp: Respiratory, _ i: Int, _ birdnumber: Any, _ j: Int, _ necId: Int) {
        if resp.measure! == "Y,N" {
            let trimmed = resp.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Resp", obsName: resp.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: 0 , index: j, obsId: Int(truncating:resp.observationId!),measure:trimmed,quickLink: resp.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:resp.refId!, actualText: "")
        } else if ( resp.measure! == "Actual"){
            let trimmed = resp.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Resp", obsName: resp.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber,  obsPoint: 0 , index: j, obsId: Int(truncating:resp.observationId!),measure:trimmed,quickLink: resp.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:resp.refId!, actualText: "")
        } else {
            let trimmed = resp.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let array = (trimmed.components(separatedBy: ",") as [String])
            
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Resp", obsName: resp.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber, obsPoint: Int(array[0])! , index: j, obsId: Int(truncating:resp.observationId!),measure:trimmed,quickLink: resp.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:resp.refId!, actualText: "")
            
        }
    }
    
    fileprivate func handleRespArr(_ resp: NSMutableArray, _ birdnumber: Any, _ i: Int, _ necId: Int) {
        for j in 0..<resp.count {
            if ((resp.object(at: j) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                let resp : Respiratory = resp.object(at: j) as! Respiratory
                
                let FetchObsArr =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(birdnumber as! NSNumber, farmname: farmArray[i] as! String, catName: "Resp",Obsid: resp.observationId!,necId: necId as NSNumber)
                if FetchObsArr.count > 0 {
                } else {
                    handleRespiratoryValidation(resp, i, birdnumber, j, necId)
                }
            } else {
                let resp : Respiratory = resp.object(at: j) as! Respiratory
                CoreDataHandler().deleteCaptureNecropsyViewDataWithObsID(resp.observationId!,necId: necId as NSNumber)
            }
        }
    }
    
    func saveResCat(_ completion: (_ status: Bool) -> Void) {
        
        let farm = farmArray.object(at: nsIndexPathFromExist)
        UserDefaults.standard.set(farm, forKey: "farm")
        UserDefaults.standard.synchronize()
        let bird = (items.object(at: 0) as AnyObject).object(at: 0)
        UserDefaults.standard.set(bird, forKey: "bird")
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        UserDefaults.standard.synchronize()
        let resp =  CoreDataHandler().fetchAllRespiratoryusingLngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        var  necId = Int()
        
        if postingIdFromExistingNavigate == "Exting" {
            
            necId =  postingIdFromExisting
        } else {
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        for i in 0..<farmArray.count {
            for x in 0..<(items[i] as AnyObject).count {
                let birdnumber = (items.object(at: i) as AnyObject).object(at: x)
                handleRespArr(resp, birdnumber, i, necId)
            }
        }
        
        dataArrayRes =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird as! NSNumber, farmname: farm as! String, catName: "Resp",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        
        completion (true)
    }
    // MARK: 🟢  Save Immune Category Data to Database
    fileprivate func handleImmuneObservationField(_ immune: Immune, _ i: Int, _ birdnumber: Any, _ j: Int, _ trimmed: String, _ necId: Int) {
        if immune.observationField == Constants.maleFemaleStr {
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber,  obsPoint: 0 , index: j, obsId: Int(truncating:immune.observationId!),measure: trimmed,quickLink: immune.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune.refId!, actualText: "0")
            
        } else {
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber,  obsPoint: 0 , index: j, obsId: Int(truncating:immune.observationId!),measure: trimmed,quickLink: immune.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune.refId!, actualText: "0.0")
        }
    }
    
    fileprivate func handleImmuneMeasureValidation(_ immune: Immune, _ i: Int, _ birdnumber: Any, _ j: Int, _ necId: Int) {
        if immune.measure! == "Y,N" {
            let trimmed = immune.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber,  obsPoint: 0 , index: j, obsId: Int(truncating:immune.observationId!),measure: trimmed,quickLink: immune.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune.refId!, actualText: immune.measure ?? "")
        } else if ( immune.measure! == "Actual") {
            let trimmed = immune.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            handleImmuneObservationField(immune, i, birdnumber, j, trimmed, necId)
        }
        
        else if ( immune.measure! == "F,M") {  /// New Addition for Bird Sex
            let trimmed = immune.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if immune.observationField == Constants.maleFemaleStr {
                CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber,  obsPoint: 0 , index: j, obsId: Int(truncating:immune.observationId!),measure: trimmed,quickLink: immune.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune.refId!, actualText: "0")
                
            }
            
        } else {
            let trimmed = immune.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let array = (trimmed.components(separatedBy: ",") as [String])
            
            if immune.refId == 58 {
                
                CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber,  obsPoint: Int(array[3])! , index: j, obsId: Int(truncating:immune.observationId!),measure: trimmed,quickLink: immune.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune.refId!, actualText: "0.0")
                
            } else {
                CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune.observationField!, formName:farmArray[i] as! String , obsVisibility: false, birdNo: birdnumber as! NSNumber,  obsPoint: Int(array[0])! , index: j, obsId: Int(truncating:immune.observationId!),measure: trimmed,quickLink: immune.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune.refId!, actualText: "0.0")
                
            }
        }
    }
    
    fileprivate func handleVisiblityCheckSaveImmuneCatValidation(_ immu: NSMutableArray, _ birdnumber: Any, _ i: Int, _ necId: Int) {
        for j in 0..<immu.count {
            if ((immu.object(at: j) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                let immune : Immune = immu.object(at: j) as! Immune
                
                let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(birdnumber as! NSNumber, farmname: farmArray[i] as! String, catName: "Immune",Obsid: immune.observationId!,necId:necId as NSNumber)
                
                if FetchObsArr.count > 0 {
                } else {
                    handleImmuneMeasureValidation(immune, i, birdnumber, j, necId)
                }
            } else {
                let immune : Immune = immu.object(at: j) as! Immune
                CoreDataHandler().deleteCaptureNecropsyViewDataWithObsID(immune.observationId!,necId: necId as NSNumber)
            }
        }
    }
    
    func saveImmuneCat(_ completion: (_ status: Bool) -> Void) {
        let farm = farmArray.object(at: nsIndexPathFromExist)
        UserDefaults.standard.set(farm, forKey: "farm")
        UserDefaults.standard.synchronize()
        let bird = (items.object(at: 0) as AnyObject).object(at: 0)
        UserDefaults.standard.set(bird, forKey: "bird")
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        UserDefaults.standard.synchronize()
        let immu =   CoreDataHandler().fetchAllImmuneUsingLngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        var  necId = Int()
        
        if postingIdFromExistingNavigate == "Exting"{
            
            necId = postingIdFromExisting
        } else {
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        for i in 0..<farmArray.count {
            for x in 0..<(items[i] as AnyObject).count {
                let birdnumber = (items.object(at: i) as AnyObject).object(at: x)
                handleVisiblityCheckSaveImmuneCatValidation(immu, birdnumber, i, necId)
            }
        }
        
        dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird as! NSNumber, farmname: farm as! String, catName: "Immune",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        completion (true)
        
    }

    // MARK: 🟠 Help PopUp
    @objc func clickHelpPopUp(_ sender:UIButton) {
        let infoImage = NSMutableArray()
        var skleta : CaptureNecropsyViewData!
        var obsName = String()
        var refId = Int()
        var obsNameArr = NSMutableArray()
        
        if btnTag == 0 {
            
            skleta = dataSkeltaArray.object(at: sender.tag) as! CaptureNecropsyViewData
            obsName  = skleta.obsName!
            refId = skleta.refId as! Int
            
            obsNameArr =  self.setObsImageDescForSkleta(desc: refId)
            
            if skleta.measure ==  "Y,N"
            {
                for i in 0..<2
                {
                    
                    let n  = String(describing: skleta.refId!)
                    if i == 0
                    {
                        let imageName = "skeltaMuscular" + "_" + n + "_n"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                        
                    }
                    
                    if i == 1
                    {
                        let imageName = "skeltaMuscular" + "_" + n + "_y"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                        
                    }
                }
                
            }
            
            else if skleta.measure ==  "Actual"
            {
                let image = UIImage(named:"image02")
                infoImage.add(image!)
                
            }
            else{
                let n  = String(describing: skleta.refId!)
                let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let array = (trimmed.components(separatedBy: ",") as [String])
                
                for i in 0..<array.count
                {
                    let imageName = "skeltaMuscular" + "_" + n + "_0" + String(i)
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    infoImage.add(image!)
                    
                }
            }
        }
        
        if btnTag == 1 {
            
            skleta  = dataArrayCocoi.object(at: sender.tag) as! CaptureNecropsyViewData
            obsName  = skleta.obsName!
            refId = skleta.refId as! Int
            obsNameArr =  self.setObsImageDescForCocodis(desc: refId)
            
            if skleta.measure ==  "Y,N"
            {
                for i in 0..<2
                {
                    let n  = String(describing: skleta.refId!)
                    
                    if i == 0
                    {
                        let imageName = "Coccidiosis" + "_" + n + "_n"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                    
                    if i == 1
                    {
                        let imageName = "Coccidiosis" + "_" + n + "_y"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                }
            }
            
            else if skleta.measure ==  "Actual"
            {
                let image = UIImage(named:"image02")
                infoImage.add(image!)
                
            }
            else{
                
                let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let array = (trimmed.components(separatedBy: ",") as [String])
                
                for i in 0..<array.count
                {
                    let n  = String(describing: skleta.refId!)
                    var imageName = "Coccidiosis" + "_" + n + "_0" + String(i)
                    
                    if lngId == 4{
                        if imageName == "Coccidiosis_23_00"
                        {
                            imageName = "CoccidiosisPor_23_00"
                        }
                    }
                    
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    infoImage.add(image!)
                }
            }
        }
        
        if btnTag == 2 {
            
            skleta  = dataArrayGiTract.object(at: sender.tag) as! CaptureNecropsyViewData
            obsName  = skleta.obsName!
            refId = skleta.refId as! Int
            obsNameArr =  self.setObsImageDescForGitract(desc: refId)
            
            if skleta.measure ==  "Y,N"
            {
                for i in 0..<2
                {
                    let n  = String(describing: skleta.refId!)
                    if i == 0
                    {
                        let imageName = "GITract" + "_" + n + "_n"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                    
                    if i == 1
                    {
                        let imageName = "GITract" + "_" + n + "_y"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                }
            }
            
            else if skleta.measure ==  "Actual"
            {
                let image = UIImage(named:"image02")
                infoImage.add(image!)
                
            }
            else{
                
                let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let array = (trimmed.components(separatedBy: ",") as [String])
                
                for i in 0..<array.count
                {
                    let n  = String(describing: skleta.refId!)
                    let imageName = "GITract" + "_" + n + "_0" + String(i)
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    infoImage.add(image!)
                }
            }
        }
        
        if btnTag == 3 {
            
            skleta  = dataArrayRes.object(at: sender.tag) as! CaptureNecropsyViewData
            obsName  = skleta.obsName!
            refId = skleta.refId as! Int
            obsNameArr =  self.setObsImageDescForResp(desc: refId)
            
            if skleta.measure ==  "Y,N"
            {
                for i in 0..<2
                {
                    let n  = String(describing: skleta.refId!)
                    if i == 0
                    {
                        let imageName = "Resp" + "_" + n + "_n"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                    
                    if i == 1
                    {
                        let imageName = "Resp" + "_" + n + "_y"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                }
            }
            
            else if skleta.measure ==  "Actual"
            {
                let image = UIImage(named:"image02")
                infoImage.add(image!)
            }
            else{
                
                let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                let array = (trimmed.components(separatedBy: ",") as [String])
                for i in 0..<array.count
                {
                    let n  = String(describing: skleta.refId!)
                    let imageName = "Resp" + "_" + n + "_0" + String(i)
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    infoImage.add(image!)
                }
            }
        }
        
        if btnTag == 4 {
            
            skleta  = dataArrayImmu.object(at: sender.tag) as! CaptureNecropsyViewData
            obsName  = skleta.obsName!
            refId = skleta.refId as! Int
            obsNameArr =  self.setObsImageDescForImmune(desc: refId)
            
            if skleta.measure ==  "Y,N"
            {
                
                for i in 0..<2
                {
                    let n  = String(describing: skleta.refId!)
                    
                    if i == 0
                    {
                        let imageName = "Immune" + "_" + n + "_n"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                    if i == 1
                    {
                        let imageName = "Immune" + "_" + n + "_y"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                }
            }
            
            else if skleta.measure ==  "Actual"
            {
                let image = UIImage(named:"image02")
                infoImage.add(image!)
                return
            }
            
            else if skleta.measure ==  "F,M"
            {
                let image = UIImage(named:"image02")
                infoImage.add(image!)
                return
            }
            
            else{
                
                if refId == 58
                {
                    let a = NSMutableArray()
                    
                    if lngId == 4
                    {
                        a.add("0")
                    }
                    else
                    {
                        a.add("0")
                        a.add("3")
                        a.add("7")
                    }
                    
                    for i in 0..<a.count
                    {
                        let n  = String(describing: skleta.refId!)
                        let imageName = "Immune" + "_" + n + "_0" + String(i)
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                }
                else
                {
                    
                    let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let array = (trimmed.components(separatedBy: ",") as [String])
                    
                    for i in 0..<array.count
                    {
                        let n  = String(describing: skleta.refId!)
                        let imageName = "Immune" + "_" + n + "_0" + String(i)
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        infoImage.add(image!)
                    }
                }
            }
        }
        buttonPopup = UIButton(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        buttonPopup.backgroundColor = UIColor(white: 0, alpha: 0.5)
        buttonPopup.addTarget(self, action: #selector(buttonActionpopup), for: .touchUpInside)
        
        self.view.addSubview(buttonPopup)
        
        self.customPopView1 =  SimpleCustomView(frame: CGRect(    x: 25, y: 150    , width: 975, height: 422))
        self.customPopView1.infoImages = infoImage
        self.customPopView1.obsNmae = obsName
        self.customPopView1.obsData = skleta
        self.customPopView1.btnIndex = btnTag
        self.customPopView1.obsDescArr = obsNameArr
        
        if postingIdFromExistingNavigate == "Exting"{
            self.customPopView1.necId =  postingIdFromExisting
        }
        else {
            self.customPopView1.necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        self.customPopView1.infoLinkkDelegate = self
        buttonPopup.addSubview(self.customPopView1!);
    }
    
    
    
    // MARK: 🟠 Setup Observation Images Description for Skeletan
    func setObsImageDescForSkleta(desc: Int) -> NSMutableArray {
        let languageDescriptions: [Int: [String]] = [
            1: [
                Constants.noLesion,
                "(<50%) footpad.",
                "(>50%) footpad or a footpad that is <50% but has toe involvement."
            ],
            3: [
                "Absence de lésion.",
                "(<50%) coussinet plantaire.",
                "(>50%) coussinet plantaire ou coussinet plantaire <50% mais dont les doigts sont impliqués."
            ],
            4: [
                "Sem lesão.",
                "(<50%) de calo no coxim plantar.",
                "(>50%) de calo ou envolvimento dos dedos."
            ]
        ]
        
        let yesNoDescriptions: [Int: [String]] = [
            1: ["No.", Constants.yesStr],
            3: ["Non.", "Oui."],
            4: ["Não.", "Sim."]
        ]
        
        let defaultDescriptions: [Int: [String]] = [
            1: ["N/A.", "N/A."],
            3: [self.noDisposibleStr, self.noDisposibleStr],
            4: ["N/A.", "N/A."]
        ]
        
        // Fetch language ID
        let lngId = UserDefaults.standard.integer(forKey: "lngId")
        
        var descriptions: [String] = []
        
        switch desc {
        case 1:
            descriptions = languageDescriptions[lngId] ?? defaultDescriptions[lngId] ?? [self.noDataAvailStr]
        case 2, 3, 4, 6, 8, 9, 11, 12, 13, 14, 16, 300, 10:
            descriptions = yesNoDescriptions[lngId] ?? defaultDescriptions[lngId] ?? [self.noDataAvailStr]
        case 5:
            descriptions = [
                Constants.noLesion,
                Constants.growth50,
                Constants.growth50GreaterStr
            ]
        case 7:
            switch lngId {
            case 1:
                descriptions = [Constants.normalStr, "Weak snap.", "Folding bone rather than snap."]
            case 3:
                descriptions = [Constants.normalStr, "Pression faible.", "Plier l'os plutôt que de casser."]
            case 4:
                descriptions = [Constants.normalStr, "Moderada resistência.", "Ausência de resistência óssea."]
            default:
                descriptions = [self.noDataAvailStr]
            }
        default:
            descriptions = defaultDescriptions[lngId] ?? [self.noDataAvailStr]
        }
        
        // Convert the array to NSMutableArray
        return NSMutableArray(array: descriptions)
    }
    
    
    // MARK: 🟠 Setup Observation images Description for Coccidiosis
    fileprivate func handleLngIdObsImageDescCase24(_ obsDescArr: NSMutableArray) {
        switch lngId {
        case 1:
            obsDescArr.add(self.noGrossLesionStr)
            obsDescArr.add("Few petechial hemorrhages.")
            obsDescArr.add("Numerous patechiae.")
            obsDescArr.add("Numerous petechiae and gut ballooning.")
            obsDescArr.add("Bloody and ballooned.")
        case 3:
            obsDescArr.add(self.pasDeLesionStr)
            obsDescArr.add("Quelques pétécchies.")
            obsDescArr.add("Nombreuses pétécchies.")
            obsDescArr.add("Nombreuses pétécchies et ballonement intestinal.")
            obsDescArr.add("Ballonné et sanguin.")
        case 4:
            obsDescArr.add(self.semLesMacroStr)
            obsDescArr.add("Petéquias externas podem aparecer e pequenas quantidades de muco alaranjado podem estar presentes.")
            obsDescArr.add("Petéquias + conteúdo alterado podem aparecer em maior intensidade.")
            obsDescArr.add("Petéquias + conteúdo laranja com alteração de mucosa, flocos de sangue/coágulos e inchaço.")
            obsDescArr.add("Embalonamento, presença de sangue com intestino espessado.")
        default:
            break
        }
    }
    
    fileprivate func handleLngIdObsImagesCase23(_ obsDescArr: NSMutableArray) {
        switch lngId {
        case 1:
            obsDescArr.add(self.noGrossLesionStr)
            obsDescArr.add("<5 lesions/cm2.")
            obsDescArr.add("5 lesions/cm2.")
            obsDescArr.add("Lesions coalescent.")
            obsDescArr.add("Lesions completely coalescent with petechial hemorrhage or red mucosa.")
        case 3:
            obsDescArr.add(self.pasDeLesionStr)
            obsDescArr.add("<5 lésions/cm2.")
            obsDescArr.add("5 lésions/cm2.")
            obsDescArr.add("Lésions coalescentes.")
            obsDescArr.add("lésions complètement coalescentes avec pétécchies ou muqueuse rouge.")
        case 4:
            obsDescArr.add(self.semLesMacroStr)
            obsDescArr.add("<5 lesões/cm2.")
            obsDescArr.add("5 lesões/cm2.")
            obsDescArr.add("Lesões coalescentes.")
            obsDescArr.add("Lesões completamente coalescentes com hemorragia petequial ou mucosa vermelha.")
        default:
            break
        }
    }
    
    func setObsImageDescForCocodis(desc : Int) -> NSMutableArray
    {
        let obsDescArr = NSMutableArray()
        switch desc {
        case 23 :
            lngId = UserDefaults.standard.integer(forKey: "lngId")
            handleLngIdObsImagesCase23(obsDescArr)
            
            break
            
        case 24 :
            handleLngIdObsImageDescCase24(obsDescArr)
            
            break
            
        case 25 :
            if lngId == 1{
                obsDescArr.add("No oocysts.")
                obsDescArr.add("1-10 Oocysts per low power field.")
                obsDescArr.add("11-20 Oocysts per low power field.")
                obsDescArr.add("21-50 Oocysts per low power field")
                obsDescArr.add(">50 Oocysts per low power field.")
            }
            else if lngId == 3{
                obsDescArr.add("Abscence d'oocysts.")
                obsDescArr.add("1-10 Oocysts par champ à faible grossissement.")
                obsDescArr.add("11-20 Oocysts par champ à faible grossissement.")
                obsDescArr.add("21-50 Oocysts par champ à faible grossissement.")
                obsDescArr.add(">50 Oocysts par champ à faible grossissement.")
            }
            else if lngId == 4{
                obsDescArr.add("Sem oocistos.")
                obsDescArr.add("1-10 Oocistos por campo de baixa potência.")
                obsDescArr.add("11-20 Oocistos por campo de baixa potência.")
                obsDescArr.add("21-50 Oocistos por campo de baixa potência")
                obsDescArr.add(">50 Oocistos por campo de baixa potência.")
            }
            
            break
            
        case 26 :
            if lngId == 1{
                obsDescArr.add(self.noGrossLesionStr)
                obsDescArr.add("Petechiae without blood. ")
                obsDescArr.add("Blood in the cecal contents; cecal wall somewhat thickened (normal contents). ")
                obsDescArr.add("Blood or cecal cores present, walls greatly thickened (no contents).")
                obsDescArr.add("Cecal wall greatly distended with blood or cores.")
            }
            else if lngId == 3{
                obsDescArr.add(self.pasDeLesionStr)
                obsDescArr.add("Pétécchies uniquement.")
                obsDescArr.add("Sang dans le contenu caecal, paroi caecale un peu épaissie (contenu normal).")
                obsDescArr.add("Sang ou caillot caecal présent, paroi légèrement épaissie (absence de contenu).")
                obsDescArr.add("Paroi caecal très distendue avec du sang ou caillot.")
            }
            else if lngId == 4{
                obsDescArr.add(self.semLesMacroStr)
                obsDescArr.add("Poucas petéquias dispersas na parede dos cecos; ausência de espessamento das paredes dos cecos; presença de conteúdo cecal normal.")
                obsDescArr.add("Lesões mais numerosas, com possibilidade de sangue no conteúdo cecal; parede do ceco um pouco espessada; pouco ou nenhum conteúdo cecal.")
                obsDescArr.add("Enorme quantidade de sangue presente com paredes dos cecos fortemente espessadas; pouco ou nenhum conteúdo cecal. Perda da estrutura normal das pregas.")
                obsDescArr.add("Parede cecal muito distendida com presença de sangue e desaparecimento total das pregas. A morte das aves é classificada no grau 4.")
            }
            
            break
            
        case 21:
            if lngId == 1{
                obsDescArr.add("No oocysts.")
                obsDescArr.add("1-10 Oocysts per low power field.")
                obsDescArr.add("11-20 Oocysts per low power field.")
                obsDescArr.add("21-50 Oocysts per low power field")
                obsDescArr.add(">50 Oocysts per low power field.")
            }
            else if lngId == 3{
                obsDescArr.add("Abscence d'oocysts.")
                obsDescArr.add("1-10 Oocysts par champ à faible grossissement.")
                obsDescArr.add("11-20 Oocysts par champ à faible grossissement.")
                obsDescArr.add("21-50 Oocysts par champ à faible grossissement.")
                obsDescArr.add(">50 Oocysts par champ à faible grossissement.")
            }
            else if lngId == 4{
                obsDescArr.add("Sem oocistos.")
                obsDescArr.add("1-10 Oocistos por campo de baixa potência.")
                obsDescArr.add("11-20 Oocistos por campo de baixa potência..")
                obsDescArr.add("21-30 Oocistos por campo de baixa potência.")
                obsDescArr.add(">50 Oocistos por campo de baixa potência.")
            }
            break
            
        case 22:
            
            if lngId == 1{
                obsDescArr.add("N/A.")
                obsDescArr.add("N/A. ")
                obsDescArr.add("N/A ")
                obsDescArr.add("N/A.")
                obsDescArr.add("N/A")
            }
            else if lngId == 3{
                obsDescArr.add(self.noDisposibleStr)
                obsDescArr.add(self.noDisposibleStr)
                obsDescArr.add(self.noDisposibleStr)
                obsDescArr.add(self.noDisposibleStr)
                obsDescArr.add(self.noDisposibleStr)
            }
            else if lngId == 4{
                obsDescArr.add("N/A.")
                obsDescArr.add("N/A. ")
                obsDescArr.add("N/A ")
                obsDescArr.add("N/A.")
                obsDescArr.add("N/A")
            }
            
            break
            
        default:
            if lngId == 1{
                obsDescArr.add("N/A.")
                obsDescArr.add("N/A.")
            }
            else if lngId == 3{
                obsDescArr.add(self.noDisposibleStr)
                obsDescArr.add(self.noDisposibleStr)
            }
            else if lngId == 4{
                obsDescArr.add("N/A.")
                obsDescArr.add("N/A.")
            }
            break
            
        }
        return obsDescArr
        
    }
    
    
    // MARK: 🟠 Setup Observation Images Description for GiTract
    
    func setObsImageDescForGitract(desc : Int) -> NSMutableArray
    {
        let obsDescArr = NSMutableArray()
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        switch desc {
        case 27:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 28 :
            if lngId == 1{
                obsDescArr.add(Constants.normalStr)
                obsDescArr.add("Swollen glands.")
                obsDescArr.add("Swollen glands and enlarged.")
                obsDescArr.add("Greatly enlarged and flaccid.")
            }
            else if lngId == 3{
                obsDescArr.add(Constants.normalStr)
                obsDescArr.add("Glandes gonflées.")
                obsDescArr.add("Glandes gonflées et élargies.")
                obsDescArr.add("Très élargi et mou."  )
            }
            else if lngId == 4{
                obsDescArr.add(Constants.normalStr)
                obsDescArr.add("Glândulas inchadas.")
                obsDescArr.add("Glândulas inchadas e aumentadas.")
                obsDescArr.add("Muito ampliado e flácido."  )
            }
            
            break
            
        case 29 :
            if lngId == 1{
                obsDescArr.add("A normal smooth lining of the gizzard with no (change 'no' to minimal) roughening to the surface lining through rough appearance to the lining but no ulcerations or hemorrhages present.")
                obsDescArr.add("Erosion that does not go through gizzard lining.")
                obsDescArr.add("Severe erosion through gizzard lining.")
                obsDescArr.add("Erosions into the gizzard muscle.")
            }
            else if lngId == 3{
                obsDescArr.add("Muqueuse normale lisse du gésier avec une rugosité minime de la surface mais sans ulcération ni hémorragie.")
                obsDescArr.add("Erosion ne traversant pas la paroi du gésier.")
                obsDescArr.add("Erosion sévère traversant la paroi du gésier.")
                obsDescArr.add("Erosion du muscle du gésier.")
            }
            else if lngId == 4{
                obsDescArr.add(Constants.normalStr)
                obsDescArr.add("Erosão que não atravessa a membrana coilínea.")
                obsDescArr.add("Lesão severa que atravessa a membrana coilínea.")
                obsDescArr.add("Erosões no músculo da moela.")
            }
            break
            
        case 31 :
            if lngId == 1{
                obsDescArr.add("<50% of gizzard contents is litter.")
                obsDescArr.add(">50% gizzard contents is litter.")
            }
            else if lngId == 3{
                obsDescArr.add("<50% du contenu du gésier est de la littière.")
                obsDescArr.add(">50% du contenu du gésier est de la littière.")
            }
            else if lngId == 4{
                obsDescArr.add("< 50% do conteúdo é cama.")
                obsDescArr.add("> 50% do conteúdo é cama")
            }
            break
            
        case 32 :
            if lngId == 1{
                obsDescArr.add("Normal gut tone and color.")
                obsDescArr.add("Loss of tone with either decreased or increased thickness of intestinal tract. Slight loss of tensile strength. Reddening of duodenal loop alone is not a reason to justify this score but is to be considered if a slight redness extends into the midgut.")
                obsDescArr.add("Intestine lays flat or has no tone when opened.  There may be significant loss of tensile strength and thinning.  Intestine may have a layer of mucous, moderate reddening, cellular debris, and an increased amount of fluid or orange material present.")
                obsDescArr.add("A generalized thinning and loss of intestinal mucosal surface.  Significant feed passage is observed.  There may be formation of diphtheritic membrane and/or severe reddening with petechiae hemorrhaging readily apparent.  No tensile strength of gut.Ballooning of gut may be observed.")
            }
            else if lngId == 3{
                obsDescArr.add("Tonus et couleur intestinale normaux.")
                obsDescArr.add("Perte de tonus avec diminution ou augmentation d'épaisseur du tractus intestinal. Légère perte de résistance à la traction. Coloration plus rouge de la boucle duodénale seule n'est pas une raison justifiant la note mais doit être considérée si une légère rougeur s'étend à l'intestin moyen.")
                obsDescArr.add("Paroi intestinale molle ou sans tonus à l'ouverture. Possible perte significative de résistance à la traction et amincissement. L'intestin peu avoir une couche de mucus, modérément rouge, des débris cellulaires, et une augmentation de la quantité de fluide ou présence de matériel orange.")
                obsDescArr.add("Un amincissement généralisé et une perte de la surface mucosale intestinale. Un passage alimentaire significatif est observé. Possible formation de membrane diphtérique et/ou rougeur sévère avec pétécchies hémorragiques facilement apparentes. Absence de résistance à la traction de l'intestin. Possible ballonement intestinal.")
            }
            else if lngId == 4{
                obsDescArr.add("Ausência de lesões.")
                obsDescArr.add("Perda de tônus com diminuição ou aumento da espessura do trato intestinal. Ligeira perda de resistência à tração. A vermelhidão por si só da alça duodenal não é uma razão para justificar essa pontuação.")
                obsDescArr.add("Parede intestinal sem tônus ​​quando aberta. Possível perda significativa de resistência à tração e afinamento. O intestino pode ter uma camada de muco e estar moderadamente vermelho.")
                obsDescArr.add(" Petéquias + conteúdo laranja com alteração de mucosa, flocos de sangue/coágulos e inchaço. ")
            }
            break
            
        case 33 :
            if lngId == 1{
                obsDescArr.add("No evidence of necrotic enteritis present.")
                obsDescArr.add("Necrotic enteritis present.")
            }
            else if lngId == 3{
                obsDescArr.add("Aucun signe d'entérite nécrotique.")
                obsDescArr.add("Présence d'entérite nécrotique.")
                
            }
            else if lngId == 4{
                obsDescArr.add("Não há evidência de enterite necrótica presente.")
                obsDescArr.add("Enterite necrótica presente.")
                
            }
            break
            
        case 34 :
            if lngId == 1{
                
                obsDescArr.add("No.")
                obsDescArr.add("Multiple fragments of undigested feed present in colon.")
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Multiples fragments d'aliment indigéré présents dans le colon.")
                
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Múltiplos fragmentos de ração não digerida presentes no cólon.")
                
            }
            break
        case 35:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 37:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 45 :
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 46 :
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            
            break
            
        case 47:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 40 :
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 36:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            
            break
            
        case 41:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 39:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 38:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        case 48:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
            
        default:
            if lngId == 1{
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            }
            else if lngId == 3{
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            }
            else if lngId == 4{
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
            break
            
        }
        
        return obsDescArr
        
    }
    
    // MARK: 🟠 Setup Observation images Description for Resp.
    fileprivate func handleLngIdObsDescForRespCase49(_ obsDescArr: NSMutableArray) {
        switch lngId {
        case 1:
            obsDescArr.add("No.")
            obsDescArr.add(Constants.yesStr)
        case 3:
            obsDescArr.add("Non.")
            obsDescArr.add("Oui.")
        case 4:
            obsDescArr.add("Não.")
            obsDescArr.add("Sim.")
        default:
            break
        }
    }
    
    fileprivate func handleLngObsDescForRespCase50(_ obsDescArr: NSMutableArray) {
        if lngId == 1 {
            obsDescArr.add(Constants.normalStr)
            obsDescArr.add("Slight mucus and/or slight hyperemia.")
            obsDescArr.add("Copious mucus and/or moderate hyperemia.")
            obsDescArr.add("Severe hyperemia and/or Hemorrhagic and/or Diphtheritic.")
        }
        else if lngId == 3{
            obsDescArr.add(Constants.normalStr)
            obsDescArr.add("Léger mucus et/ou légère hyperhémie.")
            obsDescArr.add("Mucus abondant et/ou hyperhémie modérée.")
            obsDescArr.add("Hyperhémie sévère et/ou Hémorragique et/ou Diphtérique.")
        }
        else if lngId == 4{
            obsDescArr.add(Constants.normalStr)
            obsDescArr.add("Leve muco e/ou leve hiperemia.")
            obsDescArr.add("Muco abundante e/ou hiperemia moderada.")
            obsDescArr.add("Traqueíte severa com muco hemorrágico.")
        }
    }
    
    fileprivate func handleLngObsDescForRespCase51(_ obsDescArr: NSMutableArray) {
        if lngId == 1{
            obsDescArr.add(Constants.normalStr)
            obsDescArr.add("Suds.")
            obsDescArr.add("Frothy suds or single focus of exudates.")
            obsDescArr.add("Multifocal to diffuse exudate or exudate + pericarditis.")
            obsDescArr.add("Pericarditis + perihepatitis.")
        }
        else if lngId == 3{
            obsDescArr.add(Constants.normalStr)
            obsDescArr.add("Mousse.")
            obsDescArr.add("Mousseux ou foyer unique d'exsudat.")
            obsDescArr.add("Exsudat multifocal à diffus ou exsudat + péricardite.")
            obsDescArr.add("Péricardite + périhépatite.")
        }
        else if lngId == 4{
            obsDescArr.add(Constants.normalStr)
            obsDescArr.add("Presença de espuma..")
            obsDescArr.add("Espuma espessa ou foco simples de exsudato.")
            obsDescArr.add("Exsudato multifocal ou difuso + pericardite.")
            obsDescArr.add("Pericardite + perihepatite.")
        }
    }
    
    fileprivate func handleLngObsDescForRespCase52(_ obsDescArr: NSMutableArray) {
        if lngId == 1{
            obsDescArr.add("No.")
            obsDescArr.add(Constants.yesStr)
        }
        else if lngId == 3{
            obsDescArr.add("Non.")
            obsDescArr.add("Oui.")
        }
        else if lngId == 4{
            obsDescArr.add("Não.")
            obsDescArr.add("Sim.")
        }
    }
    
    fileprivate func handleLngObsDescForRespCase53(_ obsDescArr: NSMutableArray) {
        if lngId == 1 {
            obsDescArr.add("No.")
            obsDescArr.add(Constants.yesStr)
        } else if lngId == 3{
            obsDescArr.add("Non.")
            obsDescArr.add("Oui.")
        } else if lngId == 4{
            obsDescArr.add("Não.")
            obsDescArr.add("Sim.")
        }
    }
    
    fileprivate func handleLngObsDescForRespCase54(_ obsDescArr: NSMutableArray) {
        if lngId == 1 {
            obsDescArr.add("No.")
            obsDescArr.add(Constants.yesStr)
        }
        else if lngId == 3{
            obsDescArr.add("Non.")
            obsDescArr.add("Oui.")
        }
        else if lngId == 4{
            obsDescArr.add("Não.")
            obsDescArr.add("Sim.")
        }
    }
    
    fileprivate func handleLngObsDescForRespCaseDefault(_ obsDescArr: NSMutableArray) {
        if lngId == 1 {
            obsDescArr.add("No.")
            obsDescArr.add(Constants.yesStr)
        } else if lngId == 3 {
            obsDescArr.add("Non.")
            obsDescArr.add("Oui.")
        } else if lngId == 4 {
            obsDescArr.add("Não.")
            obsDescArr.add("Sim.")
        }
    }
    
    func setObsImageDescForResp(desc : Int) -> NSMutableArray {
        let obsDescArr = NSMutableArray()
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        
        switch desc {
        case 49:
            handleLngIdObsDescForRespCase49(obsDescArr)
            break
            
        case 50:
            handleLngObsDescForRespCase50(obsDescArr)
            break
            
        case 51:
            handleLngObsDescForRespCase51(obsDescArr)
            break
            
        case 52:
            handleLngObsDescForRespCase52(obsDescArr)
            break
            
        case 53:
            handleLngObsDescForRespCase53(obsDescArr)
            break
            
        case 54:
            handleLngObsDescForRespCase54(obsDescArr)
            break
        default:
            handleLngObsDescForRespCaseDefault(obsDescArr)
            break
        }
        return obsDescArr
    }
    
    // MARK: 🟠 Setup Observation Images Description for Immune
    fileprivate func handleObsImageForImmuneCase58(_ lngId: Int, _ obsDescArr: NSMutableArray) {
        if lngId == 1 {
            obsDescArr.add("Very small.")
            obsDescArr.add("Default.")
            obsDescArr.add("Large.")
        } else if lngId == 3 {
            obsDescArr.add("Très petit.")
            obsDescArr.add("Par défaut.")
            obsDescArr.add("Large.")
        } else if lngId == 4 {
            obsDescArr.add("Escala de 1 a 8. Bolsas são medidas e recebem um escore correspondente ao menor orifício pelo qual a amostra passa completamente.")
        }
    }
    
    fileprivate func handleObsImageForImmuneCase57(_ lngId: Int, _ obsDescArr: NSMutableArray) {
        if lngId == 1 || lngId == 4 {
            obsDescArr.add("NA")
            obsDescArr.add("NA.")
            obsDescArr.add("NA.")
            obsDescArr.add("NA.")
        } else if lngId == 3 {
            obsDescArr.add(self.noDisposibleStr)
            obsDescArr.add(self.noDisposibleStr)
            obsDescArr.add(self.noDisposibleStr)
            obsDescArr.add(self.noDisposibleStr)
        }
    }
    
    fileprivate func handleObsImageForImmuneCase59(_ lngId: Int, _ obsDescArr: NSMutableArray) {
        if lngId == 1 {
            obsDescArr.add("Absent.")
            obsDescArr.add("Presents.")
        } else if lngId == 3 {
            obsDescArr.add("Absent.")
            obsDescArr.add("Présent.")
        } else if lngId == 4 {
            obsDescArr.add("Ausente.")
            obsDescArr.add("Presente.")
        }
    }
    
    fileprivate func handleObsImageForImmuneCase55To81(_ lngId: Int, _ obsDescArr: NSMutableArray) {
        if lngId == 1 {
            obsDescArr.add("No.")
            obsDescArr.add(Constants.yesStr)
        } else if lngId == 3 {
            obsDescArr.add("Non.")
            obsDescArr.add("Oui.")
        } else if lngId == 4 {
            obsDescArr.add("Não.")
            obsDescArr.add("Sim.")
        }
    }
    
    fileprivate func handleObsImageForImmuneCase1952To1957(_ lngId: Int, _ obsDescArr: NSMutableArray) {
        if lngId == 1 {
            obsDescArr.add(Constants.yesStr)
            obsDescArr.add("NO.")
        } else if lngId == 3 {
            obsDescArr.add("Oui.")
            obsDescArr.add("Non.")
        } else if lngId == 4 {
            obsDescArr.add("Sim.")
            obsDescArr.add("Não.")
        }
    }
    
    func setObsImageDescForImmune(desc: Int) -> NSMutableArray {
        let obsDescArr = NSMutableArray()
        let lngId = UserDefaults.standard.integer(forKey: "lngId")
        
        switch desc {
        case 58:
            handleObsImageForImmuneCase58(lngId, obsDescArr)
            
        case 57:
            handleObsImageForImmuneCase57(lngId, obsDescArr)
            
        case 59:
            handleObsImageForImmuneCase59(lngId, obsDescArr)
            
        case 60, 55, 65, 63, 81, 61, 64, 66:
            handleObsImageForImmuneCase55To81(lngId, obsDescArr)
            
        case 1955, 1957, 1952, 1956:
            handleObsImageForImmuneCase1952To1957(lngId, obsDescArr)
            
        default:
            if lngId == 1 {
                obsDescArr.add("No.")
                obsDescArr.add(Constants.yesStr)
            } else if lngId == 3 {
                obsDescArr.add("Non.")
                obsDescArr.add("Oui.")
            } else if lngId == 4 {
                obsDescArr.add("Não.")
                obsDescArr.add("Sim.")
            }
        }
        
        return obsDescArr
    }
    
    func getNecIdChicken() -> Int {
        if postingIdFromExistingNavigate == "Exting" {
            return postingIdFromExisting
        } else {
            return UserDefaults.standard.integer(forKey: "necId")
        }
    }
    
    
    // MARK: 🟠 Cancel Button Action
    func cancelBtnAction (_ btnTag: Int, data:CaptureNecropsyViewData){
        
        buttonPopup.alpha = 0
        
        if btnTag == 0
        {
            dataSkeltaArray.removeAllObjects()
            
            var  necId = Int()
            necId = getNecIdChicken()
            
//            if postingIdFromExistingNavigate == "Exting"{
//                necId =  postingIdFromExisting
//            }
//            else{
//                necId = UserDefaults.standard.integer(forKey: "necId") as Int
//            }
            dataSkeltaArray =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(data.birdNo!, farmname: data.formName!, catName: data.catName!,necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
            neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
            neccollectionView.reloadData()
        }
        if btnTag == 1
        {
            dataArrayCocoi.removeAllObjects()
            
            var  necId = Int()
            
            necId = getNecIdChicken()
            
            dataArrayCocoi = CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(data.birdNo!, farmname: data.formName!, catName: data.catName!,necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
            neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
            neccollectionView.reloadData()
            
        }
        if btnTag == 2
        {
            dataArrayGiTract.removeAllObjects()
            
            var  necId = Int()
            
            necId = getNecIdChicken()
            
            dataArrayGiTract =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(data.birdNo!, farmname: data.formName!, catName: data.catName!,necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
            neccollectionView.reloadData()
        }
        if btnTag == 3
        {
            dataArrayRes.removeAllObjects()
            
            var  necId = Int()
            
            necId = getNecIdChicken()
            
            dataArrayRes =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(data.birdNo!, farmname: data.formName!, catName: data.catName!,necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
            
            neccollectionView.reloadData()
        }
        if btnTag == 4
        {
            dataArrayImmu.removeAllObjects()
            
            var  necId = Int()
            
            necId = getNecIdChicken()
            
            dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(data.birdNo!, farmname: data.formName!, catName: data.catName!,necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
            neccollectionView.reloadData()
        }
    }
    // MARK: 🟠 Hide Popup view
    @objc func buttonActionpopup(_ sender: UIButton!) {
        buttonPopup.alpha = 0
    }
    
    // MARK: 🟠Quick Link Button Action
    @objc func quickLink(_ sender : UIButton){
        
        let form = farmArray[sender.tag] as? String
        let index = sender.tag
        let ageArry = (ageArray[sender.tag] as? String)!
        
        var birNo  = Int()
        
        for i in 0..<self.farmArray.count {
            let f  = self.farmArray.object(at: i) as! String
            if f == form {
                birNo  = (self.items.object(at: i) as AnyObject).count
            }
        }
        
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "AllBirdsViewController") as? AllBirdsViewController
        
        var  necId = Int()
        
        if postingIdFromExistingNavigate == "Exting"{
            necId =  postingIdFromExisting
        }
        else{
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        mapViewControllerObj!.postingIdFromExistingNavigate = postingIdFromExistingNavigate as NSString
        mapViewControllerObj!.necId = necId
        mapViewControllerObj!.formName = form!
        mapViewControllerObj!.index = index
        mapViewControllerObj!.ageValue = ageArry
        
        mapViewControllerObj!.birdNo = birNo
        self.navigationController?.pushViewController(mapViewControllerObj!, animated: false)
    }
    // MARK: 🟠 Plus Button Action
    @objc func plusButtonClick (_ sender: UIButton){
        let rowIndex :Int = sender.tag
        isFirstTimeLaunch = false
        lastSelectedIndex = IndexPath(row: rowIndex, section: 0)
        
        let cell = neccollectionView.cellForItem(at: lastSelectedIndex!) as! CaptureNecropsyCollectionViewCell
        let trimmed = cell.mesureValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let array = (trimmed.components(separatedBy: ",") as [String])
        if btnTag == 0 {
            let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: rowIndex) as! CaptureNecropsyViewData
            
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(skleta.birdNo!, farmname: skleta.formName!, catName: skleta.catName!,Obsid: skleta.obsID!,necId: necId as NSNumber)
            
            let skleta1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if skleta1.obsPoint == 0
                {
                    if Int(array[0]) != 0
                    {
                        cell.incrementLabel.text = String(array[0])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("skeltaMuscular", obsName: skleta1.obsName!, formName:skleta.formName! , obsVisibility: Bool(truncating: skleta1.objsVisibilty!), birdNo: skleta.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating: skleta1.obsID!),necId: necId as NSNumber,isSync :true)
                    }
                    else
                    {
                        cell.incrementLabel.text = String(array[1])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("skeltaMuscular", obsName: skleta1.obsName!, formName:skleta.formName! , obsVisibility: Bool(truncating: skleta1.objsVisibilty!), birdNo: skleta.birdNo!, camraImage: image!, obsPoint: Int(array[1])! , index: rowIndex, obsId: Int(truncating: skleta1.obsID!),necId: necId as NSNumber,isSync :true)
                    }
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        let lastElement = (Int(array.last!)! as Int)
                        if lastElement == Int(array[i])!
                        {
                            
                        }
                        else
                        {
                            if Int(array[i])! as NSNumber == skleta1.obsPoint
                            {
                                cell.incrementLabel.text = String(array[i+1])
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("skeltaMuscular", obsName: skleta1.obsName!, formName:skleta.formName! , obsVisibility: Bool(truncating: skleta1.objsVisibilty!), birdNo: skleta.birdNo!, camraImage: image!, obsPoint: Int(array[i+1])! , index: rowIndex, obsId: Int(truncating: skleta1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                                
                            }
                        }
                    }
                }
            }
            
            dataSkeltaArray.removeAllObjects()
            if postingIdFromExistingNavigate == "Exting"{
                
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            dataSkeltaArray =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(skleta.birdNo! , farmname: skleta.formName!, catName: "skeltaMuscular",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
        }
        
        if btnTag == 1 {
            
            let cocoi : CaptureNecropsyViewData = dataArrayCocoi.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(cocoi.birdNo!, farmname: cocoi.formName!, catName: cocoi.catName!,Obsid: cocoi.obsID!,necId:necId as NSNumber)
            
            let cocoi1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if cocoi1.obsPoint == 0
                {
                    if Int(array[0]) != 0
                    {
                        cell.incrementLabel.text = String(array[0])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Coccidiosis", obsName: cocoi1.obsName!, formName:cocoi.formName! , obsVisibility: Bool(truncating: cocoi1.objsVisibilty!), birdNo: cocoi.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating: cocoi1.obsID!),necId: necId as NSNumber,isSync :true)
                    }
                    else
                    {
                        cell.incrementLabel.text = String(array[1])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Coccidiosis", obsName: cocoi1.obsName!, formName:cocoi.formName! , obsVisibility: Bool(truncating: cocoi1.objsVisibilty!), birdNo: cocoi.birdNo!, camraImage: image!, obsPoint: Int(array[1])! , index: rowIndex, obsId: Int(truncating: cocoi1.obsID!),necId: necId as NSNumber,isSync :true)
                    }
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        let lastElement = (Int(array.last!)! as Int)
                        if lastElement == Int(array[i])!
                        {
                        }
                        else
                        {
                            if Int(array[i])! as NSNumber == cocoi1.obsPoint
                            {
                                cell.incrementLabel.text = String(array[i+1])
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Coccidiosis", obsName: cocoi1.obsName!, formName:cocoi.formName! , obsVisibility: Bool(truncating: cocoi1.objsVisibilty!), birdNo: cocoi.birdNo!, camraImage: image!, obsPoint: Int(array[i+1])! , index: rowIndex, obsId: Int(truncating: cocoi1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                                
                            }
                        }
                    }
                }
            }
            
            dataArrayCocoi.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(cocoi.birdNo! , farmname: cocoi.formName!, catName: "Coccidiosis",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        if btnTag == 2 {
            
            let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(gitract.birdNo!, farmname: gitract.formName!, catName: gitract.catName!,Obsid: gitract.obsID!,necId:necId as NSNumber)
            
            let gitract1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if gitract1.obsPoint == 0
                {
                    if Int(array[0]) != 0
                    {
                        cell.incrementLabel.text = String(array[0])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("GITract", obsName: gitract1.obsName!, formName:gitract.formName! , obsVisibility:Bool(truncating: gitract1.objsVisibilty!), birdNo: gitract.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating: gitract1.obsID!),necId: necId as NSNumber,isSync :true)
                    }
                    else
                    {
                        cell.incrementLabel.text = String(array[1])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("GITract", obsName: gitract1.obsName!, formName:gitract.formName! , obsVisibility:Bool(truncating: gitract1.objsVisibilty!), birdNo: gitract.birdNo!, camraImage: image!, obsPoint: Int(array[1])! , index: rowIndex, obsId: Int(truncating: gitract1.obsID!),necId: necId as NSNumber,isSync :true)
                    }
                    
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        let lastElement = (Int(array.last!)! as Int)
                        if lastElement == Int(array[i])!
                        {
                        }
                        else
                        {
                            if (Int(array[i])! as NSNumber)  == gitract1.obsPoint
                            {
                                cell.incrementLabel.text = String(array[i+1])
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("GITract", obsName: gitract1.obsName!, formName:gitract.formName! , obsVisibility:Bool(truncating: gitract1.objsVisibilty!), birdNo: gitract.birdNo!, camraImage: image!, obsPoint: Int(array[i+1])! , index: rowIndex, obsId: Int(truncating: gitract1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                                
                            }
                        }
                    }
                }
            }
            
            dataArrayGiTract.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(gitract.birdNo! , farmname: gitract.formName!, catName: "GITract",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
        }
        
        if btnTag == 3 {
            
            let resp : CaptureNecropsyViewData = dataArrayRes.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(resp.birdNo!, farmname: resp.formName!, catName: resp.catName!,Obsid: resp.obsID!,necId: necId as NSNumber)
            
            let resp1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if resp1.obsPoint == 0
                {
                    if Int(array[0]) != 0
                    {
                        cell.incrementLabel.text = String(array[0])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Resp", obsName: resp1.obsName!, formName:resp.formName! , obsVisibility: Bool(truncating: resp1.objsVisibilty!), birdNo: resp.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating: resp1.obsID!),necId: necId as NSNumber,isSync :true)
                    }
                    else
                    {
                        cell.incrementLabel.text = String(array[1])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Resp", obsName: resp1.obsName!, formName:resp.formName! , obsVisibility: Bool(truncating: resp1.objsVisibilty!), birdNo: resp.birdNo!, camraImage: image!, obsPoint: Int(array[1])! , index: rowIndex, obsId: Int(truncating: resp1.obsID!),necId: necId as NSNumber,isSync :true)
                        
                    }
                    
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        let lastElement = (Int(array.last!)! as Int)
                        if lastElement == Int(array[i])!
                        {
                        }
                        else
                        {
                            if Int(array[i])! as NSNumber == resp1.obsPoint
                            {
                                cell.incrementLabel.text = String(array[i+1])
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Resp", obsName: resp1.obsName!, formName:resp.formName! , obsVisibility: Bool(truncating: resp1.objsVisibilty!), birdNo: resp.birdNo!, camraImage: image!, obsPoint: Int(array[i+1])! , index: rowIndex, obsId: Int(truncating: resp1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                                
                            }
                        }
                    }
                }
            }
            
            dataArrayRes.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayRes =   CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(resp.birdNo! , farmname: resp.formName!, catName: "Resp",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        if btnTag == 4 {
            
            let immune : CaptureNecropsyViewData = dataArrayImmu.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            if postingIdFromExistingNavigate == "Exting"{
                
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(immune.birdNo!, farmname: immune.formName!, catName: immune.catName!,Obsid: immune.obsID!,necId: necId as NSNumber)
            
            let immune1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if immune1.obsPoint == 0
                {
                    if Int(array[0]) != 0
                    {
                        
                        cell.incrementLabel.text = String(array[0])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Immune", obsName: immune1.obsName!, formName:immune.formName! , obsVisibility: Bool(truncating: immune1.objsVisibilty!), birdNo: immune.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating: immune1.obsID!),necId: necId as NSNumber,isSync :true)
                    }
                    else
                    {
                        cell.incrementLabel.text = String(array[1])
                        CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Immune", obsName: immune1.obsName!, formName:immune.formName! , obsVisibility: Bool(truncating: immune1.objsVisibilty!), birdNo: immune.birdNo!, camraImage: image!, obsPoint: Int(array[1])! , index: rowIndex, obsId: Int(truncating: immune1.obsID!),necId: necId as NSNumber,isSync :true)
                        
                    }
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        
                        let lastElement = (Int(array.last!)! as Int)
                        if lastElement == Int(array[i])!
                        {
                        }
                        else
                        {
                            if Int(array[i])! as NSNumber == immune1.obsPoint
                            {
                                cell.incrementLabel.text = String(array[i+1])
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Immune", obsName: immune1.obsName!, formName:immune.formName! , obsVisibility: Bool(truncating: immune1.objsVisibilty!), birdNo: immune.birdNo!, camraImage: image!, obsPoint: Int(array[i+1])! , index: rowIndex, obsId: Int(truncating: immune1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                                
                            }
                        }
                    }
                }
            }
            
            dataArrayImmu.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(immune.birdNo! , farmname: immune.formName!, catName: "Immune",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        if postingIdFromExistingNavigate == "Exting"{
            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
        }
        else if UserDefaults.standard.bool(forKey: "Unlinked") == true
        {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
        }
        else
        {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
        }
    }
    // MARK: 🟠 Minus Button Click
    @objc func minusButtonClick (_ sender: UIButton){
        
        let rowIndex :Int = sender.tag
        
        isFirstTimeLaunch = false
        lastSelectedIndex = IndexPath(row: rowIndex, section: 0)
        let cell = neccollectionView.cellForItem(at: lastSelectedIndex!) as! CaptureNecropsyCollectionViewCell
        let trimmed = cell.mesureValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let array = (trimmed.components(separatedBy: ",") as [String])
        
        if btnTag == 0 {
            
            let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(skleta.birdNo!, farmname: skleta.formName!, catName: skleta.catName!,Obsid: skleta.obsID!,necId: necId as NSNumber)
            
            let skleta1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                if skleta1.obsPoint == 0
                {
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        if Int(array[i]) == 1
                        {
                        }
                        else
                        {
                            if skleta1.obsPoint == 1
                            {
                                if Int(array[i]) == 0
                                {
                                    cell.incrementLabel.text = array[0]
                                    CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("skeltaMuscular", obsName: skleta1.obsName!, formName:skleta.formName! , obsVisibility: Bool(truncating:skleta1.objsVisibilty!), birdNo: skleta.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating:skleta1.obsID!),necId: necId as NSNumber,isSync :true)
                                    break
                                }
                            }
                            if Int(array[i])! as NSNumber == skleta1.obsPoint
                            {
                                cell.incrementLabel.text = array[i-1]
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("skeltaMuscular", obsName: skleta1.obsName!, formName:skleta.formName! , obsVisibility: Bool(truncating:skleta1.objsVisibilty!), birdNo: skleta.birdNo!, camraImage: image!, obsPoint: Int(array[i-1])! , index: rowIndex, obsId: Int(truncating:skleta1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                                
                            }
                        }
                    }
                }
            }
            
            dataSkeltaArray.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(skleta.birdNo! , farmname: skleta.formName!, catName: "skeltaMuscular",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        
        if btnTag == 1 {
            
            let cocoi : CaptureNecropsyViewData = dataArrayCocoi.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(cocoi.birdNo!, farmname: cocoi.formName!, catName: cocoi.catName!,Obsid: cocoi.obsID!,necId: necId as NSNumber)
            
            let cocoi1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if cocoi1.obsPoint == 0
                {
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        if Int(array[i]) == 1
                        {
                        }
                        else
                        {
                            if cocoi.obsPoint == 1
                            {
                                if Int(array[i]) == 0
                                {
                                    cell.incrementLabel.text = array[0]
                                    CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Coccidiosis", obsName: cocoi1.obsName!, formName:cocoi.formName! , obsVisibility: Bool(truncating:cocoi1.objsVisibilty!), birdNo: cocoi.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating:cocoi1.obsID!),necId: necId as NSNumber,isSync :true)
                                    break
                                }
                            }
                            
                            if Int(array[i])! as NSNumber == cocoi1.obsPoint
                            {
                                cell.incrementLabel.text = array[i-1]
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Coccidiosis", obsName: cocoi1.obsName!, formName:cocoi.formName! , obsVisibility: Bool(truncating:cocoi1.objsVisibilty!), birdNo: cocoi.birdNo!, camraImage: image!, obsPoint: Int(array[i-1])! , index: rowIndex, obsId: Int(truncating:cocoi1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                                
                            }
                        }
                    }
                }
            }
            
            dataArrayCocoi.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(cocoi.birdNo! , farmname: cocoi.formName!, catName: "Coccidiosis",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            
        }
        
        
        if btnTag == 2 {
            
            let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(gitract.birdNo!, farmname: gitract.formName!, catName: gitract.catName!,Obsid: gitract.obsID!,necId: necId as NSNumber)
            
            let gitract1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if gitract1.obsPoint == 0
                {
                }
                else
                {
                    
                    for  i in 0..<array.count
                    {
                        if Int(array[i]) == 1
                        {
                        }
                        else
                        {
                            if gitract1.obsPoint == 1
                            {
                                if Int(array[i]) == 0
                                {
                                    cell.incrementLabel.text = array[0]
                                    CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("GITract", obsName: gitract1.obsName!, formName:gitract.formName! , obsVisibility:Bool(truncating:gitract1.objsVisibilty!), birdNo: gitract.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating:gitract1.obsID!),necId: necId as NSNumber,isSync :true)
                                    break
                                }
                            }
                            if Int(array[i])! as NSNumber == gitract1.obsPoint
                            {
                                cell.incrementLabel.text = array[i-1]
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("GITract", obsName: gitract1.obsName!, formName:gitract.formName! , obsVisibility:Bool(truncating:gitract1.objsVisibilty!), birdNo: gitract.birdNo!, camraImage: image!, obsPoint: Int(array[i-1])! , index: rowIndex, obsId: Int(truncating:gitract1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                            }
                        }
                    }
                }
            }
            
            dataArrayGiTract.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(gitract.birdNo! , farmname: gitract.formName!, catName: "GITract",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
        }
        
        if btnTag == 3 {
            
            let resp : CaptureNecropsyViewData = dataArrayRes.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            
            var  necId = Int()
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(resp.birdNo!, farmname: resp.formName!, catName: resp.catName!,Obsid: resp.obsID!,necId:necId as NSNumber)
            
            let resp1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if resp1.obsPoint == 0
                {
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        if Int(array[i]) == 1
                        {
                        }
                        else
                        {
                            if resp1.obsPoint == 1
                            {
                                if Int(array[i]) == 0
                                {
                                    cell.incrementLabel.text = array[0]
                                    CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Resp", obsName: resp1.obsName!, formName:resp.formName! , obsVisibility: Bool(truncating:resp1.objsVisibilty!), birdNo: resp.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating: resp1.obsID!),necId: necId as NSNumber,isSync :true)
                                    break
                                }
                            }
                            
                            if Int(array[i])! as NSNumber == resp1.obsPoint
                            {
                                cell.incrementLabel.text = array[i-1]
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Resp", obsName: resp1.obsName!, formName:resp.formName! , obsVisibility: Bool(truncating:resp1.objsVisibilty!), birdNo: resp.birdNo!, camraImage: image!, obsPoint: Int(array[i-1])! , index: rowIndex, obsId: Int(truncating:resp1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                            }
                        }
                    }
                }
            }
            
            dataArrayRes.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayRes =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(resp.birdNo! , farmname: resp.formName!, catName: "Resp",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        if btnTag == 4 {
            
            let immune : CaptureNecropsyViewData = dataArrayImmu.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(immune.birdNo!, farmname: immune.formName!, catName: immune.catName!,Obsid: immune.obsID!,necId: necId as NSNumber)
            
            let immune1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                if immune1.obsPoint == 0
                {
                }
                else
                {
                    for  i in 0..<array.count
                    {
                        if Int(array[i]) == 1
                        {
                        }
                        else
                        {
                            if immune1.obsPoint == 1
                            {
                                if Int(array[i]) == 0
                                {
                                    cell.incrementLabel.text = array[0]
                                    CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Immune", obsName: immune1.obsName!, formName:immune.formName! , obsVisibility: Bool(truncating:immune1.objsVisibilty!), birdNo: immune.birdNo!, camraImage: image!, obsPoint: Int(array[0])! , index: rowIndex, obsId: Int(truncating:immune1.obsID!),necId: necId as NSNumber,isSync :true)
                                    break
                                }
                            }
                            if Int(array[i])! as NSNumber == immune1.obsPoint
                            {
                                cell.incrementLabel.text = array[i-1]
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Immune", obsName: immune1.obsName!, formName:immune.formName! , obsVisibility: Bool(truncating:immune1.objsVisibilty!), birdNo: immune.birdNo!, camraImage: image!, obsPoint: Int(array[i-1])! , index: rowIndex, obsId: Int(truncating:immune1.obsID!),necId: necId as NSNumber,isSync :true)
                                break
                            }
                        }
                    }
                }
            }
            
            dataArrayImmu.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(immune.birdNo! , farmname: immune.formName!, catName: "Immune",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
        }
        
        if postingIdFromExistingNavigate == "Exting"{
            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
        }
        
        else if UserDefaults.standard.bool(forKey: "Unlinked") == true{
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
        }
        
        else{
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
            
        }
    }
    // MARK: 🟠 Switch Click Action
    fileprivate func handleSwitchClickBtnTag0(_ rowIndex: Int, _ sender: UISwitch) {
        if btnTag == 0 {
            
            let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting" {
                necId =  postingIdFromExisting
            } else {
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(skleta.birdNo!, farmname: skleta.formName!, catName: skleta.catName!,Obsid: skleta.obsID!,necId:necId as NSNumber)
            
            let skleta1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                let imageName = "skeltaMuscular" + "_" + skleta1.obsName! + "_n"
                var image = UIImage(named:imageName)
                if image == nil
                {
                    image = UIImage(named:"Image01")
                }
                
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("skeltaMuscular", obsName: skleta1.obsName!, formName:skleta.formName! , obsVisibility: sender.isOn, birdNo: skleta.birdNo!, camraImage: image!, obsPoint: incrementValue , index: rowIndex, obsId: Int(truncating: skleta1.obsID!),necId: necId as NSNumber,isSync :true)
                
            }
            
            dataSkeltaArray.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(skleta.birdNo! , farmname: skleta.formName!, catName: "skeltaMuscular",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
    }
    
    fileprivate func handleSwitchClickBtnTag1(_ rowIndex: Int, _ sender: UISwitch) {
        if btnTag == 1 {
            
            let cocoi : CaptureNecropsyViewData = dataArrayCocoi.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(cocoi.birdNo!, farmname: cocoi.formName!, catName: cocoi.catName!,Obsid: cocoi.obsID!,necId: necId as NSNumber)
            
            let cocoi1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                let imageName = "Coccidiosis" + "_" + cocoi1.obsName! + "_n"
                var image = UIImage(named:imageName)
                if image == nil
                {
                    image = UIImage(named:"Image01")
                }
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Coccidiosis", obsName: cocoi1.obsName!, formName:cocoi.formName! , obsVisibility: sender.isOn, birdNo: cocoi.birdNo!, camraImage: image!, obsPoint:incrementValue , index: rowIndex, obsId: Int(truncating: cocoi1.obsID!),necId: necId as NSNumber,isSync :true)
                
            }
            
            dataArrayCocoi.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(cocoi.birdNo! , farmname: cocoi.formName!, catName: "Coccidiosis",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
        }
    }
    
    fileprivate func handleSwitchClickBtnTag2(_ rowIndex: Int, _ sender: UISwitch) {
        if btnTag == 2 {
            let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: rowIndex) as! CaptureNecropsyViewData
            
            let image = UIImage(named:"Image01")
            
            var  necId = Int()
            if postingIdFromExistingNavigate == "Exting"{
                
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(gitract.birdNo!, farmname: gitract.formName!, catName: gitract.catName!,Obsid: gitract.obsID!,necId:necId as NSNumber)
            
            let gitract1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                let imageName = "GITract" + "_" + gitract1.obsName! + "_n"
                var image = UIImage(named:imageName)
                if image == nil {
                    image = UIImage(named:"Image01")
                }
                
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("GITract", obsName: gitract1.obsName!, formName:gitract.formName! , obsVisibility: sender.isOn, birdNo: gitract.birdNo!, camraImage: image!, obsPoint: incrementValue , index: rowIndex, obsId: Int(truncating: gitract1.obsID!),necId: necId as NSNumber,isSync :true)
            }
            
            dataArrayGiTract.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting" {
                necId =  postingIdFromExisting
            } else {
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(gitract.birdNo! , farmname: gitract.formName!, catName: "GITract",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
    }
    
    fileprivate func handleSwitchClickBtnTag3(_ rowIndex: Int, _ sender: UISwitch) {
        if btnTag == 3 {
            
            
            let resp : CaptureNecropsyViewData = dataArrayRes.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            
            var  necId = Int()
            if postingIdFromExistingNavigate == "Exting"{
                
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(resp.birdNo!, farmname: resp.formName!, catName: resp.catName!,Obsid: resp.obsID!,necId:necId as NSNumber)
            
            let resp1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                let imageName = "Resp" + "_" + resp1.obsName! + "_n"
                var image = UIImage(named:imageName)
                if image == nil
                {
                    image = UIImage(named:"Image01")
                    
                }
                
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Resp", obsName: resp1.obsName!, formName:resp.formName! , obsVisibility: sender.isOn, birdNo: resp.birdNo!, camraImage: image!, obsPoint: incrementValue , index: rowIndex, obsId: Int(truncating: resp1.obsID!),necId: necId as NSNumber,isSync :true)
                
            }
            
            dataArrayRes.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting"{
                
                necId =  postingIdFromExisting
            }
            else{
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            dataArrayRes =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(resp.birdNo! , farmname: resp.formName!, catName: "Resp",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
        }
    }
    
    fileprivate func handleSwitchClickBtnTag4(_ rowIndex: Int, _ sender: UISwitch) {
        if btnTag == 4 {
            let immune : CaptureNecropsyViewData = dataArrayImmu.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var necId = Int()
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
            
            if postingIdFromExistingNavigate == "Exting" {
                necId =  postingIdFromExisting
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(immune.birdNo!, farmname: immune.formName!, catName: immune.catName!,Obsid: immune.obsID!,necId:necId as NSNumber)
            
            let immune1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                let imageName = "Immune" + "_" + immune1.obsName! + "_n"
                var image = UIImage(named:imageName)
                if image == nil {
                    image = UIImage(named:"Image01")
                }
                
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnSwithCase("Immune", obsName: immune1.obsName!, formName:immune.formName! , obsVisibility: sender.isOn, birdNo: immune.birdNo!, camraImage: image!, obsPoint: incrementValue , index: rowIndex, obsId: Int(truncating: immune1.obsID!),necId: necId as NSNumber,isSync :true)
                
            }
            
            dataArrayImmu.removeAllObjects()
            
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
            if postingIdFromExistingNavigate == "Exting" {
                necId =  postingIdFromExisting
            }
            
            dataArrayImmu = CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(immune.birdNo! , farmname: immune.formName!, catName: "Immune",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            
            
        }
    }
    
    @objc func switchClick(_ sender:UISwitch) {
        
        let rowIndex :Int = sender.tag
        lastSelectedIndex = IndexPath(row: rowIndex, section: 0)
        
        handleSwitchClickBtnTag0(rowIndex, sender)
        handleSwitchClickBtnTag1(rowIndex, sender)
        handleSwitchClickBtnTag2(rowIndex, sender)
        handleSwitchClickBtnTag3(rowIndex, sender)
        handleSwitchClickBtnTag4(rowIndex, sender)
        
        if postingIdFromExistingNavigate == "Exting" {
            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
        } else if UserDefaults.standard.bool(forKey: "Unlinked") == true {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
        } else {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
        }
        
    }
    // MARK: 🟠 Bird Sex Button click
    fileprivate func handlePostingIdFromExistingNavigate() {
        if postingIdFromExistingNavigate == "Exting" {
            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
        } else if UserDefaults.standard.bool(forKey: "Unlinked") == true {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
        } else {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
        }
    }
    
    @objc func birdSexClick(_ sender:UIButton) {
        
        let rowIndex :Int = sender.tag
        lastSelectedIndex = IndexPath(row: rowIndex, section: 0)
        
        if btnTag == 4 {
            
            let immune : CaptureNecropsyViewData = dataArrayImmu.object(at: rowIndex) as! CaptureNecropsyViewData
            let image = UIImage(named:"Image01")
            var  necId = Int()
            
            if postingIdFromExistingNavigate == "Exting"{
                necId =  postingIdFromExisting
            } else {
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(immune.birdNo!, farmname: immune.formName!, catName: immune.catName!,Obsid: immune.obsID!,necId:necId as NSNumber)
            
            let immune1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                let imageName = "Immune" + "_" + immune1.obsName! + "_n"
                var image = UIImage(named:imageName)
                if image == nil {
                    image = UIImage(named:"Image01")
                }
                
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnActualClick("Immune", obsName: immune1.obsName!, formName:immune.formName! , birdNo: immune.birdNo!,  actualName : selectedSexValue, index: rowIndex, necId :necId as NSNumber, isSync :true,refId:immune.refId!)
            }
            
            dataArrayImmu.removeAllObjects()
            
            if postingIdFromExistingNavigate == "Exting" {
                necId =  postingIdFromExisting
            } else {
                necId = UserDefaults.standard.integer(forKey: "necId") as Int
            }
            dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(immune.birdNo! , farmname: immune.formName!, catName: "Immune",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        handlePostingIdFromExistingNavigate()
    }
    // MARK: 🟠 Click Image
    @objc func clickImage(_ sender: UIButton) {
        
        if btnTag == 0 {
            let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: sender.tag) as! CaptureNecropsyViewData
            
            photoDict = NSMutableDictionary()
            photoDict.setValue(sender.tag, forKey: "index")
            photoDict.setValue(skleta.formName, forKey: "formName")
            photoDict.setValue(skleta.catName, forKey: "catName")
            photoDict.setValue(skleta.obsName, forKey: "obsName")
            photoDict.setValue(skleta.birdNo, forKey: "birdNo")
            photoDict.setValue(skleta.obsID, forKey: "obsid")
            photoDict.setValue(skleta.necropsyId, forKey: "necId")
        }
        
        if btnTag == 1 {
            let cocoii : CaptureNecropsyViewData = dataArrayCocoi.object(at: sender.tag) as! CaptureNecropsyViewData
            photoDict = NSMutableDictionary()
            photoDict.setValue(sender.tag, forKey: "index")
            photoDict.setValue(cocoii.formName, forKey: "formName")
            photoDict.setValue(cocoii.catName, forKey: "catName")
            photoDict.setValue(cocoii.obsName, forKey: "obsName")
            photoDict.setValue(cocoii.birdNo, forKey: "birdNo")
            photoDict.setValue(cocoii.obsID, forKey: "obsid")
            photoDict.setValue(cocoii.necropsyId, forKey: "necId")
        }
        if btnTag == 2 {
            let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: sender.tag) as! CaptureNecropsyViewData
            photoDict = NSMutableDictionary()
            photoDict.setValue(sender.tag, forKey: "index")
            photoDict.setValue(gitract.formName, forKey: "formName")
            photoDict.setValue(gitract.catName, forKey: "catName")
            photoDict.setValue(gitract.obsName, forKey: "obsName")
            photoDict.setValue(gitract.birdNo, forKey: "birdNo")
            photoDict.setValue(gitract.obsID, forKey: "obsid")
            photoDict.setValue(gitract.necropsyId, forKey: "necId")
        }
        if btnTag == 3 {
            let res : CaptureNecropsyViewData = dataArrayRes.object(at: sender.tag) as! CaptureNecropsyViewData
            photoDict = NSMutableDictionary()
            photoDict.setValue(sender.tag, forKey: "index")
            photoDict.setValue(res.formName, forKey: "formName")
            photoDict.setValue(res.catName, forKey: "catName")
            photoDict.setValue(res.obsName, forKey: "obsName")
            photoDict.setValue(res.birdNo, forKey: "birdNo")
            photoDict.setValue(res.obsID, forKey: "obsid")
            photoDict.setValue(res.necropsyId, forKey: "necId")
        }
        if btnTag == 4 {
            let immu : CaptureNecropsyViewData = dataArrayImmu.object(at: sender.tag) as! CaptureNecropsyViewData
            photoDict = NSMutableDictionary()
            photoDict.setValue(sender.tag, forKey: "index")
            photoDict.setValue(immu.formName, forKey: "formName")
            photoDict.setValue(immu.catName, forKey: "catName")
            photoDict.setValue(immu.obsName, forKey: "obsName")
            photoDict.setValue(immu.birdNo, forKey: "birdNo")
            photoDict.setValue(immu.obsID, forKey: "obsid")
            photoDict.setValue(immu.necropsyId, forKey: "necId")
        }
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "image") as? ImageViewController
        mapViewControllerObj!.imageDict = photoDict
        self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
    }
    
    // MARK: 🟠 ************** Camera Button Action ***************************************/
    
    @objc func takePhoto(_ sender: UIButton) {
        let imageArrWithIsyncIsTrue = CoreDataHandler().fecthPhotoWithiSynsTrue(true)
        if imageArrWithIsyncIsTrue.count == 8{
            
            if lngId == 1 {
                postAlert(NSLocalizedString(Constants.alertStr, comment: ""), message: NSLocalizedString("Maximum limit of image has been exceeded. Limit will be reset after next sync.", comment: ""))
            }
            else if lngId == 3 {
                postAlert(NSLocalizedString("Alerte", comment: ""), message: NSLocalizedString("La limite maximale de l'image a été dépassée. La limite sera réinitialisée après la prochaine synchronisation.", comment: ""))
            }
            else if lngId == 4 {
                postAlert(NSLocalizedString("Alerta", comment: ""), message: NSLocalizedString("O limite máximo de imagem foi excedido. O limite será redefinido após a próxima sincronização.", comment: ""))
            }
        }
        else{
            if btnTag == 0 {
                let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: sender.tag) as! CaptureNecropsyViewData
                photoDict = NSMutableDictionary()
                photoDict.setValue(sender.tag, forKey: "index")
                photoDict.setValue(skleta.formName, forKey: "formName")
                photoDict.setValue(skleta.catName, forKey: "catName")
                photoDict.setValue(skleta.obsName, forKey: "obsName")
                photoDict.setValue(skleta.birdNo, forKey: "birdNo")
                photoDict.setValue(skleta.obsID, forKey: "obsid")
            }
            if btnTag == 1 {
                let cocoii : CaptureNecropsyViewData = dataArrayCocoi.object(at: sender.tag) as! CaptureNecropsyViewData
                photoDict = NSMutableDictionary()
                photoDict.setValue(sender.tag, forKey: "index")
                photoDict.setValue(cocoii.formName, forKey: "formName")
                photoDict.setValue(cocoii.catName, forKey: "catName")
                photoDict.setValue(cocoii.obsName, forKey: "obsName")
                photoDict.setValue(cocoii.birdNo, forKey: "birdNo")
                photoDict.setValue(cocoii.obsID, forKey: "obsid")
            }
            if btnTag == 2 {
                let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: sender.tag) as! CaptureNecropsyViewData
                photoDict = NSMutableDictionary()
                photoDict.setValue(sender.tag, forKey: "index")
                photoDict.setValue(gitract.formName, forKey: "formName")
                photoDict.setValue(gitract.catName, forKey: "catName")
                photoDict.setValue(gitract.obsName, forKey: "obsName")
                photoDict.setValue(gitract.birdNo, forKey: "birdNo")
                photoDict.setValue(gitract.obsID, forKey: "obsid")
            }
            if btnTag == 3 {
                let res : CaptureNecropsyViewData = dataArrayRes.object(at: sender.tag) as! CaptureNecropsyViewData
                photoDict = NSMutableDictionary()
                photoDict.setValue(sender.tag, forKey: "index")
                photoDict.setValue(res.formName, forKey: "formName")
                photoDict.setValue(res.catName, forKey: "catName")
                photoDict.setValue(res.obsName, forKey: "obsName")
                photoDict.setValue(res.birdNo, forKey: "birdNo")
                photoDict.setValue(res.obsID, forKey: "obsid")
            }
            if btnTag == 4 {
                let immu : CaptureNecropsyViewData = dataArrayImmu.object(at: sender.tag) as! CaptureNecropsyViewData
                photoDict = NSMutableDictionary()
                photoDict.setValue(sender.tag, forKey: "index")
                photoDict.setValue(immu.formName, forKey: "formName")
                photoDict.setValue(immu.catName, forKey: "catName")
                photoDict.setValue(immu.obsName, forKey: "obsName")
                photoDict.setValue(immu.birdNo, forKey: "birdNo")
                photoDict.setValue(immu.obsID, forKey: "obsid")
            }
            /*************** Intilzing Camera Delegate Methods **********************************/
            if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
                if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.cameraCaptureMode = .photo
                    
                    present(imagePicker, animated: true, completion: {print(appDelegateObj.testFuntion())})
                } else {
                    
                    if lngId == 1 {
                        postAlert(NSLocalizedString("Rear camera doesn't exist.", comment: ""), message:NSLocalizedString("Application cannot access the camera.", comment: "") )
                    }
                    else if lngId == 3 {
                        postAlert(NSLocalizedString("La caméra arrière n'existe pas.", comment: ""), message:NSLocalizedString("L'application ne peut pas accéder à la caméra.", comment: "") )
                    }
                    else if lngId == 4 {
                        postAlert(NSLocalizedString("A câmera traseira não existe.", comment: ""), message:NSLocalizedString("O aplicativo não pode acessar a câmera.", comment: "") )
                    }
                }
            }
            else {
                if lngId == 1 {
                    postAlert(NSLocalizedString("Camera inaccessable", comment: ""), message: NSLocalizedString("Application cannot access the camera.", comment: ""))
                }
                else if lngId == 3 {
                    postAlert(NSLocalizedString("Caméra inaccessible.", comment: ""), message:NSLocalizedString("L'application ne peut pas accéder à la caméra.", comment: "") )
                }
                else if lngId == 4 {
                    postAlert(NSLocalizedString("Câmera inacessível", comment: ""), message:NSLocalizedString("O aplicativo não pode acessar a câmera.", comment: "") )
                }
            }
        }
        /****************************************************************************************/
    }
    
    // MARK: 🟠 *********** Alert View Methods ***********************************/
    
    func postAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    /**************************************************************************************************/
    
    override func showtoast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-100, width: 250, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font =   UIFont(name: "HelveticaNeue-Light", size: 11.0)
        toastLabel.text = message
        toastLabel.numberOfLines = 3
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    // MARK: 🟠 Add Bird Responce Data
    fileprivate func handleFarmmBirdFarmVisit(_ frameBird: inout CGFloat) {
        if self.farmRow == 0 {
            self.isFirstTimeLaunch = true
        }
        if self.postingIdFromExistingNavigate == "Exting"{
            self.isFirstTimeLaunch = true
        }
        
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 2
        {
            frameBird = 80
        }
        
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 3
        {
            frameBird = 161
        }
        
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 4
        {
            frameBird = 237
        }
        
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 5
        {
            frameBird = 313
        }
        
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 6
        {
            frameBird = 392
        }
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 7
        {
            frameBird = 468
        }
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 8
        {
            frameBird = 548
        }
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 9
        {
            frameBird = 550
        }
        if (self.noOfBirdsArr1[self.farmRow] as AnyObject).count == 10
        {
            frameBird = 550
        }
    }
    
    fileprivate func handleAddImmuneResponse(_ status: Bool) {
        if status == true {
            self.neccollectionView.reloadData()
            self.birdsCollectionView.reloadData()
            var frameBird = CGFloat((self.noOfBirdsArr1[self.farmRow] as AnyObject).count) as CGFloat * 60
            
            self.handleFarmmBirdFarmVisit(&frameBird)
            UserDefaults.standard.set((self.noOfBirdsArr1[self.farmRow] as AnyObject).count, forKey: "bird")
            
            self.traingleImageView.frame = CGRect(x: 276 + frameBird, y: 229, width: 24, height: 24)
            self.increaseBirdBtn.isUserInteractionEnabled = true
            self.decBirdNumberBtn.isUserInteractionEnabled = true
            self.addFormBtn.isUserInteractionEnabled = true
            
            let totalNoOfBirdInForm  = (self.noOfBirdsArr1[self.farmRow] as AnyObject).count as Int
            if self.postingIdFromExistingNavigate == "Exting" {
                let birdCount = totalNoOfBirdInForm - 1
                let indxPth = NSIndexPath(item: birdCount, section: 0);
                self.birdsCollectionView!.selectItem(at: indxPth as IndexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
            } else {
                self.birdsCollectionView!.selectItem(at: IndexPath(item: totalNoOfBirdInForm - 1, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
            }
            Helper.dismissGlobalHUD(self.view)
        }
    }
    
    fileprivate func handleAddGITrakt(_ status: Bool) {
        if status == true {
            self.addrespResponseData(self.noOfBirdsArr1, completion: { (status) in
                if status == true {
                    self.addImmuneResponseData(self.noOfBirdsArr1, completion: { (status) in
                        handleAddImmuneResponse(status)
                    })
                }
            })
        }
    }
    
    fileprivate func handleNoOfLoops(_ formIndex: Int, _ numOfLoop: Int, _ isBirdCount: inout Bool?) {
        if formIndex == self.farmRow + 1 {
            if numOfLoop >  10 {
                isBirdCount = true
                
                if lngId == 1 {
                    Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString("You can not add more than 10 birds.", comment: ""))
                } else if lngId == 3 {
                    Helper.showAlertMessage(self,titleStr:NSLocalizedString("Alerte", comment: "") , messageStr:"Vous ne pouvez pas ajouter plus de 10 oiseaux.")
                }
                else if lngId == 4 {
                    Helper.showAlertMessage(self,titleStr:NSLocalizedString("Alerta", comment: "") , messageStr:"Você não pode adicionar mais de 10 pássaros.")
                }
                
                self.view.alpha = 1
                self.view.isUserInteractionEnabled = true
                
                self.increaseBirdBtn.isUserInteractionEnabled = true
                self.decBirdNumberBtn.isUserInteractionEnabled = true
                self.addFormBtn.isUserInteractionEnabled = true
                Helper.dismissGlobalHUD(self.view)
            }
        }
    }
    
    fileprivate func handleIsBirdCountAndAddSkeletonResponseData(_ isBirdCount: Bool?) {
        if isBirdCount == false {
            
            self.addSkeltonResponseData(noOfBirdsArr1) { (status) in
                if status == true {
                    self.addCocoiResponseData(self.noOfBirdsArr1, completion: { (status) in
                        if status == true {
                            self.addGitractResponseData(self.noOfBirdsArr1, completion: { (status) in
                                self.handleAddGITrakt(status)
                            })
                        }
                    })
                }
            }
        }
    }
    
    fileprivate func handlePostingIdFromExistingNavigateAddBirdResponseData() {
        if postingIdFromExistingNavigate == "Exting" {
            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
        } else if UserDefaults.standard.bool(forKey: "Unlinked") == true {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
        } else {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
        }
    }
    
    func addBirdResponseData() {
        
        isFirstTimeLaunch = false
        
        var isBirdCount : Bool! = false
        
        var postingId = Int()
        if postingIdFromExistingNavigate == "Exting"{
            postingId = postingIdFromExisting
            self.items.removeAllObjects()
            CoreDataHandler().updateBirdNumberInNecropsystep1withNecId(postingId as NSNumber, index: self.farmRow,isSync :true)
            noOfBirdsArr1  = NSMutableArray()
            self.captureNecropsy =  CoreDataHandler().FetchNecropsystep1neccId(postingId as NSNumber) as! [NSManagedObject]
        } else {
            postingId = UserDefaults.standard.integer(forKey: "necId") as Int
            self.items.removeAllObjects()
            CoreDataHandler().updateBirdNumberInNecropsystep1withNecId(postingId as NSNumber, index: self.farmRow,isSync :true)
            noOfBirdsArr1  = NSMutableArray()
            self.captureNecropsy =  CoreDataHandler().FetchNecropsystep1neccId(postingId as NSNumber) as! [NSManagedObject]
        }
        
        for object in self.captureNecropsy {
            
            let formIndexVal =  (object.value(forKey: "farmName")! as AnyObject).substring(with: NSRange(location: 0, length: 1)) as String
            let formIndex = Int(formIndexVal)! as Int
            let noOfBirds : Int = Int(object.value(forKey: "noOfBirds") as! String)!
            let noOfBirdsArr  = NSMutableArray()
            var numOfLoop = Int()
            numOfLoop = 0
            
            for i in 0..<noOfBirds {
                numOfLoop = i  + 1
                
                if numOfLoop > 10 {
                    handleNoOfLoops(formIndex, numOfLoop, &isBirdCount)
                } else {
                    noOfBirdsArr.add(i+1)
                }
            }
            
            self.items.add(noOfBirdsArr)
            noOfBirdsArr1.add(noOfBirdsArr)
        }
        
        self.addBirdInNotes()
        
        handleIsBirdCountAndAddSkeletonResponseData(isBirdCount)
        handlePostingIdFromExistingNavigateAddBirdResponseData()
    }
    // MARK: 🟠 Scroll Move
    func loadMoveScroll ()  {
        let totalNoOfBirdInForm  = (self.noOfBirdsArr1[self.farmRow] as AnyObject).count as Int
        let birdCount = totalNoOfBirdInForm - 1
        let indxPth = NSIndexPath(item: birdCount, section: 0);
        self.birdsCollectionView!.selectItem(at: indxPth as IndexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
        Helper.dismissGlobalHUD(self.view)
    }
    // MARK: 🟢 Save Skelaton Data to Server
    func addSkeltonResponseData (_ noOfBirdsArr1: NSMutableArray,completion: (_ status: Bool) -> Void) {
        var formName  = String()
        
        formName = UserDefaults.standard.value(forKey: "farm") as! String
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        let skeletenArr = CoreDataHandler().fetchAllSeettingdataWithLngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        for i in 0..<skeletenArr.count
        {
            if ((skeletenArr.object(at: i) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                
                let skleta : Skeleta = skeletenArr.object(at: i) as! Skeleta
                if skleta.measure! == "Y,N" {
                    
                    var necId = Int()
                 
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "skeltaMuscular", obsName: skleta.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber , obsPoint: 0 ,index: self.items.count, obsId: skleta.observationId!.intValue,measure: skleta.measure!,quickLink: skleta.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:skleta.refId!, actualText: "")
                }
                else if ( skleta.measure! == "Actual"){
                    
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "skeltaMuscular", obsName: skleta.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber as NSNumber,  obsPoint: 0 ,index: self.items.count, obsId: skleta.observationId!.intValue,measure: skleta.measure!,quickLink: skleta.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:skleta.refId!, actualText: "")
                }
                else
                {
                    let trimmed = skleta.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let array = (trimmed.components(separatedBy: ",") as [String])
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "skeltaMuscular", obsName: skleta.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: Int(array[0])! , index: self.items.count, obsId: skleta.observationId!.intValue,measure: skleta.measure!,quickLink: skleta.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:skleta.refId!, actualText: "")
                }
            }
        }
        
        self.dataSkeltaArray.removeAllObjects()
        var  necId = Int()
        
        necId = getNecIdChicken()
        
        self.dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation((noOfBirdsArr1[self.farmRow] as AnyObject).count as! NSNumber, farmname: formName , catName: "skeltaMuscular",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        
        completion (true)
        
    }
    // MARK: 🟢 Save Coccidiosis Data to Server
    func addCocoiResponseData (_ noOfBirdsArr1: NSMutableArray,completion: (_ status: Bool) -> Void) {
        var formName  = String()
        formName =  UserDefaults.standard.value(forKey: "farm") as! String
        
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        UserDefaults.standard.synchronize()
        let cocoiArr = CoreDataHandler().fetchAllCocoiiDataUsinglngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        for i in 0..<cocoiArr.count
        {
            if ((cocoiArr.object(at: i) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                
                let cocoiDis : Coccidiosis = cocoiArr.object(at: i) as! Coccidiosis
                
                if cocoiDis.measure! == "Y,N" {
                    
                    
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Coccidiosis", obsName: cocoiDis.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber,obsPoint: 0 , index: self.items.count, obsId: cocoiDis.observationId!.intValue,measure: cocoiDis.measure!,quickLink: cocoiDis.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:cocoiDis.refId!, actualText: "")
                }
                else if ( cocoiDis.measure! == "Actual"){
                    
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Coccidiosis", obsName: cocoiDis.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: 0 , index: self.items.count, obsId: cocoiDis.observationId!.intValue,measure: cocoiDis.measure!,quickLink: cocoiDis.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:cocoiDis.refId!, actualText: "")
                }
                else
                {
                    
                    let trimmed = cocoiDis.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let array = (trimmed.components(separatedBy: ",") as [String])
                    
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Coccidiosis", obsName: cocoiDis.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: Int(array[0])! , index: self.items.count, obsId: cocoiDis.observationId!.intValue,measure: cocoiDis.measure!,quickLink: cocoiDis.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:cocoiDis.refId!, actualText: "")
                }
                
            }
            
        }
        
        self.dataArrayCocoi.removeAllObjects()
        
        var  necId = Int()
        
        necId = getNecIdChicken()
        
        self.dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation((noOfBirdsArr1[self.farmRow] as AnyObject).count as! NSNumber, farmname: formName , catName: "Coccidiosis",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        
        completion (true)
        
    }
    
    // MARK: 🟢 Save GITract Data to Server
    func addGitractResponseData (_ noOfBirdsArr1: NSMutableArray,completion: (_ status: Bool) -> Void) {
        var formName  = String()
        formName  = UserDefaults.standard.value(forKey: "farm") as! String
        
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        UserDefaults.standard.synchronize()
        let gitract1 =  CoreDataHandler().fetchAllGITractDataUsingLngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        
        for  j in 0..<gitract1.count
        {
            if ((gitract1.object(at: j) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                
                let gitract2 : GITract = gitract1.object(at: j) as! GITract
                
                if gitract2.measure! == "Y,N" {
                    
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "GITract", obsName: gitract2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber,obsPoint: 0 , index: self.items.count, obsId: gitract2.observationId!.intValue,measure: gitract2.measure!,quickLink: gitract2.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:gitract2.refId!, actualText: "")
                }
                
                else if ( gitract2.measure! == "Actual"){
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "GITract", obsName: gitract2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: 0 , index: self.items.count, obsId: gitract2.observationId!.intValue,measure: gitract2.measure!,quickLink: gitract2.quicklinks!,necId:necId as NSNumber,isSync:true ,lngId:lngId as NSNumber,refId:gitract2.refId!, actualText: "")
                }
                else
                {
                    let trimmed = gitract2.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let array = (trimmed.components(separatedBy: ",") as [String])
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "GITract", obsName: gitract2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: Int(array[0])! , index: self.items.count, obsId: gitract2.observationId!.intValue,measure: gitract2.measure!,quickLink: gitract2.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:gitract2.refId!, actualText: "")
                }
                
                
            }
        }
        
        
        self.dataArrayGiTract.removeAllObjects()
        
        var  necId = Int()
        
        necId = getNecIdChicken()
        
        self.dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation((noOfBirdsArr1[self.farmRow] as AnyObject).count as! NSNumber, farmname: formName , catName: "GITract",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        
        completion (true)
        
    }
    // MARK: 🟢 Save Respiratory Data to Server
    func addrespResponseData (_ noOfBirdsArr1: NSMutableArray,completion: (_ status: Bool) -> Void) {
        var formName  = String()
        formName = UserDefaults.standard.value(forKey: "farm") as! String
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        UserDefaults.standard.synchronize()
        let resp1 =  CoreDataHandler().fetchAllRespiratoryusingLngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        for  j in 0..<resp1.count
        {
            if ((resp1.object(at: j) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                let resp2 : Respiratory = resp1.object(at: j) as! Respiratory
                if resp2.measure! == "Y,N" {
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Resp", obsName: resp2.observationField!, formName:formName, obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber,  obsPoint: 0 , index: self.items.count, obsId: resp2.observationId!.intValue,measure: resp2.measure!,quickLink: resp2.quicklinks!,necId:necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:resp2.refId!, actualText: "")
                }
                else if ( resp2.measure! == "Actual"){
                    var necId = Int()
                    necId = getNecIdChicken()
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Resp", obsName: resp2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: 0 , index: self.items.count, obsId: resp2.observationId!.intValue,measure: resp2.measure!,quickLink: resp2.quicklinks!,necId:necId as NSNumber,isSync:true ,lngId:lngId as NSNumber,refId:resp2.refId!, actualText: "")
                }
                else
                {
                    let trimmed = resp2.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let array = (trimmed.components(separatedBy: ",") as [String])
                    var necId = Int()
                    necId = getNecIdChicken()
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Resp", obsName: resp2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: Int(array[0])! , index: self.items.count, obsId: resp2.observationId!.intValue,measure: resp2.measure!,quickLink: resp2.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:resp2.refId!, actualText: "")
                }
            }
        }
        
        self.dataArrayRes.removeAllObjects()
        var  necId = Int()
        necId = getNecIdChicken()
        
        self.dataArrayRes =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation((noOfBirdsArr1[self.farmRow] as AnyObject).count as! NSNumber, farmname: formName , catName: "Resp",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        completion (true)
        
    }
    // MARK: 🟢 Save Immune & Other's Data to Server
    func addImmuneResponseData (_ noOfBirdsArr1: NSMutableArray,completion: (_ status: Bool) -> Void) {
        var formName  = String()
        formName = UserDefaults.standard.value(forKey: "farm") as! String
        lngId = UserDefaults.standard.integer(forKey: "lngId")
        UserDefaults.standard.synchronize()
        let immu1 =   CoreDataHandler().fetchAllImmuneUsingLngId(lngId: lngId as NSNumber).mutableCopy() as! NSMutableArray
        
        
        for  j in 0..<immu1.count
        {
            if ((immu1.object(at: j) as AnyObject).value(forKey: "visibilityCheck") as AnyObject).int32Value == 1 {
                let immune2 : Immune = immu1.object(at: j) as! Immune
                if immune2.measure! == "Y,N" {
                    
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune2.observationField!, formName:formName, obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: 0 , index: self.items.count, obsId: immune2.observationId!.intValue,measure: immune2.measure!,quickLink: immune2.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune2.refId!, actualText: "0.0")
                }
                else if ( immune2.measure! == "Actual"){
                    var necId = Int()
                    necId = getNecIdChicken()
                    
                    
                    CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count! as NSNumber, obsPoint: 0 , index: self.items.count, obsId: immune2.observationId!.intValue,measure: immune2.measure!,quickLink: immune2.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune2.refId!, actualText: "0.0")
                }
                
                else if ( immune2.measure! == "F,M"){  /// New Addition for Bird Sex
                    let trimmed = immune2.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if immune2.observationField == Constants.maleFemaleStr
                    {
                        var necId = Int()
                        necId = getNecIdChicken()
                        
                        CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count! as NSNumber, obsPoint: 0 , index: self.items.count, obsId: immune2.observationId!.intValue,measure: immune2.measure!,quickLink: immune2.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune2.refId!, actualText: "0")
                    }
                }
                
                else
                {
                    
                    let trimmed = immune2.measure!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let array = (trimmed.components(separatedBy: ",") as [String])
                    if immune2.observationField == "Bursa Size"
                    {
                        
                        var necId = Int()
                        necId = getNecIdChicken()
                        
                        CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: Int(array[3])! , index: self.items.count, obsId: immune2.observationId!.intValue,measure: immune2.measure!,quickLink: immune2.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune2.refId!, actualText: "0.0")
                    }
                    else
                    {
                        
                        var necId = Int()
                        necId = getNecIdChicken()
                        
                        CoreDataHandler().saveCaptureSkeletaInDatabaseOnSwithCase(catName: "Immune", obsName: immune2.observationField!, formName:formName , obsVisibility: false, birdNo: (noOfBirdsArr1[self.farmRow] as AnyObject).count as NSNumber, obsPoint: Int(array[0])! , index: self.items.count, obsId: immune2.observationId!.intValue,measure: immune2.measure!,quickLink: immune2.quicklinks!,necId: necId as NSNumber,isSync:true,lngId:lngId as NSNumber,refId:immune2.refId!, actualText: "0.0")
                    }
                }
            }
        }
        
        self.dataArrayImmu.removeAllObjects()
        
        var  necId = Int()
        
        necId = getNecIdChicken()
        self.dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation((noOfBirdsArr1[self.farmRow] as AnyObject).count as! NSNumber, farmname: formName, catName: "Immune",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        completion (true)
        
    }
    
    @objc func saveSuccess()
    {
        self.addBirdResponseData()
    }
    // MARK: 🟢 Add New Bird to existing farm Server
    @IBAction func addBirds(_ sender: AnyObject) {
        
        let formName = UserDefaults.standard.value(forKey: "farm") as! String
        
        for i in 0..<farmArray.count
        {
            let farm = farmArray.object(at: i) as! String
            if farm == formName
            {
                if (items.object(at: i) as AnyObject).count == 10
                {
                    if lngId == 1 {
                        Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString("You can not add more than 10 birds.", comment: ""))
                    }
                    else if lngId == 3 {
                        Helper.showAlertMessage(self,titleStr:NSLocalizedString("Alerte", comment: "") , messageStr:"Vous ne pouvez pas ajouter plus de 10 oiseaux.")
                    }
                    else if lngId == 4 {
                        Helper.showAlertMessage(self,titleStr:NSLocalizedString("Alerta", comment: "") , messageStr:"Você não pode adicionar mais de 10 pássaros.")
                    }
                    return
                }
            }
        }
        
        self.increaseBirdBtn.isUserInteractionEnabled = false
        self.decBirdNumberBtn.isUserInteractionEnabled = false
        self.addFormBtn.isUserInteractionEnabled = false
        Helper.showGlobalProgressHUDWithTitle(self.view, title: NSLocalizedString("Adding Bird...", comment: ""))
        self.perform(#selector(CaptureNecropsyDataViewController.saveSuccess), with: nil, afterDelay: 1.0)
    }
    
    // MARK: - 🔴 Delete Bird Data for Necropsy
    func deleteBirdResponseData (_ completion: (_ status: Bool) -> Void) {
        
        var postingId = Int()
        if postingIdFromExistingNavigate == "Exting"{
            postingId = postingIdFromExisting
        }
        else{
            postingId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        if  CoreDataHandler().reduceBirdNumberInNecropsystep1WithNecId(postingId as NSNumber, index: self.farmRow) == true
        {
            var farmName = String()
            
            farmName = UserDefaults.standard.value(forKey: "farm") as! String
            var  necId = Int()
            
            necId = getNecIdChicken()
            
            let isNotes = CoreDataHandler().fetchNoofBirdWithForm("skeltaMuscular", formName: farmName, necId: necId as NSNumber)
            
            let noOfBird = isNotes.count as Int
            
            if noOfBird == 1
            {
                Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString("At least one bird is required under a Farm.", comment: "") )
                traingleImageView.frame = CGRect(x: 276, y: 229, width: 24, height: 24)
            }
            
            items.removeAllObjects()
            var noOfBirdsArr1  = NSMutableArray()
            CoreDataHandler().deleteNotesBirdWithFarmname(farmName, birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
            
            if dataSkeltaArray.count > 0
            {
                var  necId = Int()
                
                necId = getNecIdChicken()
                
                let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: 0) as! CaptureNecropsyViewData
                CoreDataHandler().deleteCaptureNecropsyViewDataWithFarmnameandBirdsize(skleta.obsID!, formName: farmName , catName: skleta.catName!, birdNo: noOfBird as NSNumber, necId : necId as NSNumber)
                
                dataSkeltaArray.removeAllObjects()
                dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(1, farmname: farmName , catName: "skeltaMuscular",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            }
            
            if dataArrayCocoi.count > 0
            {
                var  necId = Int()
                
                necId = getNecIdChicken()
                
                let skleta1 : CaptureNecropsyViewData = dataArrayCocoi.object(at: 0) as! CaptureNecropsyViewData
                CoreDataHandler().deleteCaptureNecropsyViewDataWithFarmnameandBirdsize(skleta1.obsID!, formName: farmName , catName: skleta1.catName!, birdNo: noOfBird as NSNumber, necId : necId as NSNumber)
                
                dataArrayCocoi.removeAllObjects()
                dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(1, farmname: farmName , catName: "Coccidiosis",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            }
            if dataArrayGiTract.count > 0
            {
                
                var  necId = Int()
                
                necId = getNecIdChicken()
                
                let skleta2 : CaptureNecropsyViewData = dataArrayGiTract.object(at: 0) as! CaptureNecropsyViewData
                CoreDataHandler().deleteCaptureNecropsyViewDataWithFarmnameandBirdsize(skleta2.obsID!, formName: farmName , catName: skleta2.catName!, birdNo: noOfBird as NSNumber, necId : necId as NSNumber)
                
                dataArrayGiTract.removeAllObjects()
                dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(1, farmname: farmName , catName: "GITract",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            }
            
            
            if dataArrayRes.count > 0
            {
                var  necId = Int()
                necId = getNecIdChicken()
                
                let skleta3 : CaptureNecropsyViewData = dataArrayRes.object(at: 0) as! CaptureNecropsyViewData
                CoreDataHandler().deleteCaptureNecropsyViewDataWithFarmnameandBirdsize(skleta3.obsID!, formName: farmName , catName: skleta3.catName!, birdNo:noOfBird as NSNumber, necId : necId as NSNumber)
                
                dataArrayRes.removeAllObjects()
                dataArrayRes =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(1, farmname: farmName , catName: "Resp",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            }
            if dataArrayImmu.count > 0
            {
                
                var  necId = Int()
                necId = getNecIdChicken()
                
                let skleta4 : CaptureNecropsyViewData = dataArrayImmu.object(at: 0) as! CaptureNecropsyViewData
                CoreDataHandler().deleteCaptureNecropsyViewDataWithFarmnameandBirdsize(skleta4.obsID!, formName: farmName , catName: skleta4.catName!, birdNo: noOfBird as NSNumber, necId : necId as NSNumber)
                
                dataArrayImmu.removeAllObjects()
                dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(1, farmname: farmName , catName: "Immune",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            }
            
            for i in 0..<farmArray.count
            {
                let formName = farmArray.object(at: i)
                
                var  necId = Int()
                
                necId = getNecIdChicken()
                
                let isNotes = CoreDataHandler().fetchNoofBirdWithForm("skeltaMuscular", formName: formName as! String,necId: necId as NSNumber)
                let noOfBird = isNotes.count as Int
                let noOfBirdsArr  = NSMutableArray()
                
                for i in 0..<noOfBird
                {
                    noOfBirdsArr.add(i+1)
                }
                items.add(noOfBirdsArr)
            }
            
            if self.farmRow == 0
            {
                self.isFirstTimeLaunch = true
            }
            if postingIdFromExistingNavigate == "Exting"{
                self.isFirstTimeLaunch = true
            }
            
            neccollectionView.reloadData()
            birdsCollectionView.reloadData()
            birdsCollectionView.selectItem(at: IndexPath(item: 0 , section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
        }
        else
        {
            Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString("At least one bird is required under a Farm.", comment: "") )
        }
        
        traingleImageView.frame = CGRect(x: 276, y: 229, width: 24, height: 24)
        
        if postingIdFromExistingNavigate == "Exting"{
            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
        }
        
        else if UserDefaults.standard.bool(forKey: "Unlinked") == true{
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
        }
        else{
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
        }
        completion (true)
    }
    
    @objc func deleteSuccess()
    {
        self.deleteBirdResponseData { (status) in
            if status == true
            {
                Helper.dismissGlobalHUD(self.view)
                self.increaseBirdBtn.isUserInteractionEnabled = true
                self.decBirdNumberBtn.isUserInteractionEnabled = true
                self.addFormBtn.isUserInteractionEnabled = true
                UserDefaults.standard.set(1, forKey: "bird")
            }
        }
    }
    // MARK: - 🔴 Delete Bird Button Action
    @IBAction func deleteBirds(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: NSLocalizedString(Constants.alertStr, comment: ""), message: NSLocalizedString("Are you sure you want to delete this bird? You will lose the data by deleting this bird.", comment: ""), preferredStyle: .alert)
        let action1 = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default)
        let action2 = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel) { (action:UIAlertAction) in
            self.isFirstTimeLaunch = false
            let formName = UserDefaults.standard.value(forKey: "farm") as! String
            for i in 0..<self.farmArray.count
            {
                let farm = self.farmArray.object(at: i) as! String
                if farm == formName
                {
                    if (self.items.object(at: i) as AnyObject).count == 1
                    {
                        Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString(Constants.offline, comment: ""))
                        return
                    }
                }
            }
            
            Helper.showGlobalProgressHUDWithTitle(self.view, title: NSLocalizedString("Deleting Bird...", comment: ""))
            self.perform(#selector(CaptureNecropsyDataViewController.deleteSuccess), with: nil, afterDelay: 1.0)
        }
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
    // MARK: 🟠 Long Press gesture
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = birdsCollectionView.indexPathForItem(at: touchPoint) {
                
                let cell = birdsCollectionView.cellForItem(at: indexPath)
                let button = UIButton(frame: CGRect(x: 0, y: 20, width:20, height: 20))
                button.backgroundColor = .green
                button.setTitle("Test Button", for: UIControl.State())
                button.addTarget(self, action:#selector(CaptureNecropsyDataViewController.buttonAction(_:)), for: .touchUpInside)
                cell?.contentView.addSubview(button)
                button.tag  = indexPath.row
            }
        }
    }
    // MARK: 🟠 Done Button action
    @IBAction func doneButton(_ sender: AnyObject) {
        CommonClass.sharedInstance.updateCount()
        let necId = UserDefaults.standard.integer(forKey: "necId") as Int
        let postingDataa = CoreDataHandler().fetchAllPostingSession(necId as NSNumber)
        
        var issync = Bool()
        if postingDataa.count > 0 {
            let sync :  PostingSession =  postingDataa.object(at: 0) as! PostingSession
            issync =   sync.isSync! as! Bool
            if issync == false{
                CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
            }
        }
        
        if  finalizeValue == 1 {
            self.navigationController?.popViewController(animated: true)
            
        }else
        {
            var  postingId = Int()
            if UserDefaults.standard.bool(forKey: "Unlinked") == true
            {
                postingId = 0
                UserDefaults.standard.removeObject(forKey: "unCustId")
                let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "DashView_Controller") as? DashViewController
                self.navigationController?.pushViewController(mapViewControllerObj!, animated: false)
            }
            else if postingIdFromExistingNavigate == "Exting"{
                self.navigationController?.popViewController(animated: true)
                UserDefaults.standard.removeObject(forKey: "unCustId")
            }
            else{
                postingId = UserDefaults.standard.integer(forKey: "postingId")
                CoreDataHandler().updateFinalizeDataWithNec(postingId as NSNumber, finalizeNec: 1)
                backBttnn = UIButton(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
                backBttnn.backgroundColor = UIColor.black
                backBttnn.alpha = 0.6
                backBttnn.setTitle("", for: UIControl.State())
                backBttnn.addTarget(self, action: #selector(buttonAcn), for: .touchUpInside)
                self.view.addSubview(backBttnn)
                
                summaryRepo = summaryReport.loadFromNibNamed("summaryReport") as! summaryReport
                summaryRepo.summaryReportDelegate = self
                summaryRepo.center = self.view.center
                self.view.addSubview(summaryRepo)
            }
        }}
    
    @objc func buttonAcn(_ sender: UIButton!) {
        summaryRepo.removeFromSuperview()
        backBttnn.removeFromSuperview()
    }
    // MARK: 🟠 Yes Button Action
    func yesButtonFunc (){
        CommonClass.sharedInstance.updateCount()
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "Report") as? Report_MainVCViewController
        AllValidSessions.sharedInstance.complexName = lblComplex.text! as NSString
        AllValidSessions.sharedInstance.complexDate = lblDate.text! as NSString
        self.navigationController?.pushViewController(mapViewControllerObj!, animated: false)
    }
    // MARK: 🟠 No Button Action
    func noButtonFunc (){
        CommonClass.sharedInstance.updateCount()
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "DashView_Controller") as? DashViewController
        AllValidSessions.sharedInstance.complexName = ""
        self.navigationController?.pushViewController(mapViewControllerObj!, animated: false)
    }
    // MARK: 🟠 Cross Button Action
    func crossButtonFunct (){
        summaryRepo.removeFromSuperview()
        backBttnn.removeFromSuperview()
    }
    
    @objc func buttonAction(_ sender: UIButton!) {
        items.removeObject(at: sender.tag)
        let btn = sender as UIButton
        btn .removeFromSuperview()
        birdsCollectionView.reloadData()
    }
    // MARK: 🟠 Load Farm Data
    @objc func loadformdata(){
        
        let rowToSelect:IndexPath = IndexPath(row: tableViewSelectedRow, section: 0)
        tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: UITableView.ScrollPosition.none)
        self.tableView(self.tableView, didSelectRowAt: rowToSelect)
        var necId = Int()
        if postingIdFromExistingNavigate == "Exting"{
            necId =  postingIdFromExisting
        }
        else{
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        if tableViewSelectedRow == 0 {
            dataSkeltaArray.removeAllObjects()
            dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatname( UserDefaults.standard.object(forKey: "farm") as! String, catName: "skeltaMuscular",birdNo: 1,necId : necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        if tableViewSelectedRow == 1 {
            dataArrayCocoi.removeAllObjects()
            dataArrayCocoi =   CoreDataHandler().fecthFrmWithCatname(UserDefaults.standard.object(forKey: "farm") as! String, catName: "Coccidiosis" ,birdNo: 1,necId : necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        if tableViewSelectedRow == 2 {
            dataArrayGiTract.removeAllObjects()
            dataArrayGiTract =   CoreDataHandler().fecthFrmWithCatname( UserDefaults.standard.object(forKey: "farm") as! String, catName: "GITract",birdNo: 1,necId : necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        if tableViewSelectedRow == 3 {
            dataArrayRes.removeAllObjects()
            dataArrayRes =  CoreDataHandler().fecthFrmWithCatname( UserDefaults.standard.object(forKey: "farm") as! String, catName: "Resp",birdNo: 1,necId : necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        if tableViewSelectedRow == 4 {
            dataArrayImmu.removeAllObjects()
            dataArrayImmu =   CoreDataHandler().fecthFrmWithCatname(UserDefaults.standard.object(forKey: "farm") as! String, catName: "Immune",birdNo: 1,necId : necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        birdsCollectionView.reloadData()
        birdsCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
        neccollectionView.reloadData()
        UserDefaults.standard.setValue(1, forKey: "bird")
        UserDefaults.standard.synchronize()
        Helper.dismissGlobalHUD(self.view)
    }
    
    // MARK: 🟠 Load Bird Data from DB
    fileprivate func manageBtnTagValidations(_ bird: NSNumber, _ necId: Int) {
        if btnTag == 0 {
            
            dataSkeltaArray.removeAllObjects()
            dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird , farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "skeltaMuscular",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataSkeltaArray.count > 0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        if btnTag == 1 {
            dataArrayCocoi.removeAllObjects()
            dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird , farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "Coccidiosis",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataArrayCocoi.count > 0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        if btnTag == 2 {
            dataArrayGiTract.removeAllObjects()
            dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird , farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "GITract",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataArrayGiTract.count > 0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
    }
    
    func callLodaBirdData(_ bird : NSNumber)  {
        
        if self.farmRow == 0
        {
            self.isFirstTimeLaunch =  true
        }
        
        let  bird = UserDefaults.standard.value(forKey: "bird") as! NSNumber
        var  necId = Int()
        
        if postingIdFromExistingNavigate == "Exting"{
            necId =  postingIdFromExisting
        }
        else{
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        manageBtnTagValidations(bird, necId)
        if btnTag == 3 {
            dataArrayRes.removeAllObjects()
            dataArrayRes =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird , farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "Resp",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataArrayRes.count > 0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        if btnTag == 4 {
            dataArrayImmu.removeAllObjects()
            dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(bird , farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "Immune",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataArrayImmu.count > 0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        Helper.dismissGlobalHUD(self.view)
    }
    
    
    // MARK: 🟠 - DROP DOWN HIDDEN AND SHOW
    
    func dropHiddenAndShow(){
        if dropDown.isHidden{
            let _ = dropDown.show()
        } else {
            dropDown.hide()
        }
    }
    // MARK: 🟠 Resize Image
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: 500))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: 500))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    // MARK: -  Image Picker Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var number = 5
        let numberPointer = UnsafeMutableRawPointer(&number)
        if let pickedImage:UIImage = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]) as? UIImage {
            self.imageWasSavedSuccessfully(pickedImage, didFinishSavingWithError: nil, context:numberPointer)
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, nil, nil)
        }
        imagePicker.dismiss(animated: true, completion: {
            print(appDelegateObj.testFuntion())
        })
    }
    /******************************************************************************************************/
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @objc func imageWasSavedSuccessfully(_ image: UIImage, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        
        if let theError = error {
            print(appDelegateObj.testFuntion())
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                
                var necId  = Int()
                if self.postingIdFromExistingNavigate == "Exting"{
                    necId =  self.postingIdFromExisting
                }
                else{
                    necId = UserDefaults.standard.integer(forKey: "necId") as Int
                }
                self.showtoast(message: "Observation Start")
                CoreDataHandler().saveCaptureSkeletaImageInDatabase(self.photoDict.value(forKey: "catName") as! String, obsName: self.photoDict.value(forKey: "obsName") as! String, formName: self.photoDict.value(forKey: "formName") as! String, birdNo: self.photoDict.value(forKey: "birdNo") as! NSNumber, camraImage: image, obsId: self.photoDict.value(forKey: "obsid") as! Int , necropsyId : necId as NSNumber, isSync :true, viewController: self)
                self.showtoast(message: "Observation Saved")
                if self.postingIdFromExistingNavigate == "Exting"{
                    
                    CoreDataHandler().updateisSyncTrueOnPostingSession(self.postingIdFromExisting as NSNumber)
                    CoreDataHandler().updateisSyncNecropsystep1WithneccId(self.postingIdFromExisting as NSNumber, isSync : true)
                }
                else if UserDefaults.standard.bool(forKey: "Unlinked") == true{
                    
                    let necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
                }
                
                self.neccollectionView.reloadData()
            })
        }
    }
    
    //MARK: CollectionView
    fileprivate func handleFirstTimeLaunchValidation() -> Int {
        if isFirstTimeLaunch == true {
            if postingIdFromExistingNavigate == "Exting"{
                return (items[self.farmRow] as AnyObject).count
            } else {
                return (items[0] as AnyObject).count
            }
        } else {
            if farmRow == 0 {
                return (items[0] as AnyObject).count
            } else {
                if  Constants.isForUnlinkedChicken == true {
                    return (items[farmArray.count - 1] as AnyObject).count
                } else {
                    return (items[selectedBirdIndex] as AnyObject).count
                }
            }
        }
    }
    
    /***************************** Collection View DataSource & Delegate Methods *******************************/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == birdsCollectionView {
            if isFarmClick == true {
                return (items[self.farmRow] as AnyObject).count
            }
            
            if items.count > 0 {
                
                return handleFirstTimeLaunchValidation()
            }
            return 0
        } else if collectionView == neccollectionView {
            switch btnTag {
            case 0:
                return dataSkeltaArray.count
            case 1:
                return dataArrayCocoi.count
            case 2:
                return dataArrayGiTract.count
            case 3:
                return dataArrayRes.count
            default:
                return dataArrayImmu.count
            }
        } else if collectionView == formCollectionView{
            return self.farmArray.count
        }
        return 0
    }
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureNecropsyCollectionViewCell
        
        if collectionView == birdsCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureNecropsyCollectionViewCell
            
            if (cell.isSelected) {
                let image = UIImage(named: "addbird_bg_select")
                cell.bgImageView.image = image
                let image2 = UIImage(named: "edit")
                cell.editImage.image = image2
                cell.notePopBtn.alpha = 1
            }
            else {
                let image = UIImage(named: "addbird_bg_unselect1")
                cell.bgImageView.image = image
                let image1 = UIImage(named: "edit_black")
                cell.editImage.image = image1
                cell.notePopBtn.alpha = 0
            }
            if btnTag == 0 {
                var isNotes = NSArray()
                if dataSkeltaArray.count > 0 {
                    let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: 0) as! CaptureNecropsyViewData
                    let formName = skleta.formName
                    let catName = skleta.catName
                    let noOfBird  = indexPath.row + 1
                    var necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else {
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName! , formName: formName! , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                } else  {
                    
                    let formName = UserDefaults.standard.value(forKey: "farm") as! String
                    let catName = "skeltaMuscular"
                    let noOfBird = indexPath.row + 1
                    var necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId = postingIdFromExisting
                    } else {
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName , formName: formName , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                
                if isNotes.count > 0 {
                    let note : NotesBird = isNotes[0] as! NotesBird
                    if (note.notes == "")
                    {
                        cell.editImage.alpha = 0
                    }
                    else {
                        cell.editImage.alpha = 1
                    }
                }
                else {
                    cell.editImage.alpha = 0
                }
            }
            if btnTag == 1 {
                
                var isNotes = NSArray()
                if dataArrayCocoi.count>0
                {
                    let cocoii : CaptureNecropsyViewData = dataArrayCocoi.object(at: 0) as! CaptureNecropsyViewData
                    let formName = cocoii.formName
                    let catName = cocoii.catName
                    let noOfBird  = indexPath.row + 1
                    var  necId = Int()
                    
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else{
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName! , formName: formName! , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                else
                {
                    let formName = UserDefaults.standard.value(forKey: "farm") as! String
                    let catName = "Coccidiosis"
                    let noOfBird  = indexPath.row + 1
                    var  necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else{
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName , formName: formName , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                
                if isNotes.count > 0
                {
                    let note : NotesBird = isNotes[0] as! NotesBird
                    if (note.notes == "")
                    {
                        cell.editImage.alpha = 0
                    }
                    else
                    {
                        cell.editImage.alpha = 1
                    }
                }
                else
                {
                    cell.editImage.alpha = 0
                }
            }
            
            if btnTag == 2 {
                var isNotes = NSArray()
                if dataArrayGiTract.count > 0
                {
                    let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: 0) as! CaptureNecropsyViewData
                    let formName = gitract.formName
                    let catName = gitract.catName
                    let noOfBird  = indexPath.row + 1
                    var  necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else{
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName! , formName: formName! , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                else
                {
                    let formName = UserDefaults.standard.value(forKey: "farm") as! String
                    let catName = "GITract"
                    let noOfBird  = indexPath.row + 1
                    var  necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else{
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName , formName: formName , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                if isNotes.count > 0
                {
                    let note : NotesBird = isNotes[0] as! NotesBird
                    if (note.notes == "")
                    {
                        cell.editImage.alpha = 0
                    }
                    else
                    {
                        cell.editImage.alpha = 1
                    }
                }
                else
                {
                    cell.editImage.alpha = 0
                }
            }
            if btnTag == 3 {
                var isNotes = NSArray()
                if dataArrayRes.count>0
                {
                    let res : CaptureNecropsyViewData = dataArrayRes.object(at: 0) as! CaptureNecropsyViewData
                    let formName = res.formName
                    let catName = res.catName
                    let noOfBird  = indexPath.row + 1
                    var  necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else{
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName! , formName: formName! , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                else
                {
                    let formName = UserDefaults.standard.value(forKey: "farm") as! String
                    let catName = "Resp"
                    let noOfBird  = indexPath.row + 1
                    var  necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else{
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName , formName: formName , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                if isNotes.count > 0
                {
                    let note : NotesBird = isNotes[0] as! NotesBird
                    if (note.notes == "")
                    {
                        cell.editImage.alpha = 0
                    }
                    else
                    {
                        cell.editImage.alpha = 1
                    }
                }
                else
                {
                    cell.editImage.alpha = 0
                }
            }
            if btnTag == 4 {
                var isNotes = NSArray()
                if dataArrayImmu.count>0{
                    let immu : CaptureNecropsyViewData = dataArrayImmu.object(at: 0) as! CaptureNecropsyViewData
                    let formName = immu.formName
                    let catName = immu.catName
                    let noOfBird  = indexPath.row + 1
                    var  necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else{
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName! , formName: formName! , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                else{
                    
                    let formName = UserDefaults.standard.value(forKey: "farm") as! String
                    let catName = "Immune"
                    let noOfBird  = indexPath.row + 1
                    var  necId = Int()
                    if postingIdFromExistingNavigate == "Exting"{
                        necId =  postingIdFromExisting
                    }
                    else{
                        necId = UserDefaults.standard.integer(forKey: "necId") as Int
                    }
                    isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName , formName: formName , birdNo: noOfBird as NSNumber,necId: necId as NSNumber)
                }
                
                if isNotes.count > 0
                {
                    let note : NotesBird = isNotes[0] as! NotesBird
                    if (note.notes == "")
                    {
                        cell.editImage.alpha = 0
                    }
                    else
                    {
                        cell.editImage.alpha = 1
                    }
                }
                else
                {
                    cell.editImage.alpha = 0
                }
            }
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(CaptureNecropsyDataViewController.longPress(_:)))
            longPressRecognizer.view?.tag = indexPath.row
            cell.addGestureRecognizer(longPressRecognizer)
            
            if isFarmClick == true {
                cell.birdsCountLabel?.text = String(describing:((items.object(at: self.farmRow) as AnyObject).object(at: indexPath.row) ))
            }
            else
            {
                if isNewFarm == true
                {
                    cell.birdsCountLabel?.text =  String(describing:((items.object(at: farmArray.count-1) as AnyObject).object(at: indexPath.row) ))
                }
                else
                {
                    if isFirstTimeLaunch == true
                    {
                        if postingIdFromExistingNavigate == "Exting"{
                            cell.birdsCountLabel?.text =  String(describing:((items.object(at: self.farmRow)  as AnyObject).object(at: indexPath.row)))
                        }
                        else
                        {
                            cell.birdsCountLabel?.text =  String(describing:((items.object(at: 0) as AnyObject).object(at: indexPath.row)))
                        }
                    }
                    else
                    {
                        
                        cell.birdsCountLabel?.text =  String(describing: ((items.object(at: self.farmRow) as AnyObject).object(at: indexPath.row) ))
                      //  cell.birdsCountLabel?.text =  String(describing: ((items.object(at: farmArray.count-1) as AnyObject).object(at: indexPath.row) ))
                    }
                }
            }
            cell.notePopBtn.tag = indexPath.row
            cell.notePopBtn.addTarget(self, action: #selector(CaptureNecropsyDataViewController.notesPopView), for: .touchUpInside)
            return cell
        }
        
        else if collectionView == formCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureNecropsyCollectionViewCell
            cell.layer.borderWidth = 1.0
            cell.layer.cornerRadius = 5.0
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.QuickLink.isUserInteractionEnabled = true
            cell.quickLinkIcon.isHidden = false
            
            if (cell.isSelected) {
                cell.backgroundColor = UIColor(red: 255/255, green: 93/255, blue: 48/255, alpha: 1.0) // highlight selection
                cell.QuickLink.alpha = 1
                cell.quickLinkIcon.alpha = 1
                selectedBirdIndex = indexPath.row
            }
            else {
                cell.backgroundColor = UIColor(red: 255/255, green: 141/255, blue: 54/255, alpha: 1.0)
                cell.QuickLink.alpha = 0
                cell.quickLinkIcon.alpha = 0
            }
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 0.5
            
            var farmLength : String = (farmArray[indexPath.row] as? String)!
            let age : String = (ageArray[indexPath.row] as? String)!
            let house : String = (houseArray[indexPath.row] as? String)!
            if farmLength.count > 60  {
                
                let fullName = farmLength
                let fullNameArr = fullName.components(separatedBy: "[")
                let myStringPrefix = String(fullName.prefix(60))
                var firstName = myStringPrefix + "..." + " " + "[" + age + "]"
                var farmName2 = String()
                let range = firstName.range(of: ".")
                if range != nil{
                    var abc = String(firstName[range!.upperBound...]) as NSString
                    farmName2 = String(indexPath.row+1) + "." + " " + String(describing:abc)
                }
                cell.houseLabel.text = "HNo." + house
                cell.farmLabel.text = farmName2
                
            } else {
                var farmLengthAge  : String = (farmArray[indexPath.row] as? String)!
                farmLengthAge = farmLengthAge + " " + "[" + age + "]"
                var farmName2 = String()
                let range = farmLengthAge.range(of: ".")
                if range != nil{
                    var abc = String(farmLengthAge[range!.upperBound...]) as NSString
                    farmName2 = String(indexPath.row+1) + "." + " " + String(describing:abc)
                }
                cell.houseLabel.text = "HNo. " + house
                cell.farmLabel.text = farmName2
            }
            cell.QuickLink.addTarget(self, action: #selector(CaptureNecropsyDataViewController.quickLink(_:)), for: .touchUpInside)
            cell.QuickLink.tag = indexPath.row
            return cell
        }
        
        else if collectionView == neccollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureNecropsyCollectionViewCell
            cell.textFieldActual.delegate = self
            cell.switchNec.isUserInteractionEnabled = true
            cell.badgeButton.isUserInteractionEnabled = true
            cell.plusButton.isUserInteractionEnabled = true
            cell.minusButton.isUserInteractionEnabled = true
            cell.cameraButton.isUserInteractionEnabled = true
            cell.helpButtonAction.isUserInteractionEnabled = true
            cell.textFieldActual.isUserInteractionEnabled = true
            cell.birdSexView.isHidden = true
            
            if btnTag == 0 {
                let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: indexPath.row) as! CaptureNecropsyViewData
                let measure = skleta.measure
                cell.mesureValue = measure!
                cell.myLabel.text = skleta.obsName
                var  necId = Int()
                
                if postingIdFromExistingNavigate == "Exting"{
                    necId =  postingIdFromExisting
                }
                else{
                    necId = UserDefaults.standard.integer(forKey: "necId") as Int
                }
                
                let photoArr = CoreDataHandler().fecthPhotoWithCatnameWithBirdAndObservationID(skleta.birdNo!, farmname: skleta.formName!, catName: skleta.catName!, Obsid: skleta.obsID!, obsName: skleta.obsName!,necId: necId as NSNumber)
                if photoArr.count > 0
                {
                    cell.badgeButton.alpha = 1
                    cell.badgeButton.badgeString = String(photoArr.count) as String
                    cell.badgeButton.badgeTextColor = UIColor.white
                    cell.badgeButton.badgeEdgeInsets = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 15)
                }
                else
                {
                    cell.badgeButton.alpha = 0
                }
                
                if measure == "Y,N" {
                    
                    let n  = String(describing: skleta.refId!)
                    let imageName = "skeltaMuscular" + "_" + n + "_n"
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    cell.observationImage.image =  image
                    
                    if skleta.objsVisibilty == 1{
                        cell.switchNec.isOn = true
                    }
                    else{
                        cell.switchNec.isOn = false
                    }
                    
                    cell.switchNec.alpha = 1
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 0
                }
                
                else if ( measure == "Actual"){
                    
                    let image = UIImage(named:"image02")
                    cell.observationImage.image =  image
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 1
                    cell.textFieldActual.text = skleta.actualText
                }
                else{
                    let n  = String(describing: skleta.refId!)
                    let imageName = "skeltaMuscular" + "_" + n + "_00"
                    var image = UIImage(named:imageName)
                    if image == nil{
                        image = UIImage(named:"Image01")
                    }
                    cell.observationImage.image =  image
                    cell.incrementLabel.text = String(skleta.obsPoint!.int32Value)
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 1
                    cell.minusButton.alpha = 1
                    cell.incrementLabel.alpha = 1
                    cell.textFieldActual.alpha = 0
                }
            }
            else if btnTag == 1 {
                let cocoii : CaptureNecropsyViewData = dataArrayCocoi.object(at: indexPath.row) as! CaptureNecropsyViewData
                cell.myLabel.text = cocoii.obsName
                let measure = cocoii.measure
                cell.mesureValue = measure!
                
                var necId = Int()
                if postingIdFromExistingNavigate == "Exting"{
                    necId =  postingIdFromExisting
                }
                else{
                    necId = UserDefaults.standard.integer(forKey: "necId") as Int
                }
                let photoArr = CoreDataHandler().fecthPhotoWithCatnameWithBirdAndObservationID(cocoii.birdNo!, farmname: cocoii.formName!, catName: cocoii.catName!, Obsid: cocoii.obsID!, obsName: cocoii.obsName!,necId: necId as NSNumber)
                if photoArr.count > 0
                {
                    cell.badgeButton.alpha = 1
                    cell.badgeButton.badgeString = String(photoArr.count) as String
                    cell.badgeButton.badgeTextColor = UIColor.white
                    cell.badgeButton.badgeEdgeInsets = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 15)
                }
                else
                {
                    cell.badgeButton.alpha = 0
                }
                if measure == "Y,N" {
                    
                    let n  = String(describing: cocoii.refId!)
                    let imageName = "Coccidiosis" + "_" + n + "_n"
                    var image = UIImage(named:imageName)
                    if image == nil{
                        image = UIImage(named:"Image01")
                    }
                    cell.observationImage.image =  image
                    
                    if cocoii.objsVisibilty == 1{
                        cell.switchNec.isOn = true
                    }
                    else{
                        cell.switchNec.isOn = false
                    }
                    cell.switchNec.alpha = 1
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 0
                }
                
                else if ( measure == "Actual"){
                    let image = UIImage(named:"image02")
                    cell.observationImage.image =  image
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 1
                    cell.textFieldActual.text = cocoii.actualText
                }
                else{
                    let n  = String(describing: cocoii.refId!)
                    let imageName = "Coccidiosis" + "_" + n + "_00"
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    
                    cell.observationImage.image =  image
                    cell.incrementLabel.text = String(cocoii.obsPoint!.int32Value)
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 1
                    cell.minusButton.alpha = 1
                    cell.incrementLabel.alpha = 1
                    cell.textFieldActual.alpha = 0
                }
            }
            else if btnTag == 2 {
                
                let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: indexPath.row) as! CaptureNecropsyViewData
                cell.myLabel.text = gitract.obsName
                let measure = gitract.measure
                cell.mesureValue = measure!
                var necId = Int()
                if postingIdFromExistingNavigate == "Exting"{
                    necId =  postingIdFromExisting
                }
                else{
                    necId = UserDefaults.standard.integer(forKey: "necId") as Int
                }
                
                let photoArr = CoreDataHandler().fecthPhotoWithCatnameWithBirdAndObservationID(gitract.birdNo!, farmname: gitract.formName!, catName: gitract.catName!, Obsid: gitract.obsID!, obsName: gitract.obsName!,necId: necId as NSNumber)
                if photoArr.count > 0
                {
                    cell.badgeButton.alpha = 1
                    cell.badgeButton.badgeString = String(photoArr.count) as String
                    cell.badgeButton.badgeTextColor = UIColor.white
                    cell.badgeButton.badgeEdgeInsets = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 15)
                }
                else
                {
                    cell.badgeButton.alpha = 0
                }
                
                if measure == "Y,N" {
                    
                    let n  = String(describing: gitract.refId!)
                    let imageName = "GITract" + "_" + n + "_n"
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    
                    cell.observationImage.image =  image
                    if gitract.objsVisibilty == 1
                    {
                        cell.switchNec.isOn = true
                    }
                    else
                    {
                        cell.switchNec.isOn = false
                    }
                    
                    cell.switchNec.alpha = 1
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 0
                }
                
                else if ( measure == "Actual"){
                    
                    let image = UIImage(named:"image02")
                    cell.observationImage.image =  image
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 1
                    cell.textFieldActual.text = gitract.actualText
                }
                
                else{
                    let n  = String(describing: gitract.refId!)
                    let imageName = "GITract" + "_" + n + "_00"
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    cell.observationImage.image =  image
                    cell.incrementLabel.text = String(gitract.obsPoint!.int32Value)
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 1
                    cell.minusButton.alpha = 1
                    cell.incrementLabel.alpha = 1
                    cell.textFieldActual.alpha = 0
                }
                
            }
            else if btnTag == 3 {
                let res : CaptureNecropsyViewData = dataArrayRes.object(at: indexPath.row) as! CaptureNecropsyViewData
                cell.myLabel.text = res.obsName
                let measure = res.measure
                cell.mesureValue = measure!
                var necId = Int()
                if postingIdFromExistingNavigate == "Exting"{
                    necId =  postingIdFromExisting
                }
                else{
                    necId = UserDefaults.standard.integer(forKey: "necId") as Int
                }
                
                let photoArr = CoreDataHandler().fecthPhotoWithCatnameWithBirdAndObservationID(res.birdNo!, farmname: res.formName!, catName: res.catName!, Obsid: res.obsID!, obsName: res.obsName!,necId: necId as NSNumber)
                if photoArr.count > 0
                {
                    cell.badgeButton.alpha = 1
                    cell.badgeButton.badgeString = String(photoArr.count) as String
                    cell.badgeButton.badgeTextColor = UIColor.white
                    cell.badgeButton.badgeEdgeInsets = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 15)
                }
                else
                {
                    cell.badgeButton.alpha = 0
                }
                if measure == "Y,N" {
                    
                    let n  = String(describing: res.refId!)
                    let imageName = "Resp" + "_" + n + "_n"
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    
                    cell.observationImage.image =  image
                    
                    if res.objsVisibilty == 1{
                        cell.switchNec.isOn = true
                    }
                    else{
                        cell.switchNec.isOn = false
                    }
                    cell.switchNec.alpha = 1
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 0
                }
                
                else if ( measure == "Actual"){
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 1
                    cell.textFieldActual.text = res.actualText
                    let image = UIImage(named:"image02")
                    cell.observationImage.image =  image
                }
                
                else{
                    let n  = String(describing: res.refId!)
                    let imageName = "Resp" + "_" + n + "_00"
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    cell.observationImage.image =  image
                    cell.incrementLabel.text = String(res.obsPoint!.int32Value)
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 1
                    cell.minusButton.alpha = 1
                    cell.incrementLabel.alpha = 1
                    cell.textFieldActual.alpha = 0
                }
            }
            else{
                let immu : CaptureNecropsyViewData = dataArrayImmu.object(at: indexPath.row) as! CaptureNecropsyViewData
                cell.myLabel.text = immu.obsName
                let measure = immu.measure
                cell.mesureValue = measure!
                
                var necId = Int()
                if postingIdFromExistingNavigate == "Exting"{
                    necId =  postingIdFromExisting
                }
                else{
                    necId = UserDefaults.standard.integer(forKey: "necId") as Int
                }
                
                let photoArr = CoreDataHandler().fecthPhotoWithCatnameWithBirdAndObservationID(immu.birdNo!, farmname: immu.formName!, catName: immu.catName!, Obsid: immu.obsID!, obsName: immu.obsName!,necId: necId as NSNumber)
                if photoArr.count > 0
                {
                    cell.badgeButton.alpha = 1
                    cell.badgeButton.badgeString = String(photoArr.count) as String
                    cell.badgeButton.badgeTextColor = UIColor.white
                    cell.badgeButton.badgeEdgeInsets = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 15)
                }
                else
                {
                    cell.badgeButton.alpha = 0
                }
                
                if measure == "Y,N" {
                    cell.birdSexView.isHidden = true
                    let n  = String(describing: immu.refId!)
                    let imageName = "Immune" + "_" + n + "_n"
                    var image = UIImage(named:imageName)
                    if image == nil
                    {
                        image = UIImage(named:"Image01")
                    }
                    
                    cell.observationImage.image =  image
                    
                    if immu.objsVisibilty == 1{
                        cell.switchNec.isOn = true
                    }
                    else{
                        cell.switchNec.isOn = false
                    }
                    
                    cell.switchNec.alpha = 1
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 0
                }
                else if ( measure == "Actual"){
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 1
                    cell.textFieldActual.text = immu.actualText
                    let image = UIImage(named:"image02")
                    cell.observationImage.image =  image
                    
                    if immu.obsName == Constants.maleFemaleStr
                    {
                        cell.birdSexView.isHidden = false
                        let n  = String(describing: immu.refId!)
                        
                        let imageName = "Immune" + "_" + n + "_01"
                        
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        
                        if immu.actualText == "1" || immu.actualText == "1.00" || immu.actualText == "1.0"{
                            cell.birdSexLbl.text = "Male"
                        }
                        else if immu.actualText == "2" || immu.actualText == "2.00" || immu.actualText == "2.0"{
                            cell.birdSexLbl.text = "Female"
                        }
                        else{
                            cell.birdSexLbl.text = "N/A"
                        }
                        cell.observationImage.image =  image
                        cell.incrementLabel.text = String(immu.obsPoint!.int32Value)
                        cell.switchNec.alpha = 0
                        cell.plusButton.alpha = 0
                        cell.minusButton.alpha = 0
                        cell.incrementLabel.alpha = 0
                        cell.textFieldActual.alpha = 0
                    }
                }
                
                else if ( measure == "F,M"){
                    cell.switchNec.alpha = 0
                    cell.plusButton.alpha = 0
                    cell.minusButton.alpha = 0
                    cell.incrementLabel.alpha = 0
                    cell.textFieldActual.alpha = 1
                    cell.textFieldActual.text = immu.actualText
                    let image = UIImage(named:"image02")
                    cell.observationImage.image =  image
                    
                    if immu.obsName == Constants.maleFemaleStr{
                        cell.birdSexView.isHidden = false
                        let n  = String(describing: immu.refId!)
                        
                        let imageName = "Immune" + "_" + n + "_01"
                        
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        if immu.actualText == "1" || immu.actualText == "1.00" || immu.actualText == "1.0"
                        {
                            cell.birdSexLbl.text = "Male"
                        }
                        else if immu.actualText == "2" || immu.actualText == "2.00" || immu.actualText == "2.0"
                        {
                            cell.birdSexLbl.text = "Female"
                        }
                        else
                        {
                            cell.birdSexLbl.text = "N/A"
                        }
                        
                        cell.observationImage.image =  image
                        cell.incrementLabel.text = String(immu.obsPoint!.int32Value)
                        cell.switchNec.alpha = 0
                        cell.plusButton.alpha = 0
                        cell.minusButton.alpha = 0
                        cell.incrementLabel.alpha = 0
                        cell.textFieldActual.alpha = 0
                    }
                }
                
                else{
                    
                    if immu.refId == 58
                    {
                        let n  = String(describing: immu.refId!)
                        let imageName = "Immune" + "_" + n + "_01"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        cell.observationImage.image =  image
                        cell.incrementLabel.text = String(immu.obsPoint!.int32Value)
                        cell.switchNec.alpha = 0
                        cell.plusButton.alpha = 1
                        cell.minusButton.alpha = 1
                        cell.incrementLabel.alpha = 1
                        cell.textFieldActual.alpha = 0
                    }
                    else{
                        let n  = String(describing: immu.refId!)
                        let imageName = "Immune" + "_" + n + "_00"
                        var image = UIImage(named:imageName)
                        if image == nil
                        {
                            image = UIImage(named:"Image01")
                        }
                        cell.observationImage.image =  image
                        cell.incrementLabel.text = String(immu.obsPoint!.int32Value)
                        cell.switchNec.alpha = 0
                        cell.plusButton.alpha = 1
                        cell.minusButton.alpha = 1
                        cell.incrementLabel.alpha = 1
                        cell.textFieldActual.alpha = 0
                    }
                }
            }
            
            cell.textFieldActual.tag = indexPath.row
            cell.plusButton.addTarget(self, action: #selector(CaptureNecropsyDataViewController.plusButtonClick(_:)), for: .touchUpInside)
            cell.minusButton.addTarget(self, action: #selector(CaptureNecropsyDataViewController.minusButtonClick(_:)), for: .touchUpInside)
            cell.cameraButton.addTarget(self, action: #selector(CaptureNecropsyDataViewController.takePhoto(_:)), for: .touchUpInside)
            cell.helpButtonAction.addTarget(self, action:#selector(CaptureNecropsyDataViewController.clickHelpPopUp(_:)), for: .touchUpInside)
            cell.badgeButton.addTarget(self, action: #selector(CaptureNecropsyDataViewController.clickImage(_:)), for: .touchUpInside)
            cell.switchNec .addTarget(self, action: #selector(CaptureNecropsyDataViewController.switchClick(_:)) , for:.valueChanged)
            
            cell.birdSexCompletion = {[unowned self] ( error) in
                
                if  BirdSex.count > 0 {
                    self.dropDownVIewNew(arrayData: BirdSex as? [String] ?? [String](), kWidth: cell.birdSexView.frame.width, kAnchor: cell.birdSexView, yheight: cell.birdSexView.bounds.height) { [unowned self] selectedVal, index  in
                        cell.birdSexLbl.text = selectedVal
                        selectedSexValue = selectedVal
                        
                        if selectedVal == "Female"
                        {
                            selectedSexValue = "2"
                        }
                        else if selectedVal == "N/A"
                        {
                            selectedSexValue = "0"
                        }
                        else
                        {
                            selectedSexValue = "1"
                        }
                        
                        if btnTag == 4 {
                            
                            let immune : CaptureNecropsyViewData = dataArrayImmu.object(at: indexPath.row) as! CaptureNecropsyViewData
                            var  necId = Int()
                            if postingIdFromExistingNavigate == "Exting"{
                                necId =  postingIdFromExisting
                            }
                            else{
                                necId = UserDefaults.standard.integer(forKey: "necId") as Int
                            }
                            
                            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(immune.birdNo!, farmname: immune.formName!, catName: immune.catName!,Obsid: immune.obsID!,necId:necId as NSNumber)
                            
                            let immune1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
                            if FetchObsArr.count > 0 {
                                
                                let imageName = "Immune" + "_" + immune1.obsName! + "_n"
                                var image = UIImage(named:imageName)
                                if image == nil
                                {
                                    image = UIImage(named:"Image01")
                                }
                                
                                CoreDataHandler().updateCaptureSkeletaInDatabaseOnActualClick("Immune", obsName: immune1.obsName!, formName:immune.formName! , birdNo: immune.birdNo!,  actualName : selectedSexValue, index: indexPath.row, necId :necId as NSNumber, isSync :true,refId:immune.refId!)
                            }
                            
                            dataArrayImmu.removeAllObjects()
                            
                            if postingIdFromExistingNavigate == "Exting"{
                                necId =  postingIdFromExisting
                            }
                            else{
                                necId = UserDefaults.standard.integer(forKey: "necId") as Int
                            }
                            dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(immune.birdNo! , farmname: immune.formName!, catName: "Immune",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
                        }
                        
                        if postingIdFromExistingNavigate == "Exting"{
                            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
                        }
                        else if UserDefaults.standard.bool(forKey: "Unlinked") == true{
                            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
                            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
                        }
                        else{
                            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
                            CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
                        }
                    }
                    self.dropHiddenAndShow()
                }
            }
            
            cell.helpButtonAction.tag = indexPath.row
            cell.textFieldActual.delegate = self
            cell.switchNec.tag = indexPath.row
            cell.tag = indexPath.row
            cell.badgeButton.tag = indexPath.row
            cell.cameraButton.tag = indexPath.row
            cell.plusButton.tag = indexPath.row
            cell.minusButton.tag =  indexPath.row
            cell.birdSexBtn.tag =  indexPath.row
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        if collectionView == birdsCollectionView {
            isBirdClick = true
            birdsCollectionView.reloadData()
        }
        if collectionView == formCollectionView {
            isBirdClick = false
            formCollectionView.reloadData()
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        if collectionView == formCollectionView {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()

//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureNecroStep2TurkeyCell
            let cell = collectionView.cellForItem(at: indexPath) as! CaptureNecropsyCollectionViewCell

            isBirdClick = false
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureNecropsyCollectionViewCell
            cell.backgroundColor = UIColor(red: 255/255, green: 93/255, blue: 48/255, alpha: 1.0)
            cell.QuickLink.alpha = 1
            cell.quickLinkIcon.alpha = 1
            
            traingleImageView.frame = CGRect(x: 274, y: 229, width: 24, height: 24)
            selectedBirdIndex = indexPath.row
            isFarmClick = true
            self.farmRow = indexPath.row
            let farm = farmArray.object(at: self.farmRow)
            UserDefaults.standard.set(farm, forKey: "farm")
            Helper.showGlobalProgressHUDWithTitle(self.view, title: NSLocalizedString(appDelegateObj.loadingStr, comment: ""))
            self.perform(#selector(CaptureNecropsyDataViewController.loadformdata), with: nil, afterDelay:1)
        }
        else if collectionView == birdsCollectionView{
            collectionView.reloadData()
            collectionView.layoutIfNeeded()

            isBirdClick = true
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CaptureNecropsyCollectionViewCell
            let cell = collectionView.cellForItem(at: indexPath) as! CaptureNecropsyCollectionViewCell

            cell.notePopBtn.alpha = 1
            let image = UIImage(named: "addbird_bg_select")
            cell.bgImageView.image = image
            let image2 = UIImage(named: "edit")
            cell.editImage.image = image2
            
            let cellFrameInSuperview = collectionView.convert(cell.frame, to: view)
            traingleImageView.frame = CGRect(x: cellFrameInSuperview.origin.x + 10, y: cellFrameInSuperview.origin.y - 2, width: traingleImageView.frame.size.width, height: traingleImageView.frame.size.width)
            let bird = (items.object(at: self.farmRow) as AnyObject).object(at: indexPath.row)
            UserDefaults.standard.set(bird, forKey: "bird")
            Helper.showGlobalProgressHUDWithTitle(self.view, title: NSLocalizedString(appDelegateObj.loadingStr, comment: ""))
            self.callLodaBirdData(bird as! NSNumber)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if collectionView == birdsCollectionView
        {
            
        }
    }
    
    //MARK: UItableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:StartNecropsyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StartNecropsyTableViewCell
        
        if (cell.isSelected) {
            cell.bgView.backgroundColor = UIColor(red: 255/255, green: 93/255, blue: 48/255, alpha: 1.0) // highlight selection
        }
        else
        {
            cell.bgView.backgroundColor = UIColor(red: 255/255, green: 141/255, blue: 54/255, alpha: 1.0)
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.dataLabel.text = categoryArray[indexPath.row] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, shouldSelectItemAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let noOfBird =  UserDefaults.standard.value(forKey: "bird") as! Int
        let cell:StartNecropsyTableViewCell = tableView.cellForRow(at: indexPath) as! StartNecropsyTableViewCell
        tableViewSelectedRow = indexPath.row
        isBirdClick = false
        
        if self.farmRow == 0{
            isFirstTimeLaunch = true
        }
        if indexPath.row == 0 {
            
            btnTag = 0
            cell.bgView.backgroundColor = UIColor(red: 255/255, green: 93/255, blue: 48/255, alpha: 1.0)
            dataSkeltaArray.removeAllObjects()
            var  necId = Int()
            
            necId = getNecIdChicken()
            
            dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(noOfBird as NSNumber, farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "skeltaMuscular",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataSkeltaArray.count>0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        else if indexPath.row == 1 {
            
            if btnTag == 0
            {
                let removeindexPath : IndexPath = IndexPath(row: 0, section: 0)
                let removecell:StartNecropsyTableViewCell = tableView.cellForRow(at: removeindexPath) as! StartNecropsyTableViewCell
                removecell.bgView.backgroundColor = UIColor(red: 255/255, green: 141/255, blue: 54/255, alpha: 1.0)
            }
            
            btnTag = 1
            dataArrayCocoi.removeAllObjects()
            
            var  necId = Int()
            
            necId = getNecIdChicken()
            
            dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(noOfBird as NSNumber, farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "Coccidiosis",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataArrayCocoi.count>0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        else if indexPath.row == 2 {
            
            if btnTag == 0
            {
                let removeindexPath : IndexPath = IndexPath(row: 0, section: 0)
                let removecell:StartNecropsyTableViewCell = tableView.cellForRow(at: removeindexPath) as! StartNecropsyTableViewCell
                removecell.bgView.backgroundColor = UIColor(red: 255/255, green: 141/255, blue: 54/255, alpha: 1.0)
            }
            
            btnTag = 2
            dataArrayGiTract.removeAllObjects()
            
            var  necId = Int()
            necId = getNecIdChicken()
            dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(noOfBird as NSNumber, farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "GITract",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataArrayGiTract.count>0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        else if indexPath.row == 3 {
            
            if btnTag == 0
            {
                let removeindexPath : IndexPath = IndexPath(row: 0, section: 0)
                let removecell:StartNecropsyTableViewCell = tableView.cellForRow(at: removeindexPath) as! StartNecropsyTableViewCell
                removecell.bgView.backgroundColor = UIColor(red: 255/255, green: 141/255, blue: 54/255, alpha: 1.0)
            }
            
            btnTag = 3
            dataArrayRes.removeAllObjects()
            var  necId = Int()
            necId = getNecIdChicken()
            
            dataArrayRes =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(noOfBird as NSNumber, farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "Resp",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            
            if dataArrayRes.count>0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        else if indexPath.row == 4 {
            
            if btnTag == 0
            {
                let removeindexPath : IndexPath = IndexPath(row: 0, section: 0)
                let removecell:StartNecropsyTableViewCell = tableView.cellForRow(at: removeindexPath) as! StartNecropsyTableViewCell
                removecell.bgView.backgroundColor = UIColor(red: 255/255, green: 141/255, blue: 54/255, alpha: 1.0)
            }
            
            btnTag = 4
            dataArrayImmu.removeAllObjects()
            var  necId = Int()
            necId = getNecIdChicken()
            
            dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(noOfBird as NSNumber, farmname: UserDefaults.standard.object(forKey: "farm") as! String, catName: "Immune",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
            neccollectionView.reloadData()
            if dataArrayImmu.count>0{
                neccollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.top)
            }
        }
        
        UserDefaults.standard.set(btnTag, forKey: "clickindex")
        cell.bgView.backgroundColor = UIColor(red: 255/255, green: 93/255, blue: 48/255, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell:StartNecropsyTableViewCell = tableView.cellForRow(at: indexPath) as! StartNecropsyTableViewCell
        cell.bgView.backgroundColor = UIColor(red: 255/255, green: 141/255, blue: 54/255, alpha: 1.0)
        if btnTag == 0
        {
            let removeindexPath : IndexPath = IndexPath(row: 0, section: 0)
            let removecell:StartNecropsyTableViewCell = tableView.cellForRow(at: removeindexPath) as! StartNecropsyTableViewCell
            removecell.bgView.backgroundColor = UIColor(red: 255/255, green: 141/255, blue: 54/255, alpha: 1.0)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
    
    //MARK: UITextFiled Delegate Action
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (string == "1" || string == "2" || string == "3" || string == "4" || string == "5" || string == "6" || string == "7" || string == "8" || string == "9" || string == "0" || string == "." || isBackSpace == -92 ){
            
            var _ : Bool!
            if(self.checkCharacter(string, textfield11: textField)){
                
                let rowIndex :Int = textField.tag
                bursaSelectedIndex =  IndexPath(row: rowIndex, section: 0)
                
                let cell = neccollectionView.cellForItem(at: bursaSelectedIndex!) as! CaptureNecropsyCollectionViewCell
                if textField == cell.textFieldActual
                {
                    let computationString: String = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                    let length = computationString.count
                    if (length > 5) {
                        return false;
                    }
                }
            }
            return true
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let rowIndex :Int = textField.tag
        bursaSelectedIndex = IndexPath(row: rowIndex, section: 0)
        let cell = neccollectionView.cellForItem(at: bursaSelectedIndex!) as! CaptureNecropsyCollectionViewCell
        cell.textFieldActual.becomeFirstResponder()
        cell.textFieldActual.returnKeyType = UIReturnKeyType.done
        animateViewMoving(true, moveValue: 100)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        animateViewMoving(false, moveValue: 100)
        
        let rowIndex :Int = textField.tag
        lastSelectedIndex = IndexPath(row: rowIndex, section: 0)
        if btnTag == 0 {
            
            let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: rowIndex) as! CaptureNecropsyViewData
            var  necId = Int()
            necId = getNecIdChicken()
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(skleta.birdNo!, farmname: skleta.formName!, catName: skleta.catName!,Obsid: skleta.obsID!,necId: necId as NSNumber)
            let skleta1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            
            if FetchObsArr.count > 0 {
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnActualClick("skeltaMuscular", obsName: skleta1.obsName!, formName:skleta.formName! , birdNo: skleta.birdNo!,  actualName : textField.text!, index: rowIndex, necId :necId as NSNumber, isSync :true, refId: skleta.refId!)
            }
            
            dataSkeltaArray.removeAllObjects()
            necId = getNecIdChicken()
            
            dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(skleta.birdNo! , farmname: skleta.formName!, catName: "skeltaMuscular",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        if btnTag == 1 {
            
            let cocoi : CaptureNecropsyViewData = dataArrayCocoi.object(at: rowIndex) as! CaptureNecropsyViewData
            var  necId = Int()
            necId = getNecIdChicken()
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(cocoi.birdNo!, farmname: cocoi.formName!, catName: cocoi.catName!,Obsid: cocoi.obsID!,necId: necId as NSNumber)
            
            let cocoi1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnActualClick("Coccidiosis", obsName: cocoi1.obsName!, formName:cocoi.formName! , birdNo: cocoi.birdNo!,  actualName : textField.text!, index: rowIndex, necId :necId as NSNumber, isSync :true, refId: cocoi.refId!)
            }
            
            dataArrayCocoi.removeAllObjects()
            
            necId = getNecIdChicken()
            
            dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(cocoi.birdNo! , farmname: cocoi.formName!, catName: "Coccidiosis",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        if btnTag == 2 {
            
            let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: rowIndex) as! CaptureNecropsyViewData
            var  necId = Int()
            necId = getNecIdChicken()
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(gitract.birdNo!, farmname: gitract.formName!, catName: gitract.catName!,Obsid: gitract.obsID!,necId: necId as NSNumber)
            
            let gitract1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnActualClick("GITract", obsName: gitract1.obsName!, formName:gitract.formName! , birdNo: gitract.birdNo!,  actualName : textField.text!, index: rowIndex, necId :necId as NSNumber, isSync :true,refId: gitract.refId!)
            }
            
            dataArrayGiTract.removeAllObjects()
            necId = getNecIdChicken()
            
            dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(gitract.birdNo! , farmname: gitract.formName!, catName: "GITract",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        if btnTag == 3 {
            
            let resp : CaptureNecropsyViewData = dataArrayRes.object(at: rowIndex) as! CaptureNecropsyViewData
            var  necId = Int()
            necId = getNecIdChicken()
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(resp.birdNo!, farmname: resp.formName!, catName: resp.catName!,Obsid: resp.obsID!,necId: necId as NSNumber)
            
            let resp1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            
            if FetchObsArr.count > 0 {
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnActualClick("Resp", obsName: resp1.obsName!, formName:resp.formName! , birdNo: resp.birdNo!,  actualName : textField.text!, index: rowIndex, necId :necId as NSNumber, isSync :true,refId: resp.refId!)
            }
            
            dataArrayRes.removeAllObjects()
            
            necId = getNecIdChicken()
            
            dataArrayRes =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(resp.birdNo! , farmname: resp.formName!, catName: "Resp",necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        if btnTag == 4 {
            
            let immune : CaptureNecropsyViewData = dataArrayImmu.object(at: rowIndex) as! CaptureNecropsyViewData
            var  necId = Int()
            
            necId = getNecIdChicken()
            
            let FetchObsArr =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservationID(immune.birdNo!, farmname: immune.formName!, catName: immune.catName!,Obsid: immune.obsID!,necId:necId as NSNumber)
            
            let immune1 : CaptureNecropsyViewData = FetchObsArr.object(at: 0) as! CaptureNecropsyViewData
            if FetchObsArr.count > 0 {
                CoreDataHandler().updateCaptureSkeletaInDatabaseOnActualClick("Immune", obsName: immune1.obsName!, formName:immune.formName! , birdNo: immune.birdNo!,  actualName : textField.text!, index: rowIndex, necId :necId as NSNumber, isSync :true,refId:immune.refId!)
            }
            
            dataArrayImmu.removeAllObjects()
            
            necId = getNecIdChicken()
            
            dataArrayImmu =  CoreDataHandler().fecthFrmWithCatnameWithBirdAndObservation(immune.birdNo! , farmname: immune.formName!, catName: "Immune",necId:necId as NSNumber).mutableCopy() as! NSMutableArray
        }
        
        if postingIdFromExistingNavigate == "Exting"{
            
            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
        }
        else if UserDefaults.standard.bool(forKey: "Unlinked") == true{
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
        }
        else{
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
        }
        textField.resignFirstResponder()
    }
    
    //MARK: Custom Actionß
    
    func croppIngimage(_ imageToCrop:UIImage, toRect rect:CGRect) -> UIImage{
        
        let imageRef:CGImage = imageToCrop.cgImage!.cropping(to: rect)!
        let cropped:UIImage = UIImage(cgImage:imageRef)
        return cropped
    }
    // MARK: 🟠 Add Farm Button Action
    @IBAction func addFramActionButton(_ sender: AnyObject) {
        
        selectedBirdIndex = farmArray.count
        buttonback = UIButton(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        buttonback.backgroundColor = UIColor.black
        buttonback.alpha = 0.6
        buttonback.setTitle("", for: UIControl.State())
        buttonback.addTarget(self, action: #selector(buttonAcntion), for: .touchUpInside)
        self.view.addSubview(buttonback)
        var  necId = Int()
        
        customPopV = AddFarm.loadFromNibNamed("AddFarm") as! AddFarm
        customPopV.AddFarmDelegate = self
        
        if postingIdFromExistingNavigate == "Exting"{
            necId = postingIdFromExisting
            customPopV.necIdExIsting = "Exting"
            customPopV.necIdExist = necId
        }
        else{
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
        
        customPopV.delegeterefreshPage = self
        customPopV.center = self.view.center
        self.view.addSubview(customPopV)
    }
    
    @objc func buttonAcntion(_ sender: UIButton!) {
        customPopV.removeFromSuperview()
        buttonback.removeFromSuperview()
    }
    // MARK: 🟠 Refresh Page after feed added.
    fileprivate func handleValidations(_ postingId: inout Int) {
        if postingIdFromExistingNavigate == "Exting" {
            postingId = postingIdFromExisting
            self.captureNecropsy =  CoreDataHandler().FetchNecropsystep1NecId(postingId as NSNumber) as! [NSManagedObject]
            CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
        } else if UserDefaults.standard.bool(forKey: "Unlinked") == true {
            let necId = UserDefaults.standard.integer(forKey: "necId") as Int
            CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
            self.captureNecropsy =  CoreDataHandler().FetchNecropsystep1neccId(necId as NSNumber) as! [NSManagedObject]
        } else {
            postingId = UserDefaults.standard.integer(forKey: "necId") as Int
            self.captureNecropsy =  CoreDataHandler().FetchNecropsystep1neccId(postingId as NSNumber) as! [NSManagedObject]
        }
    }
    
    fileprivate func handleCaptureNecropsyArray() {
        for object in captureNecropsy {
            let noOfBirds : Int = Int(object.value(forKey: "noOfBirds") as! String)!
            let noOfBirdsArr  = NSMutableArray()
            
            var numOfLoop = Int()
            numOfLoop = 0
            for i in 0..<noOfBirds {
                numOfLoop  = i + 1
                if numOfLoop > 10 {
                } else {
                    noOfBirdsArr.add(i+1)
                }
            }
            items.add(noOfBirdsArr)
            farmArray.add(object.value(forKey: "farmName")!)
            ageArray.add(object.value(forKey: "age")!)
            houseArray.add(object.value(forKey: "houseNo")!)
        }
    }
    
    fileprivate func handleValidations() {
        if self.farmArray.count > 0
        {
            formCollectionView.dataSource = self
            formCollectionView.delegate = self
            self.formCollectionView!.reloadData()
            formCollectionView.selectItem(at: IndexPath(item: self.farmArray.count - 1, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
        }
        
        if items.count > 0
        {
            birdsCollectionView.dataSource = self
            birdsCollectionView.delegate = self
            self.birdsCollectionView!.reloadData()
            birdsCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
        }
    }
    
    fileprivate func handleValidationsAndUpdateNecId(_ necId: inout Int) {
        if tableViewSelectedRow == 0 {
            print(appDelegateObj.testFuntion())
        } else {
            let rowToSelect1:IndexPath = IndexPath(row: tableViewSelectedRow, section: 0)
            self.tableView(self.tableView, didDeselectRowAt: rowToSelect1)
        }
        
        if postingIdFromExistingNavigate == "Exting"{
            necId =  postingIdFromExisting
        } else {
            necId = UserDefaults.standard.integer(forKey: "necId") as Int
        }
    }
    
    func refreshPageafterAddFeed(_ formName: String)
    {
        isFirstTimeLaunch = false
        customPopV.removeFromSuperview()
        self.items.removeAllObjects()
        self.farmArray.removeAllObjects()
        self.ageArray.removeAllObjects()
        self.houseArray.removeAllObjects()
        
        buttonback.alpha = 0
        buttonback.removeFromSuperview()
        
        isFarmClick = false
        isNewFarm = true
        btnTag = 0
        
        var postingId = Int()
        handleValidations(&postingId)
        
        handleCaptureNecropsyArray()
        
        let rowToSelect:IndexPath = IndexPath(row: 0, section: 0)
        self.farmRow = self.farmArray.count - 1
        tableView.selectRow(at: rowToSelect, animated: true, scrollPosition: UITableView.ScrollPosition.none)
        self.tableView(self.tableView, didSelectRowAt: rowToSelect)
        var necId = Int()
        handleValidationsAndUpdateNecId(&necId)
        
        dataSkeltaArray.removeAllObjects()
        dataSkeltaArray =  CoreDataHandler().fecthFrmWithCatname(formName, catName: "skeltaMuscular",birdNo: 1,necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        dataArrayCocoi.removeAllObjects()
        dataArrayCocoi =  CoreDataHandler().fecthFrmWithCatname(formName, catName: "Coccidiosis" ,birdNo: 1,necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        dataArrayGiTract.removeAllObjects()
        dataArrayGiTract =  CoreDataHandler().fecthFrmWithCatname(formName, catName: "GITract",birdNo:  1,necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        dataArrayRes.removeAllObjects()
        dataArrayRes =  CoreDataHandler().fecthFrmWithCatname(formName, catName: "Resp",birdNo: 1,necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        dataArrayImmu.removeAllObjects()
        dataArrayImmu =  CoreDataHandler().fecthFrmWithCatname(formName, catName: "Immune",birdNo: 1,necId: necId as NSNumber).mutableCopy() as! NSMutableArray
        self.addBirdInNotes()
        
        handleValidations()
        traingleImageView.frame = CGRect(x: 274, y: 229, width: 24, height: 24)
        birdsCollectionView.reloadData()
        birdsCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition.left)
        
        let farm = farmArray.object(at: farmArray.count - 1)
        UserDefaults.standard.set(farm, forKey: "farm")
        UserDefaults.standard.synchronize()
        neccollectionView.reloadData()
        isNewFarm = false
    }
    
    var customPopV :AddFarm!
    
    func buttonPressedDroper() {
        buttonDroper.alpha = 0
    }
    
    func anv (){
        customPopV.removeFromSuperview()
        buttonback.removeFromSuperview()
        
        UserDefaults.standard.set(1, forKey: "bird")
        self.tableView.reloadData()
        self.birdsCollectionView.reloadData()
        self.formCollectionView.reloadData()
        self.neccollectionView.reloadData()
    }
    // MARK: 🟠 Back Button Action
    @IBAction func backBtn(_ sender: AnyObject) {
        activityView.removeFromSuperview()
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: 🟠 Logout Button Action
    @IBAction func logOut(_ sender: AnyObject) {
        logOutPopUP()
    }
    // MARK: 🟠 Side menu Button Action
    func leftController(_ leftController: UserListView, didSelectTableView tableView: UITableView ,indexValue : String){
        
        if indexValue == "Log Out"
        {
            UserDefaults.standard.removeObject(forKey: "login")
            if WebClass.sharedInstance.connected() == true{
                self.ssologoutMethod()
                CoreDataHandler().deleteAllData("Custmer")
            }
            let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "viewC") as? ViewController
            self.navigationController?.pushViewController(mapViewControllerObj!, animated: false)
            buttonbg.removeFromSuperview()
            customPopVi.removeView(view)
        }
    }
    
    // MARK:  /*********** Logout SSO Account **************/
    func ssologoutMethod()
    {
        gigya.logout() { result in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    // MARK: 🟠 Create Custome popup
    func logOutPopUP() {
        
        buttonbg.frame = CGRect(x: 0, y: 0, width: 1024, height: 768)
        buttonbg.addTarget(self, action: #selector(CaptureNecropsyDataViewController.buttonPres), for: .touchUpInside)
        buttonbg.backgroundColor = UIColor(red: 45/255, green:45/255, blue:45/255, alpha:0.3)
        self.view .addSubview(buttonbg)
        customPopVi = UserListView.loadFromNibNamed("UserListView") as! UserListView
        customPopVi.logoutDelegate = self
        customPopVi.layer.cornerRadius = 8
        customPopVi.layer.borderWidth = 3
        customPopVi.layer.borderColor =  UIColor.clear.cgColor
        self.buttonbg .addSubview(customPopVi)
        customPopVi.showView(self.view, frame1: CGRect(x: self.view.frame.size.width - 200, y: 60, width: 150, height: 60))
    }
    
    @objc func buttonPres() {
        customPopVi.removeView(view)
        buttonbg.removeFromSuperview()
    }
    var notesView :notes!
    // MARK: 🟠 Notes Button Action
    @objc func notesPopView(_ sender : UIButton){
        
        let notesDict = NSMutableArray()
        
        if btnTag == 0
        {
            if dataSkeltaArray.count > 0
            {
                let skleta : CaptureNecropsyViewData = dataSkeltaArray.object(at: 0) as! CaptureNecropsyViewData
                notesDict.add(skleta)
                self.opennoteView(sender, notesDict: notesDict)
            }
        }
        if btnTag == 1
        {
            if dataArrayCocoi.count > 0
            {
                let cocoiDis : CaptureNecropsyViewData = dataArrayCocoi.object(at: 0) as! CaptureNecropsyViewData
                notesDict.add(cocoiDis)
                self.opennoteView(sender, notesDict: notesDict)
            }
        }
        if btnTag == 2
        {
            if dataArrayGiTract.count > 0
            {
                let gitract : CaptureNecropsyViewData = dataArrayGiTract.object(at: sender.tag) as! CaptureNecropsyViewData
                notesDict.add(gitract)
                self.opennoteView(sender, notesDict: notesDict)
            }
        }
        if btnTag == 3
        {
            if dataArrayRes.count > 0
            {
                let resp : CaptureNecropsyViewData = dataArrayRes.object(at: 0) as! CaptureNecropsyViewData
                notesDict.add(resp)
                self.opennoteView(sender, notesDict: notesDict)
            }
        }
        if btnTag == 4
        {
            if dataArrayImmu.count > 0
            {
                let immune : CaptureNecropsyViewData = dataArrayImmu.object(at: 0) as! CaptureNecropsyViewData
                notesDict.add(immune)
                self.opennoteView(sender, notesDict: notesDict)
            }
        }
    }
    // MARK: 🟠 Create Custome Notes popup
    func opennoteView(_ sender : UIButton , notesDict : NSMutableArray){
        notesBGbtn = UIButton(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        notesBGbtn.backgroundColor = UIColor.black
        notesBGbtn.alpha = 0.6
        notesBGbtn.setTitle("", for: UIControl.State())
        notesBGbtn.addTarget(self, action: #selector(notesButtonAcn), for: .touchUpInside)
        self.view.addSubview(notesBGbtn)
        notesView = notes.loadFromNibNamed("Notes") as! notes
        notesView.noteDelegate = self
        notesView.noOfBird = sender.tag + 1
        notesView.notesDict = notesDict
        notesView.necIdFromExisting = postingIdFromExisting
        notesView.strExist = postingIdFromExistingNavigate
        notesView.finalizeValue = finalizeValue
        notesView.center = self.view.center
        self.view.addSubview(notesView)
    }
    // MARK: 🟠 Remove Custome Notes popup
    func openNoteFunc(){
        self.notesBGbtn.removeFromSuperview()
        self.notesView.removeFromSuperview()
        
    }
    // MARK: 🟠 Done Button Action.
    func doneBtnFunc (_ notes : NSMutableArray , notesText : String, noOfBird : Int)
    {
        if notes.count > 0
        {
            let skleta : CaptureNecropsyViewData = notes.object(at: 0) as! CaptureNecropsyViewData
            let formName = skleta.formName
            let catName  = skleta.catName
            var  necId = Int()
            necId = getNecIdChicken()
            
            let isNotes = CoreDataHandler().fetchNoofBirdWithNotes(catName!, formName: formName!, birdNo: noOfBird as NSNumber, necId: necId as NSNumber)
            let note : NotesBird = isNotes[0] as! NotesBird
            let catArr = ["skeltaMuscular","Coccidiosis","GITract","Resp","Immune"] as NSArray
            
            if note.notes!.isEmpty && notesText.isEmpty
            {
                for i in  0..<catArr.count
                {
                    var  necId = Int()
                    necId = getNecIdChicken()
                    CoreDataHandler().updateNoofBirdWithNotes(catArr.object(at: i) as! String,  formName: note.formName!, birdNo: note.noofBirds!,notes:note.notes!,necId: necId as NSNumber,isSync :true)
                }
                return
            }
            else
            {
                if isNotes.count > 0
                {
                    let note : NotesBird = isNotes[0] as! NotesBird
                    for i in  0..<catArr.count
                    {
                        var  necId = Int()
                        necId = getNecIdChicken()
                        CoreDataHandler().updateNoofBirdWithNotes(catArr.object(at: i) as! String,  formName: note.formName!, birdNo: note.noofBirds!,notes:notesText,necId: necId as NSNumber,isSync :true)
                    }
                }
                else
                {
                    for i in  0..<catArr.count
                    {
                        var  necId = Int()
                        necId = getNecIdChicken()
                        CoreDataHandler().saveNoofBirdWithNotes(catArr.object(at: i) as! String , notes: notesText, formName: formName! , birdNo: noOfBird as NSNumber, index: 0 , necId: necId as NSNumber, isSync :true)
                    }
                }
            }
            
            if postingIdFromExistingNavigate == "Exting"
            {
                CoreDataHandler().updateisSyncTrueOnPostingSession(postingIdFromExisting as NSNumber)
            }
            else if UserDefaults.standard.bool(forKey: "Unlinked") == true{
                let necId = UserDefaults.standard.integer(forKey: "necId") as Int
                CoreDataHandler().updateisSyncNecropsystep1WithneccId(necId as NSNumber, isSync : true)
            }
            else{
                let necId = UserDefaults.standard.integer(forKey: "necId") as Int
                CoreDataHandler().updateisSyncTrueOnPostingSession(necId as NSNumber)
            }
        }
        
        self.notesBGbtn.removeFromSuperview()
        self.notesView.removeFromSuperview()
        birdsCollectionView.reloadData()
        birdsCollectionView.selectItem(at: IndexPath(item: noOfBird-1, section: 0), animated: false, scrollPosition: UICollectionView.ScrollPosition())
    }
    // MARK: 🟠 Remove Notes Custome popup
    @objc func notesButtonAcn(_ sender: UIButton!) {
        self.notesBGbtn.removeFromSuperview()
        self.notesView.removeFromSuperview()
    }
    // MARK: 🟠 Check Characters in TextField
    func checkCharacter( _ inputChar : String , textfield11 : UITextField ) -> Bool {
        
        let newCharacters = CharacterSet(charactersIn: inputChar)
        let boolIsNumber = CharacterSet.decimalDigits.isSuperset(of: newCharacters)
        if boolIsNumber == true {
            return true
        }
        else {
            
            if inputChar == "." {
                let countdots = textfield11.text!.components(separatedBy: ".").count - 1
                if countdots == 0 {
                    return true
                } else {
                    if countdots > 0 && inputChar == "." {
                        return false
                    } else {
                        return true
                    }
                }
            } else {
                return false
            }
        }
    }
    // MARK: 🟠 Animate Custome view
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func postingNotesdoneBtnFunc(_ notesText : String)
    {print(appDelegateObj.testFuntion())}
    // MARK: 🟠 Sync Button Action
    @IBAction func syncBtnAction(_ sender: AnyObject) {
        
        if self.allSessionArr().count > 0
        {
            if WebClass.sharedInstance.connected() == true{
                Helper.showGlobalProgressHUDWithTitle(self.view, title: NSLocalizedString("Data syncing...", comment: ""))
                self.callSyncApi()
            }
            else
            {
                Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString(Constants.offline, comment: ""))
            }
        }
        else
        {
            Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString("Data not available for syncing.", comment: ""))
        }
    }
    // MARK: 🟠 Get all Sessions
    func allSessionArr() ->NSMutableArray{
        
        let postingArrWithAllData = CoreDataHandler().fetchAllPostingSessionWithisSyncisTrue(true).mutableCopy() as! NSMutableArray
        let cNecArr = CoreDataHandler().FetchNecropsystep1WithisSync(true)
        let necArrWithoutPosting = NSMutableArray()
        
        for j in 0..<cNecArr.count
        {
            let captureNecropsyData = cNecArr.object(at: j)  as! CaptureNecropsyData
            necArrWithoutPosting.add(captureNecropsyData)
            for w in 0..<necArrWithoutPosting.count - 1
            {
                let c = necArrWithoutPosting.object(at: w)  as! CaptureNecropsyData
                if c.necropsyId == captureNecropsyData.necropsyId
                {
                    necArrWithoutPosting.remove(c)
                }
            }
        }
        
        let allPostingSessionArr = NSMutableArray()
        var sessionId = NSNumber()
        for i in 0..<postingArrWithAllData.count
        {
            let pSession = postingArrWithAllData.object(at: i) as! PostingSession
            sessionId = pSession.postingId!
            allPostingSessionArr.add(sessionId)
        }
        
        for i in 0..<necArrWithoutPosting.count
        {
            let nIdSession = necArrWithoutPosting.object(at: i) as! CaptureNecropsyData
            sessionId = nIdSession.necropsyId!
            allPostingSessionArr.add(sessionId)
        }
        return allPostingSessionArr
    }
    // MARK: 🟠 Call Sync Api for Feed Program
    func callSyncApi()
    {
        objApiSync.feedprogram()
    }
    
    // MARK: 🟠 -- Delegate SyNC Api
    func failWithError(statusCode:Int)
    {
        Helper.dismissGlobalHUD(self.view)
        
        if statusCode == 0 {
            Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString("There are problem in data syncing please try again.(NA))", comment: ""))
        }
        else{
            if lngId == 1
            {
                Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:"There are problem in data syncing please try again. \n(\(statusCode))")
            } else if lngId == 3
            {
                Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:"Problème de synchronisation des données, veuillez réessayer à nouveau. \n(\(statusCode))")
            }
        }
    }
    func failWithErrorInternal()
    {
        Helper.dismissGlobalHUD(self.view)
        Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString("No internet connection. Please try again!", comment: ""))
    }
    
    func didFinishApi()
    {
        Helper.dismissGlobalHUD(self.view)
        Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString(Constants.dataSyncCompleted, comment: ""))
    }
    
    func failWithInternetConnection()
    {
        Helper.dismissGlobalHUD(self.view)
        Helper.showAlertMessage(self,titleStr:NSLocalizedString(Constants.alertStr, comment: "") , messageStr:NSLocalizedString(Constants.offline, comment: ""))
    }
    
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
