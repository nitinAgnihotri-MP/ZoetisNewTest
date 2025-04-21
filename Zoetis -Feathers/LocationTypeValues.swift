//
//  LocationTypeValues.swift
//  Zoetis -Feathers
//
//  Created by Abdul Shamim on 17/02/20.
//  Copyright © 2020 . All rights reserved.
//

import Foundation
import SwiftyJSON

class LocationTypeValues {
    
    
    let success: Bool?
    let statusCode: Int?
    let message: String?
    
    var locationValueArray: [LocationValues]?
    
    init(_ json: JSON) {
        success = json["IsSuccess"].boolValue
        statusCode = json["StatusCode"].intValue
        message = json["DisplayMessage"].stringValue
        
        locationValueArray = json["ResponseData"].arrayValue.map { LocationValues($0) }
    }
    
    func getAllLocationTypes(array: [LocationValues]) -> [LocationValues] {
        var allLocationValueArray : [LocationValues] = []
        for obj in array {
            allLocationValueArray.append(obj)
        }
        return allLocationValueArray
    }
}


public class LocationValues {
    
    let locatgionTypeId: Int?
    let rapNo40: Int?
    let rapNo20: Int?
    let std40: Bool?
    let std20: Bool?
    let standard: Bool?
    let stnRep: Int?
    var mediaTypeDefault : String?
    var samplingMethodDefault : String?
    var locationValuesObj: LocationValue?
    
    init(_ json: JSON) {
        locatgionTypeId = json["LocationTypeId"].intValue
        std40 = json["IsBactTemp"].boolValue
        std20 = json["IsBactTemp20"].boolValue
        rapNo20 = json["RepNo20"].intValue
        rapNo40 = json["RepNo"].intValue
        standard = json["IsStandard"].boolValue
        stnRep = json["StndRep"].intValue
        mediaTypeDefault = ""
        samplingMethodDefault = ""
        let new = json["Media"].dictionary
        if let object = new,let moreData = object["Text"]?.string {
            mediaTypeDefault = moreData
        }
        
        let newZ = json["Sampling"].dictionary
        
        if let object = newZ,let sampling = object["Text"]?.string {
            samplingMethodDefault = sampling
        }
        
        locationValuesObj = LocationValue(json["LocationValue"], locatgionTypeId, std40: std40, std20: std20, rapNo40: rapNo40, rapoNo20: rapNo20, standard: standard, stnRep: stnRep ,mediaTypeDefault : mediaTypeDefault, samplingMethodDefault : samplingMethodDefault)
    }    
}

public class LocationValue {
    
    let locatgionTypeId: Int?
    let id: Int?
    let text: String?
    let std40: Bool?
    let std20: Bool?
    let rapNo40: Int?
    let rapNo20: Int?
    let standard: Bool?
    let stnRep: Int?
    let mediaTypeDefault : String?
    let samplingMethodDefault : String?
    
    init(_ json: JSON, _ locatgionTypeId: Int?, std40: Bool?, std20: Bool?, rapNo40: Int?, rapoNo20: Int?, standard: Bool?, stnRep: Int? ,mediaTypeDefault : String?, samplingMethodDefault : String?) {
        self.locatgionTypeId = locatgionTypeId
        self.std40 = std40
        self.std20 = std20
        id = json["Id"].intValue
        text = json["Text"].stringValue
        self.rapNo40 = rapNo40
        self.rapNo20 = rapoNo20
        self.standard = standard
        self.stnRep = stnRep
        self.mediaTypeDefault = mediaTypeDefault
        self.samplingMethodDefault = samplingMethodDefault

        //saveLocationTypeValuesInDB(_ locationId: NSNumber, id: NSNumber, value: String)
        CoreDataHandlerMicro().saveLocationTypeValuesInDB(NSNumber(value: locatgionTypeId!), id: NSNumber(value: id!), value: text!, std40: std40 ?? false, std20: std20 ?? false, rep20: rapoNo20 ?? 0, rep40: rapNo40 ?? 0, standard: standard ?? false, stnRep: stnRep ?? 0, mediaTypeDefault : mediaTypeDefault ?? "", samplingMethodDefault : samplingMethodDefault ?? "" )
    }
}
