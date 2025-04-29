//
//  SingleSyncDataTurkey.swift
//  Zoetis -Feathers
//
//  Created by Manish Behl on 23/05/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import Reachability
import SystemConfiguration
import CoreData


// MARK: - PROTOCOLS
protocol SyncApiDataTurkey{
    func failWithErrorSyncdata(statusCode:Int)
    func failWithErrorInternalSyncdata()
    func didFinishApiSyncdata()
    func failWithInternetConnectionSyncdata()
}

class SingleSyncDataTurkey: NSObject {
    
    // MARK: - VARIABLES
    var reachability: Reachability!
    var delegeteSyncApiData : SyncApiDataTurkey!
    var postingIdArr = NSMutableArray()
    var postingArrWithAllData = NSMutableArray()
    var strdateTimeStamp = String()
    var accestoken = String()
    var networkStatus : Reachability.Connection!
    
    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return Session(configuration: configuration)
    }()
    
    // MARK: - METHODS AND FUNCTIONS
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ApiSyncTurkey.networkStatusChanged(_:)),
                                               name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification),
                                               object: nil)
        Reach().monitorReachabilityChanges()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(ReachabilityStatusChangedNotification)
    }
    
    func networkStatusChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let value = userInfo.values.first as? String {
            switch value {
            case "Online (WiFi)", "Online (WWAN)":
                print(value)
            default:
                break
            }
        }
    }
    
    
    // MARK: - Get All Session's Array
    func allSessionArr(postinId:NSNumber) ->NSMutableArray{
        
        let postingSessionArrWithAllData = CoreDataHandlerTurkey().fetchAllPostingSessionTurkey(postinId).mutableCopy() as! NSMutableArray
        let cNecArr =  CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postinId)
        let necArrWithoutPosting = NSMutableArray()
        
        for j in 0..<cNecArr.count {
            let captureNecropsyData = cNecArr.object(at: j)  as! CaptureNecropsyDataTurkey
            necArrWithoutPosting.add(captureNecropsyData)
            for w in 0..<necArrWithoutPosting.count - 1
            {
                let c = necArrWithoutPosting.object(at: w)  as! CaptureNecropsyDataTurkey
                if c.necropsyId == captureNecropsyData.necropsyId
                {
                    necArrWithoutPosting.remove(c)
                }
            }
        }
        
        let allPostingSessionArr = NSMutableArray()
        for i in 0..<postingSessionArrWithAllData.count {
            let pSession = postingSessionArrWithAllData.object(at: i) as! PostingSessionTurkey
            var sessionId = pSession.postingId!
            allPostingSessionArr.add(sessionId)
        }
        
        for i in 0..<necArrWithoutPosting.count {
            let nIdSession = necArrWithoutPosting.object(at: i) as! CaptureNecropsyDataTurkey
            var sessionId = nIdSession.necropsyId!
            allPostingSessionArr.add(sessionId)
        }
        return allPostingSessionArr
    }
    
    // MARK: - Resize the Image
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // MARK: - Convert image to Base 64
    func imageToNSString(_ image: UIImage) -> String {
        let data = image.pngData()
        return data!.base64EncodedString(options: .lineLength64Characters)
    }
    /********************* Save Feed Program data On Server *****************************************************************************************************/
    // MARK: - Get Feed Program with Posting ID
    func feedprogram(postingId:NSNumber)  {
        let savedPostingArrWithAllData = CoreDataHandlerTurkey().fetchAllPostingSessionTurkey(postingId).mutableCopy() as! NSMutableArray
        let cNecArr =  CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postingId)
        let necArrWithoutPosting = NSMutableArray()
        for j in 0..<cNecArr.count
        {
            let captureNecropsyData =  cNecArr.object(at: j)  as! CaptureNecropsyDataTurkey
            necArrWithoutPosting.add(captureNecropsyData)
            for w in 0..<necArrWithoutPosting.count - 1
            {
                let c =  necArrWithoutPosting.object(at: w)  as! CaptureNecropsyDataTurkey
                if c.necropsyId == captureNecropsyData.necropsyId
                {
                    necArrWithoutPosting.remove(c)
                }
            }
        }
        self.postingIdArr.removeAllObjects()
        let tempArrTime = NSMutableArray()
        let actualTmestamp = NSMutableArray()
        var sessionId = NSNumber()
        for i in 0..<savedPostingArrWithAllData.count
        {
            let pSession =  savedPostingArrWithAllData.object(at: i) as! PostingSessionTurkey
            sessionId = pSession.postingId!
            var timestamp = pSession.timeStamp!
            var actualTimestampStr =  pSession.actualTimeStamp
            if actualTimestampStr == nil {
                actualTimestampStr = ""
            }
            self.postingIdArr.add(sessionId)
            tempArrTime.add(timestamp)
            actualTmestamp.add(actualTimestampStr!)
        }
        
        let sessionArray = NSMutableArray()
        var sessionDictMain = NSMutableDictionary()
        
        for i in 0..<self.postingIdArr.count {
            
            let mainDict = NSMutableDictionary()
            var FinalArray1 = NSMutableArray()
            let allCocciControl =  CoreDataHandlerTurkey().fetchAllCocciControlviaPostingidTurkey(self.postingIdArr[i] as! NSNumber)
            var dataSet = Int()
            var  index = Int()
            let mainFeeds = NSMutableArray()
            var feeds = NSMutableDictionary()
            for i in 0..<allCocciControl.count {
                dataSet+=1
                
                let mainDict = NSMutableDictionary()
                let cocciControl =  allCocciControl.object(at: i) as! CoccidiosisControlFeedTurkey
                let coccidiosisVaccine = cocciControl.coccidiosisVaccine
                let dosage = cocciControl.dosage
                let fromDays = cocciControl.fromDays
                let molecule = cocciControl.molecule
                let toDays = cocciControl.toDays
                let moleculeId = cocciControl.dosemoleculeId
                let cocoId = cocciControl.coccidiosisVaccineId
                let feedType = cocciControl.feedType
                let startDate =  cocciControl.feedDate
                mainDict.setValue(startDate, forKey: "startDate")
                mainDict.setValue(coccidiosisVaccine, forKey: "coccidiosisVaccine")
                mainDict.setValue(dosage, forKey: "dose")
                mainDict.setValue(fromDays, forKey: "durationFrom")
                mainDict.setValue(molecule, forKey: "molecule")
                mainDict.setValue(toDays, forKey: "durationTo")
                mainDict.setValue(5, forKey: "feedProgramCategoryId")
                mainDict.setValue(moleculeId, forKey: "moleculeId")
                mainDict.setValue(cocoId, forKey: "cocciVaccineId")
                mainDict.setValue(feedType, forKey: "feedType")
                FinalArray1.add(mainDict)
                
                if dataSet == 7 {
                    dataSet = 0
                    
                    let feedId = cocciControl.feedId as! Int
                    let feedProgram = cocciControl.feedProgram
                    
                    feeds = ["feedName" : feedProgram!, "feedId" : feedId, "startDate" : startDate ?? "","feedProgramDetails" : FinalArray1]
                    FinalArray1 = NSMutableArray()
                    mainFeeds.add(feeds)
                    feeds = NSMutableDictionary()
                }
            }
            
            let fetchAntibotic = CoreDataHandlerTurkey().fetchAntiboticViaPostingIdTurkey(self.postingIdArr[i] as! NSNumber)
            
            
            for i in 0..<fetchAntibotic.count {
                
                dataSet+=1
                let mainDict = NSMutableDictionary()
                let antiboticFeed = fetchAntibotic.object(at: i) as! AntiboticFeedTurkey
                let dosage = antiboticFeed.dosage
                let feedId = antiboticFeed.feedId as! Int
                let feedProgram = antiboticFeed.feedProgram
                let fromDays = antiboticFeed.fromDays
                let molecule = antiboticFeed.molecule
                let toDays = antiboticFeed.toDays
                let feedType = antiboticFeed.feedType
                let startDate =  antiboticFeed.feedDate
                mainDict.setValue(dosage, forKey: "dose")
                mainDict.setValue(feedId, forKey: "feedId")
                mainDict.setValue(feedProgram, forKey: "feedName")
                mainDict.setValue(fromDays, forKey: "durationFrom")
                mainDict.setValue(molecule, forKey: "molecule")
                mainDict.setValue(toDays, forKey: "durationTo")
                mainDict.setValue(12, forKey: "feedProgramCategoryId")
                mainDict.setValue(0, forKey: "moleculeId")
                mainDict.setValue(feedType, forKey: "feedType")
                FinalArray1.add(mainDict)
                
                if dataSet == 6 {
                    dataSet = 0
                    
                    let tempArray = (mainFeeds.object(at: index) as AnyObject).value(forKey: "feedProgramDetails") as! NSMutableArray
                    if (tempArray.count > 0) {
                        tempArray.addObjects(from: FinalArray1 as [AnyObject])
                        feeds = ["feedName" : feedProgram!, "feedId" : feedId, "startDate" : startDate ?? "","feedProgramDetails" : tempArray]
                    }
                    mainFeeds.replaceObject(at: index, with: feeds)
                    index+=1
                    FinalArray1 = NSMutableArray()
                    feeds = NSMutableDictionary()
                }
            }
            
            let fetchAlternative = CoreDataHandlerTurkey().fetchAlternativeFeedPostingidTurkey(self.postingIdArr[i] as! NSNumber)
            
            index = 0
            for i in 0..<fetchAlternative.count {
                
                dataSet+=1
                let mainDict = NSMutableDictionary()
                let antiboticFeed = fetchAlternative.object(at: i) as! AlternativeFeedTurkey
                let dosage = antiboticFeed.dosage
                let feedId = antiboticFeed.feedId as! Int
                let feedProgram = antiboticFeed.feedProgram
                let fromDays = antiboticFeed.fromDays
                let molecule = antiboticFeed.molecule
                let startDate = antiboticFeed.feedDate
                let toDays = antiboticFeed.toDays
                let feedType = antiboticFeed.feedType
                mainDict.setValue(dosage, forKey: "dose")
                mainDict.setValue(feedId, forKey: "feedId")
                mainDict.setValue(feedProgram, forKey: "feedName")
                mainDict.setValue(fromDays, forKey: "durationFrom")
                mainDict.setValue(molecule, forKey: "molecule")
                mainDict.setValue(toDays, forKey: "durationTo")
                mainDict.setValue(6, forKey: "feedProgramCategoryId")
                mainDict.setValue(0, forKey: "moleculeId")
                mainDict.setValue(feedType, forKey: "feedType")
                
                FinalArray1.add(mainDict)
                
                if dataSet == 6 {
                    dataSet = 0
                    
                    if mainFeeds.count>0 {
                        
                        let tempArray = (mainFeeds.object(at: index) as AnyObject).value(forKey: "feedProgramDetails") as! NSMutableArray
                        if tempArray.count > 0 {
                            tempArray.addObjects(from: FinalArray1 as [AnyObject])
                            feeds = ["feedName" : feedProgram!, "feedId" : feedId, "startDate" : startDate ?? "","feedProgramDetails" : tempArray]
                        }
                        mainFeeds.replaceObject(at: index, with: feeds)
                        index+=1
                        FinalArray1 = NSMutableArray()
                        feeds = NSMutableDictionary()
                    }
                }
            }
            
            let fetchMyBinde = CoreDataHandlerTurkey().fetchMyBindersViaPostingIdTurkey(self.postingIdArr[i] as! NSNumber)
            
            index = 0
            for i in 0..<fetchMyBinde.count {
                
                dataSet+=1
                let mainDict = NSMutableDictionary()
                let antiboticFeed = fetchMyBinde.object(at: i) as! MyCotoxinBindersFeedTurkey
                let dosage = antiboticFeed.dosage
                let feedId = antiboticFeed.feedId as! Int
                let feedProgram = antiboticFeed.feedProgram
                let fromDays = antiboticFeed.fromDays
                let molecule = antiboticFeed.molecule
                let toDays = antiboticFeed.toDays
                let feedType = antiboticFeed.feedType
                let startDate = antiboticFeed.feedDate
                mainDict.setValue(dosage, forKey: "dose")
                mainDict.setValue(feedId, forKey: "feedId")
                mainDict.setValue(feedProgram, forKey: "feedName")
                mainDict.setValue(fromDays, forKey: "durationFrom")
                mainDict.setValue(molecule, forKey: "molecule")
                mainDict.setValue(toDays, forKey: "durationTo")
                mainDict.setValue(18, forKey: "feedProgramCategoryId")
                mainDict.setValue(0, forKey: "moleculeId")
                mainDict.setValue(feedType, forKey: "feedType")
                
                FinalArray1.add(mainDict)
                
                if dataSet == 6 {
                    dataSet = 0
                    if mainFeeds.count>0 {
                        let tempArray = (mainFeeds.object(at: index) as AnyObject).value(forKey: "feedProgramDetails") as! NSMutableArray
                        if tempArray.count > 0 {
                            tempArray.addObjects(from: FinalArray1 as [AnyObject])
                            feeds = ["feedName" : feedProgram!, "feedId" : feedId, "startDate" : startDate ?? "","feedProgramDetails" : tempArray]
                        }
                        mainFeeds.replaceObject(at: index, with: feeds)
                        index+=1
                        FinalArray1 = NSMutableArray()
                        feeds = NSMutableDictionary()
                    }
                }
            }
            
            if ( allCocciControl.count > 0 || fetchAntibotic.count > 0 || fetchAlternative.count > 0 || fetchMyBinde.count > 0){
                
                mainDict.setValue(sessionId, forKey: "sessionId")
                let data = savedPostingArrWithAllData.object(at: 0) as! PostingSessionTurkey
                let acttimeStamp = data.timeStamp
             
                var  fullData = acttimeStamp!
                mainDict.setValue(fullData, forKey: "deviceSessionId")
                
                let id = UserDefaults.standard.integer(forKey: "Id")
                mainDict.setValue(id, forKey: "UserId")
                mainDict.setValue(false, forKey: "finalized")
                var sessionDict = NSMutableDictionary()
                sessionDict = ["deviceSessionId" : fullData,"sessionId" : postingIdArr[i] as! NSNumber, "userId" : id,"feeds" : mainFeeds]
                sessionArray.add(sessionDict)
                sessionDict = NSMutableDictionary()
                sessionDictMain = ["Sessions" : sessionArray]
            }
        }
        do {
            
            if WebClass.sharedInstance.connected() {
                
                let Url = "PostingSession/SaveMultipleFeedsSyncData"
                accestoken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken)!
              //  accestoken = (UserDefaults.standard.value(forKey: Constants.accessToken) as? String)!
                let headerDict = [Constants.authorization:accestoken]
                
                let urlString: String = WebClass.sharedInstance.webUrl + Url
                var request = URLRequest(url: URL(string: urlString)! )
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = headerDict
                request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
                request.httpBody = try? JSONSerialization.data(withJSONObject: sessionDictMain, options: [])
                
                sessionManager.request(request as URLRequestConvertible).responseJSON { response in
                    let statusCode =  response.response?.statusCode
                    
                    if statusCode == 401  {
                        self.loginMethod(postingId: postingId)
                    }
                    else if statusCode == 500 || statusCode == 503 ||  statusCode == 403 ||  statusCode==501 || statusCode == 502 || statusCode == 400 || statusCode == 504 || statusCode == 404 || statusCode == 408{
                        self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: statusCode!)
                    }
                    
                    switch response.result {
                        
                    case .success(let responseObject):
                        // internet works.
                        self.addVaccination(postingId:postingId )
                        
                    case .failure(let encodingError):
                        
                        if let err = encodingError as? URLError, err.code == .notConnectedToInternet {
                            
                            self.delegeteSyncApiData.failWithErrorInternalSyncdata()
                        } else if let data = response.data{
                            debugPrint(data)
                            if let s = statusCode {
                                self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: s)
                                
                            }  else {
                                self.delegeteSyncApiData.failWithErrorInternalSyncdata()
                            }
                        }
                    }
                }
            }
        }
    }
    // MARK: - ******************* Save Add Vacination data On Server ***************************/
    fileprivate func handlecNecArray(_ cNecArr: NSArray, _ necArrWithoutPosting: NSMutableArray) {
        for j in 0..<cNecArr.count
        {
            let captureNecropsyData = cNecArr.object(at: j)  as! CaptureNecropsyDataTurkey
            necArrWithoutPosting.add(captureNecropsyData)
            for w in 0..<necArrWithoutPosting.count - 1
            {
                let c = necArrWithoutPosting.object(at: w)  as! CaptureNecropsyDataTurkey
                if c.necropsyId == captureNecropsyData.necropsyId {
                    necArrWithoutPosting.remove(c)
                }
                
            }
            
        }
    }
    
    fileprivate func handlePostingArrWithAllData(_ postingArrWithAllData: NSMutableArray, _ sessionId: inout NSNumber, _ timeStamp: inout String, _ actualTemp: NSMutableArray, _ tempArrTime: NSMutableArray) {
        for i in 0..<postingArrWithAllData.count {
            let pSession = postingArrWithAllData.object(at: i) as! PostingSessionTurkey
            sessionId = pSession.postingId!
            timeStamp = pSession.timeStamp!
            var actualtimeStr = pSession.actualTimeStamp
            if actualtimeStr == nil{
                actualtimeStr = ""
            }
            actualTemp.add(actualtimeStr!)
            tempArrTime.add(timeStamp)
            self.postingIdArr.add(sessionId)
        }
    }
    
    fileprivate func handleAddVacinationAll(_ addVacinationAll: NSArray, _ vaccinationName: inout String, _ vaccinationDetail: NSMutableDictionary) {
        for i in 0..<addVacinationAll.count {
            let pSession = addVacinationAll.object(at: i) as! FieldVaccinationTurkey
            if i == 0{
                vaccinationName = pSession.vaciNationProgram!
            }
            
            let routeName = pSession.route
            var routeId = NSNumber()
            if routeName == Constants.drinkingWater {
                routeId = 2
            } else if routeName == Constants.wingWeb {
                routeId = 1
            } else if routeName == Constants.spray {
                routeId = 3
            } else if routeName == Constants.inOvoStr {
                routeId = 4
            } else if routeName == "Subcutaneous" {
                routeId = 5
            } else if routeName == "Intramuscular" {
                routeId = 6
            } else  if  routeName == Constants.eveDrop{
                routeId = 7
            }
            else{
                routeId = 0
            }
          
            var strain = pSession.strain!
            let strainKey = "hatcheryStrain\(i + 1)"
            let routeKey = "hatcheryRoute\(i+1)Id"
            
            vaccinationDetail .setObject(strain, forKey: strainKey as NSCopying)
            vaccinationDetail .setObject(routeId, forKey: routeKey as NSCopying)
        }
    }
    
    fileprivate func handleFieldVacinationAllArr(_ FieldVacinationAll: NSArray, _ vaccinationDetail: NSMutableDictionary) {
        for i in 0..<FieldVacinationAll.count {
            let pSession = FieldVacinationAll.object(at: i) as! HatcheryVacTurkey
            let routeName = pSession.route
            
          
            var routeId = NSNumber()
            if routeName == Constants.drinkingWater {
                routeId = 2
            }
            else if routeName == Constants.wingWeb {
                routeId = 1
            }
            else if routeName == Constants.spray {
                routeId = 3
            }
            else if routeName == Constants.inOvoStr {
                routeId = 4
            }
            else if routeName == "Subcutaneous" {
                routeId = 5
            }
            else if routeName == "Intramuscular" {
                routeId = 6
            }
            else  if  routeName == Constants.eveDrop{
                routeId = 7
            }
            else{
                routeId = 0
            }
            let age = pSession.age
            var  strain = pSession.strain!
            let fieldStrainKey = "fieldStrain\(i + 1)"
            let fieldrouteKey = "fieldRoute\(i+1)Id"
            let fieldAgeKey = "fieldAge\(i + 1)"
            
            vaccinationDetail .setObject(strain, forKey: fieldStrainKey as NSCopying)
            vaccinationDetail .setObject(routeId, forKey: fieldrouteKey as NSCopying)
            vaccinationDetail .setObject(age!, forKey: fieldAgeKey as NSCopying)
        }
    }
    
    fileprivate func handlePostingIdArr(_ vaccinationName: inout String, _ postingArrWithAllData: NSMutableArray, _ sessionArr: NSMutableArray) {
        for i in 0..<self.postingIdArr.count {
            
            let pId = self.postingIdArr.object(at: i) as! NSNumber
            let addVacinationAll = CoreDataHandlerTurkey().fetchFieldAddvacinationDataTurkey(pId)
            
            let vaccinationDetail = NSMutableDictionary()
            handleAddVacinationAll(addVacinationAll, &vaccinationName, vaccinationDetail)
            
            let FieldVacinationAll = CoreDataHandlerTurkey().fetchAddvacinationDataTurkey(pId)
            handleFieldVacinationAllArr(FieldVacinationAll, vaccinationDetail)
            
            if FieldVacinationAll.count > 0 || addVacinationAll.count > 0 {
                let vaccinationArray = NSMutableArray()
                vaccinationArray .add(vaccinationDetail)
                let mainDict = NSMutableDictionary()
                mainDict .setObject(vaccinationArray, forKey: "vaccinationDetail" as NSCopying)
                let id = UserDefaults.standard.integer(forKey: "Id")
                mainDict.setValue(id, forKey: "UserId")
                mainDict.setValue(pId, forKey: "sessionId")
                mainDict.setValue(pId, forKey: "vaccinationId")
                mainDict.setValue(vaccinationName, forKey: "vaccinationName")
                
                let data = postingArrWithAllData.object(at: 0) as! PostingSessionTurkey
                let acttimeStamp = data.timeStamp
               
                var fullData = acttimeStamp!
                mainDict.setValue(fullData, forKey: "deviceSessionId")
                sessionArr.add(mainDict)
            }
        }
    }
    
    fileprivate func handleSaveMultipleVaccAPIResponse(postingId:NSNumber,_ statusCode: Int?, _ response: AFDataResponse<Any>) {
        if statusCode == 401  {
            self.loginMethod(postingId: postingId)
        }
        else if statusCode == 500 || statusCode == 503 ||  statusCode == 403 ||  statusCode==501 || statusCode == 502 || statusCode == 400 || statusCode == 504 || statusCode == 404 || statusCode == 408{
            self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: statusCode!)
        }
        
        switch response.result {
            
        case .success(let responseObject):
            self.savePostingDataOnServer(postingId: postingId)
            
        case .failure(let encodingError):
            
            if let err = encodingError as? URLError, err.code == .notConnectedToInternet {
                
                self.delegeteSyncApiData.failWithErrorInternalSyncdata()
            } else if let statusData = response.data{
                debugPrint(statusData)
                if let s = statusCode {
                    self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: s)
                } else {
                    self.delegeteSyncApiData.failWithErrorInternalSyncdata()
                }
            }
        }
    }
    
    /**************************************************************************/
    func addVaccination(postingId:NSNumber)  {
        
        let vaccinationPostingArrWithAllData = CoreDataHandlerTurkey().fetchAllPostingSessionTurkey(postingId).mutableCopy() as! NSMutableArray
        let cNecArr =  CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postingId)
        let necArrWithoutPosting = NSMutableArray()
        
        handlecNecArray(cNecArr, necArrWithoutPosting)
        self.postingIdArr.removeAllObjects()
        var sessionId = NSNumber()
        var timeStamp = String()
        let tempArrTime = NSMutableArray()
        let actualTemp  = NSMutableArray()
        var vaccinationName = String ()
        
        handlePostingArrWithAllData(vaccinationPostingArrWithAllData, &sessionId, &timeStamp, actualTemp, tempArrTime)
        
        let sessionArr = NSMutableArray()
        let sessionDictWithVac = NSMutableDictionary()
        
        handlePostingIdArr(&vaccinationName, vaccinationPostingArrWithAllData, sessionArr)
        sessionDictWithVac.setValue(sessionArr, forKey: "Vaccinations")
        
        do {
            
            if WebClass.sharedInstance.connected() {
                let Url = "/PostingSession/SaveMultipleVaccinationsSyncData"
                accestoken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken)!
                let headerDict = [Constants.authorization:accestoken]
                let urlString: String = WebClass.sharedInstance.webUrl + Url
                var request = URLRequest(url: URL(string: urlString)! )
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = headerDict
                request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
                request.httpBody = try? JSONSerialization.data(withJSONObject: sessionDictWithVac, options: [])
                
                sessionManager.request(request as URLRequestConvertible).responseJSON { response in
                    let statusCode =  response.response?.statusCode
                    
                    self.handleSaveMultipleVaccAPIResponse(postingId: postingId, statusCode, response)
                }
            }
        }
    }
    // MARK: - ********************* Save Posting data On Server ***************************/
    
    fileprivate func failuerOfPostedSessionAPI(_ encodingError: AFError, _ response: AFDataResponse<Any>, _ statusCode: Int?) {
        if let err = encodingError as? URLError, err.code == .notConnectedToInternet {
            self.delegeteSyncApiData.failWithErrorInternalSyncdata()
        } else if let data = response.data {
            
            if let s = statusCode {
                self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: s)
            }
            else {
                self.delegeteSyncApiData.failWithErrorInternalSyncdata()
            }
        }
    }
    
   
    func savePostingDataOnServer(postingId :NSNumber){
        let lngId = UserDefaults.standard.integer(forKey: "lngId")
        let SessionPostingArrWithAllData = CoreDataHandlerTurkey().fetchAllPostingSessionTurkey(postingId).mutableCopy() as! NSMutableArray
        
        self.postingIdArr.removeAllObjects()
        let postingServerArray = NSMutableArray()
        let  postingDictOnServer = NSMutableDictionary()
        
        for i in 0..<SessionPostingArrWithAllData.count {
            let postingDataDict = NSMutableDictionary()
            let pSession = SessionPostingArrWithAllData.object(at: i) as! PostingSessionTurkey
            let sessionDate = pSession.sessiondate
            var sessionTypeId  = Int ()
            let sessiontype = pSession.sessionTypeName
            if sessiontype == "Farm Visit" {
                sessionTypeId = 2
            } else if sessiontype == "Posting Visit" {
                sessionTypeId = 1
            }
            else {
                sessionTypeId = 0
            }
            let customerId = pSession.customerId
            let complexId = pSession.complexId
            let customerRep = pSession.customerRepName
            let vetUserId = pSession.veterinarianId
            let salesUserId = pSession.salesRepId
            let cocciProgramId = pSession.cocciProgramId
            let breedName = pSession.birdBreedName
            let notes = pSession.notes
            let maleBreedName = pSession.mail
            let femaleBreedName = pSession.female
            let birdSize = pSession.birdSize
            let catptureNec = pSession.catptureNec
            let cociiProgramName = pSession.cociiProgramName
            let sessionId = pSession.postingId
            let finalize = pSession.finalizeExit
            
            let avgAGe = pSession.avgAge
            let avgWght = pSession.avgWeight
            let outTime = pSession.outTime
            let fcr = pSession.fcr
            let livability = pSession.livability
            let mortality = pSession.dayMortality
            
            self.postingIdArr.add(sessionId!)
            
           
            var  fullData =  pSession.timeStamp!
            let udid1 = UserDefaults.standard.value(forKey: "ApplicationIdentifier")! as! String
            postingDataDict.setValue(finalize, forKey: "finalized")
            postingDataDict.setValue(sessionDate, forKey: "sessionDate")
            postingDataDict.setValue(sessionTypeId, forKey: "sessionTypeId")
            postingDataDict.setValue(lngId, forKey: "LanguageId")
            postingDataDict.setValue(customerId, forKey: "customerId")
            postingDataDict.setValue(complexId, forKey: "complexId")
            postingDataDict.setValue(fullData, forKey: "deviceSessionId")
            postingDataDict.setValue(customerRep, forKey: "customerRep")
            postingDataDict.setValue(vetUserId, forKey: "vetUserId")
            postingDataDict.setValue(salesUserId, forKey: "salesUserId")
            postingDataDict.setValue(cocciProgramId, forKey: "cocciProgramId")
            postingDataDict.setValue(breedName, forKey: "breedName")
            postingDataDict.setValue(1, forKey: "birdTypeId")
            postingDataDict.setValue(notes, forKey: "notes")
            postingDataDict.setValue(maleBreedName, forKey: "maleBreedName")
            postingDataDict.setValue(femaleBreedName, forKey: "femaleBreedName")
            postingDataDict.setValue(birdSize, forKey: "birdSize")
            postingDataDict.setValue(catptureNec, forKey: "catptureNec")
            postingDataDict.setValue(cociiProgramName, forKey: "cociiProgramName")
            postingDataDict.setValue(sessionId, forKey: "sessionId")
            let id = UserDefaults.standard.integer(forKey: "Id")
            postingDataDict.setValue(id, forKey: "UserId")
            postingDataDict.setValue(udid1, forKey: "udid")
            postingDataDict.setValue(fcr, forKey: "FCR")
            postingDataDict.setValue(avgWght, forKey: "AvgWeight")
            postingDataDict.setValue(avgAGe, forKey: "AvgAge")
            postingDataDict.setValue(outTime, forKey: "AvgOutTime")
            postingDataDict.setValue(livability, forKey: "Livability")
            postingDataDict.setValue(mortality, forKey: "Avg7DayMortality")
            postingServerArray.add(postingDataDict)
        }
        
        postingDictOnServer.setValue(postingServerArray, forKey: "PostingSessions")
        
        do {

            if WebClass.sharedInstance.connected() {
                let Url = "PostingSession/TurkeySaveMultiplePostingsSyncData"
                accestoken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken)!
                let headerDict = [Constants.authorization:accestoken]
                let urlString: String = WebClass.sharedInstance.webUrl + Url
                var request = URLRequest(url: URL(string: urlString)! )
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = headerDict
                request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
                request.httpBody = try? JSONSerialization.data(withJSONObject: postingDictOnServer, options: [])
                sessionManager.request(request as URLRequestConvertible).responseJSON { response in
                    let statusCode =  response.response?.statusCode
                    
                    if statusCode == 401  {
                        self.loginMethod(postingId: postingId)
                    }
                    else if statusCode == 500 || statusCode == 503 ||  statusCode == 403 ||  statusCode==501 || statusCode == 502 || statusCode == 400 || statusCode == 504 || statusCode == 404 || statusCode == 408{
                        self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: statusCode!)
                    }
                    
                    switch response.result {
                        
                    case .success(let responseObject):
                        self.saveNecropsyDataOnServer(postingId: postingId)
                        
                    case .failure(let encodingError):
                        
                        self.failuerOfPostedSessionAPI(encodingError, response, statusCode)
                    }
                }
            }
        }
    }
    // MARK: - ********************* Save Farms  data On Server **************/
    fileprivate func ApiFailuerHandleForPostedData(_ encodingError: AFError, _ response: AFDataResponse<Any>, _ statusCode: Int?) {
        if let err = encodingError as? URLError, err.code == .notConnectedToInternet {
            self.delegeteSyncApiData.failWithErrorInternalSyncdata()
        } else if let statusResult = response.data{
            debugPrint(statusResult)
            if let s = statusCode {
                self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: s)
                
            } else  {
                self.delegeteSyncApiData.failWithErrorInternalSyncdata()
            }
        }
    }
    
    fileprivate func handleBirdArray(_ noOfBird: Int?, _ farmName: String?, _ cNData: CaptureNecropsyDataTurkey, _ birdArry: NSMutableArray) {
        for j in 0..<noOfBird!
        {
            let obsNameWithValue =   CoreDataHandlerTurkey().fetchObsWithBirdandFarmNameTurkey(farmName!, birdNo: (j + 1) as NSNumber, necId: cNData.necropsyId!)
            let notesWithFarm = CoreDataHandlerTurkey().fetchNotesWithBirdNumandFarmNameTurkey((j + 1) as NSNumber, formName: farmName!, necId: cNData.necropsyId!)
            if notesWithFarm.count > 0
            {
                let n = notesWithFarm.object(at: 0) as! NotesBirdTurkey
                let notes = n.notes
                obsNameWithValue.setValue(j + 1, forKey: "BirdId")
                obsNameWithValue.setValue(notes, forKey: "birdNotes")
            } else {
                obsNameWithValue.setValue(j + 1, forKey: "BirdId")
                obsNameWithValue.setValue("", forKey: "birdNotes")
            }
            birdArry.add(obsNameWithValue)
        }
    }
    
    fileprivate func handlecNecArrayAndAllArr(_ cNec: NSArray, _ complexId: inout Int, _ allArray: NSMutableArray) {
        for x in 0..<cNec.count
        {
            let birdArry = NSMutableArray()
            let cNData = cNec.object(at: x) as! CaptureNecropsyDataTurkey
            let farmName = cNData.farmName
            let noOfBird = Int(cNData.noOfBirds!)
            let houseNo = cNData.houseNo
            let feedProgram = cNData.feedProgram
          
            let age = cNData.age
            let flock = cNData.flockId
            let sick = cNData.sick
            let imgId = cNData.imageId
            complexId = cNData.complexId as! Int
            let customerId = cNData.custmerId
            let customerName = cNData.complexName
            let complexdate = cNData.complexDate
            let abf = cNData.abf
            let farmWeight = cNData.farmWeight
            let breedString = cNData.breed
            let sex = cNData.sex
            let farmId = cNData.farmId
            let genName = cNData.generName
            let genId = cNData.generID
            let formWithcatNameWithBirdAndAllObs = NSMutableDictionary()
            
            handleBirdArray(noOfBird, farmName, cNData, birdArry)
            
            formWithcatNameWithBirdAndAllObs.setValue(birdArry, forKey: "BirdDetails")
            formWithcatNameWithBirdAndAllObs.setValue(farmName, forKey: "farmName")
            formWithcatNameWithBirdAndAllObs.setValue(houseNo, forKey: "houseNo")
            formWithcatNameWithBirdAndAllObs.setValue(noOfBird!, forKey: "birds")
            formWithcatNameWithBirdAndAllObs.setValue(farmId, forKey: "SortId")
            formWithcatNameWithBirdAndAllObs.setValue(imgId, forKey: "ImgId")
            formWithcatNameWithBirdAndAllObs.setValue(feedProgram, forKey: "feedProgram")
            formWithcatNameWithBirdAndAllObs.setValue(feedId, forKey: "DeviceFeedId")
            formWithcatNameWithBirdAndAllObs.setValue(age, forKey: "age")
            formWithcatNameWithBirdAndAllObs.setValue(customerId, forKey: "customerId")
            formWithcatNameWithBirdAndAllObs.setValue(customerName, forKey: "customerName")
            formWithcatNameWithBirdAndAllObs.setValue(sick, forKey: "sick")
            formWithcatNameWithBirdAndAllObs.setValue(flock, forKey: "flockId")
            formWithcatNameWithBirdAndAllObs.setValue(complexdate, forKey: "ComplexDate")
            formWithcatNameWithBirdAndAllObs.setValue(abf, forKey: "ABF")
            formWithcatNameWithBirdAndAllObs.setValue(farmWeight, forKey: "Farm_Weight")
            formWithcatNameWithBirdAndAllObs.setValue(breedString, forKey: "Breed")
            formWithcatNameWithBirdAndAllObs.setValue(sex, forKey: "Sex")
            
            formWithcatNameWithBirdAndAllObs.setValue(genName, forKey: "GenerationName")
            formWithcatNameWithBirdAndAllObs.setValue(genId, forKey: "GenerationId")
            allArray.add(formWithcatNameWithBirdAndAllObs)
        }
    }
    
    fileprivate func handleNoOfBirdsValidation(_ noOfBird: Int?, _ farmName: String?, _ cNData: CaptureNecropsyDataTurkey, _ birdArry: NSMutableArray) {
        for j in 0..<noOfBird! {
            
            let obsNameWithValue =   CoreDataHandlerTurkey().fetchObsWithBirdandFarmNameTurkey(farmName!, birdNo: (j + 1) as NSNumber, necId: cNData.necropsyId!)
            let notesWithFarm = CoreDataHandlerTurkey().fetchNotesWithBirdNumandFarmNameTurkey((j + 1) as NSNumber, formName: farmName!, necId: cNData.necropsyId!)
            
            if notesWithFarm.count > 0 {
                let n = notesWithFarm.object(at: 0) as! NotesBirdTurkey
                let notes = n.notes
                obsNameWithValue.setValue(j + 1, forKey: "BirdId")
                obsNameWithValue.setValue(notes, forKey: "birdNotes")
            }  else  {
                obsNameWithValue.setValue(j + 1, forKey: "BirdId")
                obsNameWithValue.setValue("", forKey: "birdNotes")
            }
            birdArry.add(obsNameWithValue)
        }
    }
    
    fileprivate func handlecNecArrayValidation(_ cNec: NSArray, _ complexId: inout Int, _ allArray: NSMutableArray) {
        for x in 0..<cNec.count {
            
            let birdArry = NSMutableArray()
            let cNData = cNec.object(at: x) as! CaptureNecropsyDataTurkey
            let farmName = cNData.farmName
            let noOfBird = Int(cNData.noOfBirds!)
            let houseNo = cNData.houseNo
            let feedProgram = cNData.feedProgram
            if let value =  (cNData.feedId  as? Int){
                feedId = value
            }
            let age = cNData.age
            complexId = cNData.complexId as! Int
            let flock = cNData.flockId
            let imgId = cNData.imageId
            let farmId = cNData.farmId
            let sick = cNData.sick
            let customerId = cNData.custmerId
            let customerName = cNData.complexName
            let complexDate = cNData.complexDate
            let formWithcatNameWithBirdAndAllObs = NSMutableDictionary()
            var abf = cNData.abf
            let farmWeight = cNData.farmWeight
            let breedString = cNData.breed
            let sex = cNData.sex
            let genName = cNData.generName
            let genId = cNData.generID
            
            handleNoOfBirdsValidation(noOfBird, farmName, cNData, birdArry)
            
            formWithcatNameWithBirdAndAllObs.setValue(abf, forKey: "ABF")
            formWithcatNameWithBirdAndAllObs.setValue(farmWeight, forKey: "Farm_Weight")
            formWithcatNameWithBirdAndAllObs.setValue(breedString, forKey: "Breed")
            formWithcatNameWithBirdAndAllObs.setValue(sex, forKey: "Sex")
            formWithcatNameWithBirdAndAllObs.setValue(farmId, forKey: "SortId")
            formWithcatNameWithBirdAndAllObs.setValue(imgId, forKey: "ImgId")
            formWithcatNameWithBirdAndAllObs.setValue(birdArry, forKey: "BirdDetails")
            formWithcatNameWithBirdAndAllObs.setValue(farmName, forKey: "farmName")
            formWithcatNameWithBirdAndAllObs.setValue(houseNo, forKey: "houseNo")
            formWithcatNameWithBirdAndAllObs.setValue(noOfBird!, forKey: "birds")
            formWithcatNameWithBirdAndAllObs.setValue(feedProgram, forKey: "feedProgram")
            formWithcatNameWithBirdAndAllObs.setValue(feedId, forKey: "DeviceFeedId")
            formWithcatNameWithBirdAndAllObs.setValue(age, forKey: "age")
            formWithcatNameWithBirdAndAllObs.setValue(customerId, forKey: "customerId")
            formWithcatNameWithBirdAndAllObs.setValue(customerName, forKey: "customerName")
            formWithcatNameWithBirdAndAllObs.setValue(sick, forKey: "sick")
            formWithcatNameWithBirdAndAllObs.setValue(flock, forKey: "flockId")
            formWithcatNameWithBirdAndAllObs.setValue(complexDate, forKey: "ComplexDate")
            formWithcatNameWithBirdAndAllObs.setValue(genName, forKey: "GenerationName")
            formWithcatNameWithBirdAndAllObs.setValue(genId, forKey: "GenerationId")
            allArray.add(formWithcatNameWithBirdAndAllObs)
            
        }
    }
    
    fileprivate func callloginMethod(_ statusCode: Int? , postingsessionId: NSNumber) {
        if statusCode == 401  {
            self.loginMethod(postingId:postingsessionId)
        }
        else if statusCode == 500 || statusCode == 503 ||  statusCode == 403 ||  statusCode==501 || statusCode == 502 || statusCode == 400 || statusCode == 504 || statusCode == 404 || statusCode == 408{
            self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: statusCode!)
        }
    }
    
    /************************************/
    
    func saveNecropsyDataOnServer(postingId: NSNumber){
        var complexId = Int()
        let lngId = UserDefaults.standard.integer(forKey: "lngId")
        let cNecArr = CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postingId)
        let a = NSMutableArray()
        
        for j in 0..<cNecArr.count {
            let captureNecropsyData = cNecArr.object(at: j)  as! CaptureNecropsyDataTurkey
            a.add(captureNecropsyData)
            for w in 0..<a.count - 1 {
                let c = a.object(at: w)  as! CaptureNecropsyDataTurkey
                if c.necropsyId == captureNecropsyData.necropsyId {
                    a.remove(c)
                }
            }
        }
        
        let sessionWithAllforms = NSMutableDictionary()
        let sessionArr = NSMutableArray()
        for i in 0..<a.count {
            let allArray = NSMutableArray()
            let captureNecropsyData = a.object(at: i)  as! CaptureNecropsyDataTurkey
            complexId = Int(captureNecropsyData.complexId!)
            
            let cNec =  CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postingId)
            let formWithcatNameWithBirdAndAllObs1 = NSMutableDictionary()
            handlecNecArrayAndAllArr(cNec, &complexId, allArray)
            
            var fullData = captureNecropsyData.timeStamp!
            formWithcatNameWithBirdAndAllObs1.setValue(captureNecropsyData.necropsyId!, forKey: "SessionId")
            formWithcatNameWithBirdAndAllObs1.setValue(lngId, forKey: "LanguageId")
            formWithcatNameWithBirdAndAllObs1.setValue(fullData, forKey: "deviceSessionId")
            if complexId > 0{
                formWithcatNameWithBirdAndAllObs1.setValue(complexId, forKey: "ComplexId")
            }
            
            formWithcatNameWithBirdAndAllObs1.setValue(captureNecropsyData.complexDate!, forKey: "sessionDate")
            formWithcatNameWithBirdAndAllObs1.setValue(allArray, forKey: "farmDetails")
            let Id = UserDefaults.standard.integer(forKey: "Id")
            formWithcatNameWithBirdAndAllObs1.setValue(Id, forKey: "UserId")
            
            sessionArr.add(formWithcatNameWithBirdAndAllObs1)
        }
        postingArrWithAllData.removeAllObjects()
        postingArrWithAllData = CoreDataHandlerTurkey().fetchAllPostingSessionTurkey(postingId).mutableCopy() as! NSMutableArray
        
        for i in 0..<postingArrWithAllData.count {
            
            let allArray = NSMutableArray()
            let captureNecropsyData = postingArrWithAllData.object(at: i)  as! PostingSessionTurkey
            let cid = captureNecropsyData.complexId!
            let cNec =  CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postingId)
            
            let formWithcatNameWithBirdAndAllObs1 = NSMutableDictionary()
            
            handlecNecArrayValidation(cNec, &complexId, allArray)
            
            var fullData = captureNecropsyData.timeStamp!
            formWithcatNameWithBirdAndAllObs1.setValue(captureNecropsyData.postingId!, forKey: "SessionId")
            formWithcatNameWithBirdAndAllObs1.setValue(fullData, forKey: "deviceSessionId")
            formWithcatNameWithBirdAndAllObs1.setValue(lngId, forKey: "LanguageId")
            formWithcatNameWithBirdAndAllObs1.setValue(cid, forKey: "ComplexId")
            formWithcatNameWithBirdAndAllObs1.setValue(captureNecropsyData.sessiondate!, forKey: "sessionDate")
            formWithcatNameWithBirdAndAllObs1.setValue(allArray, forKey: "farmDetails")
            let Id = UserDefaults.standard.integer(forKey: "Id")
            formWithcatNameWithBirdAndAllObs1.setValue(Id, forKey: "UserId")
            sessionArr.add(formWithcatNameWithBirdAndAllObs1)
        }
        
        sessionWithAllforms.setValue(sessionArr, forKey: "Session")
        
        do {
            
            if WebClass.sharedInstance.connected() {
                accestoken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken)!
                let headerDict = [Constants.authorization:accestoken]
            // old   let Url = "PostingSession/T_SaveMultipleNecropsySyncData"
                let Url = "PostingSession/TurkeySaveMultipleNecropsySyncData"
                let urlString: String = WebClass.sharedInstance.webUrl + Url
                var request = URLRequest(url: URL(string: urlString)! )
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = headerDict
                request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
                request.httpBody = try? JSONSerialization.data(withJSONObject: sessionWithAllforms, options: [])
                
                sessionManager.request(request as URLRequestConvertible).responseJSON { response in
                    let statusCode =  response.response?.statusCode
                    
                    self.callloginMethod(statusCode, postingsessionId: postingId)
                    
                    switch response.result {
                        
                    case .success(let responseObject):
                        self.saveObservationImageOnServer(postingId: postingId)
                        
                    case .failure(let encodingError):
                        
                        self.ApiFailuerHandleForPostedData(encodingError, response, statusCode)
                    }
                }
            }
        }
    }
    // MARK: -********************* Save Image  On Server ***************************/
    fileprivate func statusUpdateForPostedSession(postingId : NSNumber) {
        CoreDataHandlerTurkey().updateisSyncOnMyBindersViaPostingIdTurkey(postingId, isSync: false, { (success) in
            
            if success == true{
                
                CoreDataHandlerTurkey().updateisSyncOnAlternativeFeedPostingidTurkey(postingId , isSync: false, { (success) in
                    
                    if success == true{
                        
                        CoreDataHandlerTurkey().updateisSyncOnAntiboticViaPostingIdTurkey(postingId , isSync: false, { (success) in
                            
                            if success == true{
                                
                                CoreDataHandlerTurkey().updateisSyncOnAllCocciControlviaPostingidTurkey(postingId , isSync: false, { (success) in
                                    
                                    if success == true{
                                        
                                        CoreDataHandlerTurkey().updateisSyncOnHetcharyVacDataWithPostingIdTurkey(postingId , isSync: false, { (success) in
                                            
                                            if success == true{
                                                
                                                CoreDataHandlerTurkey().updateisSyncOnPostingSessionTurkey(postingId , isSync: false, { (success) in
                                                    
                                                    if success == true{
                                                        
                                                        CoreDataHandlerTurkey().updateisSyncOnBirdPhotoCaptureDatabaseTurkey(postingId , isSync: false, { (success) in
                                                            
                                                            if success == true{
                                                                CoreDataHandlerTurkey().updateisSyncOnNotesBirdDatabaseTurkey(postingId , isSync: false, { (success) in
                                                                    
                                                                    if success == true{
                                                                        CoreDataHandlerTurkey().updateisSyncNecropsystep1neccIdTurkey(postingId , isSync: false, { (success) in
                                                                            if success == true{
                                                                                CoreDataHandlerTurkey().updateisSyncOnCaptureSkeletaInDatabaseTurkey(postingId , isSync: false, { (success) in
                                                                                    if success == true{
                                                                                        
                                                                                        CoreDataHandlerTurkey().updateisSyncOnBirdPhotoCaptureDatabaseTurkey(postingId , isSync: false, { (success) in
                                                                                            if success == true{
                                                                                                self.delegeteSyncApiData.didFinishApiSyncdata()
                                                                                            }
                                                                                        })
                                                                                    }
                                                                                })
                                                                            }
                                                                        })
                                                                    }
                                                                })
                                                            }
                                                        })
                                                    }
                                                })
                                            }
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }
    
    fileprivate func postImagesApiFailer(_ encodingError: AFError, _ response: AFDataResponse<Any>, _ statusCode: Int?) {
        if let err = encodingError as? URLError, err.code == .notConnectedToInternet {
            self.delegeteSyncApiData.failWithErrorInternalSyncdata()
        } else if let respinceData = response.data {
            debugPrint(respinceData)
            if let s = statusCode {
                self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: s)
            }  else  {
                self.delegeteSyncApiData.failWithErrorInternalSyncdata()
            }
        }
    }
    
    fileprivate func handleCNecArr(_ cNecArr: NSArray, _ totalSession: NSMutableArray) {
        for j in 0..<cNecArr.count {
            let captureNecropsyData = cNecArr.object(at: j)  as! CaptureNecropsyDataTurkey
            totalSession.add(captureNecropsyData)
            for w in 0..<totalSession.count - 1
            {
                let c = totalSession.object(at: w)  as! CaptureNecropsyDataTurkey
                if c.necropsyId == captureNecropsyData.necropsyId
                {
                    totalSession.remove(c)
                }
            }
        }
    }
    
    fileprivate func handleObsArr(_ obsArr: NSArray, _ j: Int, _ farmName: String?, _ catArr: NSArray, _ w: Int, _ necId: Int, _ obsWithImageArr: NSMutableArray) {
        for y in 0..<obsArr.count {
            let obsWithAllImageDataDict = NSMutableDictionary()
            let cData = obsArr.object(at: y) as! CaptureNecropsyViewDataTurkey
            let photoArr = CoreDataHandlerTurkey().fecthPhotoWithCatnameWithBirdAndObservationIDandIsyncTurkey( (j + 1) as NSNumber, farmname: farmName!, catName: catArr.object(at: w) as! String, Obsid: cData.obsID!, isSync: true,necId: necId as NSNumber)
            obsWithAllImageDataDict.setValue(farmName!, forKey: "farmName")
            obsWithAllImageDataDict.setValue(j + 1, forKey: "birdNumber")
            
            var catName1 = catArr.object(at: w) as! String
            if catName1 == "Coccidiosis"{
                catName1 = "Microscopy"
            }
            
            obsWithAllImageDataDict.setValue(catName1, forKey: "categoryName")
            obsWithAllImageDataDict.setValue(cData.obsID!, forKey: "observationId")
            
            let photoValArr = NSMutableArray()
            var yImage =  UIImage()
            for z in 0..<photoArr.count
            {
                let objBirdPhotoCapture = photoArr.object(at: z) as! BirdPhotoCaptureTurkey
                var image : UIImage = UIImage(data: objBirdPhotoCapture.photo! as Data)!
                
                if let imageData = image.jpeg(.lowest) {
                    image = UIImage(data: imageData)!
                }
                
                let w : CGFloat = image.size.width / 7
                yImage = self.resizeImage(image, newWidth: w)!
                let imageDict =  NSMutableDictionary()
                imageDict.setValue(self.imageToNSString(yImage), forKey: "Image")
                photoValArr.add(imageDict)
            }
            obsWithAllImageDataDict.setValue(photoValArr, forKey: "images")
            obsWithImageArr.add(obsWithAllImageDataDict)
        }
    }
    
    fileprivate func handleNoOfBirdaArr(_ noOfBird: Int?, _ farmName: String?, _ necId: Int, _ obsWithImageArr: NSMutableArray) {
        for j in 0..<noOfBird! {
            let catArr = ["skeltaMuscular","Coccidiosis","GITract","Resp","Immune"] as NSArray
            for w in 0..<catArr.count {
                let obsArr = CoreDataHandlerTurkey().fecthobsDataWithCatnameAndFarmNameAndBirdNumberTurkey((j + 1) as NSNumber, farmname: farmName!, catName: catArr.object(at: w) as! String, necId: necId as NSNumber)
                
                handleObsArr(obsArr, j, farmName, catArr, w, necId, obsWithImageArr)
            }
        }
    }
    
    fileprivate func totalSessionItertion(_ totalSession: NSMutableArray, _ postingId: NSNumber, _ sessionArr: NSMutableArray) {
        for i in 0..<totalSession.count {
            let sessionDetails = NSMutableDictionary()
            let captureNecropsyData = totalSession.object(at: i)  as! CaptureNecropsyDataTurkey
           
            let cNec =  CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postingId)
            let obsWithImageArr = NSMutableArray()
            for x in 0..<cNec.count {
                let cNData = cNec.object(at: x) as! CaptureNecropsyDataTurkey
                let farmName = cNData.farmName
                let noOfBird = Int(cNData.noOfBirds!)
                let necId = Int(cNData.necropsyId!)
                handleNoOfBirdaArr(noOfBird, farmName, necId, obsWithImageArr)
            }
            
            var fullData = captureNecropsyData.timeStamp!
            sessionDetails.setValue(obsWithImageArr, forKey: "ImageDetails")
            let id = UserDefaults.standard.integer(forKey: "Id")
            sessionDetails.setValue(id, forKey: "UserId")
            sessionDetails.setValue(fullData, forKey: "deviceSessionId")
            sessionArr.add(sessionDetails)
        }
    }
    
    fileprivate func handlePhotoArrSaveObsImageOnServerValidations(_ photoArr: NSArray, _ yImage: inout UIImage, _ photoValArr: NSMutableArray) {
        for z in 0..<photoArr.count {
            let objBirdPhotoCapture = photoArr.object(at: z) as! BirdPhotoCaptureTurkey
            
            var image : UIImage = UIImage(data: objBirdPhotoCapture.photo! as Data)!
           
            
            if let imageData = image.jpeg(.lowest) {
                
                image = UIImage(data: imageData)!
            }
            let w : CGFloat = image.size.width / 7
            yImage = self.resizeImage(image, newWidth: w)!
           
            let imageDict =  NSMutableDictionary()
            imageDict.setValue(self.imageToNSString(yImage), forKey: "Image")
            photoValArr.add(imageDict)
            
        }
    }
    
    fileprivate func handleCatArrValidationsSaveObsImageOnServer(_ catArr: NSArray, _ j: Int, _ farmName: String?, _ necId: Int, _ obsWithImageArr: NSMutableArray) {
        for w in 0..<catArr.count {
            let obsArr = CoreDataHandlerTurkey().fecthobsDataWithCatnameAndFarmNameAndBirdNumberTurkey((j + 1) as NSNumber, farmname: farmName!, catName: catArr.object(at: w) as! String, necId: necId as NSNumber)
            
            for y in 0..<obsArr.count {
                let obsWithAllImageDataDict = NSMutableDictionary()
                let cData = obsArr.object(at: y) as! CaptureNecropsyViewDataTurkey
                let photoArr = CoreDataHandlerTurkey().fecthPhotoWithCatnameWithBirdAndObservationIDandIsyncTurkey((j + 1) as NSNumber, farmname: farmName!, catName: catArr.object(at: w) as! String, Obsid: cData.obsID!, isSync: true,necId: necId as NSNumber)
                obsWithAllImageDataDict.setValue(farmName!, forKey: "farmName")
                obsWithAllImageDataDict.setValue(j + 1, forKey: "birdNumber")
                var catName = catArr.object(at: w) as! String
                if catName == "Coccidiosis"{
                    catName = "Microscopy"
                }
                
                obsWithAllImageDataDict.setValue(catName, forKey: "categoryName")
                obsWithAllImageDataDict.setValue(cData.obsID!, forKey: "observationId")
                
                let photoValArr = NSMutableArray()
                var yImage = UIImage()
                handlePhotoArrSaveObsImageOnServerValidations(photoArr, &yImage, photoValArr)
                obsWithAllImageDataDict.setValue(photoValArr, forKey: "images")
                obsWithImageArr.add(obsWithAllImageDataDict)
            }
        }
    }
    
    fileprivate func handleSaveBirdImageSyncDataResponse(_ statusCode: Int?, _ response: AFDataResponse<Any>,postingId:NSNumber) {
        if statusCode == 401  {
            self.loginMethod(postingId: postingId)
        }
        else if statusCode == 500 || statusCode == 503 ||  statusCode == 403 ||  statusCode==501 || statusCode == 502 || statusCode == 400 || statusCode == 504 || statusCode == 404 || statusCode == 408{
            self.delegeteSyncApiData.failWithErrorSyncdata(statusCode: statusCode!)
        }
        
        switch response.result {
            
        case .success(let responseObject):
            Constants.isFromPsotingTurkey = false
            UserDefaults.standard.removeObject(forKey: "postingTurkey")
            CoreDataHandlerTurkey().updateisSyncOnBirdPhotoCaptureDatabaseTurkey(postingId , isSync: false, { (success) in
                
                if success == true{
                    
                    self.statusUpdateForPostedSession(postingId: postingId)
                    
                }
            })
            
        case .failure(let encodingError):
            
            self.postImagesApiFailer(encodingError, response, statusCode)
        }
    }
    
    /**************************************************************************/
    
    func saveObservationImageOnServer (postingId:NSNumber) {
        
        let imageArrWithIsyncIsTrue = CoreDataHandlerTurkey().fecthPhotoWithiSynsTrueTurkey(true)
        let sessionDict = NSMutableDictionary()
        let sessionArr = NSMutableArray()
        let cNecArr =  CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postingId)
        let totalSession = NSMutableArray()
        
        handleCNecArr(cNecArr, totalSession)
        
        postingArrWithAllData.removeAllObjects()
        postingArrWithAllData =  CoreDataHandlerTurkey().fetchAllPostingSessionTurkey(postingId).mutableCopy() as! NSMutableArray
        
        if imageArrWithIsyncIsTrue.count > 0 {
            totalSessionItertion(totalSession, postingId, sessionArr)
            
            for i in 0..<postingArrWithAllData.count {
                let sessionDetails = NSMutableDictionary()
                let captureNecropsyData = postingArrWithAllData.object(at: i)  as! PostingSessionTurkey
                _ = captureNecropsyData.timeStamp
                
                let cNec = CoreDataHandlerTurkey().FetchNecropsystep1NecIdTurkey(postingId)
                let obsWithImageArr = NSMutableArray()
                for x in 0..<cNec.count {
                    let cNData = cNec.object(at: x) as! CaptureNecropsyDataTurkey
                    let farmName = cNData.farmName
                    let noOfBird = Int(cNData.noOfBirds!)
                    let necId = Int(cNData.necropsyId!)
                    for j in 0..<noOfBird! {
                        let catArr = ["skeltaMuscular","Coccidiosis","GITract","Resp","Immune"] as NSArray
                        
                        handleCatArrValidationsSaveObsImageOnServer(catArr, j, farmName, necId, obsWithImageArr)
                    }
                }
                
                _ = Int()
                var fullData = captureNecropsyData.timeStamp!
                sessionDetails.setValue(obsWithImageArr, forKey: "ImageDetails")
                let id = UserDefaults.standard.integer(forKey: "Id")
                sessionDetails.setValue(id, forKey: "UserId")
                sessionDetails.setValue(fullData, forKey: "deviceSessionId")
                sessionArr.add(sessionDetails)
                
            }
        }
        sessionDict.setValue(sessionArr, forKey: "Sessions")
        
        do {

            
            if WebClass.sharedInstance.connected() {
                accestoken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken)!
                let headerDict = [Constants.authorization:accestoken]
                let Url = "PostingSession/SaveBirdImageSyncData"
                let urlString: String = WebClass.sharedInstance.webUrl + Url
                var request = URLRequest(url: URL(string: urlString)! )
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = headerDict
                request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: sessionDict, options: [])
                
                sessionManager.request(request as URLRequestConvertible).responseJSON { response in
                    let statusCode =  response.response?.statusCode
                    
                    self.handleSaveBirdImageSyncDataResponse(statusCode, response, postingId: postingId)
                }
            }
        }
    }
 
    // MARK: -*************** Login Method call Again  ***************************************************/
    
    func loginMethod(postingId:NSNumber){
        
        if WebClass.sharedInstance.connected() {
            let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier")!
            let userName =  PasswordService.shared.getUsername()
            let pass =  PasswordService.shared.getPassword()
            
            let Url = "Token"
            let urlString: String = WebClass.sharedInstance.webUrl + Url
            let headers: HTTPHeaders = [Constants.contentType: "application/x-www-form-urlencoded", "Accept": Constants.applicationJson]
            let parameters:[String:String] = ["grant_type": "password","UserName" : CryptoHelper.encrypt(input: userName) as! String, "Password" : CryptoHelper.encrypt(input: pass) as! String, "LoginType": "Web", "DeviceId":udid as! String]
            sessionManager.request(urlString, method: .post, parameters: parameters, headers: headers).responseJSON { response in
                switch response.result {
                case let .success(value):
                    let statusCode = response.response?.statusCode
                    let dict : NSDictionary = value as! NSDictionary
                    if statusCode == 400{
                        _ = dict["error_description"]
                    }
                    
                    else if statusCode == 401{
                        _ = dict["error_description"]
                    }
                    else{
                        let acessToken = (dict.value(forKey: "access_token") as? String)!
                        let tokenType = (dict.value(forKey: "token_type") as? String)!
                        let aceesTokentype: String = tokenType + " " + acessToken
                        _ = dict.value(forKey: "HasAccess")! as AnyObject
                        let keychainHelper = AccessTokenHelper()
                        keychainHelper.saveToKeychain(valued: aceesTokentype, keyed: Constants.accessToken)
                        self.feedprogram(postingId: postingId)
                    }
                    break
                case let .failure(error):
                    debugPrint(error.localizedDescription)
                    break
                }
            }
        }
    }
    // MARK: - Update Data on Data Base
    fileprivate func handleSyncOnPostingSessionTurkey(pId: NSNumber, _ completion: @escaping (_ status: Bool) -> Void) {
        CoreDataHandlerTurkey().updateisSyncOnPostingSessionTurkey(pId , isSync: false, { (success) in
            if success == true {
                self.updadateNacDataOnCoreData(nId: pId, { (success) in
                    if success == true {
                        completion(success)
                        self.delegeteSyncApiData.didFinishApiSyncdata()
                    }
                })
            }
        })
    }
    
    fileprivate func handleUpdateIsSyncCocciSaveDB(pId: NSNumber, _ completion: @escaping (_ status: Bool) -> Void) {
        CoreDataHandlerTurkey().updateisSyncOnAllCocciControlviaPostingidTurkey(pId , isSync: false, { (success) in
            if success == true {
                CoreDataHandlerTurkey().updateisSyncOnHetcharyVacDataWithPostingIdTurkey(pId , isSync: false, { (success) in
                    if success == true {
                        handleSyncOnPostingSessionTurkey(pId: pId) { status in
                            completion(status)
                        }
                    }
                })
            }
        })
    }
    
    func updadateDataOnCoreData(pId: NSNumber, _ completion: @escaping (_ status: Bool) -> Void){
        CoreDataHandlerTurkey().updateisSyncOnMyBindersViaPostingIdTurkey(pId, isSync: false, { (success) in
            if success == true {
                CoreDataHandlerTurkey().updateisSyncOnAlternativeFeedPostingidTurkey(pId , isSync: false, { (success) in
                    if success == true {
                        
                        CoreDataHandlerTurkey().updateisSyncOnAntiboticViaPostingIdTurkey(pId , isSync: false, { (success) in
                            if success == true {
                                handleUpdateIsSyncCocciSaveDB(pId: pId) { status in
                                    completion(status)
                                }
                            }
                        })
                    }
                })
            }
        })
    }
    // MARK: - Update Necropsy Data on Core DB
    fileprivate func updateIsSyncInDB(_ nId: NSNumber,_ success: Bool, _ completion: (_ status: Bool) -> Void) {
        if success == true{
            
            CoreDataHandlerTurkey().updateisSyncOnBirdPhotoCaptureDatabaseTurkey(nId , isSync: false, { (success) in
                if success == true{
                    CoreDataHandlerTurkey().updateisSyncOnNotesBirdDatabaseTurkey(nId , isSync: false, { (success) in
                        if success == true{
                            completion(success)
                        }
                    })
                }
            })
        }
    }
    
    func updadateNacDataOnCoreData(nId: NSNumber, _ completion: (_ status: Bool) -> Void){
        
        CoreDataHandlerTurkey().updateisSyncOnCaptureSkeletaInDatabaseTurkey(nId , isSync: false, { (success) in
            if success == true {
                
                CoreDataHandlerTurkey().updateisSyncNecropsystep1neccIdTurkey(nId , isSync: false, { (success) in
                    if success == true {
                        
                        CoreDataHandlerTurkey().updateisSyncOnCaptureInDatabaseTurkey(nId , isSync: false, { (success) in
                            updateIsSyncInDB(nId,success) { (status) in
                                completion(status)
                            }
                        })
                    }
                })
            }
        })
    }
}
