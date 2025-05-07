//
//  ReportComposer.swift
//  PDFDemo
//
//  Created by "" on 01/02/17.
//  Copyright © 2017 "". All rights reserved.
//

import UIKit
import AVFoundation

struct Metric {
    var total: Float = 0
    var mean: Float = 0
    var updated: Float = 0
    var spliterTotal: Float = 0
    var spliterMean: Float = 0
    var spliterMeanBirds: Float = 0
    
    mutating func update(with value: Float, meanValue: Float) {
        total += value
        spliterTotal += value
        mean += meanValue
        spliterMean += meanValue
        if meanValue > 0 {
            updated += 1
            spliterMeanBirds += 1
        }
    }
    
    mutating func resetSpliter() {
        spliterTotal = 0
        spliterMean = 0
        spliterMeanBirds = 0
    }
}

struct ReportData {
    var birdsTotal: Int = 0
    var meanAge: Float = 0
    var birdsTotalSpliter: Int = 0
    var meanAgeSpliter: Float = 0
    var indexSpliter: Float = 0
    var indexTotal: Int = 0
}

class ReportComposerDaignostic: NSObject {
    
    var pathToReportHTMLTemplate = UserDefaults.standard.bool(forKey: "turkeyReport") ?Bundle.main.path(forResource:"DiagnosticReportTr-\(Regions.countryId)\(1)", ofType: "html") : Bundle.main.path(forResource:"DiagnosticReport-\(Regions.countryId)\(Regions.languageID)", ofType: "html")
    
    var pathToSingleItemHTMLTemplate = UserDefaults.standard.bool(forKey: "turkeyReport") ? Bundle.main.path(forResource: "single_item_DignosticTr", ofType: "html") : Bundle.main.path(forResource:"single_item_Dignostic-\(Regions.countryId)\(Regions.languageID)", ofType: "html")
    
    var pathToLastItemHTMLTemplate = UserDefaults.standard.bool(forKey: "turkeyReport") ? Bundle.main.path(forResource: "last_item_daignosticTr", ofType: "html") : Bundle.main.path(forResource:"last_item_daignostic-\(Regions.countryId)\(Regions.languageID)", ofType: "html")
    
    let logoImageURL = WebClass.sharedInstance.connected() == true ? "https://mypoultryview360.com/Images/logo.png" : Bundle.main.path(forResource:"logo", ofType: "png")
    
    let birdsMargin = Regions.countryId == 40 ? Constants.leftMargin : "margin-left:-180px"
    
    let birdsMarginHistory = Regions.countryId == 40 ? Constants.leftMargin : "margin-left:-225px"
    
    let birdsMarginSummary = Regions.countryId == 40 ? "margin-left:-60px" : "margin-left:-130px"
    
    let ageMarginHistory = Regions.countryId == 40 ? "margin-left:-20px" : "margin-left:-110px"
    
    let ageMarginSummary = Regions.countryId == 40 ? "margin-left:-45px" : "margin-left:-55px"
    
    var invoiceNumber: String!
    
    var pdfFilename: String!
    
    var meanAge = Float()
    let displayStr = "#display#"

    override init() {
        super.init()
    }
    
    func SingleItemBirdsMargin(countryID: Int) -> String {
        
        var margin: String = ""
        switch countryID {
        case 35: margin = "margin-left:-100px"
            break
        case 40: margin = "margin-left:-60px"
            break
        default:
            break
        }
        return margin
    }
    
    func SingleItemAgeMargin(countryID: Int) -> String {
        
        var margin: String = ""
        switch countryID {
        case 35: margin = "margin-left:-50px"
            break
        case 40: margin = Constants.leftMargin
            break
        default:
            break
        }
        return margin
    }
    
