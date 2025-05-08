//
//  GI_Tract_Modal.swift
//  Zoetis -Feathers
//
//  Created by "" on 01/12/16.
//  Copyright © NOT_EXIST16 "". All rights reserved.
//


import UIKit

@objc protocol GI_TtactDelegate {
    func didFinishWithParsing(finishedArray : NSArray)
    @objc optional func didFinishWithParsingWithFarmData(_ finishedArray : NSArray)
    @objc optional func didFinishParsingWithAllSummaryData(_ finishedArray : NSArray)
    @objc optional func didFinishWithParsingWithEimeriaAcervulinaGross(_ finishedArray : NSArray)
    @objc optional func didFinishWithParsingMaximaGross(_ finishedArray : NSArray)
    @objc optional func didFinishWithParsingMaximaMicro(_ finishedArray : NSArray)
    @objc optional func didFinishWithParsingTenellaGross(_ finishedArray : NSArray)
    @objc optional func didFinishWithParsingAirSac(_ finishedArray : NSArray, birds: Float)
    @objc optional func didFinishWithParsingBursaSize(_ bursaTotal : Float)
}

class GI_Tract_Modal: NSObject {

    var delegate: GI_TtactDelegate?
    
    let NOT_EXIST: Float = -1
    
    func setupData(_ aArray : NSArray , birdsCount : Float , catName : NSString) {
        
        if catName == "Gi_tract" {
            self.forGi_tract(aArray, birdsCount: birdsCount)
        }
        if catName == "Gi_tractTr" {
            self.forGi_tractTr(aArray, birdsCount: birdsCount)
        }
        else if catName == "immune"{
            self.forImmune(aArray, birdsCount: birdsCount)
        }
        else if catName == "immuneTr"{
            self.forImmuneTr(aArray, birdsCount: birdsCount)
        }
        else if catName == "resp"{
            self.forResp(aArray, birdsCount: birdsCount)
        }
        else if catName == "respTr"{
            self.forRespTr(aArray, birdsCount: birdsCount)
        }
        else if catName == "skeltaMuscular"{
            self.forSkeleton(aArray, birdsCount: birdsCount)
        }
        else if catName == "skeltaMuscularTr"{
            self.forSkeletonTr(aArray, birdsCount: birdsCount)
        }
        else if catName == "Coccidiosis"{
            self.forCocciSummuary(aArray, birdsCount: birdsCount)
        }
        else if catName == "AllSummary"{
            self.allSummaryPDF(aArray, birdsCount: birdsCount)
        }
    }
    
