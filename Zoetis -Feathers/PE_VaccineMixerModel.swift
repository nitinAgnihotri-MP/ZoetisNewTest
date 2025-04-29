//
//  PE_VaccineMixerModel.swift
//  Zoetis -Feathers
//
//  Created by MobileProgramming on 18/10/22.
//

import Foundation
import SwiftyJSON

public struct VaccineMixerResponse {
    
    let success: Bool?
    let statusCode: Int?
    let message: String?
    let vaccineMixerArray: [VaccineMixerDetail]?
    
    init(_ json: JSON) {
        success = json["Success"].boolValue
        statusCode = json["StatusCode"].intValue
        message = json["Message"].stringValue
        vaccineMixerArray = json["Data"].arrayValue.map { VaccineMixerDetail($0) }
    }
}

public struct VaccineMixerDetail {
    
    let id: Int?
    let Name: String?
    let certificationDate: String?
    let isCertExpired: Bool?
    let signatureImg: String?
    
    init(_ json: JSON) {
        id = json["Id"].intValue
        Name = json["Name"].stringValue
        certificationDate = json["CertficationDate"].stringValue
        isCertExpired = json["IsCertExpired"].boolValue
        signatureImg = json["SignatureImg"].string
        
        let NameIs = Name ?? ""
        let idN = id ?? 0
        let certificationDateIs = certificationDate ?? ""
        let isCertExpiredValue = isCertExpired ?? false
        let signatureImgIs = signatureImg ?? ""
        
        CoreDataHandlerPE().saveVaccineMixerInDB(NSNumber(value: idN), Name: NameIs, certificationDate: certificationDateIs, isCertExpired: isCertExpiredValue, signatureImg: signatureImgIs)
        
    }
    
}
