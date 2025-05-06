//  Zoetis -Feathers
//
//  Created by "" ""on 08/11/19.
//  Copyright © 2019 . All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

typealias JSONDictionaryArray = [JSONDictionary]
typealias SuccessBlock = (JSON) -> Void
typealias ErrorBlock = (NSError) -> Void
let apiHeaders = ["DeviceType":"ios", "UserId":"\(String(describing: UserDefaults.standard.value(forKey: "Id") ?? 0))",
                  "Authorization":"\(AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken) ?? "")"]

extension Notification.Name {
    
    static let NotConnectedToInternet = Notification.Name("NotConnectedToInternet")
}

enum ZoetisApiManager {
    
    static func POST(   _ showHud: Bool,
                     _ showHudText: String,
                     endPoint: String,
                     parameters: JSONDictionary = [:],
                     imageData: Data = Data(),
                     imageKey: String = "",
                     success : @escaping SuccessBlock,
                     failure : @escaping ErrorBlock) {
        
        request(URLString: endPoint, httpMethod: .post, parameters: parameters, imageData: imageData,
                imageKey: imageKey, success: success, failure: failure)
    }
    
    static func GET(  _ showHud: Bool,
                      _ showHudText: String,
                    endPoint: String,
                    parameters: JSONDictionary = [:],
                    success : @escaping SuccessBlock,
                    failure : @escaping ErrorBlock) {
        
        request(URLString: endPoint, httpMethod: .get, parameters: parameters, success: success, failure: failure)
    }
    
    static func PUT(  _ showHud: Bool,
                 
                    endPoint: String,
                    parameters: JSONDictionary = [:],
                    imageData: Data = Data(),
                    imageKey: String = "",
                    success : @escaping SuccessBlock,
                    failure : @escaping ErrorBlock) {
        
        request(URLString: endPoint, httpMethod: .put, parameters: parameters, imageData: imageData,
                imageKey: imageKey, success: success, failure: failure)
    }
    
    static func PATCH(  _ showHud: Bool,
                       
                      endPoint: String,
                      parameters: JSONDictionary = [:],
                      imageData: Data = Data(),
                      imageKey: String = "",
                      success : @escaping SuccessBlock,
                      failure : @escaping ErrorBlock) {
        
        request(URLString: endPoint, httpMethod: .patch, parameters: parameters, imageData: imageData,
                imageKey: imageKey, success: success, failure: failure)
    }
    
    static func DELETE(  _ showHud: Bool,
                         _ showHudText: String,
                       endPoint: String,
                       parameters: JSONDictionary = [:],
                   
                       success : @escaping SuccessBlock,
                       failure : @escaping ErrorBlock) {
        
        request(URLString: endPoint, httpMethod: .delete, parameters: parameters, success: success, failure: failure)
    }
    
    private static func request(
        URLString: String,
        httpMethod: HTTPMethod,
        parameters: JSONDictionary = [:],
        imageData: Data = Data(),
        imageKey: String = "",
        success: @escaping SuccessBlock,
        failure: @escaping ErrorBlock
    ) {
        let additionalHeaders = buildHeaders()
        if !imageKey.isEmpty {
            handleMultipartRequest(
                URLString: URLString,
                parameters: parameters,
                imageData: imageData,
                imageKey: imageKey,
                headers: additionalHeaders,
                success: success,
                failure: failure
            )
        } else {
            handleStandardRequest(
                URLString: URLString,
                httpMethod: httpMethod,
                parameters: parameters,
                headers: additionalHeaders,
                success: success,
                failure: failure
            )
        }
    }

    // Helper 1: Build headers
    private static func buildHeaders() -> HTTPHeaders {
        return [
            "DeviceType": "ios",
            "UserId": "\(String(describing: UserDefaults.standard.value(forKey: "Id") ?? 0))",
            "Authorization": "\(AccessTokenHelper().getFromKeychain(keyed: Constants.accessToken) ?? "")"
        ]
    }

    // Helper 2: Handle multipart (image) request
    private static func handleMultipartRequest(
        URLString: String,
        parameters: JSONDictionary,
        imageData: Data,
        imageKey: String,
        headers: HTTPHeaders,
        success: @escaping SuccessBlock,
        failure: @escaping ErrorBlock
    ) {
        guard let url = URL(string: URLString) else { return }
        AF.upload(
            multipartFormData: { multipartFormData in
                appendParametersToMultipart(multipartFormData, parameters: parameters)
                multipartFormData.append(imageData, withName: imageKey, fileName: "image.png", mimeType: "jpeg/png")
            },
            to: url, method: .post, headers: headers
        )
        .responseJSON { resp in
            switch resp.result {
            case .success(let value):
                if let dataResponse = value as? AFDataResponse<Data> {
                    parseResponse(dataResponse, success: success, failure: failure)
                } else {
                    // Fallback: try to parse as JSON directly
                    success(JSON(value))
                }
            case .failure(let error):
                print(error)
                failure(error as NSError)
            }
        }
    }

    // Helper 3: Append parameters to multipart form data
    private static func appendParametersToMultipart(_ multipartFormData: MultipartFormData, parameters: JSONDictionary) {
        for (key, value) in parameters {
            if let data = "\(value)".data(using: .utf8) {
                multipartFormData.append(data, withName: key)
            }
        }
    }

    // Helper 4: Handle standard (non-image) request
    private static func handleStandardRequest(
        URLString: String,
        httpMethod: HTTPMethod,
        parameters: JSONDictionary,
        headers: HTTPHeaders,
        success: @escaping SuccessBlock,
        failure: @escaping ErrorBlock
    ) {
        print("*************\(URLString)***************")
        AF.request(
            URLString,
            method: httpMethod,
            parameters: parameters,
            encoding: httpMethod == .post || httpMethod == .put || httpMethod == .patch ? JSONEncoding.default : URLEncoding.queryString,
            headers: headers
        ).responseData { (response: AFDataResponse<Data>) in
            print("Response from server is ", response)
            parseResponse(response, success: success, failure: failure)
        }
    }
    
    private static func parseResponse(_ response: AFDataResponse<Data>,
                                      success : @escaping SuccessBlock,
                                      failure : @escaping ErrorBlock) {
        switch response.result {
        case .success(let value): success(JSON(value))
        case .failure(let error):
            let err = (error as NSError)
            if err.code == NSURLErrorNotConnectedToInternet || err.code == NSURLErrorInternationalRoamingOff {
                // Handle Internet Not available UI
                NotificationCenter.default.post(name: .NotConnectedToInternet, object: nil)
                
                let internetNotAvailableError = err
                failure(internetNotAvailableError)
            } else {
                failure(error as NSError)
            }
        }
    }
}
