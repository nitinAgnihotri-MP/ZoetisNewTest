//
//  ApiSync.swift
//  Zoetis -Feathers
//
//  Created by "" on 15/02/17.
//  Copyright © 2017 "". All rights reserved.


import UIKit
import Alamofire
import MBProgressHUD
import Reachability
import SystemConfiguration
import CoreData

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


protocol syncApi{
    func failWithError(statusCode:Int)
    func failWithErrorInternal()
    func didFinishApi()
    func failWithInternetConnection()
}

private struct FeedProgramConstants {
	static let feedProgramCategoryIds = [
		"cocci": 5,
		"antibiotic": 12,
		"alternative": 6,
		"mycotoxin": 18
	]
	
	static let batchSizes = [
		"cocci": 7,
		"antibiotic": 6,
		"alternative": 6,
		"mycotoxin": 6
	]
}

private protocol FeedProtocol {
	var dosage: String? { get }
	var feedId: NSNumber? { get }
	var feedDate: String? { get }
	var feedProgram: String? { get }
	var fromDays: String? { get }
	var molecule: String? { get }
	var toDays: String? { get }
	var feedType: String? { get }
}

extension CoccidiosisControlFeed: FeedProtocol {}
extension AntiboticFeed: FeedProtocol {}
extension AlternativeFeed: FeedProtocol {}
extension MyCotoxinBindersFeed: FeedProtocol {}

class ApiSync: NSObject {
    /***************** Create Singloton Objcet for this class ****************/
    // static let sharedInstance = ApiSync()
    // MARK: - VARIABLES
    var reachability: Reachability!
    var delegeteSyncApi : syncApi!
    var postingIdArr = NSMutableArray()
    var postingArrWithAllData = NSMutableArray()
    var strdateTimeStamp = String()
    var accestoken = String()
    
    var networkStatus : Reachability.Connection!
    var isSyncPostingIdArr : Bool = false
    var isSyncPostingArrWithData : Bool = false
    var isDelegateCalled : Bool = false
	
