//
//  ReportComposer.swift
//  PDFDemo
//
//  Created by "" on 01/02/17.
//  Copyright © 2017 "". All rights reserved.
//

import UIKit
import AVFoundation

class ReportComposer: NSObject {
    
    let pathToReportHTMLTemplate = UserDefaults.standard.bool(forKey: "turkeyReport") ? Bundle.main.path(forResource:"reportTr\(1)", ofType: "html") : Bundle.main.path(forResource:"report\(Regions.languageID)", ofType: "html")
    
    let categoryName = UserDefaults.standard.bool(forKey: "turkeyReport") ? "Microscopy" : "Coccidiosis"
    
    let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "single_item\(Regions.languageID)", ofType: "html")
    
    let pathToLastItemHTMLTemplate = Bundle.main.path(forResource: "last_item\(Regions.languageID)", ofType: "html")
    let logoImageURL = WebClass.sharedInstance.connected() == true ? "https://mypoultryview360.com/Images/logo.png" : Bundle.main.path(forResource: "logo", ofType: "png")
    var invoiceNumber: String!
    var pdfFilename: String!
    var meanAge = Float()
    let displayStr = "#display#"
    
    struct ReportTotals {
        var birds: Int = 0
        var meanAge: Float = 0
        var ag: Float = 0
        var mg: Float = 0
        var mm: Float = 0
        var tg: Float = 0
        var agMean: Float = 0
        var mgMean: Float = 0
        var mmMean: Float = 0
        var tgMean: Float = 0
        var agMeanBirds: Float = 0
        var mgMeanBirds: Float = 0
        var mmMeanBirds: Float = 0
        var tgMeanBirds: Float = 0
    }

    struct SplitFlags {
        var needToSplit0114: Bool = false
        var needToSplit1424: Bool = false
        var needToSplit2532: Bool = false
        var needToSplit3341: Bool = false
        var needToSplit42: Bool = false
        var isCheckSum: Bool = false
        var isCheckSum1: Bool = false
        var isCheckSum2: Bool = false
        var isCheckSum3: Bool = false
    }
    override init() {
        super.init()
    }
    fileprivate func handleNeedToSplit0114(_ needToSplit0114: inout Bool, _ needToSplit3341: inout Bool, _ needToSplit42: inout Bool, _ needToSplit2532: inout Bool, _ needToSplit1424: inout Bool, _ isCheckSum: inout Bool) {
        if needToSplit0114 == true {
            needToSplit3341 = false
            needToSplit42 = false
            needToSplit2532 = false
            needToSplit1424 = false
            needToSplit0114 = false
            isCheckSum = true
        } else {
            if isCheckSum == false {
                needToSplit0114 = true
            } else {
                needToSplit0114 = false
            }
        }
    }
    
    fileprivate func handleNeedToSplit1424(_ needToSplit1424: inout Bool, _ needToSplit3341: inout Bool, _ needToSplit42: inout Bool, _ needToSplit2532: inout Bool, _ needToSplit0114: inout Bool, _ isCheckSum1: inout Bool) {
        if needToSplit1424 == true {
            needToSplit3341 = false
            needToSplit42 = false
            needToSplit2532 = false
            needToSplit1424 = false
            needToSplit0114 = false
            isCheckSum1 = true
        } else {
            if isCheckSum1 == false {
                needToSplit1424 = true
            } else {
                needToSplit1424 = false
            }
        }
    }
    
    fileprivate func handleNeedToSplit2532(_ needToSplit2532: inout Bool, _ needToSplit3341: inout Bool, _ needToSplit42: inout Bool, _ needToSplit1424: inout Bool, _ needToSplit0114: inout Bool, _ isCheckSum2: inout Bool) {
        if needToSplit2532 == true{
            needToSplit3341 = false
            needToSplit42 = false
            needToSplit2532 = false
            needToSplit1424 = false
            needToSplit0114 = false
            isCheckSum2 = true
        } else {
            if isCheckSum2 == false {
                needToSplit2532 = true
            } else {
                needToSplit2532 = false
            }
        }
    }
    
    fileprivate func handleNeedToSplit42(_ needToSplit42: inout Bool, _ needToSplit3341: inout Bool, _ needToSplit2532: inout Bool, _ needToSplit1424: inout Bool, _ needToSplit0114: inout Bool, _ isCheckSum3: inout Bool, _ items: [[String : AnyObject]], _ i: Int) {
        if needToSplit42 == true {
            needToSplit3341 = false
            needToSplit42 = false
            needToSplit2532 = false
            needToSplit1424 = false
            needToSplit0114 = false
            isCheckSum3 = true
        } else if needToSplit3341 == true {
            if (items.count == i + 1) {
                needToSplit42 = true
                needToSplit3341 = false
                needToSplit2532 = false
                needToSplit1424 = false
                needToSplit0114 = false
            } else {
                needToSplit42 = false
                needToSplit3341 = false
                needToSplit2532 = false
                needToSplit1424 = false
                needToSplit0114 = false
                isCheckSum3 = true
            }
        } else {
            
            if (items.count == i + 1) {
                needToSplit42 = true
                needToSplit3341 = false
                needToSplit2532 = false
                needToSplit1424 = false
                needToSplit0114 = false
            } else {
                needToSplit42 = false
                if isCheckSum3 == false {
                    needToSplit3341 = true
                } else{
                    needToSplit3341 = false
                }
                needToSplit2532 = false
                needToSplit1424 = false
                needToSplit0114 = false
            }
        }
    }
    
    fileprivate func handleItemHTMLContextValidations(_ itemHTMLContent: inout String?, _ items: [[String : AnyObject]], _ i: Int) {
        itemHTMLContent = itemHTMLContent!.replacingOccurrences(of:displayStr, with: "" )
        if items[i]["meanAge"]!.integerValue > 0 && items[i]["meanAge"]!.integerValue < 14 {
            itemHTMLContent = itemHTMLContent!.replacingOccurrences(of:Constants.complexTotal, with: "01 - 13 \(NSLocalizedString("Days", comment: ""))")
        } else if items[i]["meanAge"]!.integerValue > 13 && items[i]["meanAge"]!.integerValue < 25 {
            itemHTMLContent = itemHTMLContent!.replacingOccurrences(of:Constants.complexTotal, with: "14 - 24 \(NSLocalizedString("Days", comment: ""))")
        } else if items[i]["meanAge"]!.integerValue > 24 && items[i]["meanAge"]!.integerValue < 33 {
            itemHTMLContent = itemHTMLContent!.replacingOccurrences(of:Constants.complexTotal, with: "25 - 32 \(NSLocalizedString("Days", comment: ""))")
        } else if items[i]["meanAge"]!.integerValue > 32 && items[i]["meanAge"]!.integerValue < 43 {
            itemHTMLContent = itemHTMLContent!.replacingOccurrences(of:Constants.complexTotal, with: "33 - 41 \(NSLocalizedString("Days", comment: ""))")
        } else  if items[i]["meanAge"]!.integerValue > 42 && items[i]["meanAge"]!.integerValue < 81 {
            itemHTMLContent = itemHTMLContent!.replacingOccurrences(of:Constants.complexTotal, with: NSLocalizedString("42 days or older", comment: ""))
        }
    }
    
    fileprivate func handleNeedToSplit0114(_ items: [[String : AnyObject]], _ i: Int, _ needToSplit0114: inout Bool, _ needToSplit3341: inout Bool) {
        if items[i]["meanAge"]!.integerValue > 13 && items[i]["meanAge"]!.integerValue < 25 {
            needToSplit0114 = false
        }
        if items[i]["meanAge"]!.integerValue > 41 && items[i]["meanAge"]!.integerValue < 81 {
            needToSplit3341 = false
        }
    }

    func renderReports(
        _ complexName: String,
        customerName: String,
        vetanatrionName: String,
        salesRepName: String,
        customerRepName: String,
        typeDate: String,
        items: [[String: Any]]
    ) -> String? {
        guard let pathToReportHTMLTemplate = pathToReportHTMLTemplate,
              let htmlContent = try? String(contentsOfFile: pathToReportHTMLTemplate, encoding: .utf8) else {
            return nil
        }

        do {
            var content = replacePlaceholders(
                in: htmlContent,
                complexName: complexName,
                customerName: customerName,
                vetanatrionName: vetanatrionName,
                salesRepName: salesRepName,
                customerRepName: customerRepName,
                typeDate: typeDate,
                items: items
            )
            let allItems = processItems(items)
            content = content.replacingOccurrences(of: "#ITEMS#", with: allItems)
            AllValidSessions.sharedInstance.meanValues.removeAllObjects()
            return content
        } catch {
            print(appDelegateObj.testFuntion())
            return nil
        }
    }

    private func replacePlaceholders(
        in htmlContent: String,
        complexName: String,
        customerName: String,
        vetanatrionName: String,
        salesRepName: String,
        customerRepName: String,
        typeDate: String,
        items: [[String: Any]]
    ) -> String {
        var content = htmlContent
        let isCocciHistory = items.first?["isCocciHistory"] as? Bool ?? false
        let reportTitle = isCocciHistory ? NSLocalizedString("\(categoryName) Historical Report", comment: "") : NSLocalizedString("\(categoryName) Summary Report", comment: "")
        let farmLabel = isCocciHistory ? "Date" : NSLocalizedString("Farm", comment: "")

        content = content.replacingOccurrences(of: "#complexName#", with: complexName)
            .replacingOccurrences(of: "#CustomerName#", with: customerName)
            .replacingOccurrences(of: "#vetanatrionName#", with: vetanatrionName)
            .replacingOccurrences(of: "#salesRepName#", with: salesRepName.isEmpty ? "NA" : salesRepName)
            .replacingOccurrences(of: "#customerRepName#", with: customerRepName.isEmpty ? "NA" : customerRepName)
            .replacingOccurrences(of: "#reportTitle#", with: reportTitle)
            .replacingOccurrences(of: "#typeDate#", with: typeDate)
            .replacingOccurrences(of: "#Farm#", with: farmLabel)
            .replacingOccurrences(of: "#LOGO_IMAGE#", with: logoImageURL ?? "")
            .replacingOccurrences(of: Constants.displayNone, with: isCocciHistory ? Constants.visibilityHidden : "")

        return content
    }

    private func processItems(_ items: [[String: Any]]) -> String {
        var allItems = ""
        var totals = ReportTotals()
        var splitterTotals = ReportTotals()
        var splitFlags = SplitFlags()
        var indexSplitter: Float = 0
        var indexTotal = 0
        let meanArray = AllValidSessions.sharedInstance.meanValues as? [[Float]] ?? []

        for i in 0..<items.count + 1 {
            var itemHTMLContent: String
            if i < items.count {
                itemHTMLContent = processSingleItem(
                    items[i],
                    index: i,
                    items: items,
                    meanArray: meanArray,
                    totals: &totals,
                    splitterTotals: &splitterTotals,
                    splitFlags: &splitFlags,
                    indexSplitter: &indexSplitter,
                    indexTotal: &indexTotal
                )
            } else {
                itemHTMLContent = processLastItem(totals: totals, items: items)
            }
            allItems += itemHTMLContent
        }

        return allItems
    }

    private func processSingleItem(
        _ item: [String: Any],
        index: Int,
        items: [[String: Any]],
        meanArray: [[Float]],
        totals: inout ReportTotals,
        splitterTotals: inout ReportTotals,
        splitFlags: inout SplitFlags,
        indexSplitter: inout Float,
        indexTotal: inout Int
    ) -> String {
        guard let templatePath = pathToSingleItemHTMLTemplate,
              let content = try? String(contentsOfFile: templatePath, encoding: .utf8) else {
            return ""
        }

        indexSplitter += 1
        let meanValues = meanArray[index]
        let isCocciHistory = item["isCocciHistory"] as? Bool ?? false
        var updatedContent = updateItemContent(
            content: content,
            item: item,
            meanValues: meanValues,
            isCocciHistory: isCocciHistory
        )

        updateTotals(item: item, meanValues: meanValues, totals: &totals, splitterTotals: &splitterTotals)
        updateSplitFlags(item: item, index: index, items: items, splitFlags: &splitFlags)

        let shouldSplit = shouldSplitItems(splitFlags: splitFlags, isCocciHistory: isCocciHistory)
        let isLastItem = index == items.count - 1 && !isCocciHistory

        if shouldSplit || isLastItem {
            updatedContent = updateSplitterTotals(
                content: updatedContent,
                splitterTotals: splitterTotals,
                indexSplitter: indexSplitter,
                isCocciHistory: isCocciHistory
            )
            handleItemHTMLContextValidations(&updatedContent, items: items, index: index)
            resetSplitter(&splitterTotals, &indexSplitter, &splitFlags)
            indexTotal += 1
        } else {
            updatedContent = updatedContent.replacingOccurrences(of: displayStr, with: "display:none")
        }

        return updatedContent
    }

    private func updateItemContent(
        content: String,
        item: [String: Any],
        meanValues: [Float],
        isCocciHistory: Bool
    ) -> String {
        var updatedContent = content
        let acer = item["acer"] as? Float ?? 0
        let mg = item["mg"] as? Float ?? 0
        let mm = item["mm"] as? Float ?? 0
        let tg = item["tg"] as? Float ?? 0
        let birds = item["birds"] as? String ?? "0"
        let meanAge = item["meanAge"] as? String ?? "0"
        let farmName = isCocciHistory ? (item["sessionDate"] as? String ?? "") : (item["farmName"] as? String ?? "")
        let isSick = (item["isSick"] as? Int ?? 0) == 0 ? "" : "checked"

        updatedContent = updatedContent
            .replacingOccurrences(of: "#Acervulina#", with: String(format: "%.1f", acer))
            .replacingOccurrences(of: "#acerMean#", with: String(format: "%.1f", meanValues[0].isNaN ? 0 : meanValues[0]))
            .replacingOccurrences(of: "#MaximaGross#", with: String(format: "%.1f", mg))
            .replacingOccurrences(of: "#mgMean#", with: String(format: "%.1f", meanValues[1].isNaN ? 0 : meanValues[1]))
            .replacingOccurrences(of: "#MaximaMicro#", with: String(format: "%.1f", mm))
            .replacingOccurrences(of: "#mmMean#", with: String(format: "%.1f", meanValues[2].isNaN ? 0 : meanValues[2]))
            .replacingOccurrences(of: "#TenellaGross#", with: String(format: "%.1f", tg))
            .replacingOccurrences(of: "#tgMean#", with: String(format: "%.1f", meanValues[3].isNaN ? 0 : meanValues[3]))
            .replacingOccurrences(of: "#FarmName#", with: farmName)
            .replacingOccurrences(of: "#birds#", with: birds)
            .replacingOccurrences(of: "#MeanAge#", with: meanAge)
            .replacingOccurrences(of: "#Sick#", with: isSick)
            .replacingOccurrences(of: Constants.displayNone, with: isCocciHistory ? Constants.visibilityHidden : "")

        return updatedContent
    }

    private func updateTotals(
        item: [String: Any],
        meanValues: [Float],
        totals: inout ReportTotals,
        splitterTotals: inout ReportTotals
    ) {
        let acer = item["acer"] as? Float ?? 0
        let mg = item["mg"] as? Float ?? 0
        let mm = item["mm"] as? Float ?? 0
        let tg = item["tg"] as? Float ?? 0
        let birds = item["birds"] as? Int ?? 0
        let meanAge = item["meanAge"] as? Float ?? 0

        totals.birds += birds
        totals.meanAge += meanAge
        totals.ag += acer
        totals.mg += mg
        totals.mm += mm
        totals.tg += tg
        totals.agMean += meanValues[0]
        totals.mgMean += meanValues[1]
        totals.mmMean += meanValues[2]
        totals.tgMean += meanValues[3]
        totals.agMeanBirds += meanValues[0] > 0 ? 1 : 0
        totals.mgMeanBirds += meanValues[1] > 0 ? 1 : 0
        totals.mmMeanBirds += meanValues[2] > 0 ? 1 : 0
        totals.tgMeanBirds += meanValues[3] > 0 ? 1 : 0

        splitterTotals.birds += birds
        splitterTotals.meanAge += meanAge
        splitterTotals.ag += acer
        splitterTotals.mg += mg
        splitterTotals.mm += mm
        splitterTotals.tg += tg
        splitterTotals.agMean += meanValues[0]
        splitterTotals.mgMean += meanValues[1]
        splitterTotals.mmMean += meanValues[2]
        splitterTotals.tgMean += meanValues[3]
        splitterTotals.agMeanBirds += meanValues[0] > 0 ? 1 : 0
        splitterTotals.mgMeanBirds += meanValues[1] > 0 ? 1 : 0
        splitterTotals.mmMeanBirds += meanValues[2] > 0 ? 1 : 0
        splitterTotals.tgMeanBirds += meanValues[3] > 0 ? 1 : 0
    }

    private func updateSplitFlags(
        item: [String: Any],
        index: Int,
        items: [[String: Any]],
        splitFlags: inout SplitFlags
    ) {
        let arrayIndex = index + 1 < items.count ? index + 1 : index
        let meanAge = items[arrayIndex]["meanAge"] as? Int ?? 0

        if meanAge > 13 && meanAge < 25 {
            handleNeedToSplit0114(
                &splitFlags.needToSplit0114,
                &splitFlags.needToSplit3341,
                &splitFlags.needToSplit42,
                &splitFlags.needToSplit2532,
                &splitFlags.needToSplit1424,
                &splitFlags.isCheckSum
            )
        } else if meanAge > 24 && meanAge < 33 {
            handleNeedToSplit1424(
                &splitFlags.needToSplit1424,
                &splitFlags.needToSplit3341,
                &splitFlags.needToSplit42,
                &splitFlags.needToSplit2532,
                &splitFlags.needToSplit0114,
                &splitFlags.isCheckSum1
            )
        } else if meanAge > 32 && meanAge < 43 {
            handleNeedToSplit2532(
                &splitFlags.needToSplit2532,
                &splitFlags.needToSplit3341,
                &splitFlags.needToSplit42,
                &splitFlags.needToSplit1424,
                &splitFlags.needToSplit0114,
                &splitFlags.isCheckSum2
            )
        } else if meanAge > 42 && meanAge < 81 {
            handleNeedToSplit42(
                &splitFlags.needToSplit42,
                &splitFlags.needToSplit3341,
                &splitFlags.needToSplit2532,
                &splitFlags.needToSplit1424,
                &splitFlags.needToSplit0114,
                &splitFlags.isCheckSum3,
                items: items,
                index: index
            )
        }

        handleNeedToSplit3341(items, index, &splitFlags.needToSplit3341, &splitFlags.needToSplit0114)
    }

    private func shouldSplitItems(splitFlags: SplitFlags, isCocciHistory: Bool) -> Bool {
        return (splitFlags.needToSplit2532 || splitFlags.needToSplit3341 || splitFlags.needToSplit42 ||
                splitFlags.needToSplit1424 || splitFlags.needToSplit0114) && !isCocciHistory
    }

    private func updateSplitterTotals(
        content: String,
        splitterTotals: ReportTotals,
        indexSplitter: Float,
        isCocciHistory: Bool
    ) -> String {
        var updatedContent = content
        let avgAg = splitterTotals.ag / indexSplitter
        let avgMg = splitterTotals.mg / indexSplitter
        let avgMm = splitterTotals.mm / indexSplitter
        let avgTg = splitterTotals.tg / indexSplitter
        let avgMeanAge = round(splitterTotals.meanAge / indexSplitter)
        let avgAgMean = splitterTotals.agMeanBirds > 0 ? splitterTotals.agMean / splitterTotals.agMeanBirds : 0
        let avgMgMean = splitterTotals.mgMeanBirds > 0 ? splitterTotals.mgMean / splitterTotals.mgMeanBirds : 0
        let avgMmMean = splitterTotals.mmMeanBirds > 0 ? splitterTotals.mmMean / splitterTotals.mmMeanBirds : 0
        let avgTgMean = splitterTotals.tgMeanBirds > 0 ? splitterTotals.tgMean / splitterTotals.tgMeanBirds : 0

        updatedContent = updatedContent
            .replacingOccurrences(of: "#TotalBirds#", with: String(splitterTotals.birds))
            .replacingOccurrences(of: "#MeanAgeTotal#", with: String(format: "%.0f", avgMeanAge))
            .replacingOccurrences(of: "#AG_TOTAL#", with: String(format: "%.1f", avgAg))
            .replacingOccurrences(of: "#MG_TOTAL#", with: String(format: "%.1f", avgMg))
            .replacingOccurrences(of: "#MM_TOTAL#", with: String(format: "%.1f", avgMm))
            .replacingOccurrences(of: "#TG_TOTAL#", with: String(format: "%.1f", avgTg))
            .replacingOccurrences(of: "#AGMean_Total#", with: String(format: "%.1f", avgAgMean))
            .replacingOccurrences(of: "#MGMean_Total#", with: String(format: "%.1f", avgMgMean))
            .replacingOccurrences(of: "#MMMean_Total#", with: String(format: "%.1f", avgMmMean))
            .replacingOccurrences(of: "#TGMean_Total#", with: String(format: "%.1f", avgTgMean))
            .replacingOccurrences(of: Constants.displayNone, with: isCocciHistory ? "display:none" : "")

        return updatedContent
    }

    private func resetSplitter(
        _ splitterTotals: inout ReportTotals,
        _ indexSplitter: inout Float,
        _ splitFlags: inout SplitFlags
    ) {
        splitterTotals = ReportTotals()
        indexSplitter = 0
        splitFlags.isCheckSum = false
        splitFlags.isCheckSum1 = false
        splitFlags.isCheckSum2 = false
        splitFlags.isCheckSum3 = false
    }

    private func processLastItem(totals: ReportTotals, items: [[String: Any]]) -> String {
        guard let templatePath = pathToLastItemHTMLTemplate,
              let content = try? String(contentsOfFile: templatePath, encoding: .utf8) else {
            return ""
        }

        let itemCount = Float(items.count)
        let isCocciHistory = items.first?["isCocciHistory"] as? Bool ?? false
        let avgMeanAge = itemCount > 0 ? round(totals.meanAge / itemCount) : 0
        let avgAg = itemCount > 0 ? totals.ag / itemCount : 0
        let avgMg = itemCount > 0 ? totals.mg / itemCount : 0
        let avgMm = itemCount > 0 ? totals.mm / itemCount : 0
        let avgTg = itemCount > 0 ? totals.tg / itemCount : 0
        let avgAgMean = totals.agMeanBirds > 0 ? totals.agMean / totals.agMeanBirds : 0
        let avgMgMean = totals.mgMeanBirds > 0 ? totals.mgMean / totals.mgMeanBirds : 0
        let avgMmMean = totals.mmMeanBirds > 0 ? totals.mmMean / totals.mmMeanBirds : 0
        let avgTgMean = totals.tgMeanBirds > 0 ? totals.tgMean / totals.tgMeanBirds : 0

        return content
            .replacingOccurrences(of: "#TotalBirds#", with: String(totals.birds))
            .replacingOccurrences(of: "#MeanAge#", with: String(format: "%.0f", avgMeanAge))
            .replacingOccurrences(of: "#AG_TOTAL#", with: String(format: "%.1f", avgAg))
            .replacingOccurrences(of: "#MG_TOTAL Материал#", with: String(format: "%.1f", avgMg))
            .replacingOccurrences(of: "#MM_TOTAL#", with: String(format: "%.1f", avgMm))
            .replacingOccurrences(of: "#TG_TOTAL#", with: String(format: "%.1f", avgTg))
            .replacingOccurrences(of: "#AGMean_Total#", with: String(format: "%.1f", avgAgMean))
            .replacingOccurrences(of: "#MGMean_Total#", with: String(format: "%.1f", avgMgMean))
            .replacingOccurrences(of: "#MMMean_Total#", with: String(format: "%.1f", avgMmMean))
            .replacingOccurrences(of: "#TGMean_Total#", with: String(format: "%.1f", avgTgMean))
            .replacingOccurrences(of: Constants.displayNone, with: isCocciHistory ? Constants.visibilityHidden : "")
    }

    private func handleNeedToSplit42(
        _ needToSplit42: inout Bool,
        _ needToSplit3341: inout Bool,
        _ needToSplit2532: inout Bool,
        _ needToSplit1424: inout Bool,
        _ needToSplit0114: inout Bool,
        _ isCheckSum3: inout Bool,
        items: [[String: Any]],
        index: Int
    ) {
        needToSplit42 = true
        needToSplit3341 = false
        needToSplit2532 = false
        needToSplit1424 = false
        needToSplit0114 = false
        isCheckSum3 = true
    }

    private func handleNeedToSplit3341(
        _ items: [[String: Any]],
        _ index: Int,
        _ needToSplit3341: inout Bool,
        _ needToSplit0114: inout Bool
    ) {
        let arrayIndex = index + 1 < items.count ? index + 1 : index
        let meanAge = items[arrayIndex]["meanAge"] as? Int ?? 0
        if meanAge > 32 && meanAge < 42 {
            needToSplit3341 = true
            needToSplit0114 = false
        }
    }

    private func handleItemHTMLContextValidations(
        _ itemHTMLContent: inout String,
        items: [[String: Any]],
        index: Int
    ) {
        let isCocciHistory = items.first?["isCocciHistory"] as? Bool ?? false
        if !isCocciHistory {
            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: displayStr, with: "")
        }
    }
    func exportHTMLContentToPDF(_ HTMLContent: String){
        let printPageRenderer = UIPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 800) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        printPageRenderer.setValue(NSValue(cgRect: page), forKey: "paperRect")
        printPageRenderer.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer)
        let newPdfData = NSMutableData.init(data: pdfData!)
        UIGraphicsBeginPDFContextToData(newPdfData , CGRect.zero, nil)
        for i in 1...printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            printPageRenderer.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        pdfFilename = "\(getDocDir())/Report.pdf"
        try? newPdfData.write(to: URL(fileURLWithPath: pdfFilename), options: [.atomic])
        
    }
    func drawPDFUsingPrintPageRenderer(_ printPageRenderer: UIPrintPageRenderer) -> Data! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        
        UIGraphicsBeginPDFPage()
        
        printPageRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        UIGraphicsEndPDFContext()
        
        return data as Data?
    }
    func getDocDir() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
}