    func renderReports(
        complexName: String,
        customerName: String,
        vetanatrionName: String,
        salesRepName: String,
        customerRepName: String,
        typeDate: String,
        items: [[String: AnyObject]]
    ) -> String? {
        debugPrint("DiagnosticReport-\(Regions.countryId)\(Regions.languageID)")
        
        guard !items.isEmpty else { return nil }
        guard let (reportTemplate, singleItemTemplate, lastItemTemplate) = loadTemplates(isCocciHistory: items[0]["isCocciHistory"]?.boolValue == true) else { return nil }
        guard let htmlContent = loadMainTemplate(path: reportTemplate) else { return nil }
        
        let placeholderData = ReportPlaceholderData(
            complexName: complexName,
            customerName: customerName,
            vetanatrionName: vetanatrionName,
            salesRepName: salesRepName,
            customerRepName: customerRepName,
            typeDate: typeDate,
            isCocciHistory: items[0]["isCocciHistory"]?.boolValue == true,
            logoImageURL: logoImageURL ?? ""
        )

        let replacedContent = replaceMainPlaceholders(htmlContent: htmlContent, with: placeholderData)
        let layout = ReportLayoutConfigProcessItems(
            birdsMarginHistory: birdsMarginHistory,
            birdsMarginSummary: birdsMarginSummary,
            ageMarginHistory: ageMarginHistory,
            ageMarginSummary: ageMarginSummary
        )
        let allItemsContent = processItems(
            items: items,
            singleItemTemplate: singleItemTemplate,
            lastItemTemplate: lastItemTemplate,
            isCocciHistory: items[0]["isCocciHistory"]?.boolValue == true,
            layout: layout
        )
        
        let finalContent = replacedContent.replacingOccurrences(of: "#ITEMS#", with: allItemsContent)
        AllValidSessions.sharedInstance.meanValues.removeAllObjects()
        return finalContent
    }

    func loadTemplates(isCocciHistory: Bool) -> (String, String, String)? {
        var reportTemplate = UserDefaults.standard.bool(forKey: "turkeyReport")
            ? Bundle.main.path(forResource: "DiagnosticReportTr-\(Regions.countryId)\(1)", ofType: "html")
            : Bundle.main.path(forResource: "DiagnosticReport-\(Regions.countryId)\(Regions.languageID)", ofType: "html")
        
        var singleItemTemplate = Bundle.main.path(forResource: "single_item_Dignostic-\(Regions.countryId)\(Regions.languageID)", ofType: "html")
        var lastItemTemplate = Bundle.main.path(forResource: "last_item_daignostic-\(Regions.countryId)\(Regions.languageID)", ofType: "html")
        
        if isCocciHistory {
            if let headerPath = Bundle.main.path(forResource: "DiagnosticReport-\(Regions.countryId)\(Regions.languageID)H", ofType: "html") {
                reportTemplate = headerPath
            }
            if let singleItemPath = Bundle.main.path(forResource: "single_item_Dignostic-\(Regions.countryId)\(Regions.languageID)H", ofType: "html") {
                singleItemTemplate = singleItemPath
            }
            if let lastItemPath = Bundle.main.path(forResource: "last_item_daignostic-\(Regions.countryId)\(Regions.languageID)H", ofType: "html") {
                lastItemTemplate = lastItemPath
            }
        }
        
        guard let report = reportTemplate, let single = singleItemTemplate, let last = lastItemTemplate else { return nil }
        return (report, single, last)
    }