	private var sessionArray = NSMutableArray()
	private var sessionDictMain = NSMutableDictionary()
    private let sessionManager: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return Session(configuration: configuration)
    }()
    
    // MARK: - METHODS AND FUNCTIONS
    override init()
    {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ApiSync.networkStatusChanged(_:)),
                                               name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification),
                                               object: nil)
        Reach().monitorReachabilityChanges()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(ReachabilityStatusChangedNotification)
    }
    
    // MARK: 🟠 Network Status Check
    @objc func networkStatusChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo, let value = userInfo.values.first as? String {
            switch value {
            case "Online (WiFi)", "Online (WWAN)":
                debugPrint(value)
            default: break
            }
        }
    }
    
    
    // MARK: 🟠 Get all session's List
    func allSessionArr() ->NSMutableArray{
        
        let allPostingArrWithAllData = CoreDataHandler().fetchAllPostingSessionWithisSyncisTrue(true).mutableCopy() as! NSMutableArray
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
        for i in 0..<allPostingArrWithAllData.count
        {
            let pSession = allPostingArrWithAllData.object(at: i) as! PostingSession
            let sessionId = pSession.postingId!
            allPostingSessionArr.add(sessionId)
        }
        for i in 0..<necArrWithoutPosting.count
        {
            let nIdSession = necArrWithoutPosting.object(at: i) as! CaptureNecropsyData
            let sessionId = nIdSession.necropsyId!
            allPostingSessionArr.add(sessionId)
        }
        return allPostingSessionArr
    }
    // MARK: 🟠 Reset Image Size
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func imageToNSString(_ image: UIImage) -> String {
        let data = image.pngData()
        return data!.base64EncodedString(options: .lineLength64Characters)
    }
    // MARK: 🟢 ****************** Save Feed Program data On Server *****************************************************************************************************/
	// MARK: - Feed Program Sync
	func feedprogram() {
		isSyncPostingIdArr = false
		let (postingSessions, necropsyData) = fetchSyncData()
		let postingIds = preparePostingIds(postingSessions: postingSessions, necropsyData: necropsyData)
		processPostingIds(postingIds)
	}
	
	// MARK: - Data Fetching
	private func fetchSyncData() -> (NSMutableArray, NSMutableArray) {
		let feedPostingArr = CoreDataHandler().fetchAllPostingSessionWithisSyncisTrue(true).mutableCopy() as! NSMutableArray
		let cNecArr = CoreDataHandler().FetchNecropsystep1WithisSync(true)
		let necArrWithoutPosting = removeDuplicateNecropsyData(cNecArr)
		
		return (feedPostingArr, necArrWithoutPosting)
	}
	
	private func removeDuplicateNecropsyData(_ necropsyData: NSArray) -> NSMutableArray {
		let uniqueNecropsyData = NSMutableArray()
		
		for data in necropsyData {
			guard let captureNecropsyData = data as? CaptureNecropsyData else { continue }
			
			let isDuplicate = uniqueNecropsyData.contains { existingData in
				guard let existingNecropsyData = existingData as? CaptureNecropsyData else { return false }
				return existingNecropsyData.necropsyId == captureNecropsyData.necropsyId
			}
			
			if !isDuplicate {
				uniqueNecropsyData.add(captureNecropsyData)
			}
		}
		
		return uniqueNecropsyData
	}
	
	// MARK: - Posting ID Preparation
	private func preparePostingIds(postingSessions: NSMutableArray, necropsyData: NSMutableArray) -> NSMutableArray {
		let postingIds = NSMutableArray()
		
		if !isSyncPostingArrWithData {
			isSyncPostingArrWithData = true
			for session in postingSessions {
				guard let postingSession = session as? PostingSession else { continue }
				if let postingId = postingSession.postingId {
					postingIds.add(postingId)
				}
			}
		}
		
		for necropsy in necropsyData {
			guard let necropsyData = necropsy as? CaptureNecropsyData,
				  let necropsyId = necropsyData.necropsyId else { continue }
			postingIds.add(necropsyId)
		}
		
		return postingIds
	}
	
	// MARK: - Feed Processing
	private func processPostingIds(_ postingIds: NSMutableArray) {
		for postingId in postingIds {
			guard let postingId = postingId as? NSNumber else { continue }
			processSinglePostingId(postingId)
		}
	}
	
	private func processSinglePostingId(_ postingId: NSNumber) {
		guard !isSyncPostingIdArr else { return }
		isSyncPostingIdArr = true
		
		var mainFeeds = NSMutableArray()
		
		// Process each feed type
		processCocciControlFeeds(postingId: postingId, mainFeeds: &mainFeeds)
		processAntibioticFeeds(postingId: postingId, mainFeeds: &mainFeeds)
		processAlternativeFeeds(postingId: postingId, mainFeeds: &mainFeeds)
		processMycotoxinFeeds(postingId: postingId, mainFeeds: &mainFeeds)
		
		// Add to session array
		let sessionDict = ["sessionId": postingId, "Feeds": mainFeeds]
		sessionArray.add(sessionDict)
	}
	
	// MARK: - Feed Type Processing
	private func processCocciControlFeeds(postingId: NSNumber, mainFeeds: inout NSMutableArray) {
		let cocciControls = CoreDataHandler().fetchAllCocciControlviaIsync(true, postinID: postingId)
		var feedDetails = NSMutableArray()
		var currentFeed: NSMutableDictionary?
		
		for (index, control) in cocciControls.enumerated() {
			guard let cocciControl = control as? CoccidiosisControlFeed else { continue }
			
			let feedDict = createFeedDict(from: cocciControl, categoryId: FeedProgramConstants.feedProgramCategoryIds["cocci"]!)
			feedDetails.add(feedDict)
			
			if (index + 1) % FeedProgramConstants.batchSizes["cocci"]! == 0 {
				currentFeed = createFeedSummary(from: cocciControl, details: feedDetails)
				mainFeeds.add(currentFeed!)
				feedDetails = NSMutableArray()
			}
		}
	}
	
	private func processAntibioticFeeds(postingId: NSNumber, mainFeeds: inout NSMutableArray) {
		let antibiotics = CoreDataHandler().fetchAntiboticViaIsSync(true, postingID: postingId)
		var feedDetails = NSMutableArray()
		var currentFeed: NSMutableDictionary?
		
		for (index, antibiotic) in antibiotics.enumerated() {
			guard let antibioticFeed = antibiotic as? AntiboticFeed else { continue }
			
			let feedDict = createFeedDict(from: antibioticFeed, categoryId: FeedProgramConstants.feedProgramCategoryIds["antibiotic"]!)
			feedDetails.add(feedDict)
			
			if (index + 1) % FeedProgramConstants.batchSizes["antibiotic"]! == 0 {
				currentFeed = createFeedSummary(from: antibioticFeed, details: feedDetails)
				mainFeeds.add(currentFeed!)
				feedDetails = NSMutableArray()
			}
		}
	}
	
	private func processAlternativeFeeds(postingId: NSNumber, mainFeeds: inout NSMutableArray) {
		let alternatives = CoreDataHandler().fetchAlternativeFeedWithIsSync(true, postingID: postingId)
		var feedDetails = NSMutableArray()
		var currentFeed: NSMutableDictionary?
		
		for (index, alternative) in alternatives.enumerated() {
			guard let alternativeFeed = alternative as? AlternativeFeed else { continue }
			
			let feedDict = createFeedDict(from: alternativeFeed, categoryId: FeedProgramConstants.feedProgramCategoryIds["alternative"]!)
			feedDetails.add(feedDict)
			
			if (index + 1) % FeedProgramConstants.batchSizes["alternative"]! == 0 {
				currentFeed = createFeedSummary(from: alternativeFeed, details: feedDetails)
				mainFeeds.add(currentFeed!)
				feedDetails = NSMutableArray()
			}
		}
	}
	
	private func processMycotoxinFeeds(postingId: NSNumber, mainFeeds: inout NSMutableArray) {
		let mycotoxins = CoreDataHandler().fetchMyBindersViaIsSync(true, postingID: postingId)
		var feedDetails = NSMutableArray()
		var currentFeed: NSMutableDictionary?
		
		for (index, mycotoxin) in mycotoxins.enumerated() {
			guard let mycotoxinFeed = mycotoxin as? MyCotoxinBindersFeed else { continue }
			
			let feedDict = createFeedDict(from: mycotoxinFeed, categoryId: FeedProgramConstants.feedProgramCategoryIds["mycotoxin"]!)
			feedDetails.add(feedDict)
			
			if (index + 1) % FeedProgramConstants.batchSizes["mycotoxin"]! == 0 {
				currentFeed = createFeedSummary(from: mycotoxinFeed, details: feedDetails)
				mainFeeds.add(currentFeed!)
				feedDetails = NSMutableArray()
			}
		}
	}
	
	// MARK: - Feed Dictionary Creation
	private func createFeedDict<T: FeedProtocol>(from feed: T, categoryId: Int) -> NSMutableDictionary {
		let dict = NSMutableDictionary()
		dict.setValue(feed.dosage, forKey: "dose")
		dict.setValue(feed.feedId, forKey: "feedId")
		dict.setValue(feed.feedProgram, forKey: "feedName")
		dict.setValue(feed.fromDays, forKey: "durationFrom")
		dict.setValue(feed.molecule, forKey: "molecule")
		dict.setValue(feed.toDays, forKey: "durationTo")
		dict.setValue(categoryId, forKey: "feedProgramCategoryId")
		dict.setValue(0, forKey: "moleculeId")
		dict.setValue(feed.feedType, forKey: "feedType")
		return dict
	}
	
	private func createFeedSummary<T: FeedProtocol>(from feed: T, details: NSMutableArray) -> NSMutableDictionary {
		return [
			"feedName": feed.feedProgram ?? "",
			"feedId": feed.feedId ?? 0,
			"startDate": feed.feedDate ?? "",
			"feedProgramDetails": details
		]
	}
    // MARK: 🟢******************* Save Add Vacination data On Server ***************************/
    /**************************************************************************/
	// MARK: - Vaccination Constants
	private struct VaccinationConstants {
		static let routeIds: [String: [String: Int]] = [
			"4": [ // Portuguese
				Constants.spray: 21,
				Constants.inOvoStr: 22,
				"Intramuscular": 24,
				Constants.aguaDeBebida: 20,
				"Membrana Da Asa": 19,
				"Ocular": 25,
				Constants.Subcutânea: 23
				 ],
			"default": [ // English
				Constants.wingWeb: 1,
				Constants.drinkingWater: 2,
				Constants.spray: 3,
				Constants.inOvoStr: 4,
				"Subcutaneous": 5,
				"Intramuscular": 6,
				Constants.eveDrop: 7
					   ]
		]
	}
	
	// MARK: - Vaccination Sync
	func addVaccination() {
		let (postingSessions, necropsyData) = fetchSyncData()
		let postingIds = preparePostingIds(postingSessions: postingSessions, necropsyData: necropsyData)
		processVaccinationData(postingIds: postingIds)
	}
	
	// MARK: - Vaccination Processing
	private func processVaccinationData(postingIds: NSMutableArray) {
		let sessionArr = NSMutableArray()
		let sessionDictWithVac = NSMutableDictionary()
		
		for postingId in postingIds {
			guard let postingId = postingId as? NSNumber else { continue }
			processSinglePostingVaccination(postingId: postingId, sessionArr: sessionArr, sessionDict: sessionDictWithVac)
		}
	}
	
	private func processSinglePostingVaccination(postingId: NSNumber, sessionArr: NSMutableArray, sessionDict: NSMutableDictionary) {
		guard !isSyncPostingIdArr else { return }
		isSyncPostingIdArr = true
		
		let vaccinationDetail = NSMutableDictionary()
		
		// Process field vaccinations
		processFieldVaccinations(postingId: postingId, vaccinationDetail: vaccinationDetail)
		
		// Process hatchery vaccinations
		processHatcheryVaccinations(postingId: postingId, vaccinationDetail: vaccinationDetail)
		
		// Add to session array
		let sessionDict = ["sessionId": postingId, "VaccinationDetails": vaccinationDetail]
		sessionArr.add(sessionDict)
	}
	
	// MARK: - Field Vaccination Processing
	private func processFieldVaccinations(postingId: NSNumber, vaccinationDetail: NSMutableDictionary) {
		let fieldVaccinations = CoreDataHandler().fetchFieldAddvacinationDataWithisSyncTrue(postingId, isSync: true)
		
		for (index, vaccination) in fieldVaccinations.enumerated() {
			guard let fieldVaccination = vaccination as? FieldVaccination,
				  let routeName = fieldVaccination.route,
				  let strain = fieldVaccination.strain else { continue }
			
			let routeId = getRouteId(for: routeName, languageId: fieldVaccination.lngId)
			
			let strainKey = "hatcheryStrain\(index + 1)"
			let routeKey = "hatcheryRoute\(index + 1)Id"
			
			vaccinationDetail.setObject(strain, forKey: strainKey as NSCopying)
			vaccinationDetail.setObject(routeId, forKey: routeKey as NSCopying)
		}
	}
	
	// MARK: - Hatchery Vaccination Processing
	private func processHatcheryVaccinations(postingId: NSNumber, vaccinationDetail: NSMutableDictionary) {
		let hatcheryVaccinations = CoreDataHandler().fetchAddvacinationDataWithisSync(postingId, isSync: true)
		
		for (index, vaccination) in hatcheryVaccinations.enumerated() {
			guard let hatcheryVaccination = vaccination as? HatcheryVac,
				  let routeName = hatcheryVaccination.route,
				  let strain = hatcheryVaccination.strain,
				  let age = hatcheryVaccination.age else { continue }
			
			let routeId = getRouteId(for: routeName, languageId: hatcheryVaccination.lngId)
			
			let fieldStrainKey = "fieldStrain\(index + 1)"
			let fieldRouteKey = "fieldRoute\(index + 1)Id"
			let fieldAgeKey = "fieldAge\(index + 1)"
			
			vaccinationDetail.setObject(strain, forKey: fieldStrainKey as NSCopying)
			vaccinationDetail.setObject(routeId, forKey: fieldRouteKey as NSCopying)
			vaccinationDetail.setObject(age, forKey: fieldAgeKey as NSCopying)
		}
	}
	
	// MARK: - Route ID Helper
	private func getRouteId(for routeName: String, languageId: NSNumber?) -> NSNumber {
		let languageKey = languageId?.stringValue == "4" ? "4" : "default"
		let routeId = VaccinationConstants.routeIds[languageKey]?[routeName] ?? 0
		return NSNumber(value: routeId)
	}
    
    // MARK: 🟢 ******************* Save Posting data On Server ***************************/
    
    fileprivate func handleSessionTyoeId(_ sessiontype: String?, _ sessionTypeId: inout Int) {
        if sessiontype == "Farm Visit" {
            sessionTypeId = 2
        } else if  sessiontype == "Visite De Ferme" {
            sessionTypeId = 3
        } else if  sessiontype ==  "Visite De Publication" {
            sessionTypeId = 4
        } else if sessiontype == "Posting Visit" {
            sessionTypeId = 1
        } else if  sessiontype ==  "Visita Em Andamento" {
            sessionTypeId = 5
        } else if  sessiontype ==  "Visita Na Unidade" {
            sessionTypeId = 6
        } else {
            sessionTypeId = 0
        }
    }
    
    fileprivate func handleVetUserId(_ vetUserId: NSNumber?, _ birdTypeId: inout Int) {
        if vetUserId == 0 {
            birdTypeId = 0
        } else {
            birdTypeId = 1
        }
    }
    
    fileprivate func handlePostingArrWithAllData(_ lngId: Int, _ postingServerArray: NSMutableArray) {
        for i in 0..<postingArrWithAllData.count {
            if isSyncPostingArrWithData == false {
                isSyncPostingArrWithData = true
                let postingDataDict = NSMutableDictionary()
                let pSession = postingArrWithAllData.object(at: i) as! PostingSession
                let sessionDate = pSession.sessiondate
                var sessionTypeId  = Int ()
                let sessiontype = pSession.sessionTypeName
                
                handleSessionTyoeId(sessiontype, &sessionTypeId)
                let customerId = pSession.customerId
                let complexId = pSession.complexId
                let customerRep = pSession.customerRepName
                let vetUserId = pSession.veterinarianId
                var birdTypeId = 0
                handleVetUserId(vetUserId, &birdTypeId)
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
                let timestamp = pSession.timeStamp
                let proName = pSession.productionTypeName
                let proId = pSession.productionTypeId
                
                let avgAGe = (pSession.avgAge ?? "") as String
                let avgWght = (pSession.avgWeight ?? "") as String
                let outTime = (pSession.outTime ?? "") as String
                let fcr = (pSession.fcr ?? "") as String
                let livability = (pSession.livability ?? "") as String
                let mortality = (pSession.dayMortality ?? "") as String
                
                self.postingIdArr.add(sessionId!)
             
               
                
                let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier")! as! String
                _ =   timestamp! + "_" + String(describing: sessionId!)
                
                var fullData = timestamp!
                postingDataDict.setValue(finalize, forKey: "finalized")
                postingDataDict.setValue(sessionDate, forKey: "sessionDate")
                postingDataDict.setValue(lngId, forKey: "LanguageId")
                postingDataDict.setValue(sessionTypeId, forKey: "sessionTypeId")
                postingDataDict.setValue(customerId, forKey: "customerId")
                postingDataDict.setValue(complexId, forKey: "complexId")
                postingDataDict.setValue(fullData, forKey: "deviceSessionId")
                postingDataDict.setValue(customerRep, forKey: "customerRep")
                postingDataDict.setValue(vetUserId, forKey: "vetUserId")
                postingDataDict.setValue(salesUserId, forKey: "salesUserId")
                postingDataDict.setValue(cocciProgramId, forKey: "cocciProgramId")
                postingDataDict.setValue(breedName, forKey: "breedName")
                postingDataDict.setValue(birdTypeId, forKey: "birdTypeId")
                postingDataDict.setValue(notes, forKey: "notes")
                postingDataDict.setValue(maleBreedName, forKey: "maleBreedName")
                postingDataDict.setValue(femaleBreedName, forKey: "femaleBreedName")
                postingDataDict.setValue(birdSize, forKey: "birdSize")
                postingDataDict.setValue(catptureNec, forKey: "catptureNec")
                postingDataDict.setValue(cociiProgramName, forKey: "cociiProgramName")
                postingDataDict.setValue(sessionId, forKey: "sessionId")
                postingDataDict.setValue(proId, forKey: "productionTypeId")
                postingDataDict.setValue(proName, forKey: "productionTypeName")
                let id = UserDefaults.standard.integer(forKey: "Id")
                postingDataDict.setValue(id, forKey: "UserId")
                postingDataDict.setValue(udid, forKey: "udid")
                postingDataDict.setValue(fcr, forKey: "FCR")
                postingDataDict.setValue(avgWght, forKey: "AvgWeight")
                postingDataDict.setValue(avgAGe, forKey: "AvgAge")
                postingDataDict.setValue(outTime, forKey: "AvgOutTime")
                postingDataDict.setValue(livability, forKey: "Livability")
                postingDataDict.setValue(mortality, forKey: "Avg7DayMortality")
                postingServerArray.add(postingDataDict)
            }
        }
    }
    
    fileprivate func handleCNecArr(_ cNecArr: NSArray, _ necArrWithoutPosting: NSMutableArray) {
        for j in 0..<cNecArr.count {
            let captureNecropsyData = cNecArr.object(at: j)  as! CaptureNecropsyData
            necArrWithoutPosting.add(captureNecropsyData)
            for w in 0..<necArrWithoutPosting.count - 1 {
                let c = necArrWithoutPosting.object(at: w)  as! CaptureNecropsyData
                if c.necropsyId == captureNecropsyData.necropsyId
                {
                    necArrWithoutPosting.remove(c)
                }
            }
        }
    }
    
    fileprivate func handleNecArrWithoutPosting(_ necArrWithoutPosting: NSMutableArray, _ lngId: Int, _ postingServerArray: NSMutableArray) {
        for j in 0..<necArrWithoutPosting.count {
            let postingDataDict = NSMutableDictionary()
            let pSession = necArrWithoutPosting.object(at: j) as! CaptureNecropsyData
            let sessionDate = pSession.complexDate
            let sessionTypeId : Int = 0
            let customerId = pSession.custmerId
            let complexId = pSession.complexId
            let customerRep = ""
            let vetUserId = 0
            let salesUserId = 0
            let cocciProgramId = 0
            let breedName = ""
            let notes = ""
            let maleBreedName = ""
            let femaleBreedName = ""
            let birdSize = ""
            let fcr = ""
            let avgWght = ""
            let avgAGe = ""
            let outTime = ""
            let livability = ""
            let mortality = ""
            let catptureNec = 0
            let cociiProgramName = ""
            let proId = 0
            let proName = ""
            let sessionId = pSession.necropsyId
            let finalize = false
            let TimeStamp = pSession.timeStamp
            self.postingIdArr.add(sessionId!)
           
            let udid = String()
            _ = String()
            _ = String()
            var fullData = TimeStamp!
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
            postingDataDict.setValue(notes, forKey: "notes")
            postingDataDict.setValue(maleBreedName, forKey: "maleBreedName")
            postingDataDict.setValue(femaleBreedName, forKey: "femaleBreedName")
            postingDataDict.setValue(birdSize, forKey: "birdSize")
            postingDataDict.setValue(catptureNec, forKey: "catptureNec")
            postingDataDict.setValue(cociiProgramName, forKey: "cociiProgramName")
            postingDataDict.setValue(sessionId, forKey: "sessionId")
            postingDataDict.setValue(proId, forKey: "productionTypeId")
            postingDataDict.setValue(proName, forKey: "productionTypeName")
            postingDataDict.setValue(fcr, forKey: "FCR")
            postingDataDict.setValue(avgWght, forKey: "AvgWeight")
            postingDataDict.setValue(avgAGe, forKey: "AvgAge")
            postingDataDict.setValue(outTime, forKey: "AvgOutTime")
            postingDataDict.setValue(livability, forKey: "Livability")
            postingDataDict.setValue(mortality, forKey: "Avg7DayMortality")
            let id = UserDefaults.standard.integer(forKey: "Id")
            postingDataDict.setValue(id, forKey: "UserId")
            postingDataDict.setValue(udid, forKey: "udid")
            postingDataDict.setValue(fullData, forKey: "sessionGUID")
            postingServerArray.add(postingDataDict)
        }
    }
    
    fileprivate func handleFailureResponse(_ encodingError: AFError, _ response: AFDataResponse<Any>, _ statusCode: Int?) {
        if let err = encodingError as? URLError, err.code == .notConnectedToInternet {
            self.delegeteSyncApi.failWithErrorInternal()
            
        }
        else if response.data != nil {
            if let s = statusCode {
                self.delegeteSyncApi.failWithError(statusCode: s)
            } else {
                self.delegeteSyncApi.failWithErrorInternal()
            }
        }
    }
    
    fileprivate func handleErrorStatusCodes(_ statusCode: Int?) {
        if statusCode == 401 {
            self.loginMethod()
        } else if statusCode == 500 || statusCode == 503 ||  statusCode == 403 ||  statusCode==501 || statusCode == 502 || statusCode == 400 || statusCode == 504 || statusCode == 404 || statusCode == 408 {
            self.delegeteSyncApi.failWithError(statusCode: statusCode!)
        }
    }
    
    func savePostingDataOnServer() {
        let lngId = UserDefaults.standard.integer(forKey: "lngId")
        postingArrWithAllData = CoreDataHandler().fetchAllPostingSessionWithisSyncisTrue(true).mutableCopy() as! NSMutableArray
        
        self.postingIdArr.removeAllObjects()
        let postingServerArray = NSMutableArray()
        let  postingDictOnServer = NSMutableDictionary()
        handlePostingArrWithAllData(lngId, postingServerArray)
        
        let cNecArr = CoreDataHandler().FetchNecropsystep1WithisSync(true)
        let necArrWithoutPosting = NSMutableArray()
        handleCNecArr(cNecArr, necArrWithoutPosting)
        
        handleNecArrWithoutPosting(necArrWithoutPosting, lngId, postingServerArray)
        postingDictOnServer.setValue(postingServerArray, forKey: "PostingSessions")
        
        do {
            
            if WebClass.sharedInstance.connected() {
                let Url = "PostingSession/SaveMultiplePostingsSyncData"
                accestoken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken)!
                let headerDict = [Constants.authorization:accestoken]
                let urlString: String = WebClass.sharedInstance.webUrl + Url
                var request = URLRequest(url: URL(string: urlString)! )
                request.httpMethod = "POST"
                request.allHTTPHeaderFields = headerDict
                request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
                request.httpBody = try? JSONSerialization.data(withJSONObject: postingDictOnServer, options: [])
                
                sessionManager.request(request as URLRequestConvertible).responseJSON { response in
                    let statusCode = response.response?.statusCode
                    
                    self.handleErrorStatusCodes(statusCode)
                    
                    switch response.result {
                    case .success(let responseObject):
                        
                        self.isSyncPostingArrWithData = false
                        self.isSyncPostingIdArr = false
                        self.saveNecropsyDataOnServer()
                        
                    case .failure(let encodingError):
                        
                        self.handleFailureResponse(encodingError, response, statusCode)
                    }
                }
            }
        }
    }
    // MARK: 🟢******************* Save Farms  data On Server ***************************/
    /**************************************************************************/
    
	// MARK: - Necropsy Constants
	private struct NecropsyConstants {
		static let userIdKey = "Id"
		static let languageIdKey = "lngId"
		static let sessionKey = "Session"
		static let farmDetailsKey = "farmDetails"
		static let birdDetailsKey = "BirdDetails"
		static let birdIdKey = "BirdId"
		static let birdNotesKey = "birdNotes"
	}
	
	// MARK: - Necropsy Data Sync
	func saveNecropsyDataOnServer() {
		let necropsyData = fetchAndProcessNecropsyData()
		let postingData = fetchAndProcessPostingData()
		
		let sessionArrayNew = NSMutableArray()
        sessionArrayNew.addObjects(from: necropsyData as! [Any])
        sessionArrayNew.addObjects(from: postingData as! [Any])
		
		let sessionWithAllForms = NSMutableDictionary()
		sessionWithAllForms.setValue(sessionArrayNew, forKey: NecropsyConstants.sessionKey)
		
		sendNecropsyDataToServer(sessionWithAllForms)
	}
	
	// MARK: - Data Fetching and Processing
	private func fetchAndProcessNecropsyData() -> NSMutableArray {
		let cNecArr = CoreDataHandler().FetchNecropsystep1WithisSync(true)
		let uniqueNecropsyData = removeDuplicateNecropsyData(cNecArr)
		return processNecropsyData(uniqueNecropsyData)
	}
	
	private func fetchAndProcessPostingData() -> NSMutableArray {
		postingArrWithAllData.removeAllObjects()
		postingArrWithAllData = CoreDataHandler().fetchAllPostingSessionWithisSyncisTrue(true).mutableCopy() as! NSMutableArray
		return processPostingData(postingArrWithAllData)
	}
	
	// MARK: - Data Processing
	private func processNecropsyData(_ necropsyData: NSMutableArray) -> NSMutableArray {
		let processSessionArray = NSMutableArray()
		
		for data in necropsyData {
			guard let captureNecropsyData = data as? CaptureNecropsyData,
				  let necropsyId = captureNecropsyData.necropsyId else { continue }
			
			let farmDetails = processFarmDetails(for: necropsyId)
			let sessionDict = createSessionDict(
				sessionId: necropsyId,
				timestamp: captureNecropsyData.timeStamp,
				complexId: captureNecropsyData.complexId,
				complexDate: captureNecropsyData.complexDate,
				farmDetails: farmDetails
			)
			
            processSessionArray.add(sessionDict)
		}
		
		return processSessionArray
	}
	
	private func processPostingData(_ postingData: NSMutableArray) -> NSMutableArray {
		let sessionNewArray = NSMutableArray()
		
		if !isSyncPostingArrWithData {
			isSyncPostingArrWithData = true
			
			for data in postingData {
				guard let postingSession = data as? PostingSession,
					  let postingId = postingSession.postingId else { continue }
				
				let farmDetails = processFarmDetails(for: postingId)
				let sessionDict = createSessionDict(
					sessionId: postingId,
					timestamp: postingSession.timeStamp,
					complexId: postingSession.complexId,
					complexDate: postingSession.sessiondate,
					farmDetails: farmDetails
				)
				
                sessionNewArray.add(sessionDict)
			}
		}
		
		return sessionNewArray
	}
	
	private func processFarmDetails(for sessionId: NSNumber) -> NSMutableArray {
		let farmDetails = NSMutableArray()
		let necropsyData = CoreDataHandler().FetchNecropsystep1WithisSyncandPostingId(true, postingId: sessionId)
		
		for data in necropsyData {
			guard let captureNecropsyData = data as? CaptureNecropsyData,
				  let farmName = captureNecropsyData.farmName,
				  let noOfBirds = captureNecropsyData.noOfBirds else { continue }
			
			let birdDetails = processBirdDetails(
				farmName: farmName,
				noOfBirds: Int(noOfBirds)!,
				necropsyId: captureNecropsyData.necropsyId
			)

            let farmInput = chickenCoreDataHandlerModels.chickenFarmInputData(
                   farmName: farmName,
                   houseNo: captureNecropsyData.houseNo,
                   noOfBirds: Int(noOfBirds)!,
                   farmId: captureNecropsyData.farmId,
                   imageId: captureNecropsyData.imageId,
                   feedProgram: captureNecropsyData.feedProgram,
                   feedId: captureNecropsyData.feedId as? Int ?? 0,
                   age: captureNecropsyData.age,
                   customerId: captureNecropsyData.custmerId,
                   customerName: captureNecropsyData.complexName,
                   sick: "\(captureNecropsyData.sick ?? 0)",
                   flockId: (captureNecropsyData.flockId != nil) ? NSNumber(value: Int(captureNecropsyData.flockId!) ?? 0) : nil,
                   complexDate: captureNecropsyData.complexDate,
                   birdDetails: birdDetails
            )
			
			farmDetails.add(farmInput)
		}
		
		return farmDetails
	}
	
	private func processBirdDetails(farmName: String, noOfBirds: Int, necropsyId: NSNumber?) -> NSMutableArray {
		let birdArray = NSMutableArray()
		
		for birdNumber in 1...noOfBirds {
			let birdNumberNS = NSNumber(value: birdNumber)
			let observations = CoreDataHandler().fetchObsWithBirdandFarmName(farmName, birdNo: birdNumberNS, necId: necropsyId!)
			let notes = fetchBirdNotes(farmName: farmName, birdNumber: birdNumberNS, necropsyId: necropsyId)
			
			observations.setValue(birdNumber, forKey: NecropsyConstants.birdIdKey)
			observations.setValue(notes, forKey: NecropsyConstants.birdNotesKey)
			
			birdArray.add(observations)
		}
		
		return birdArray
	}
	
	private func fetchBirdNotes(farmName: String, birdNumber: NSNumber, necropsyId: NSNumber?) -> String {
		let notes = CoreDataHandler().fetchNotesWithBirdNumandFarmName(birdNumber, formName: farmName, necId: necropsyId!)
		return (notes.firstObject as? NotesBird)?.notes ?? ""
	}
	
	// MARK: - Dictionary Creation
	private func createSessionDict(sessionId: NSNumber, timestamp: String?, complexId: NSNumber?, complexDate: String?, farmDetails: NSMutableArray) -> NSMutableDictionary {
		let dict = NSMutableDictionary()
		dict.setValue(sessionId, forKey: "SessionId")
		dict.setValue(UserDefaults.standard.integer(forKey: NecropsyConstants.languageIdKey), forKey: "LanguageId")
		dict.setValue(timestamp, forKey: "deviceSessionId")
		dict.setValue(complexId, forKey: "ComplexId")
		dict.setValue(complexDate, forKey: "sessionDate")
		dict.setValue(farmDetails, forKey: NecropsyConstants.farmDetailsKey)
		dict.setValue(UserDefaults.standard.integer(forKey: NecropsyConstants.userIdKey), forKey: "UserId")
		return dict
	}
	
    private func createFarmDict(from input: chickenCoreDataHandlerModels.chickenFarmInputData) -> NSMutableDictionary {
        let dict = NSMutableDictionary()
        dict.setValue(input.birdDetails, forKey: NecropsyConstants.birdDetailsKey)
        dict.setValue(input.farmName, forKey: "farmName")
        dict.setValue(input.houseNo, forKey: "houseNo")
        dict.setValue(input.noOfBirds, forKey: "birds")
        dict.setValue(input.farmId, forKey: "SortId")
        dict.setValue(input.imageId, forKey: "ImgId")
        dict.setValue(input.feedProgram, forKey: "feedProgram")
        dict.setValue(input.feedId, forKey: "DeviceFeedId")
        dict.setValue(input.age, forKey: "age")
        dict.setValue(input.customerId, forKey: "customerId")
        dict.setValue(input.customerName, forKey: "customerName")
        dict.setValue(input.sick, forKey: "sick")
        dict.setValue(input.flockId, forKey: "flockId")
        dict.setValue(input.complexDate, forKey: "ComplexDate")
        return dict
    }

    
	
	// MARK: - Server Communication
	private func sendNecropsyDataToServer(_ data: NSMutableDictionary) {
		guard WebClass.sharedInstance.connected(),
			  let accessToken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken) else { return }
		
		let headerDict = [Constants.authorization: accessToken]
		let urlString = WebClass.sharedInstance.webUrl + "PostingSession/SaveMultipleNecropsySyncData"
		
		var request = URLRequest(url: URL(string: urlString)!)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = headerDict
		request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
		} catch {
			print("Error serializing data: \(error)")
			return
		}
		
		sessionManager.request(request as URLRequestConvertible).responseJSON { [weak self] response in
			guard let self = self else { return }
			
			if let statusCode = response.response?.statusCode {
				self.handleServerResponse(statusCode: statusCode)
			}
		}
	}
	
	private func handleServerResponse(statusCode: Int) {
		switch statusCode {
			case 401:
				loginMethod()
			case 500, 503, 403, 501, 502, 400, 504, 404, 408:
				delegeteSyncApi.failWithError(statusCode: statusCode)
			default:
				break
		}
	}
	
    // MARK: 🟢******************* Save Image  On Server ***************************/
    /**************************************************************************/
   
	// MARK: - Image Sync Constants
	private struct ImageSyncConstants {
		static let sessionsKey = "Sessions"
		static let imageDetailsKey = "ImageDetails"
		static let farmNameKey = "farmName"
		static let birdNumberKey = "birdNumber"
		static let categoryNameKey = "categoryName"
		static let observationIdKey = "observationId"
		static let imagesKey = "images"
		static let imageKey = "Image"
		static let deviceSessionIdKey = "deviceSessionId"
		static let userIdKey = "UserId"
		
		static let categories = ["skeltaMuscular", "Coccidiosis", "GITract", "Resp", "Immune"]
	}
	
	// MARK: - Image Sync
	func saveObservationImageOnServer() {
		let imageArrWithIsyncIsTrue = CoreDataHandler().fecthPhotoWithiSynsTrue(true)
		guard imageArrWithIsyncIsTrue.count > 0 else { return }
		
		let (necropsySessions, postingSessions) = fetchAllSessions()
		let sessionArrayObs = processAllSessions(necropsySessions: necropsySessions, postingSessions: postingSessions)
		
		let sessionDict = NSMutableDictionary()
		sessionDict.setValue(sessionArrayObs, forKey: ImageSyncConstants.sessionsKey)
		
		sendImagesToServer(sessionDict)
	}
	
	// MARK: - Session Fetching
	private func fetchAllSessions() -> (NSMutableArray, NSMutableArray) {
		let cNecArr = CoreDataHandler().FetchNecropsystep1WithisSync(true)
		let totalSession = removeDuplicateNecropsyData(cNecArr)
		
		postingArrWithAllData.removeAllObjects()
		postingArrWithAllData = CoreDataHandler().fetchAllPostingSessionWithisSyncisTrue(true).mutableCopy() as! NSMutableArray
		
		return (totalSession, postingArrWithAllData)
	}
	
	// MARK: - Session Processing
	private func processAllSessions(necropsySessions: NSMutableArray, postingSessions: NSMutableArray) -> NSMutableArray {
		let sessionArrayAllSessions = NSMutableArray()
		
		// Process necropsy sessions
		for session in necropsySessions {
			guard let captureNecropsyData = session as? CaptureNecropsyData,
				  let necropsyId = captureNecropsyData.necropsyId else { continue }
			
			let sessionDetails = processSessionDetails(
				sessionId: necropsyId,
				timestamp: captureNecropsyData.timeStamp
			)
            sessionArrayAllSessions.add(sessionDetails)
		}
		
		// Process posting sessions
		if !isSyncPostingArrWithData {
			isSyncPostingArrWithData = true
			for session in postingSessions {
				guard let postingSession = session as? PostingSession,
					  let postingId = postingSession.postingId else { continue }
				
				let sessionDetails = processSessionDetails(
					sessionId: postingId,
					timestamp: postingSession.timeStamp
				)
                sessionArrayAllSessions.add(sessionDetails)
			}
		}
		
		return sessionArrayAllSessions
	}
	
	private func processSessionDetails(sessionId: NSNumber, timestamp: String?) -> NSMutableDictionary {
		let sessionDetails = NSMutableDictionary()
		let imageDetails = processImageDetails(for: sessionId)
		
		sessionDetails.setValue(imageDetails, forKey: ImageSyncConstants.imageDetailsKey)
		sessionDetails.setValue(UserDefaults.standard.integer(forKey: ImageSyncConstants.userIdKey), forKey: ImageSyncConstants.userIdKey)
		sessionDetails.setValue(timestamp, forKey: ImageSyncConstants.deviceSessionIdKey)
		
		return sessionDetails
	}
	
	// MARK: - Image Processing
	private func processImageDetails(for sessionId: NSNumber) -> NSMutableArray {
		var imageDetails = NSMutableArray()
		let necropsyData = CoreDataHandler().FetchNecropsystep1WithisSyncandPostingId(true, postingId: sessionId)
		
		for data in necropsyData {
			guard let captureNecropsyData = data as? CaptureNecropsyData,
				  let farmName = captureNecropsyData.farmName,
				  let noOfBirds = captureNecropsyData.noOfBirds,
				  let necropsyId = captureNecropsyData.necropsyId else { continue }
			
			processFarmImages(
				farmName: farmName,
				noOfBirds: Int(noOfBirds)!,
				necropsyId: necropsyId,
				imageDetails: &imageDetails
			)
		}
		
		return imageDetails
	}
	
	private func processFarmImages(farmName: String, noOfBirds: Int, necropsyId: NSNumber, imageDetails: inout NSMutableArray) {
		for birdNumber in 1...noOfBirds {
			processBirdImages(
				farmName: farmName,
				birdNumber: birdNumber,
				necropsyId: necropsyId,
				imageDetails: &imageDetails
			)
		}
	}
	
	private func processBirdImages(farmName: String, birdNumber: Int, necropsyId: NSNumber, imageDetails: inout NSMutableArray) {
		for category in ImageSyncConstants.categories {
			let observations = CoreDataHandler().fecthobsDataWithCatnameAndFarmNameAndBirdNumber(
				NSNumber(value: birdNumber),
				farmname: farmName,
				catName: category,
				necId: necropsyId
			)
			
			processObservationImages(
				observations: observations,
				farmName: farmName,
				birdNumber: birdNumber,
				category: category,
				necropsyId: necropsyId,
				imageDetails: &imageDetails
			)
		}
	}
	
	private func processObservationImages(observations: NSArray, farmName: String, birdNumber: Int, category: String, necropsyId: NSNumber, imageDetails: inout NSMutableArray) {
		for observation in observations {
			guard let captureData = observation as? CaptureNecropsyViewData,
				  let observationId = captureData.obsID else { continue }
			
			let photos = CoreDataHandler().fecthPhotoWithCatnameWithBirdAndObservationIDandIsync(
				NSNumber(value: birdNumber),
				farmname: farmName,
				catName: category,
				Obsid: observationId,
				isSync: true,
				necId: necropsyId
			)
			
			let imageDict = createImageDict(
				farmName: farmName,
				birdNumber: birdNumber,
				category: category,
				observationId: observationId,
				photos: photos
			)
			
			imageDetails.add(imageDict)
		}
	}
	
	private func createImageDict(farmName: String, birdNumber: Int, category: String, observationId: NSNumber, photos: NSArray) -> NSMutableDictionary {
		let dict = NSMutableDictionary()
		dict.setValue(farmName, forKey: ImageSyncConstants.farmNameKey)
		dict.setValue(birdNumber, forKey: ImageSyncConstants.birdNumberKey)
		dict.setValue(category, forKey: ImageSyncConstants.categoryNameKey)
		dict.setValue(observationId, forKey: ImageSyncConstants.observationIdKey)
		
		let photoArray = processPhotos(photos)
		dict.setValue(photoArray, forKey: ImageSyncConstants.imagesKey)
		
		return dict
	}
	
	private func processPhotos(_ photos: NSArray) -> NSMutableArray {
		let photoArray = NSMutableArray()
		
		for photo in photos {
			guard let birdPhoto = photo as? BirdPhotoCapture,
				  let photoData = birdPhoto.photo else { continue }
			
			var image = UIImage(data: photoData as Data)!
			if let compressedData = image.jpeg(.lowest) {
				image = UIImage(data: compressedData)!
			}
			
			let newWidth = image.size.width / 7
			if let resizedImage = resizeImage(image, newWidth: newWidth) {
				let imageDict = NSMutableDictionary()
				imageDict.setValue(imageToNSString(resizedImage), forKey: ImageSyncConstants.imageKey)
				photoArray.add(imageDict)
			}
		}
		
		return photoArray
	}
	
	// MARK: - Server Communication
	private func sendImagesToServer(_ data: NSMutableDictionary) {
		guard WebClass.sharedInstance.connected(),
			  let accessToken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken) else { return }
		
		let headerDict = [Constants.authorization: accessToken]
		let urlString = WebClass.sharedInstance.webUrl + "PostingSession/SaveBirdImageSyncData"
		
		var request = URLRequest(url: URL(string: urlString)!)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = headerDict
		request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
		
		do {
			request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
		} catch {
			print("Error serializing data: \(error)")
			return
		}
		
		sessionManager.request(request as URLRequestConvertible).responseJSON { [weak self] response in
			guard let self = self else { return }
			
			if let statusCode = response.response?.statusCode {
				self.handleServerResponse(statusCode: statusCode, response: response)
			}
		}
	}
	
	private func handleServerResponse(statusCode: Int, response: AFDataResponse<Any>) {
		switch statusCode {
			case 401:
				loginMethod()
			case 500, 503, 403, 501, 502, 400, 504, 404, 408:
				delegeteSyncApi.failWithError(statusCode: statusCode)
			default:
				if case .success(let responseObject) = response.result {
					handleSuccessResponse(responseObject)
				}
		}
	}
	
	private func handleSuccessResponse(_ responseObject: Any) {
		isSyncPostingArrWithData = false
		isSyncPostingIdArr = false
		isDelegateCalled = false
		
		let cNecArr = CoreDataHandler().FetchNecropsystep1WithisSync(true)
		if cNecArr.count > 0 {
			if postingIdArr.count == 0 {
				updadateNacDataOnCoreData(cNecArr: cNecArr) { success in
					if success {
                        self.delegeteSyncApi.didFinishApi()
					}
				}
			} else {
				updadateDataOnCoreData(cNecArr: cNecArr) { success in
					if success {
                        self.delegeteSyncApi.didFinishApi()
					}
				}
			}
		}
	}
	
    // MARK: 🟢 Update Psting  Details
    func updadateDataOnCoreData(cNecArr: NSArray, _ completion: @escaping (_ status: Bool) -> Void) {
        guard postingIdArr.count > 0, isSyncPostingIdArr == false else {
            completion(false)
            return
        }

        isSyncPostingIdArr = true
        let pId = postingIdArr[0] as! NSNumber
        let handler = CoreDataHandler()

        let syncTasks: [(NSNumber, @escaping (Bool) -> Void) -> Void] = [
            { id, cb in handler.updateisSyncOnMyBindersViaPostingId(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnAlternativeFeedPostingid(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnAntiboticViaPostingId(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnCaptureSkeletaInDatabase(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnAllCocciControlviaPostingid(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnHetcharyVacDataWithPostingId(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncValOnFieldAddvacinationData(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnPostingSession(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnBirdPhotoCaptureDatabase(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnNotesBirdDatabase(id, isSync: false, cb) }
        ]

        func runSyncTasks(_ index: Int) {
            if index >= syncTasks.count {
                if cNecArr.count > 0 {
                    self.updadateNacDataOnCoreData(cNecArr: cNecArr) { success in
                        completion(success)
                    }
                } else {
                    completion(true)
                }
                return
            }

            let task = syncTasks[index]
            task(pId) { success in
                if success {
                    runSyncTasks(index + 1)
                } else {
                    completion(false)
                }
            }
        }

        runSyncTasks(0)
    }
    
    
    // MARK: 🟢 Update Necropsy Details
    func updadateNacDataOnCoreData(cNecArr: NSArray, _ completion: @escaping (_ status: Bool) -> Void) {
        guard cNecArr.count > 0 else {
            completion(true)
            return
        }

        processCaptureNecropsyData(cNecArr: cNecArr, at: 0, completion: completion)
    }

    private func processCaptureNecropsyData(cNecArr: NSArray, at index: Int, completion: @escaping (Bool) -> Void) {
        if index >= cNecArr.count {
            completion(true)
            return
        }

        guard let captureNecropsyData = cNecArr.object(at: index) as? CaptureNecropsyData,
              let nId = captureNecropsyData.necropsyId else {
            processCaptureNecropsyData(cNecArr: cNecArr, at: index + 1, completion: completion)
            return
        }

        runSyncTasks(forId: nId) { success in
            if success {
                self.processCaptureNecropsyData(cNecArr: cNecArr, at: index + 1, completion: completion)
            } else {
                completion(false)
            }
        }
    }

    private func runSyncTasks(forId nId: NSNumber, completion: @escaping (Bool) -> Void) {
        let handler = CoreDataHandler()

        let syncTasks: [(NSNumber, @escaping (Bool) -> Void) -> Void] = [
            { id, cb in handler.updateisSyncOnCaptureSkeletaInDatabase(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncNecropsystep1neccId(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnCaptureInDatabase(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnBirdPhotoCaptureDatabase(id, isSync: false, cb) },
            { id, cb in handler.updateisSyncOnNotesBirdDatabase(id, isSync: false, cb) }
        ]

        func runTask(at index: Int) {
            if index >= syncTasks.count {
                handler.updateisAllSyncFalseOnPostingSession(true, completion)
                return
            }

            syncTasks[index](nId) { success in
                if success {
                    runTask(at: index + 1)
                } else {
                    completion(false)
                }
            }
        }

        runTask(at: 0)
    }

    // MARK: 🟢******************* Save User Setting On Server ***************************/
    fileprivate func handleSkeletenArr(_ skeletenArr: NSMutableArray, _ lngId: Int, _ arr1: NSMutableArray) {
        for i in 0..<skeletenArr.count {
            let obsId = (skeletenArr.object(at: i) as AnyObject).value(forKey: "observationId")
            let visbility = (skeletenArr.object(at: i) as AnyObject).value(forKey: "visibilityCheck")
            let quickLink = (skeletenArr.object(at: i) as AnyObject).value(forKey: "quicklinks")
            let quicklinkIndex = (skeletenArr.object(at: i) as AnyObject).value(forKey: "quicklinkIndex")
            let Internaldict = NSMutableDictionary()
            Internaldict.setValue(obsId, forKey: "ObservationId")
            Internaldict.setValue(quickLink, forKey: "QuickLink")
            Internaldict.setValue(visbility, forKey: "Visibility")
            Internaldict.setValue(lngId, forKey: "LanguageId")
            Internaldict.setValue(quicklinkIndex, forKey: "SequenceId")
            arr1.add(Internaldict)
        }
    }
    
    fileprivate func handlecocoii(_ cocoii: NSMutableArray, _ lngId: Int, _ arr1: NSMutableArray) {
        for i in 0..<cocoii.count {
            let obsId = (cocoii.object(at: i) as AnyObject).value(forKey: "observationId")
            let visbility = (cocoii.object(at: i) as AnyObject).value(forKey: "visibilityCheck")
            let quickLink = (cocoii.object(at: i) as AnyObject).value(forKey: "quicklinks")
            let quicklinkIndex = (cocoii.object(at: i) as AnyObject).value(forKey: "quicklinkIndex")
            let Internaldict = NSMutableDictionary()
            Internaldict.setValue(obsId, forKey: "ObservationId")
            Internaldict.setValue(quickLink, forKey: "QuickLink")
            Internaldict.setValue(visbility, forKey: "Visibility")
            Internaldict.setValue(lngId, forKey: "LanguageId")
            Internaldict.setValue(quicklinkIndex, forKey: "SequenceId")
            arr1.add(Internaldict)
        }
    }
    
    fileprivate func handlegitract(_ gitract: NSMutableArray, _ lngId: Int, _ arr1: NSMutableArray) {
        for i in 0..<gitract.count {
            let obsId = (gitract.object(at: i) as AnyObject).value(forKey: "observationId")
            let visbility = (gitract.object(at: i) as AnyObject).value(forKey: "visibilityCheck")
            let quickLink = (gitract.object(at: i) as AnyObject).value(forKey: "quicklinks")
            let quicklinkIndex = (gitract.object(at: i) as AnyObject).value(forKey: "quicklinkIndex")
            let Internaldict = NSMutableDictionary()
            Internaldict.setValue(obsId, forKey: "ObservationId")
            Internaldict.setValue(quickLink, forKey: "QuickLink")
            Internaldict.setValue(visbility, forKey: "Visibility")
            Internaldict.setValue(lngId, forKey: "LanguageId")
            Internaldict.setValue(quickLink, forKey: "visibilityCheck")
            Internaldict.setValue(quicklinkIndex, forKey: "SequenceId")
            arr1.add(Internaldict)
        }
    }
    
    fileprivate func handleResp(_ resp: NSMutableArray, _ lngId: Int, _ arr1: NSMutableArray) {
        for i in 0..<resp.count {
            let obsId = (resp.object(at: i) as AnyObject).value(forKey: "observationId")
            let visbility = (resp.object(at: i) as AnyObject).value(forKey: "visibilityCheck")
            let quickLink = (resp.object(at: i) as AnyObject).value(forKey: "quicklinks")
            let quicklinkIndex = (resp.object(at: i) as AnyObject).value(forKey: "quicklinkIndex")
            let Internaldict = NSMutableDictionary()
            Internaldict.setValue(obsId, forKey: "ObservationId")
            Internaldict.setValue(quickLink, forKey: "QuickLink")
            Internaldict.setValue(visbility, forKey: "Visibility")
            Internaldict.setValue(lngId, forKey: "LanguageId")
            Internaldict.setValue(quicklinkIndex, forKey: "SequenceId")
            arr1.add(Internaldict)
        }
    }
    
    fileprivate func handleimmu(_ immu: NSMutableArray, _ lngId: Int, _ arr1: NSMutableArray) {
        for i in 0..<immu.count {
            let obsId = (immu.object(at: i) as AnyObject).value(forKey: "observationId")
            let visbility = (immu.object(at: i) as AnyObject).value(forKey: "visibilityCheck")
            let quickLink = (immu.object(at: i) as AnyObject).value(forKey: "quicklinks")
            let quicklinkIndex = (immu.object(at: i) as AnyObject).value(forKey: "quicklinkIndex")
            let Internaldict = NSMutableDictionary()
            Internaldict.setValue(obsId, forKey: "ObservationId")
            Internaldict.setValue(quickLink, forKey: "QuickLink")
            Internaldict.setValue(visbility, forKey: "Visibility")
            Internaldict.setValue(lngId, forKey: "LanguageId")
            Internaldict.setValue(quicklinkIndex, forKey: "SequenceId")
            arr1.add(Internaldict)
        }
    }
    
    fileprivate func handleSaveUserSettingResponse(_ response: AFDataResponse<Any>, _ statusCode: Int?) {
        switch response.result {
            
        case .success(let responseObject):
            debugPrint(responseObject)
            
        case .failure(let encodingError):
            
            if let err = encodingError as? URLError, err.code == .notConnectedToInternet {
                self.delegeteSyncApi.failWithErrorInternal()
            } else if response.data != nil {
                
            
                debugPrint("error found.")
                
            }
        }
    }
    
    fileprivate func handleSaveUserSettingErrorStatusCode(_ statusCode: Int?) {
        if statusCode == 401 {
            self.loginMethod()
        } else if statusCode == 500 || statusCode == 503 ||  statusCode == 403 ||  statusCode==501 || statusCode == 502 || statusCode == 400 || statusCode == 504 || statusCode == 404 || statusCode == 408 {
            self.delegeteSyncApi.failWithError(statusCode: statusCode!)
        }
    }
    
    /**************************************************************************/
    func saveDatOnServerAllSeting() {
        
        let lngId = UserDefaults.standard.integer(forKey: "lngId")
        let outerDict = NSMutableDictionary()
        let arr1 = NSMutableArray()
        let Id = UserDefaults.standard.integer(forKey: "Id")
        outerDict.setValue(Id, forKey: "UserId")
        
        let cocoii =  CoreDataHandler().fetchAllCocoiiData().mutableCopy() as! NSMutableArray
        let gitract =  CoreDataHandler().fetchAllGITractData().mutableCopy() as! NSMutableArray
        let resp =  CoreDataHandler().fetchAllRespiratory().mutableCopy() as! NSMutableArray
        let immu =  CoreDataHandler().fetchAllImmune().mutableCopy() as! NSMutableArray
        let skeletenArr =  CoreDataHandler().fetchAllSeettingdata().mutableCopy() as! NSMutableArray
        
        handleSkeletenArr(skeletenArr, lngId, arr1)
        handlecocoii(cocoii, lngId, arr1)
        handlegitract(gitract, lngId, arr1)
        handleResp(resp, lngId, arr1)
        handleimmu(immu, lngId, arr1)
        
        outerDict.setValue(arr1, forKey: "ObservationUserDetails")
  
       
        if WebClass.sharedInstance.connected() {
            
            let Url = "Setting/SaveUserSetting"
            accestoken = AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken)!
           // accestoken = (UserDefaults.standard.value(forKey: Constants.accessToken) as? String)!
            let headerDict = [Constants.authorization:accestoken]
            let urlString: String = WebClass.sharedInstance.webUrl + Url
            var request = URLRequest(url: URL(string: urlString)! )
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headerDict
            request.setValue(Constants.applicationJson, forHTTPHeaderField: Constants.contentType)
            request.httpBody = try? JSONSerialization.data(withJSONObject: outerDict, options: [])
            
            sessionManager.request(request as URLRequestConvertible).responseJSON { response in
                let statusCode =  response.response?.statusCode
                
                self.handleSaveUserSettingErrorStatusCode(statusCode)
                
                self.handleSaveUserSettingResponse(response, statusCode)
            }
        }
    }
    // MARK: 🟠 ************* Login Method call Again  ***************************************************/
    
    func loginMethod(){
        
        if WebClass.sharedInstance.connected() {
            
            let udid = UserDefaults.standard.value(forKey: "ApplicationIdentifier")!
            let userName = PasswordService.shared.getUsername()
            let pass = PasswordService.shared.getPassword()
            let Url = "Token"
            let urlString: String = WebClass.sharedInstance.webUrl + Url
            let header = HTTPHeaders([HTTPHeader(name: Constants.contentType, value: "application/x-www-form-urlencoded"), HTTPHeader(name: "Accept", value: Constants.applicationJson)])
            let parameters:[String:String] = ["grant_type": "password","UserName" : CryptoHelper.encrypt(input: userName) , "Password" : CryptoHelper.encrypt(input: pass) as! String,"LoginType": "Web","DeviceId":udid as! String]
            sessionManager.request(urlString, method: .post,parameters: parameters, headers: header).responseJSON { response in
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
//                        UserDefaults.standard.set(aceesTokentype,forKey: Constants.accessToken)
//                        UserDefaults.standard.synchronize()
                        self.feedprogram()
                    }
                    break
                case let .failure(error):
                    print(error.localizedDescription)
                    break
                }
            }
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

