//
//  MIcroscopyCalculations.swift
//  Zoetis -Feathers
//
//  Created by Pradeep Dahiya on 12/06/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit

@objc protocol MicroscopyCalculationsDelegates {
    func didFinishWithParsing(finishedArray : NSArray)
    @objc optional func didFinishWithParsingWithFarmData(_ finishedArray : NSArray)
}

struct FarmReport {
    let farmName: String
    let adjustedOocystCount: Float
    let category: String
}

class MIcroscopyCalculations: NSObject {
    
    var delegate: MicroscopyCalculationsDelegates?
    var farmReports: [FarmReport] = []
    func setupData(_ aArray : NSArray , birdsCount : Float , catName : NSString) {
        if catName == "Microscopy"{
            self.forMicroscopySummuary(aArray, birdsCount: birdsCount)
        }
    }
    
    func forMicroscopySummuary(_ aArray: NSArray, birdsCount: Float) {
        let preparedArray = NSMutableArray()
        let preparedArrayForMean = NSMutableArray()
        
        let refIds: [Int: (label: String, mean: Float, count: Float, updated: Float)] = [
            607: ("Coccidia", 0, 0, 0),
            612: ("BacteriaMotile", 0, 0, 0),
            613: ("BacteriaNonMotile", 0, 0, 0),
            611: ("Pepto", 0, 0, 0)
        ]

        var metrics = refIds
        var observationSet: Float = 0

        for case let entry as NSDictionary in aArray {
            guard entry["catName"] as? NSString == "Coccidiosis",
                  let lngId = entry["lngId"] as? Int, lngId == Regions.languageID,
                  let refId = entry["refId"] as? NSNumber,
                  let obsPoint = entry["obsPoint"] as? NSNumber,
                  metrics.keys.contains(refId.intValue) else { continue }

            let value = obsPoint.floatValue
            var metric = metrics[refId.intValue]!

            observationSet += 1
            metric.mean += value
            metric.count += (value > 0 ? 1 : 0)
            if value > 0 {
                metric.updated += 1
            }

            metrics[refId.intValue] = metric
        }

        addPercentageValues(to: preparedArray, using: metrics, birdsCount: birdsCount)
        addMeanValues(to: preparedArrayForMean, using: metrics)

        AllValidSessions.sharedInstance.meanValues.add(preparedArrayForMean)
        UserDefaults.standard.set(AllValidSessions.sharedInstance.meanValues, forKey: "meanArray")

        delegate?.didFinishWithParsing(finishedArray: preparedArray)
    }

    private func addPercentageValues(to array: NSMutableArray, using metrics: [Int: (label: String, mean: Float, count: Float, updated: Float)], birdsCount: Float) {
        for id in [607, 612, 613, 611] {
            let count = metrics[id]?.count ?? 0
            let percentage = (count / birdsCount) * 100
            array.add(percentage)
        }
    }

    private func addMeanValues(to array: NSMutableArray, using metrics: [Int: (label: String, mean: Float, count: Float, updated: Float)]) {
        for id in [607, 612, 613, 611] {
            array.add(meanValue(for: metrics[id]))
        }
    }

    private func meanValue(for metric: (label: String, mean: Float, count: Float, updated: Float)?) -> Float {
        guard let metric = metric, metric.updated > 0 else { return 0.0 }
        let mean = metric.mean / metric.updated
        return mean.isNaN ? 0.0 : mean
    }

    
    func setupCocciDataByFarm(_ aArray: NSArray, birdsCount: Float, catName: NSString) {
        let preparedArray = NSMutableArray()
        let meanValuesArray = NSMutableArray()

        let refIds = [
            607: (label: "Coccidia", mean: Float(0), count: Float(0), updated: Float(0)),
            612: (label: "BacteriaMotile", mean: Float(0), count: Float(0), updated: Float(0)),
            613: (label: "BacteriaNonMotile", mean: Float(0), count: Float(0), updated: Float(0)),
            611: (label: "Pepto", mean: Float(0), count: Float(0), updated: Float(0))
        ]

        var metrics = refIds
        var observationSet: Float = 0

        for case let entry as NSDictionary in aArray {
            guard entry["catName"] as? NSString == "Coccidiosis",
                  let lngId = entry["lngId"] as? Int, lngId == Regions.languageID,
                  let refId = entry["refId"] as? NSNumber,
                  let obsPoint = entry["obsPoint"] as? NSNumber,
                  let _ = refIds[refId.intValue] else { continue }

            var metric = metrics[refId.intValue]!
            let value = obsPoint.floatValue

            observationSet += 1
            metric.mean += value
            metric.count += (value > 0 ? 1 : 0)
            if value > 0 {
                metric.updated += 1
            }

            metrics[refId.intValue] = metric
        }

        // Add observed counts to the prepared array
        preparedArray.add(metrics[607]?.count ?? 0)
        preparedArray.add(metrics[612]?.count ?? 0)
        preparedArray.add(metrics[613]?.count ?? 0)
        preparedArray.add(metrics[611]?.count ?? 0)

        // Calculate and add mean arrays
        meanValuesArray.add(meanValueArray(metrics[607]))
        meanValuesArray.add(meanValueArray(metrics[612]))
        meanValuesArray.add(meanValueArray(metrics[613]))
        meanValuesArray.add(meanValueArray(metrics[611]))

        AllValidSessions.sharedInstance.meanValues.add(meanValuesArray)
        UserDefaults.standard.set(AllValidSessions.sharedInstance.meanValues, forKey: "meanArray")

        delegate?.didFinishWithParsingWithFarmData!(preparedArray)
    }

    private func meanValueArray(_ metric: (label: String, mean: Float, count: Float, updated: Float)?) -> NSMutableArray {
        let resultArray = NSMutableArray()
        guard let metric = metric, metric.updated > 0 else {
            resultArray.add(0.0)
            return resultArray
        }
        let meanValue = metric.mean / metric.updated
        resultArray.add(meanValue.isNaN ? 0.0 : meanValue)
        return resultArray
    }
}