    func loadMainTemplate(path: String) -> String? {
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            print("Unable to open main HTML template file.")
            return nil
        }
    }

    func replaceMainPlaceholders(
        htmlContent: String,
        with data: ReportPlaceholderData
    ) -> String {
        var content = htmlContent
        content = content.replacingOccurrences(of: "#complexName#", with: data.complexName)
        content = content.replacingOccurrences(of: "#CustomerName#", with: data.customerName)
        content = content.replacingOccurrences(of: "#vetanatrionName#", with: data.vetanatrionName)
        content = content.replacingOccurrences(of: "#salesRepName#", with: data.salesRepName.isEmpty ? "NA" : data.salesRepName)
        content = content.replacingOccurrences(of: "#customerRepName#", with: data.customerRepName.isEmpty ? "NA" : data.customerRepName)
        content = content.replacingOccurrences(of: "#reportTitle#", with: data.isCocciHistory ? NSLocalizedString("Necropsy Historical Report", comment: "") : NSLocalizedString("Necropsy Summary Report", comment: ""))
        content = content.replacingOccurrences(of: "#digHisMargn#", with: data.isCocciHistory ? "margin-left:-20px" : Constants.leftMargin)
        content = content.replacingOccurrences(of: "#typeDate#", with: data.typeDate)
        content = content.replacingOccurrences(of: "#Farm#", with: data.isCocciHistory ? "Date" : NSLocalizedString("Farm", comment: ""))
        content = content.replacingOccurrences(of: "#LOGO_IMAGE#", with: data.logoImageURL)
        content = content.replacingOccurrences(of: Constants.displayNone, with: data.isCocciHistory ? Constants.noneDisplay : "")
        return content
    }