    func setupMeanBursaSize(_ aArray : NSArray , birdsCount : Float , catName : NSString) {
        
        var Bursa_Size : Float = 0.0
    
        for  j in 0..<aArray.count
        {
            if ((aArray.object(at: j) as AnyObject).value(forKey: "catName") as! NSString == "Immune" &&
                (aArray.object(at: j) as AnyObject).value(forKey: "lngId") as! Int == Regions.languageID) &&
                (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 58 {

                let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
                Bursa_Size = Bursa_Size + value.floatValue
            }

            
        }
        if Bursa_Size == 0 {
            delegate?.didFinishWithParsingBursaSize!(4)
        }else{
         delegate?.didFinishWithParsingBursaSize!(Bursa_Size/birdsCount)
        }
    }
    
    func setupCocciDataByFarm(_ aArray: NSArray, birdsCount: Float, catName: NSString) {
        var scoreData: [(refId: Int, count: Float, mean: Float, updates: Float)] = [
            (23, 0, 0, 0), // Eimeria_Acervulina_Gross
            (24, 0, 0, 0), // Eimeria_Maxima_Gross
            (25, 0, 0, 0), // Eimeria_Maxima_Micro
            (26, 0, 0, 0)  // Eimeria_Tenella_Gross
        ]
        
        var observationSet: Float = 0

        for case let entry as NSDictionary in aArray {
            guard entry["catName"] as? String == "Coccidiosis",
                  entry["lngId"] as? Int == Regions.languageID,
                  let refId = entry["refId"] as? Int,
                  let value = entry["obsPoint"] as? NSNumber else {
                continue
            }
            
            if let index = scoreData.firstIndex(where: { $0.refId == refId }) {
                let floatValue = value.floatValue
                observationSet += 1
                scoreData[index].mean += floatValue
                scoreData[index].count += (floatValue > 0 ? 1 : 0)
                if floatValue > 0 {
                    scoreData[index].updates += 1
                }
            }
        }
        
        // Prepare counts
        let preparedArray = NSMutableArray(array: scoreData.map { $0.count })
        // Prepare means
        let tempArray = NSMutableArray()
        for data in scoreData {
            let mean = data.updates > 0 ? data.mean / data.updates : 0
            let meanArray = NSMutableArray()
            meanArray.add(mean)
            tempArray.add(meanArray)
        }

        AllValidSessions.sharedInstance.meanValues.add(tempArray)
        UserDefaults.standard.set(AllValidSessions.sharedInstance.meanValues, forKey: "meanArray")
        delegate?.didFinishWithParsingWithFarmData?(preparedArray)
    }
    
    func setupEimeriaAcervulinaGross(_ aArray : NSArray , birdsCount : Float , catName : NSString) {
        
        let preparedArray = NSMutableArray()
        
        var Eimeria_Acervulina_Gross0 : Float = 0
        var Eimeria_Acervulina_Gross1 : Float = 0
        var Eimeria_Acervulina_Gross2 : Float = 0
        var Eimeria_Acervulina_Gross3 : Float = 0
        var Eimeria_Acervulina_Gross4 : Float = 0
        
        for  j in 0..<aArray.count
        {
            if ((aArray.object(at: j) as AnyObject).value(forKey: "catName") as! NSString == "Coccidiosis" &&
                (aArray.object(at: j) as AnyObject).value(forKey: "lngId") as! Int == Regions.languageID) &&
                (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 23 {

                let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
                Eimeria_Acervulina_Gross0 = Eimeria_Acervulina_Gross0 + (value.floatValue == 0 ? 1 : 0)
                Eimeria_Acervulina_Gross1 = Eimeria_Acervulina_Gross1 + (value.floatValue == 1 ? 1 : 0)
                Eimeria_Acervulina_Gross2 = Eimeria_Acervulina_Gross2 + (value.floatValue == 2 ? 1 : 0)
                Eimeria_Acervulina_Gross3 = Eimeria_Acervulina_Gross3 + (value.floatValue == 3 ? 1 : 0)
                Eimeria_Acervulina_Gross4 = Eimeria_Acervulina_Gross4 + (value.floatValue == 4 ? 1 : 0)
            }

            
        }
        preparedArray.add(Eimeria_Acervulina_Gross0)
        preparedArray.add(Eimeria_Acervulina_Gross1)
        preparedArray.add(Eimeria_Acervulina_Gross2)
        preparedArray.add(Eimeria_Acervulina_Gross3)
        preparedArray.add(Eimeria_Acervulina_Gross4)
        
        delegate?.didFinishWithParsingWithEimeriaAcervulinaGross!(preparedArray)
    }
    func setupMaximaGross(_ aArray : NSArray , birdsCount : Float , catName : NSString) {
        
        let preparedArray = NSMutableArray()
        
        var Eimeria_Maxima_Gross0 : Float = 0
        var Eimeria_Maxima_Gross1 : Float = 0
        var Eimeria_Maxima_Gross2 : Float = 0
        var Eimeria_Maxima_Gross3 : Float = 0
        var Eimeria_Maxima_Gross4 : Float = 0
        
        for  j in 0..<aArray.count
        {
            if ((aArray.object(at: j) as AnyObject).value(forKey: "catName") as! NSString == "Coccidiosis" &&
                (aArray.object(at: j) as AnyObject).value(forKey: "lngId") as! Int == Regions.languageID) &&
                (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 24 {

                let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
                Eimeria_Maxima_Gross0 = Eimeria_Maxima_Gross0 + (value.floatValue == 0 ? 1 : 0)
                Eimeria_Maxima_Gross1 = Eimeria_Maxima_Gross1 + (value.floatValue == 1 ? 1 : 0)
                Eimeria_Maxima_Gross2 = Eimeria_Maxima_Gross2 + (value.floatValue == 2 ? 1 : 0)
                Eimeria_Maxima_Gross3 = Eimeria_Maxima_Gross3 + (value.floatValue == 3 ? 1 : 0)
                Eimeria_Maxima_Gross4 = Eimeria_Maxima_Gross4 + (value.floatValue == 4 ? 1 : 0)
            }

            
        }
        
        preparedArray.add(Eimeria_Maxima_Gross0)
        preparedArray.add(Eimeria_Maxima_Gross1)
        preparedArray.add(Eimeria_Maxima_Gross2)
        preparedArray.add(Eimeria_Maxima_Gross3)
        preparedArray.add(Eimeria_Maxima_Gross4)
        
        delegate?.didFinishWithParsingMaximaGross!(preparedArray)
    }
    func setupMaximaMicro(_ aArray : NSArray , birdsCount : Float , catName : NSString) {
        
        let preparedArray = NSMutableArray()
        
        var Eimeria_Maxima_Micro0 : Float = 0
        var Eimeria_Maxima_Micro1 : Float = 0
        var Eimeria_Maxima_Micro2 : Float = 0
        var Eimeria_Maxima_Micro3 : Float = 0
        var Eimeria_Maxima_Micro4 : Float = 0
        
        for  j in 0..<aArray.count
        {
            
            if ((aArray.object(at: j) as AnyObject).value(forKey: "catName") as! NSString == "Coccidiosis" &&
                (aArray.object(at: j) as AnyObject).value(forKey: "lngId") as! Int == Regions.languageID) &&
                (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 25 {

                let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
                Eimeria_Maxima_Micro0 = Eimeria_Maxima_Micro0 + (value.floatValue == 0 ? 1 : 0)
                Eimeria_Maxima_Micro1 = Eimeria_Maxima_Micro1 + (value.floatValue == 1 ? 1 : 0)
                Eimeria_Maxima_Micro2 = Eimeria_Maxima_Micro2 + (value.floatValue == 2 ? 1 : 0)
                Eimeria_Maxima_Micro3 = Eimeria_Maxima_Micro3 + (value.floatValue == 3 ? 1 : 0)
                Eimeria_Maxima_Micro4 = Eimeria_Maxima_Micro4 + (value.floatValue == 4 ? 1 : 0)
            }

            
        }
        
        preparedArray.add(Eimeria_Maxima_Micro0)
        preparedArray.add(Eimeria_Maxima_Micro1)
        preparedArray.add(Eimeria_Maxima_Micro2)
        preparedArray.add(Eimeria_Maxima_Micro3)
        preparedArray.add(Eimeria_Maxima_Micro4)
        
        delegate?.didFinishWithParsingMaximaMicro!(preparedArray)
    }
    func setupTenellaGross(_ aArray : NSArray , birdsCount : Float , catName : NSString) {
        
        let preparedArray = NSMutableArray()
        
        var Eimeria_Tenella_Gross0 : Float = 0
        var Eimeria_Tenella_Gross1 : Float = 0
        var Eimeria_Tenella_Gross2 : Float = 0
        var Eimeria_Tenella_Gross3 : Float = 0
        var Eimeria_Tenella_Gross4 : Float = 0
        
        for  j in 0..<aArray.count
        {
            if ((aArray.object(at: j) as AnyObject).value(forKey: "catName") as! NSString == "Coccidiosis" &&
                (aArray.object(at: j) as AnyObject).value(forKey: "lngId") as! Int == Regions.languageID) &&
                (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 26 {

                let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
                Eimeria_Tenella_Gross0 = Eimeria_Tenella_Gross0 + (value.floatValue == 0 ? 1 : 0)
                Eimeria_Tenella_Gross1 = Eimeria_Tenella_Gross1 + (value.floatValue == 1 ? 1 : 0)
                Eimeria_Tenella_Gross2 = Eimeria_Tenella_Gross2 + (value.floatValue == 2 ? 1 : 0)
                Eimeria_Tenella_Gross3 = Eimeria_Tenella_Gross3 + (value.floatValue == 3 ? 1 : 0)
                Eimeria_Tenella_Gross4 = Eimeria_Tenella_Gross4 + (value.floatValue == 4 ? 1 : 0)
            }

            
        }
        
        preparedArray.add(Eimeria_Tenella_Gross0)
        preparedArray.add(Eimeria_Tenella_Gross1)
        preparedArray.add(Eimeria_Tenella_Gross2)
        preparedArray.add(Eimeria_Tenella_Gross3)
        preparedArray.add(Eimeria_Tenella_Gross4)
        
        delegate?.didFinishWithParsingTenellaGross!(preparedArray)
    }
    
    func forCocciSummuary(_ aArray: NSArray, birdsCount: Float) {
        enum RefID: Int, CaseIterable {
            case acervulinaGross = 23
            case maximaGross = 24
            case maximaMicro = 25
            case tenellaGross = 26
        }

        struct EimeriaStats {
            var count: Float = 0
            var sum: Float = 0
            var updated: Float = 0
        }

        var statsMap = [RefID: EimeriaStats]()
        RefID.allCases.forEach { statsMap[$0] = EimeriaStats() }

        var observationSet: Float = 0

        for case let item as NSDictionary in aArray {
            guard
                let catName = item["catName"] as? String,
                catName == "Coccidiosis",
                let lngId = item["lngId"] as? Int,
                lngId == Regions.languageID,
                let refIdRaw = item["refId"] as? Int,
                let refId = RefID(rawValue: refIdRaw),
                let obsPoint = item["obsPoint"] as? NSNumber
            else {
                continue
            }

            let value = obsPoint.floatValue
            observationSet += 1

            var stat = statsMap[refId] ?? EimeriaStats()
            stat.sum += value
            stat.count += (value > 0 ? 1 : 0)
            if value > 0 {
                stat.updated += 1
            }
            statsMap[refId] = stat
        }

        let preparedArray: [Float] = RefID.allCases.map {
            let stat = statsMap[$0] ?? EimeriaStats()
            return birdsCount > 0 ? (stat.count / birdsCount) * 100 : 0
        }

        let preparedArrayForMean: [Float] = RefID.allCases.map {
            let stat = statsMap[$0] ?? EimeriaStats()
            return stat.updated > 0 ? stat.sum / stat.updated : 0
        }

        let meanValues = NSMutableArray(array: AllValidSessions.sharedInstance.meanValues)
        meanValues.add(preparedArrayForMean)
        AllValidSessions.sharedInstance.meanValues = meanValues

        UserDefaults.standard.set(meanValues, forKey: "meanArray")

        delegate?.didFinishWithParsing(finishedArray: NSMutableArray(array: preparedArray))
    }
    
    func increment(_ value: Float, _ target: inout Float) {
        if value > 0 {
            target += 1
        }
    }
    
    fileprivate func handleDataParamsAndValidations(_ healthDataParams: GITractDataModels.HealthDataParams) -> GITractDataModels.HealthDataParams {
        var updatedHealthDataParams = healthDataParams
        let item = updatedHealthDataParams.aArray[updatedHealthDataParams.j] as? [String: Any]
        
        guard let item = item, let refId = item["refId"] as? Int else {
            return updatedHealthDataParams
        }
        
        let obsPoint = (item["obsPoint"] as? NSNumber)?.floatValue ?? 0
        let visibility = (item["objsVisibilty"] as? NSNumber)?.floatValue ?? 0
        
        // Matching refId with appropriate health data parameters
        switch refId {
        case 1 where updatedHealthDataParams.footPadLesions != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.footPadLesions += obsPoint
        case 2 where updatedHealthDataParams.scratchedBirds != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.scratchedBirds += visibility
        case 3 where updatedHealthDataParams.cornealUlcers != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.cornealUlcers += visibility // This looks odd - likely a bug
        case 4 where updatedHealthDataParams.femoralHeadNecrosis != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.femoralHeadNecrosis += visibility
        case 5 where updatedHealthDataParams.tibialDyschondroplasia != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.tibialDyschondroplasia += obsPoint
        case 6 where updatedHealthDataParams.rickets != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.rickets += visibility
        case 7 where updatedHealthDataParams.boneStrength != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.boneStrength += obsPoint
        case 8 where updatedHealthDataParams.synovitis != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.synovitis += visibility
        case 9 where updatedHealthDataParams.infectiousProcess != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.infectiousProcess += visibility
        case 12 where updatedHealthDataParams.breastMyopathy != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.breastMyopathy += visibility
        case 14 where updatedHealthDataParams.muscularHemorrhages != updatedHealthDataParams.notExistValue:
            updatedHealthDataParams.muscularHemorrhages += visibility
        default:
            break
        }
        
        return updatedHealthDataParams
    }

    func forSkeleton(_ aArray: NSArray, birdsCount: Float) {
        let preparedArray = NSMutableArray()

        // Define observation IDs
        let observationIDs = Regions.getobservationsSkeletal(countryID: Regions.countryId)

        // Local variables instead of in-array references
        var footPadLesions: Float = observationIDs.contains(1) ? 0 : NOT_EXIST
        var scratchedBirds: Float = observationIDs.contains(2) ? 0 : NOT_EXIST
        var cornealUlcers: Float = observationIDs.contains(3) ? 0 : NOT_EXIST
        var femoralHeadNecrosis: Float = observationIDs.contains(4) ? 0 : NOT_EXIST
        var tibialDyschondroplasia: Float = observationIDs.contains(5) ? 0 : NOT_EXIST
        var rickets: Float = observationIDs.contains(6) ? 0 : NOT_EXIST
        var boneStrength: Float = observationIDs.contains(7) ? 0 : NOT_EXIST
        var synovitis: Float = observationIDs.contains(8) ? 0 : NOT_EXIST
        var infectiousProcess: Float = observationIDs.contains(9) ? 0 : NOT_EXIST
        var breastMyopathy: Float = observationIDs.contains(12) ? 0 : NOT_EXIST
        var muscularHemorrhages: Float = observationIDs.contains(14) ? 0 : NOT_EXIST

        for j in 0..<aArray.count {
            guard
                let entry = aArray.object(at: j) as? NSDictionary,
                entry["catName"] as? String == "skeltaMuscular",
                entry["lngId"] as? Int == Regions.languageID
            else {
                continue
            }
            
            let healthDataParams = GITractDataModels.HealthDataParams(
                aArray: aArray,
                j: j,
                footPadLesions: footPadLesions,
                scratchedBirds: scratchedBirds,
                cornealUlcers: cornealUlcers,
                femoralHeadNecrosis: femoralHeadNecrosis,
                tibialDyschondroplasia: tibialDyschondroplasia,
                rickets: rickets,
                boneStrength: boneStrength,
                synovitis: synovitis,
                infectiousProcess: infectiousProcess,
                breastMyopathy: breastMyopathy,
                muscularHemorrhages: muscularHemorrhages,
                notExistValue: -1 // assuming NOT_EXIST value is -1
            )

            // Call the function with the struct and get the updated struct back
            let updatedHealthDataParams = handleDataParamsAndValidations(healthDataParams)
            
        }

        // Append non-NOT_EXIST observations as percentage
        let metrics: [Float] = [
            footPadLesions, scratchedBirds, cornealUlcers, femoralHeadNecrosis,
            tibialDyschondroplasia, rickets, boneStrength, synovitis,
            infectiousProcess, breastMyopathy, muscularHemorrhages
        ]

        for metric in metrics where metric != NOT_EXIST {
            preparedArray.add((metric / birdsCount) * 100)
        }

        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    }
    
    func forSkeletonTr(_ aArray: NSArray, birdsCount: Float) {
        struct Observation {
            let refId: Int
            let usesObsPoint: Bool
        }

        let observations: [String: Observation] = [
            "Foot_Pad_Lesions": Observation(refId: 596, usesObsPoint: true),
            "Scratched_Birds": Observation(refId: 597, usesObsPoint: false),
            "Corneal_Ulcers": Observation(refId: 598, usesObsPoint: false),
            "Tibial_Dyschondroplasia": Observation(refId: 599, usesObsPoint: true),
            "Rickets": Observation(refId: 600, usesObsPoint: false),
            "Bone_Strength": Observation(refId: 601, usesObsPoint: true),
            "Synovitis": Observation(refId: 602, usesObsPoint: false),
            "Infectious_Process": Observation(refId: 603, usesObsPoint: false),
            "Woody_Breast": Observation(refId: 604, usesObsPoint: false),
            "Tibial_Head_Necrosis": Observation(refId: 605, usesObsPoint: false)
        ]

        let allowedRefIds = Set(Regions.getobservationsSkeletalTr(countryID: Regions.countryId))
        var results: [String: Float] = [:]

        // Initialize with 0 if observation is allowed, NOT_EXIST otherwise
        for (key, observation) in observations {
            results[key] = allowedRefIds.contains(observation.refId) ? 0 : NOT_EXIST
        }

        for case let dict as NSDictionary in aArray {
            guard
                let catName = dict["catName"] as? String,
                catName == "skeltaMuscular",
                let lngId = dict["lngId"] as? Int,
                lngId == Regions.languageID,
                let refId = dict["refId"] as? Int
            else {
                continue
            }

            guard let (key, observation) = observations.first(where: { $0.value.refId == refId }),
                  let current = results[key],
                  current != NOT_EXIST
            else {
                continue
            }

            let valueKey = observation.usesObsPoint ? "obsPoint" : "objsVisibilty"
            guard let value = dict[valueKey] as? NSNumber else { continue }

            if value.floatValue > 0 {
                results[key]! += 1
            }
        }

        let preparedArray = NSMutableArray()
        for (key, value) in results {
            if value != NOT_EXIST {
                let percent = (value / birdsCount) * 100
                preparedArray.add(percent)
            }
        }

        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    }
    
    fileprivate func handleObjRefIdAndObjsVisibilityValidation(_ aArray: NSArray, _ j: Int, _ conjunctivitis: inout Float) {
        if ((aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 49) && conjunctivitis != NOT_EXIST {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            conjunctivitis=(conjunctivitis)+(value.floatValue > 0 ? 1 : 0)
        }
    }
    
    fileprivate func handleCatNameRefIdValidation(_ aArray: NSArray, _ conjunctivitis: inout Float, _ tracheitis: inout Float, _ air_Sac: inout Float) {
        for j in 0..<aArray.count {
            if ((aArray.object(at: j) as AnyObject).value(forKey: "catName")) as! NSString == "Resp" && ((aArray.object(at: j) as AnyObject).value(forKey: "lngId")) as! Int == Regions.languageID  {
                
                handleObjRefIdAndObjsVisibilityValidation(aArray, j, &conjunctivitis)
                if ((aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 50) && tracheitis != NOT_EXIST {
                    let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
                    tracheitis=(tracheitis)+(value.floatValue > 0 ? 1 : 0)
                }
                if ((aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 51) && air_Sac != NOT_EXIST {
                    let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
                    air_Sac=(air_Sac)+(value.floatValue > 0 ? 1 : 0)
                }
            }
        }
    }
    
    func forResp(_ aArray : NSArray , birdsCount : Float) {
    
        let preparedArray = NSMutableArray()
        
        var conjunctivitis : Float = Regions.getObservationsResp(countryID: Regions.countryId).contains(49) ? 0 : NOT_EXIST
        var tracheitis : Float = Regions.getObservationsResp(countryID: Regions.countryId).contains(50) ? 0 : NOT_EXIST
        var air_Sac : Float = Regions.getObservationsResp(countryID: Regions.countryId).contains(51) ? 0 : NOT_EXIST
        
        handleCatNameRefIdValidation(aArray, &conjunctivitis, &tracheitis, &air_Sac)
        
        if conjunctivitis != NOT_EXIST{
            conjunctivitis = (conjunctivitis/birdsCount)*100
            preparedArray.add(conjunctivitis)
        }
        
        if tracheitis != NOT_EXIST{
            tracheitis = (tracheitis/birdsCount)*100
            preparedArray.add(tracheitis)
        }
        
        if air_Sac != NOT_EXIST{
            air_Sac = (air_Sac/birdsCount)*100
            preparedArray.add(air_Sac)
        }
        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    
    }
    
    func forRespTr(_ aArray: NSArray, birdsCount: Float) {
        class FloatBox {
            var value: Float
            init(_ value: Float) {
                self.value = value
            }
        }

        let preparedArray = NSMutableArray()
        let validRefs = Set(Regions.getObservationsRespTr(countryID: Regions.countryId))

        // Map of refId to (initial FloatBox, key to extract value from)
        let obsMap: [Int: (box: FloatBox, key: String)] = [
            635: (FloatBox(validRefs.contains(635) ? 0 : NOT_EXIST), "objsVisibilty"),
            636: (FloatBox(validRefs.contains(636) ? 0 : NOT_EXIST), "obsPoint"),
            637: (FloatBox(validRefs.contains(637) ? 0 : NOT_EXIST), "obsPoint"),
            638: (FloatBox(validRefs.contains(638) ? 0 : NOT_EXIST), "objsVisibilty"),
            639: (FloatBox(validRefs.contains(639) ? 0 : NOT_EXIST), "objsVisibilty"),
            640: (FloatBox(validRefs.contains(640) ? 0 : NOT_EXIST), "objsVisibilty")
        ]

        for j in 0..<aArray.count {
            guard
                let item = aArray[j] as? NSDictionary,
                item["catName"] as? String == "Resp",
                item["lngId"] as? Int == Regions.languageID,
                let refId = item["refId"] as? Int,
                let (box, key) = obsMap[refId],
                let value = item[key] as? NSNumber,
                box.value != NOT_EXIST
            else { continue }

            if value.floatValue > 0 {
                box.value += 1
            }
        }

        for (_, (box, _)) in obsMap {
            if box.value != NOT_EXIST {
                let normalized = (box.value / birdsCount) * 100
                preparedArray.add(normalized)
            }
        }

        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    }
    
    
    fileprivate func handleArrayAndConditionsValidations(_ aArray: NSArray, _ conditionMap: [String : Int], _ scores: inout [String : Float]) {
        // Loop through array and populate scores
        for item in aArray {
            guard
                let dict = item as? [String: Any],
                dict["catName"] as? String == "Immune",
                dict["lngId"] as? Int == Regions.languageID,
                let refId = (dict["refId"] as? NSNumber)?.intValue
            else { continue }
            
            for (key, expectedRefId) in conditionMap where refId == expectedRefId && scores[key] != NOT_EXIST {
                if key == "Bursa_Lesion_Score" {
                    if let val = (dict["obsPoint"] as? NSNumber)?.floatValue {
                        scores[key]! += val > 0 ? 1 : 0
                    }
                } else {
                    if let val = (dict["objsVisibilty"] as? NSNumber)?.floatValue {
                        scores[key]! += val > 0 ? 1 : 0
                    }
                }
            }
        }
    }
    
    func forImmune(_ aArray: NSArray, birdsCount: Float) {
        guard birdsCount > 0 else {
            delegate?.didFinishWithParsing(finishedArray: [])
            return
        }

        let observations = Set(Regions.getObservationsForImmune(countryID: Regions.countryId))
        let environment = Constants.Api.versionUrl
        let lngId = UserDefaults.standard.integer(forKey: "lngId")

        // Define all conditions with default refIds
        var conditionMap: [String: Int] = ["retained_Yolk": 59,
                                           "cardiovascular_Hydropericardium": 55,
                                           "Bursa_Lesion_Score": 57,
                                           "Pericarditis": 1870,
                                           "Septicemia": 1874,
                                           "Liver_Granuloma": 1875,
                                           "Active_Bursa": 1873,
                                           "Cellulitis": 1878]
        
        // Override refIds based on environment + lngId
        if environment.contains("stageapi"), lngId == 1 {
            conditionMap["Pericarditis"] = 1952
            conditionMap["Septicemia"] = 1956
            conditionMap["Liver_Granuloma"] = 1957
            conditionMap["Active_Bursa"] = 1955
            conditionMap["Cellulitis"] = 1960
        } else if !environment.contains("devapi"), lngId == 1 {
            conditionMap["Pericarditis"] = 2030
            conditionMap["Septicemia"] = 2034
            conditionMap["Liver_Granuloma"] = 2035
            conditionMap["Active_Bursa"] = 2033
            // Cellulitis uses same ID across envs (1878)
        }

        // Initialize scores
        var scores: [String: Float] = [:]
        for (key, refId) in conditionMap {
            scores[key] = observations.contains(refId) ? 0 : NOT_EXIST
        }

        handleArrayAndConditionsValidations(aArray, conditionMap, &scores)

        // Calculate percentages
        let preparedArray = NSMutableArray()
        for key in ["retained_Yolk","cardiovascular_Hydropericardium","Bursa_Lesion_Score","Pericarditis","Septicemia","Liver_Granuloma","Active_Bursa","Cellulitis"] {
            if let value = scores[key], value != NOT_EXIST {
                let percentage = (value / birdsCount) * 100
                preparedArray.add(percentage)
            }
        }
        
        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    }
    
    fileprivate func forImmuneTr(_ aArray: NSArray, birdsCount: Float) {
        let environmentIs = Constants.Api.versionUrl
        let refIdToKeyMap = getRefIdMapping(for: environmentIs)

        var values: [Int: Float] = [:]
        for (refId, _) in refIdToKeyMap {
            values[refId] = Regions.getObservationsForImmuneTr(countryID: Regions.countryId).contains(refId) ? 0 : NOT_EXIST
        }

        for case let item as NSDictionary in aArray {
            guard item["catName"] as? String == "Immune",
                  item["lngId"] as? Int == Regions.languageID,
                  let refId = item["refId"] as? Int,
                  let visibility = (item["objsVisibilty"] as? NSNumber)?.floatValue,
                  var currentVal = values[refId], currentVal != NOT_EXIST
            else { continue }

            values[refId] = (currentVal == NOT_EXIST ? 0 : currentVal) + (visibility > 0 ? 1 : 0)
        }

        let preparedArray = NSMutableArray()
        for refId in refIdToKeyMap.keys.sorted() {
            if let value = values[refId], value != NOT_EXIST {
                preparedArray.add((value / birdsCount) * 100)
            }
        }

        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    }

    private func getRefIdMapping(for environment: String) -> [Int: String] {
        var cellulitisId: Int
        if environment.contains("stageapi") {
            cellulitisId = 1960
        } else if environment.contains("devapi") {
            cellulitisId = 1878
        } else {
            cellulitisId = 2037
        }

        return [
            643: "retained_Yolk",
            641: "cardiovascular_Hydropericardium",
            645: "Splenomegaly",
            647: "CecalTonsilsHemorrhages",
            648: "Dehydration",
            649: "ThymusAtrophy",
            650: "Omphalitis",
            2036: "LiverGramnuloma",
            cellulitisId: "Cellulitis"
        ]
    }
    
    fileprivate func forGi_tract(_ aArray: NSArray, birdsCount: Float) {
        let preparedArray = NSMutableArray()
        let countryId = Regions.countryId
        let observations = Regions.getObservationsGITract(countryID: countryId)
        
        var values = initializeGiTractValues(from: observations)
        
        for case let item as NSDictionary in aArray {
            guard item["catName"] as? String == "GITract",
                  item["lngId"] as? Int == Regions.languageID,
                  let refId = item["refId"] as? Int,
                  var currentVal = values[refId], currentVal != NOT_EXIST
            else { continue }
            
            let valueToAdd = getValueToAdd(for: refId, from: item)
            values[refId] = currentVal + valueToAdd
        }
        
        for refId in giTractRefOrder {
            if let value = values[refId], value != NOT_EXIST {
                preparedArray.add((value / birdsCount) * 100)
            }
        }

        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    }
    private let giTractRefOrder: [Int] = [
        32, // enteritis
        34, // feed_Passage
        29, // gizzard_Erosions
        31, // litter_Eater
        27, // mouth_Lesions
        33, // necrotic_Enteritis
        28, // proventriculitis
        37, // roundworms
        35, // tapeworms
        38, // Thin_Intestine
        41  // Intestinal_Content
    ]

    private func initializeGiTractValues(from observations: [Int]) -> [Int: Float] {
        var values: [Int: Float] = [:]
        for refId in giTractRefOrder {
            values[refId] = observations.contains(refId) ? 0 : NOT_EXIST
        }
        return values
    }
    private func getValueToAdd(for refId: Int, from item: NSDictionary) -> Float {
        let usesObsPoint: Set<Int> = [32, 29, 28] // These use `obsPoint`, others use `objsVisibilty`
        let key = usesObsPoint.contains(refId) ? "obsPoint" : "objsVisibilty"
        guard let number = item[key] as? NSNumber else { return 0 }
        return number.floatValue > 0 ? 1 : 0
    }
    
    fileprivate func handleAndPopulateFootPadOtherData(_ aArray: NSArray, _ j: Int, _ Foot_Pad_Lesions: inout Float, _ Foot_Pad_Lesions_Mean: inout Float, _ Foot_Pad_Lesions_Updated: inout Float, _ Ammonia_Burns: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            Foot_Pad_Lesions=Foot_Pad_Lesions+(value.floatValue > 0 ? 1 : 0)
            Foot_Pad_Lesions_Mean = Foot_Pad_Lesions_Mean + value.floatValue
            if value.floatValue > 0 {
                Foot_Pad_Lesions_Updated += 1
            }
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 3 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            Ammonia_Burns=Ammonia_Burns+(value.floatValue > 0 ? 1 : 0)
        }
    }
    
    fileprivate func handleMouthLesionTrachitisData(_ aArray: NSArray, _ j: Int, _ mouth_Lesions: inout Float, _ tracheitis: inout Float, _ Tracheitis_Mean: inout Float, _ Tracheitis_Updated: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 27 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            mouth_Lesions=mouth_Lesions+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 50 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            tracheitis=tracheitis+(value.floatValue > 0 ? 1 : 0)
            Tracheitis_Mean = Tracheitis_Mean + value.floatValue
            if value.floatValue > 0 {
                Tracheitis_Updated += 1
            }
        }
    }
    
    fileprivate func handleFormoralTibialData(_ aArray: NSArray, _ j: Int, _ Femoral_Head_Necrosis: inout Float, _ Tibial_Dyschondroplasia: inout Float, _ Tibial_Dyschondroplasia_Mean: inout Float, _ Tibial_Dyschondroplasia_Updated: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 4 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            Femoral_Head_Necrosis=Femoral_Head_Necrosis+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 5 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            Tibial_Dyschondroplasia=Tibial_Dyschondroplasia+(value.floatValue > 0 ? 1 : 0)
            Tibial_Dyschondroplasia_Mean = Tibial_Dyschondroplasia_Mean + value.floatValue
            if value.floatValue > 0 {
                Tibial_Dyschondroplasia_Updated += 1
            }
        }
    }
    
    fileprivate func handleRicketsBoneStrenghtData(_ aArray: NSArray, _ j: Int, _ Rickets: inout Float, _ Bone_Strength: inout Float, _ Bone_Strength_Mean: inout Float, _ Bone_Strength_Updated: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 6 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            Rickets=Rickets+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 7 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            Bone_Strength=Bone_Strength+(value.floatValue > 0 ? 1 : 0)
            Bone_Strength_Mean = Bone_Strength_Mean + value.floatValue
            if value.floatValue > 0 {
                Bone_Strength_Updated += 1
            }
        }
    }
    
    fileprivate func handleSynovitisBursaSizeData(_ aArray: NSArray, _ j: Int, _ Synovitis: inout Float, _ Bursa_Size: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 8 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            Synovitis=Synovitis+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 58 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            Bursa_Size=Bursa_Size+value.floatValue
        }
    }
    
    fileprivate func handleIpAirSacData(_ aArray: NSArray, _ j: Int, _ IP: inout Float, _ air_Sac: inout Float, _ air_Sac_Mean: inout Float, _ air_Sac_Updated: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 9 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            IP=IP+value.floatValue
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 51 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            air_Sac=air_Sac+(value.floatValue > 0 ? 1 : 0)
            air_Sac_Mean = air_Sac_Mean + value.floatValue
            if value.floatValue > 0 {
                air_Sac_Updated += 1
            }
        }
    }
    
    fileprivate func handleRetainedYolkFeedPassageOtherData(_ aArray: NSArray, _ j: Int, _ retained_Yolk: inout Float, _ feed_Passage: inout Float, _ gizzard_Erosions: inout Float, _ gizzard_Erosions_Mean: inout Float, _ gizzard_Erosions_Updated: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 59 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            retained_Yolk=retained_Yolk+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 34 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            feed_Passage=feed_Passage+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 29 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            gizzard_Erosions=gizzard_Erosions+(value.floatValue > 0 ? 1 : 0)
            gizzard_Erosions_Mean = gizzard_Erosions_Mean + value.floatValue
            if value.floatValue > 0 {
                gizzard_Erosions_Updated += 1
            }
        }
    }
    
    fileprivate func handleEntriesMeanUpdatedData(_ dataVar: (NSArray,Int, Float),
                                                  _ enterties_Mean: inout Float,
                                                  _ enterties_Updated: inout Float,
                                                  _ litter_Eater: inout Float,
                                                  _ proventriculitis: inout Float,
                                                  _ proventriculitis_Mean: inout Float,
                                                  _ proventriculitis_Updated: inout Float) {
        let intV = dataVar.1
        if (dataVar.0.object(at: intV) as AnyObject).value(forKey: "refId") as! NSNumber == 32 {
            let value = (dataVar.0.object(at: intV) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            enterties_Mean = enterties_Mean + value.floatValue
            if value.floatValue > 0 {
                enterties_Updated += 1
            }
        }
        if (dataVar.0.object(at: intV) as AnyObject).value(forKey: "refId") as! NSNumber == 31 {
            let value = (dataVar.0.object(at: intV) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            litter_Eater=litter_Eater+(value.floatValue > 0 ? 1 : 0)
        }
        if (dataVar.0.object(at: intV) as AnyObject).value(forKey: "refId") as! NSNumber == 28 {
            let value = (dataVar.0.object(at: intV) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            proventriculitis=proventriculitis+(value.floatValue > 0 ? 1 : 0)
            proventriculitis_Mean = proventriculitis_Mean + value.floatValue
            if value.floatValue > 0 {
                proventriculitis_Updated += 1
            }
        }
    }
    
    fileprivate func handleRoundWormsTapeWormsData(_ aArray: NSArray, _ j: Int, _ roundworms: inout Float, _ tapeworms: inout Float, _ Intestinal_Content: inout Float, _ Thin_Intestine: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 37 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            roundworms=roundworms+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 35 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            tapeworms=tapeworms+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 41 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            Intestinal_Content = Intestinal_Content+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 38 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            Thin_Intestine = Thin_Intestine + (value.floatValue > 0 ? 1 : 0)
        }
    }
    
    fileprivate func handleMuscularLesionScoreData(_ aArray: NSArray, _ j: Int, _ Muscular_Hemorrhages: inout Float, _ Bursa_Lesion_Score: inout Float, _ Bursa_Lesion_Score_Mean: inout Float, _ Bursa_Lesion_Score_Updated: inout Float) {
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 14 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
            Muscular_Hemorrhages = Muscular_Hemorrhages+(value.floatValue > 0 ? 1 : 0)
        }
        if (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 57 {
            let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
            Bursa_Lesion_Score = Bursa_Lesion_Score + (value.floatValue > 0 ? 1 : 0)
            Bursa_Lesion_Score_Mean = Bursa_Lesion_Score_Mean + value.floatValue
            if value.floatValue > 0 {
                Bursa_Lesion_Score_Updated += 1
            }
        }
    }
    
    fileprivate func handleStageAPIDataParams(_ dataVar:(Int,NSArray), _ j: Int, _ Pericarditis: inout Float, _ Septicemia: inout Float, _ Liver_Granuloma: inout Float, _ Active_Bursa: inout Float, _ Cellulitis: inout Float) {
        if dataVar.0 == 1 {
            if (dataVar.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1952 {
                let value = (dataVar.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Pericarditis = Pericarditis+(value.floatValue > 0 ? 1 : 0)
            }
            if (dataVar.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1956 {
                let value = (dataVar.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Septicemia = Septicemia+(value.floatValue > 0 ? 1 : 0)
            }
            if (dataVar.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1957 {
                let value = (dataVar.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Liver_Granuloma=Liver_Granuloma+(value.floatValue > 0 ? 1 : 0)
            }
            
            if (dataVar.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1955 {
                let value = (dataVar.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Active_Bursa=Active_Bursa+(value.floatValue > 0 ? 1 : 0)
            }
            
            if (dataVar.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1960 {
                let value = (dataVar.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Cellulitis=Cellulitis+(value.floatValue > 0 ? 1 : 0)
            }
        }
    }
    
    fileprivate func handleDevAPIDataParams(_ dataArr:(Int,NSArray), _ j: Int, _ Pericarditis: inout Float, _ Septicemia: inout Float, _ Liver_Granuloma: inout Float, _ Active_Bursa: inout Float, _ Cellulitis: inout Float) {
        if dataArr.0 == 1 {
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1870 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Pericarditis = Pericarditis+(value.floatValue > 0 ? 1 : 0)
            }
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1874 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Septicemia=Septicemia+(value.floatValue > 0 ? 1 : 0)
            }
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1875 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Liver_Granuloma=Liver_Granuloma+(value.floatValue > 0 ? 1 : 0)
            }
            
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1873 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Active_Bursa=Active_Bursa+(value.floatValue > 0 ? 1 : 0)
            }
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 1878 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Cellulitis=Cellulitis+(value.floatValue > 0 ? 1 : 0)
            }
        }
    }
    
    fileprivate func handleElseCaseAPIDataParams(_ dataArr:(Int,NSArray), _ j: Int, _ Pericarditis: inout Float, _ Septicemia: inout Float, _ Liver_Granuloma: inout Float, _ Active_Bursa: inout Float, _ Cellulitis: inout Float) {
        if dataArr.0 == 1 {
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 2030 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Pericarditis = Pericarditis+(value.floatValue > 0 ? 1 : 0)
            }
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 2034 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Septicemia=Septicemia+(value.floatValue > 0 ? 1 : 0)
            }
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 2035 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Liver_Granuloma=Liver_Granuloma+(value.floatValue > 0 ? 1 : 0)
            }
            
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 2033 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Active_Bursa=Active_Bursa+(value.floatValue > 0 ? 1 : 0)
            }
            if (dataArr.1.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == 2037 {
                let value = (dataArr.1.object(at: j) as AnyObject).value(forKey: "objsVisibilty") as! NSNumber
                Cellulitis=Cellulitis+(value.floatValue > 0 ? 1 : 0)
            }
        }
    }
    
    fileprivate func handleDataAsPerEnvioronments(_ data: inout GITractDataModels.EnvironmentData) {
        if data.dataVar.0.contains("stageapi") {
            handleStageAPIDataParams((data.dataVar.1, data.aArray), data.j, &data.pericarditis, &data.septicemia, &data.liverGranuloma, &data.activeBursa, &data.cellulitis)
        } else if data.dataVar.0.contains("devapi") {
            handleDevAPIDataParams((data.dataVar.1, data.aArray), data.j, &data.pericarditis, &data.septicemia, &data.liverGranuloma, &data.activeBursa, &data.cellulitis)
        } else {
            handleElseCaseAPIDataParams((data.dataVar.1, data.aArray), data.j, &data.pericarditis, &data.septicemia, &data.liverGranuloma, &data.activeBursa, &data.cellulitis)
        }
    }

    func allSummaryPDF(_ aArray : NSArray , birdsCount : Float)  {
        
        let preparedArray = NSMutableArray()
        let preparedArrayForMean = NSMutableArray()
        
        var Foot_Pad_Lesions : Float = 0
        var Ammonia_Burns : Float = 0
        var tracheitis : Float = 0
        var Femoral_Head_Necrosis : Float = 0
        var feed_Passage : Float = 0
        var gizzard_Erosions : Float = 0
        var enterties : Float = 0
        var litter_Eater : Float = 0
        var mouth_Lesions : Float = 0
        var proventriculitis : Float = 0
        var roundworms : Float = 0
        var tapeworms : Float = 0
        var Tibial_Dyschondroplasia : Float = 0
        var Rickets : Float = 0
        var Bone_Strength : Float = 0
        var Bursa_Size : Float = 0.0
        var IP : Float = 0.0
        var Synovitis : Float = 0
        var retained_Yolk : Float = 0
        var air_Sac : Float = 0
        var Intestinal_Content: Float = 0
        var Thin_Intestine: Float = 0
        var Muscular_Hemorrhages: Float = 0
        var Bursa_Lesion_Score: Float = 0
        
 
        var Cellulitis : Float = 0
        var Pericarditis : Float = 0
        var Septicemia : Float = 0
        var Liver_Granuloma : Float = 0
        var Active_Bursa : Float = 0
        
        var air_Sac_Mean : Float = 0
        var Foot_Pad_Lesions_Mean : Float = 0
        var Tracheitis_Mean : Float = 0
        var Tibial_Dyschondroplasia_Mean : Float = 0
        var gizzard_Erosions_Mean : Float = 0
        var proventriculitis_Mean : Float = 0
        var enterties_Mean : Float = 0
        var Bone_Strength_Mean : Float = 0
        var Bursa_Lesion_Score_Mean: Float = 0
        
        var air_Sac_Updated : Float = 0
        var Foot_Pad_Lesions_Updated : Float = 0
        var Tracheitis_Updated : Float = 0
        var Tibial_Dyschondroplasia_Updated : Float = 0
        var gizzard_Erosions_Updated : Float = 0
        var proventriculitis_Updated : Float = 0
        var enterties_Updated : Float = 0
        var Bone_Strength_Updated : Float = 0
        var Bursa_Lesion_Score_Updated: Float = 0
        let environmentIs = Constants.Api.versionUrl
        let  lngId = UserDefaults.standard.integer(forKey: "lngId")
      
          
        
        for j in 0..<aArray.count {
            if ((aArray.object(at: j) as AnyObject).value(forKey: "lngId")) as! Int == Regions.languageID {
                
                handleAndPopulateFootPadOtherData(aArray, j, &Foot_Pad_Lesions, &Foot_Pad_Lesions_Mean, &Foot_Pad_Lesions_Updated, &Ammonia_Burns)
                handleMouthLesionTrachitisData(aArray, j, &mouth_Lesions, &tracheitis, &Tracheitis_Mean, &Tracheitis_Updated)
                handleFormoralTibialData(aArray, j, &Femoral_Head_Necrosis, &Tibial_Dyschondroplasia, &Tibial_Dyschondroplasia_Mean, &Tibial_Dyschondroplasia_Updated)
                handleRicketsBoneStrenghtData(aArray, j, &Rickets, &Bone_Strength, &Bone_Strength_Mean, &Bone_Strength_Updated)
                handleSynovitisBursaSizeData(aArray, j, &Synovitis, &Bursa_Size)
                handleIpAirSacData(aArray, j, &IP, &air_Sac, &air_Sac_Mean, &air_Sac_Updated)
                handleRetainedYolkFeedPassageOtherData(aArray, j, &retained_Yolk, &feed_Passage, &gizzard_Erosions, &gizzard_Erosions_Mean, &gizzard_Erosions_Updated)
                handleEntriesMeanUpdatedData((aArray,j,enterties), &enterties_Mean, &enterties_Updated, &litter_Eater, &proventriculitis, &proventriculitis_Mean, &proventriculitis_Updated)
                handleRoundWormsTapeWormsData(aArray, j, &roundworms, &tapeworms, &Intestinal_Content, &Thin_Intestine)
                handleMuscularLesionScoreData(aArray, j, &Muscular_Hemorrhages, &Bursa_Lesion_Score, &Bursa_Lesion_Score_Mean, &Bursa_Lesion_Score_Updated)
                
                var data = GITractDataModels.EnvironmentData(
                    dataVar: (environmentIs, lngId),
                    aArray: aArray,
                    j: j,
                    pericarditis: Pericarditis,
                    septicemia: Septicemia,
                    liverGranuloma: Liver_Granuloma,
                    activeBursa: Active_Bursa,
                    cellulitis: Cellulitis
                )

                handleDataAsPerEnvioronments(&data)
                
                
            }
        }
        
        
        Foot_Pad_Lesions = (Foot_Pad_Lesions/birdsCount)*100
        preparedArray.add(Foot_Pad_Lesions)
        
        Ammonia_Burns = (Ammonia_Burns/birdsCount)*100
        preparedArray.add(Ammonia_Burns)
        
        mouth_Lesions = (mouth_Lesions/birdsCount)*100
        preparedArray.add(mouth_Lesions)
        
        tracheitis = (tracheitis/birdsCount)*100
        preparedArray.add(tracheitis)
        
        Femoral_Head_Necrosis = (Femoral_Head_Necrosis/birdsCount)*100
        preparedArray.add(Femoral_Head_Necrosis)
        
        Tibial_Dyschondroplasia = (Tibial_Dyschondroplasia/birdsCount)*100
        preparedArray.add(Tibial_Dyschondroplasia)
        
        Rickets = (Rickets/birdsCount)*100
        preparedArray.add(Rickets)
        
        Bone_Strength = (Bone_Strength/birdsCount)*100
        preparedArray.add(Bone_Strength)
        
        Synovitis = (Synovitis/birdsCount)*100
        preparedArray.add(Synovitis)
        
        Bursa_Size = Bursa_Size == 0 ? 4 : (Bursa_Size/birdsCount)
        preparedArray.add(Bursa_Size)
        
        IP = (IP/birdsCount)*100
        preparedArray.add(IP)
        
        air_Sac = (air_Sac/birdsCount)*100
        preparedArray.add(air_Sac)
        
        retained_Yolk = (retained_Yolk/birdsCount)*100
        preparedArray.add(retained_Yolk)
        
        litter_Eater = (litter_Eater/birdsCount)*100
        preparedArray.add(litter_Eater)
        
        gizzard_Erosions = (gizzard_Erosions/birdsCount)*100
        preparedArray.add(gizzard_Erosions)
        
        proventriculitis = (proventriculitis/birdsCount)*100
        preparedArray.add(proventriculitis)
        
        tapeworms = (tapeworms/birdsCount)*100
        preparedArray.add(tapeworms)
        
        roundworms = (roundworms/birdsCount)*100
        preparedArray.add(roundworms)
        
        feed_Passage = (feed_Passage/birdsCount)*100
        preparedArray.add(feed_Passage)
        
        enterties = (enterties/birdsCount)*100
        preparedArray.add(enterties)
        
        Intestinal_Content = (Intestinal_Content/birdsCount)*100
        preparedArray.add(Intestinal_Content)
        
        Thin_Intestine = (Thin_Intestine/birdsCount)*100
        preparedArray.add(Thin_Intestine)
        
        Muscular_Hemorrhages = (Muscular_Hemorrhages/birdsCount)*100
        preparedArray.add(Muscular_Hemorrhages)
        
        Bursa_Lesion_Score = (Bursa_Lesion_Score/birdsCount)*100
        preparedArray.add(Bursa_Lesion_Score)
        if lngId == 1 {
            Pericarditis = (Pericarditis/birdsCount)*100
            preparedArray.add(Pericarditis)
            
            Septicemia = (Septicemia/birdsCount)*100
            preparedArray.add(Septicemia)
            
            Liver_Granuloma = (Liver_Granuloma/birdsCount)*100
            preparedArray.add(Liver_Granuloma)
            
            Active_Bursa = (Active_Bursa/birdsCount)*100
            preparedArray.add(Active_Bursa)
            
            Cellulitis = (Cellulitis/birdsCount)*100
            preparedArray.add(Cellulitis)
        }
        preparedArrayForMean.add((Foot_Pad_Lesions_Mean/Foot_Pad_Lesions_Updated).isNaN ? 0 : Foot_Pad_Lesions_Mean/Foot_Pad_Lesions_Updated)
        preparedArrayForMean.add((Tracheitis_Mean/Tracheitis_Updated).isNaN ? 0 : Tracheitis_Mean/Tracheitis_Updated)
        preparedArrayForMean.add((Tibial_Dyschondroplasia_Mean/Tibial_Dyschondroplasia_Updated).isNaN ? 0 : Tibial_Dyschondroplasia_Mean/Tibial_Dyschondroplasia_Updated)
        preparedArrayForMean.add((Bone_Strength_Mean/Bone_Strength_Updated).isNaN ? 0 : Bone_Strength_Mean/Bone_Strength_Updated)
        preparedArrayForMean.add((air_Sac_Mean/air_Sac_Updated).isNaN ? 0 : air_Sac_Mean/air_Sac_Updated)
        preparedArrayForMean.add((gizzard_Erosions_Mean/gizzard_Erosions_Updated).isNaN ? 0 : gizzard_Erosions_Mean/gizzard_Erosions_Updated)
        preparedArrayForMean.add((proventriculitis_Mean/proventriculitis_Updated).isNaN ? 0 : proventriculitis_Mean/proventriculitis_Updated)
        preparedArrayForMean.add((enterties_Mean/enterties_Updated).isNaN ? 0 : enterties_Mean/enterties_Updated)
        preparedArrayForMean.add((Bursa_Lesion_Score_Mean/Bursa_Lesion_Score_Updated).isNaN ? 0 : Bursa_Lesion_Score_Mean/Bursa_Lesion_Score_Updated)
        
        AllValidSessions.sharedInstance.meanValues.add(preparedArrayForMean)
        
        delegate?.didFinishParsingWithAllSummaryData!(preparedArray)
    }
    
    
    func forGi_tractTr(_ aArray: NSArray, birdsCount: Float) {
        guard birdsCount > 0 else {
            delegate?.didFinishWithParsing(finishedArray: [])
            return
        }

        let observations = Regions.getObservationsGITractTr(countryID: Regions.countryId)
        let filtered = aArray.compactMap { $0 as? NSDictionary }
            .filter { ($0["catName"] as? String) == "GITract" && ($0["lngId"] as? Int) == Regions.languageID }

        let metrics: [(id: Int, keyPath: String, observationKey: String)] = [
            (622, "enteritis", "obsPoint"),
            (624, "feed_Passage", "objsVisibilty"),
            (619, "gizzard_Erosions", "obsPoint"),
            (621, "litter_Eater", "objsVisibilty"),
            (617, "mouth_Lesions", "objsVisibilty"),
            (623, "feedInCrop", "objsVisibilty"),
            (618, "proventriculitis", "obsPoint"),
            (627, "Content", "obsPoint"),
            (628, "Intestinal_Content", "obsPoint"),
            (625, "Thin_Intestine", "obsPoint"),
            (632, "CropMycosis", "objsVisibilty"),
            (633, "Ceca", "obsPoint"),
            (634, "Hepatomegaly", "objsVisibilty"),
            (675, "wallThickness", "objsVisibilty")
        ]

        var scores = [String: Float]()
        for metric in metrics {
            if observations.contains(metric.id) {
                scores[metric.keyPath] = 0
            }
        }

        for item in filtered {
            guard let refId = item["refId"] as? Int else { continue }
            guard let metric = metrics.first(where: { $0.id == refId }) else { continue }
            guard var currentScore = scores[metric.keyPath],
                  let value = item[metric.observationKey] as? NSNumber else { continue }

            if value.floatValue > 0 {
                scores[metric.keyPath] = currentScore + 1
            }
        }

        let preparedArray = NSMutableArray()
        for (_, value) in scores {
            let percent = (value / birdsCount) * 100
            preparedArray.add(percent)
        }

        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    }
    
    //MARK: AirSec Calculations
    
    func setupAirSec(_ aArray : NSArray , birdsCount : Float , catName : NSString, referanceID: NSNumber ) {
        
        let preparedArray = NSMutableArray()
        
        var airSec0 : Float = 0
        var airSec1 : Float = 0
        var airSec2 : Float = 0
        var airSec3 : Float = 0
        var airSec4 : Float = 0
        
        for  j in 0..<aArray.count
        {
            
            if ((aArray.object(at: j) as AnyObject).value(forKey: "catName") as! NSString == catName &&
                (aArray.object(at: j) as AnyObject).value(forKey: "lngId") as! Int == Regions.languageID) &&
                (aArray.object(at: j) as AnyObject).value(forKey: "refId") as! NSNumber == referanceID {

                let value = (aArray.object(at: j) as AnyObject).value(forKey: "obsPoint") as! NSNumber
                airSec0 = airSec0 + (value.floatValue == 0 ? 1 : 0)
                airSec1 = airSec1 + (value.floatValue == 1 ? 1 : 0)
                airSec2 = airSec2 + (value.floatValue == 2 ? 1 : 0)
                airSec3 = airSec3 + (value.floatValue == 3 ? 1 : 0)
                airSec4 = airSec4 + (value.floatValue == 4 ? 1 : 0)
            }

            
        }
        
        preparedArray.add(airSec0)
        preparedArray.add(airSec1)
        preparedArray.add(airSec2)
        preparedArray.add(airSec3)
        preparedArray.add(airSec4)
        
        delegate?.didFinishWithParsingAirSac?(preparedArray, birds: birdsCount)
    }
}