//    let birdsMarginHistory: String
//    let birdsMarginSummary: String
//    let ageMarginHistory: String
//    let ageMarginSummary: String

    func processItems(
        items: [[String: AnyObject]],
        singleItemTemplate: String,
        lastItemTemplate: String,
        isCocciHistory: Bool,
        layout:ReportLayoutConfigProcessItems
    ) -> String {
        var metrics: [String: Metric] = [
            "FP": Metric(), "trac": Metric(), "TD": Metric(), "Bone": Metric(), "air": Metric(),
            "ge": Metric(), "pro": Metric(), "enterties": Metric(), "BLS": Metric()
        ]
        var simpleMetrics: [String: Float] = [
            "Intestinal": 0, "Thin_Intestine": 0, "Muscular": 0, "amonia": 0, "mouth": 0,
            "FHN": 0, "Rick": 0, "Syno": 0, "Bursa": 0, "IP": 0, "retained": 0, "litter": 0,
            "tape": 0, "round": 0, "feed": 0, "feed_P": 0, "pericarditis": 0, "septicemia": 0,
            "Liver_Granuloma": 0, "Active_Bursa": 0
        ]
        var reportData = ReportData()
        var allItems = ""
        let lngId = UserDefaults.standard.integer(forKey: "lngId")
        let meanArray = AllValidSessions.sharedInstance.meanValues as! [[AnyObject]]
        let dataVars = ReportConfigDiagnosticVariable(
            template: singleItemTemplate,
            meanArray: meanArray,
            lngId: lngId,
            isCocciHistory: isCocciHistory)
        for i in 0...items.count {
            if i < items.count {
                allItems += processSingleItem(
                    item: items[i],
                    index: i,
                    metrics: &metrics,
                    simpleMetrics: &simpleMetrics,
                    reportData: &reportData,
                    dataVars: dataVars,
                    layout: layout
                )
            } else {
                allItems += processLastItem(
                    metrics: metrics,
                    simpleMetrics: simpleMetrics,
                    reportData: reportData,
                    template: lastItemTemplate,
                    lngId: lngId,
                    isCocciHistory: isCocciHistory,
                    layout: layout
                )
            }
        }
        
        return allItems
    }

    fileprivate func handleMeanIndexValidations(_ key: String, _ meanIndex: inout Int) {
        if key == "trac" || key == "TD" || key == "ge" {
            meanIndex += 1
        }
    }
    
    func processSingleItem(item: [String: AnyObject],
                           index: Int,
                           metrics: inout [String: Metric],
                           simpleMetrics: inout [String: Float],
                           reportData: inout ReportData,
                           dataVars: ReportConfigDiagnosticVariable,
                           layout:ReportLayoutConfigProcessItems) -> String {
        
        guard let content = try? String(contentsOfFile: dataVars.template, encoding: .utf8) else { return "" }
        var result = content
        let metricKeys = ["FP", "trac", "TD", "Bone", "air", "ge", "pro", "enterties", "BLS"]
        let meanPlaceholders = [
            "#Foot_Pad_Lesions_Mean#", "#Tracheitis_Mean#", "#Tibial_Dyschondroplasia_Mean#",
            "#boneStrength_Mean#", "#air_Sac_Mean#", "#gizzard_Erosions_Mean#",
            "#proventriculitis_Mean#", "#enterties_Mean#", "#bursaLesionScore_Mean#"
        ]
        
        // Replace margins
        result = result.replacingOccurrences(of: "margin-left:-40px;", with: dataVars.isCocciHistory ? birdsMarginHistory : SingleItemBirdsMargin(countryID: Regions.countryId))
        result = result.replacingOccurrences(of: "margin-left: -20px;", with: dataVars.isCocciHistory ? ageMarginHistory : SingleItemAgeMargin(countryID: Regions.countryId))
        
        // Update and replace metrics
        var meanIndex = 0
        for (key, placeholder) in zip(metricKeys, meanPlaceholders) {
            let value = item[key]?.floatValue ?? 0
            let meanValue = (dataVars.meanArray[index][meanIndex] as? Float) ?? 0
            metrics[key]!.update(with: value, meanValue: meanValue.isNaN ? 0 : meanValue)
            result = result.replacingOccurrences(of: "#\(key)#", with: String(format: "%.1f", value))
            result = result.replacingOccurrences(of: placeholder, with: String(format: "%.1f", meanValue.isNaN ? 0 : meanValue))
            meanIndex += 1
            handleMeanIndexValidations(key, &meanIndex)
        }
        
        // Update and replace simple metrics
        for (key, _) in simpleMetrics {
            let value = item[key]?.floatValue ?? 0
            simpleMetrics[key]! += value
            result = result.replacingOccurrences(of: "#\(key)#", with: String(format: "%.1f", value))
        }
        
        // Handle special cases
        result = result.replacingOccurrences(of: "#FarmName#", with: dataVars.isCocciHistory ? (item["sessionDate"] as? String ?? "") : (item["farmName"] as? String ?? ""))
        result = result.replacingOccurrences(of: Constants.displayNone, with: dataVars.isCocciHistory ? Constants.noneDisplay : "")
        result = result.replacingOccurrences(of: "#birds#", with: item["birds"] as? String ?? "0")
        result = result.replacingOccurrences(of: "#MeanAge#", with: item["meanAge"] as? String ?? "0")
        result = result.replacingOccurrences(of: "#Sick#", with: (item["isSick"]?.intValue ?? 0) == 0 ? "" : "checked")
        
        // Update report data
        reportData.birdsTotal += (item["birds"]?.intValue ?? 0)
        reportData.birdsTotalSpliter += (item["birds"]?.intValue ?? 0)
        reportData.meanAge += (item["meanAge"]?.floatValue ?? 0)
        reportData.meanAgeSpliter += (item["meanAge"]?.floatValue ?? 0)
        reportData.indexSpliter += 1
        
        // Handle age splitting
        result = result.replacingOccurrences(of: displayStr, with: Constants.noneDisplay)
        let layout = ReportConfigDiagnosticHandleAgeSplitting(
            content: result,
            item: item,
            index: index,
            items: [item]
        )
        if !dataVars.isCocciHistory {            
            result = handleAgeSplitting(dataVars: layout,
                                        metrics: &metrics,
                                        simpleMetrics: &simpleMetrics,
                                        reportData: &reportData,
                                        lngId: dataVars.lngId)

        }
        return result
    }

    func handleAgeSplitting(
        dataVars:ReportConfigDiagnosticHandleAgeSplitting,
        metrics: inout [String: Metric],
        simpleMetrics: inout [String: Float],
        reportData: inout ReportData,
        lngId: Int
    ) -> String {
        var result = dataVars.content
        let meanAgeIs = dataVars.item["meanAge"]?.intValue ?? 0
        let ageRanges = [
            (0...13, "01 - 13 Days"),
            (14...24, "14 - 24 Days"),
            (25...32, "25 - 32 Days"),
            (33...41, "33 - 41 Days"),
            (42...80, "42 days or older")
        ]
        
        let shouldSplit = ageRanges.contains { range, _ in
            range.contains(meanAgeIs) && (dataVars.index == dataVars.items.count - 1 || dataVars.items[dataVars.index + 1]["meanAge"]?.intValue ?? 0 > range.upperBound)
        }
        
        if shouldSplit || dataVars.index == dataVars.items.count - 1 {
            let ageLabel = ageRanges.first { $0.0.contains(meanAgeIs) }?.1 ?? "Unknown"
            
            let result = replaceTotals(
                content: result,
                metrics: metrics,
                simpleMetrics: simpleMetrics,
                reportData: reportData,
                lngId: lngId
            )
            
            // Reset spliter values
            for key in metrics.keys {
                metrics[key]!.resetSpliter()
            }
            for key in simpleMetrics.keys {
                simpleMetrics[key]! = 0
            }
            reportData.birdsTotalSpliter = 0
            reportData.meanAgeSpliter = 0
            reportData.indexSpliter = 0
            reportData.indexTotal += 1
        } else {
            result = result.replacingOccurrences(of: displayStr, with: Constants.noneDisplay)
        }
        
        return result
    }

    func processLastItem(
        metrics: [String: Metric],
        simpleMetrics: [String: Float],
        reportData: ReportData,
        template: String,
        lngId: Int,
        isCocciHistory: Bool,
        layout:ReportLayoutConfigProcessItems
    ) -> String {
        guard let content = try? String(contentsOfFile: template, encoding: .utf8) else { return "" }
        var result = content
        
        result = result.replacingOccurrences(of: Constants.displayNone, with: isCocciHistory ? Constants.noneDisplay : "")
        result = result.replacingOccurrences(of: "margin-left:-40px;", with: isCocciHistory ? birdsMarginHistory : birdsMarginSummary)
        result = result.replacingOccurrences(of: "margin-left: -20px;", with: isCocciHistory ? ageMarginHistory : ageMarginSummary)
        result = result.replacingOccurrences(of: "margin-left:-140px", with: isCocciHistory ? "margin-left:-180px" : "margin-left:-140px")
        
        result = result.replacingOccurrences(of: "#TotalBirds#", with: String(reportData.birdsTotal))
        result = result.replacingOccurrences(of: "#MeanAge#", with: String(format: "%.0f", round(reportData.meanAge / Float(reportData.indexTotal))))
        
        return replaceTotals(
            content: result,
            metrics: metrics,
            simpleMetrics: simpleMetrics,
            reportData: reportData,
            lngId: lngId
        )
    }

    func replaceTotals(
        content: String,
        metrics: [String: Metric],
        simpleMetrics: [String: Float],
        reportData: ReportData,
        lngId: Int
    ) -> String {
        var result = content
        let count = reportData.indexSpliter > 0 ? reportData.indexSpliter : Float(reportData.indexTotal)
        // Simple metrics
        let simpleKeys = [
            ("Intestinal", "#Intestinal_TOTAL#"), ("Thin_Intestine", "#Thin_TOTAL#"),
            ("Muscular", "#MuscularHemorrhages_TOTAL#"), ("amonia", "#amonia_TOTAL#"),
            ("mouth", "#mouth_TOTAL#"), ("FHN", "#FHN_TOTAL#"), ("Rick", "#Rick_TOTAL#"),
            ("Syno", "#Syno_TOTAL#"), ("Bursa", "#Bursa_TOTAL#"), ("IP", "#IP_TOTAL#"),
            ("retained", "#retained_TOTAL#"), ("litter", "#litter_TOTAL#"), ("ge", "#ge_TOTAL#"),
            ("pro", "#pro_TOTAL#"), ("tape", "#tape_TOTAL#"), ("round", "#round_TOTAL#"),
            ("feed", "#feed_TOTAL#"), ("feed_P", "#feed_P_TOTAL#"), ("enterties", "#enterties_TOTAL#"),
            ("BLS", "#bursaLesionSize_TOTAL#")
        ]
        for (key, placeholder) in simpleKeys {
            let value = simpleMetrics[key]! / count
            result = result.replacingOccurrences(of: placeholder, with: String(format: "%.1f", key == "Bursa" && value == 0 ? 4 : value))
        }
        
        // Conditional metrics for lngId == 1
        if lngId == 1 {
            let conditionalKeys = [
                ("pericarditis", "#pericarditis_TOTAL#"), ("septicemia", "#septicemia_TOTAL#"),
                ("Liver_Granuloma", "#Liver_Granuloma_TOTAL#"), ("Active_Bursa", "#Active_Bursa_TOTAL#")
            ]
            for (key, placeholder) in conditionalKeys {
                result = result.replacingOccurrences(of: placeholder, with: String(format: "%.1f", simpleMetrics[key]! / count))
            }
        }
        
        // Complex metrics
        let metricKeys = [
            ("FP", "#FP_TOTAL#", "#Foot_Pad_Lesions_Mean_Total#"),
            ("trac", "#trac_TOTAL#", "#Tracheitis_Mean_Total#"),
            ("TD", "#TD_TOTAL#", "#Tibial_Dyschondroplasia_Mean_Total#"),
            ("Bone", "#Bone_TOTAL#", "#boneStrength_Mean_Total#"),
            ("air", "#air_TOTAL#", "#air_Sac_Mean_Total#"),
            ("ge", "#ge_TOTAL#", "#gizzard_Erosions_Mean_Total#"),
            ("pro", "#pro_TOTAL#", "#proventriculitis_Mean_Total#"),
            ("enterties", "#enterties_TOTAL#", "#enterties_Mean_Total#"),
            ("BLS", "#bursaLesionSize_TOTAL#", "#bursaLesionSize_Mean_Total#")
        ]
        for (key, totalPlaceholder, meanPlaceholder) in metricKeys {
            let metric = metrics[key]!
            result = result.replacingOccurrences(of: totalPlaceholder, with: String(format: "%.1f", metric.spliterTotal / count))
            let meanValue = metric.spliterMean / (metric.spliterMeanBirds > 0 ? metric.spliterMeanBirds : 1)
            result = result.replacingOccurrences(of: meanPlaceholder, with: String(format: "%.1f", meanValue.isNaN ? 0 : meanValue))
        }
        
        result = result.replacingOccurrences(of: "#TotalBirds#", with: String(reportData.birdsTotalSpliter))
        result = result.replacingOccurrences(of: "#MeanAgeTotal#", with: String(format: "%.0f", round(reportData.meanAgeSpliter / count)))
        
        return result
    }

    struct Constants {
        static let leftMargin: String = "0px"
        static let displayNone: String = "display:none"
        static let noneDisplay: String = ""
        static let complexTotal: String = "#complexTotal#"
    }

    class AllValidSessions {
        static let sharedInstance = AllValidSessions()
        var meanValues: NSMutableArray = []
    }

    func SingleItemBirdsMargin(countryID: String) -> String { "0px" }
    func SingleItemAgeMargin(countryID: String) -> String { "0px" }
    
    
    func exportHTMLContentToPDF(HTMLContent: String) {
        
        let printPageRenderer = UIPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        printPageRenderer.setValue(NSValue(cgRect: page), forKey: "paperRect")
        printPageRenderer.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        let newPdfData = NSMutableData.init(data: pdfData! as Data)
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
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        
        UIGraphicsBeginPDFPage()
        
        printPageRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        UIGraphicsEndPDFContext()
        
        return data
    }
    func getDocDir() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
}
