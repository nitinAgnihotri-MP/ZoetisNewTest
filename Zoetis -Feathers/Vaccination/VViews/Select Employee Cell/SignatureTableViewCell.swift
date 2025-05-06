//
//  SignatureTableViewCell.swift
//  Zoetis -Feathers
//
//  Created by Mobile Programming on 29/05/20.
//  Copyright © 2020 . All rights reserved.
//

import UIKit

class SignatureTableViewCell: UITableViewCell, SignatureViewDelegate  {
    
    // MARK: - OUTLETS
    
    
    @IBOutlet weak var shippindAddressBtn: UIButton!
    
    @IBOutlet weak var shipToLbl: UILabel!
    @IBOutlet weak var deviceOperatorNamebl: UILabel!
    @IBOutlet weak var operatorSignLbl: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var signImgVw: UIImageView!
    @IBOutlet weak var operatornameConstraint: NSLayoutConstraint!
    @IBOutlet weak var operatorNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signView: SignatureView!
    
    
    // MARK: - VARIABLES
    
    var employeesAddedArr = [VaccinationEmployeeVM]()
    var empIndex = -1
    var rowIndex = -1
    var signImage:UIImage?
    var prevController = ""
    var fromScreen = ""
    var certificateData : [PECertificateData] = []
    var blockSignature : (([PECertificateData])-> Void)?
    var isRunningBack = false
    var isRunningForward = false
    var index = -1
    static let identifier = "signatureTableViewCell"
    var curentCertification:VaccinationCertificationVM?
    var regionID = Int()
    class var classIdentifier: String {
        return String(describing: self)
    }
    class var nib: UINib {
        return UINib(nibName: classIdentifier, bundle: nil)
    }
    
    // MARK: - INITIALIZATION METHODS
    
    override func awakeFromNib() {
        super.awakeFromNib()
        regionID = UserDefaults.standard.integer(forKey: "Regionid")
        setBordeViewWithColor(signView)
        nextBtn.setGradient(topGradientColor: UIColor.getEmployeeStartBtnUpperGradient(), bottomGradientColor: UIColor.getDashboardTableHeaderLowerGradColor())
        clearBtn.setGradient(topGradientColor: UIColor.getEmployeeStartBtnUpperGradient(), bottomGradientColor: UIColor.getDashboardTableHeaderLowerGradColor())
        
        previousBtn.setGradient(topGradientColor: UIColor.getViewCertUpperGradColor() , bottomGradientColor: UIColor.getViewCertLowerGradColor())
        self.signView.delegate = self
        previousBtn.isHidden = true
        
        shippindAddressBtn.setTitleColor(.white, for: .normal)
        shippindAddressBtn.layer.cornerRadius = 10
        
        shippindAddressBtn.setGradient(topGradientColor: UIColor.getEmployeeStartBtnUpperGradient(), bottomGradientColor: UIColor.getDashboardTableHeaderLowerGradColor())
        
    }
    
    func animateButton(button: UIButton) {
        UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
            button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        })
    }
    
    func glowEffect(button: UIButton) {
        
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            button.layer.shadowOpacity = 1.0
            button.layer.shadowRadius = 10
            button.isUserInteractionEnabled = true
            
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = button.bounds
            gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor]
            button.layer.insertSublayer(gradientLayer, at: 0)
            
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - IBACTIONS
    @IBAction func nextBtnAction(_ sender: UIButton) {
        empIndex += 1
        signView.clearCanvas()
        if fromScreen == "PEFinishPopUpScreen" {
            handlePEFinishPopUpScreen()
        } else {
            handleDefaultScreen()
        }
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "UpdateEmployeeSign"),
            object: nil,
            userInfo: ["index": empIndex, "rowIndex": rowIndex]
        )
    }

    private func handlePEFinishPopUpScreen() {
        if empIndex > -1, certificateData.count > empIndex {
            updateVaccineMixerSignature()
        }
        updatePreviousButtonState()
        if empIndex > -1, empIndex == certificateData.count {
            updateFSRSignature()
        }
        updateFSRSignatureFromDefaults()
    }

    private func updateVaccineMixerSignature() {
        let firstname = certificateData[empIndex].name
        let fullName = "\(firstname ?? "") "
        operatorSignLbl.text = "Vaccine Mixer Signature*"
        operatorSignLbl.text = (operatorSignLbl.text ?? "") + "*"
        deviceOperatorNamebl.text = "Vaccine Mixer Name: \(fullName)"
        showImgVw(true)
        if certificateData[empIndex].isSigned {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[empIndex].signatureImg)
        }
        if shouldShowRejectedOrDraftSignature(empIndex: empIndex) {
            updateRejectedOrDraftSignature(empIndex: empIndex)
        } else if !(certificateData[empIndex].isCertExpired ?? false), prevController == "Draft" {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[empIndex].signatureImg)
            if certificateData[empIndex].signatureImg == "" {
                hideShowImgVw(true)
            }
        }
    }

    private func shouldShowRejectedOrDraftSignature(empIndex: Int) -> Bool {
        let cert = certificateData[empIndex]
        return (!(cert.isCertExpired ?? false) && prevController == "Rejected") ||
               ((cert.isCertExpired ?? false) && prevController == "Draft")
    }

    private func updateRejectedOrDraftSignature(empIndex: Int) {
        updateSignature(for: empIndex)
    }

    private func updatePreviousButtonState() {
        if empIndex > 0 {
            previousBtn.isEnabled = true
            previousBtn.isUserInteractionEnabled = true
            previousBtn.isHidden = false
        }
    }

    private func updateFSRSignature() {
        operatorSignLbl.text = "FSR Signature"
        let firstName = UserDefaults.standard.value(forKey: "FirstName") as? String ?? ""
        let lastName = UserDefaults.standard.value(forKey: "LastName") as? String ?? ""
        deviceOperatorNamebl.text = "Zoetis Representative: \(firstName) \(lastName)"
        nextBtn.isUserInteractionEnabled = false
        nextBtn.isHidden = true
        for item in certificateData {
            if item.fsrSign != "" {
                signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[0].fsrSign)
                hideShowImgVw(false)
            } else {
                if certificateData[0].fsrSign != "" {
                    hideShowImgVw(false)
                    signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[0].fsrSign)
                } else {
                    hideShowImgVw(true)
                }
            }
        }
    }

    private func updateFSRSignatureFromDefaults() {
        if let isSignedFSR = UserDefaults.standard.value(forKey: "isSignedFSR") as? Bool, isSignedFSR {
            hideShowImgVw(false)
            if let signatureImg = UserDefaults.standard.value(forKey: "FsrSign") as? String {
                signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: signatureImg)
            }
        }
    }

    private func handleDefaultScreen() {
        if empIndex > -1, empIndex == employeesAddedArr.count + 1 {
            updateFieldServiceTechnicianSignature()
        }
        if empIndex > -1, empIndex == employeesAddedArr.count {
            updateHatcheryManagerSignature()
        }
        if empIndex > -1, empIndex < employeesAddedArr.count {
            updateEmployeeSignature()
        }
        updatePreviousButtonState()
        if empIndex == employeesAddedArr.count + 1 {
            nextBtn.isEnabled = false
            nextBtn.isUserInteractionEnabled = false
            nextBtn.isHidden = true
            previousBtn.isEnabled = true
            previousBtn.isUserInteractionEnabled = true
            previousBtn.isHidden = false
        }
    }

    private func updateFieldServiceTechnicianSignature() {
        let firstname = UserContext.sharedInstance.userDetailsObj?.firstname
        let lastName = UserContext.sharedInstance.userDetailsObj?.lastName
        var fullName = firstname ?? ""
        if let lastName = lastName, !lastName.isEmpty {
            fullName = "\(firstname ?? "") \(lastName)"
        }
        operatorSignLbl.text = "Field Service Technician Signature*"
        operatorSignLbl.text = (operatorSignLbl.text ?? "") + "*"
        deviceOperatorNamebl.text = "Field Service Technician: \(fullName)"
        if let fsrSignature = curentCertification?.fsrSignature, !fsrSignature.isEmpty {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: fsrSignature)
        } else {
            hideShowImgVw(true)
        }
    }
 

    private func updateHatcheryManagerSignature() {
        operatorSignLbl.text = "Hatchery Manager Signature"
        deviceOperatorNamebl.text = "Hatchery Manager Name: "
        if let fsmName = curentCertification?.fsmName {
            deviceOperatorNamebl.text = "Hatchery Manager Name: \(fsmName)"
        }
        if let hatcheryManagerSign = curentCertification?.hatcheryManagerSign, !hatcheryManagerSign.isEmpty {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: hatcheryManagerSign)
        } else {
            hideShowImgVw(true)
        }
    }

    private func updateEmployeeSignature() {
        let emp = employeesAddedArr[empIndex]
        deviceOperatorNamebl.text = getEmpName(empobj: emp)
        if let signBase64 = emp.signBase64, !signBase64.isEmpty {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: signBase64)
        } else {
            hideShowImgVw(true)
        }
    }
    
    @IBAction func previousBtnAction(_ sender: UIButton) {
        empIndex -= 1
        signView.clearCanvas()
        if fromScreen == "PEFinishPopUpScreen" {
            handlePEFinishPopUpPrevious()
        } else {
            handleDefaultScreenPrevious()
        }
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "UpdateEmployeeSign"),
            object: nil,
            userInfo: ["index": empIndex, "rowIndex": rowIndex]
        )
    }

    private func handlePEFinishPopUpPrevious() {
        nextBtn.isUserInteractionEnabled = true
        nextBtn.isHidden = false
        if empIndex == 0 {
            previousBtn.isHidden = true
        }
        if empIndex > -1, certificateData.count > empIndex {
            updateVaccineMixerSignaturePrevious()
        }
        if empIndex > -1, empIndex == certificateData.count {
            updateManagerSignaturePrevious()
        }
    }

    private func updateVaccineMixerSignaturePrevious() {
        let firstname = certificateData[empIndex].name
        let fullName = "\(firstname ?? "") "
        nextBtn.isUserInteractionEnabled = true
        operatorSignLbl.text = "Vaccine Mixer Signature*"
        operatorSignLbl.text = (operatorSignLbl.text ?? "") + "*"
        deviceOperatorNamebl.text = "Vaccine Mixer Name: \(fullName)"
        hideShowImgVw(true)
        if certificateData[empIndex].isSigned {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[empIndex].signatureImg)
        }
        if regionID == 3 {
            updateRegionSignature(empIndex: empIndex)
        } else {
            updateDefaultSignature(empIndex: empIndex)
        }
    }

    private func updateRegionSignature(empIndex: Int) {
        hideShowImgVw(false)
        if certificateData[empIndex].signatureImg == "" {
            hideShowImgVw(true)
        } else {
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[empIndex].signatureImg)
        }
    }

    private func updateDefaultSignature(empIndex: Int) {
        updateSignature(for: empIndex)
    }
    
    private func updateSignature(for index: Int) {
        hideShowImgVw(false)
        if certificateData[index].signatureImg == "" {
            hideShowImgVw(true)
        } else {
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[index].signatureImg)
        }
    }
    

    private func updateManagerSignaturePrevious() {
        operatorSignLbl.text = "Manager Signature"
        deviceOperatorNamebl.text = "Manager Name: "
        nextBtn.isUserInteractionEnabled = false
        if let isSignedFSR = UserDefaults.standard.value(forKey: "isSignedFSR") as? Bool, isSignedFSR {
            hideShowImgVw(false)
            if let signatureImg = UserDefaults.standard.value(forKey: "FsrSign") as? String {
                if signatureImg == "" {
                    hideShowImgVw(false)
                } else {
                    signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: signatureImg)
                }
            }
        }
        if certificateData[empIndex - 1].fsrSign != "" {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: certificateData[empIndex].fsrSign)
        }
    }

    private func handleDefaultScreenPrevious() {
        if empIndex > -1, empIndex == employeesAddedArr.count + 1 {
            updateFieldServiceTechnicianSignaturePrevious()
        }
        if empIndex > -1, empIndex == employeesAddedArr.count {
            updateHatcheryManagerSignaturePrevious()
        }
        if empIndex > -1, empIndex < employeesAddedArr.count {
            updateDeviceOperatorSignaturePrevious()
        }
        updateButtonStatesPrevious()
    }

    private func updateFieldServiceTechnicianSignaturePrevious() {
        let firstname = UserContext.sharedInstance.userDetailsObj?.firstname
        let lastName = UserContext.sharedInstance.userDetailsObj?.lastName
        var fullName = firstname ?? ""
        if let lastName = lastName, !lastName.isEmpty {
            fullName = "\(firstname ?? "") \(lastName)"
        }
        operatorSignLbl.text = "Field Service Technician Signature*"
        operatorSignLbl.text = (operatorSignLbl.text ?? "") + "*"
        deviceOperatorNamebl.text = "Field Service Technician: \(fullName)"
        if let fsrSignature = curentCertification?.fsrSignature, !fsrSignature.isEmpty {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: fsrSignature)
        } else {
            hideShowImgVw(true)
        }
    }

    private func updateHatcheryManagerSignaturePrevious() {
        operatorSignLbl.text = "Hatchery Manager Signature"
        deviceOperatorNamebl.text = "Hatchery Manager Name: "
        if let fsmName = curentCertification?.fsmName {
            deviceOperatorNamebl.text = "Hatchery Manager Name: \(fsmName)"
        }
        if let hatcheryManagerSign = curentCertification?.hatcheryManagerSign, !hatcheryManagerSign.isEmpty {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: hatcheryManagerSign)
        } else {
            hideShowImgVw(true)
        }
    }

    private func updateDeviceOperatorSignaturePrevious() {
        operatorSignLbl.text = "Device Operator Signature*"
        operatorSignLbl.text = (operatorSignLbl.text ?? "") + "*"
        let emp = employeesAddedArr[empIndex]
        deviceOperatorNamebl.text = getEmpName(empobj: emp)
        if let signBase64 = emp.signBase64, !signBase64.isEmpty {
            hideShowImgVw(false)
            signImgVw.image = CodeHelper.sharedInstance.convertToImage(base64: signBase64)
        } else {
            hideShowImgVw(true)
        }
    }

    private func updateButtonStatesPrevious() {
        if empIndex == 0 {
            previousBtn.isEnabled = false
            previousBtn.isUserInteractionEnabled = false
            previousBtn.isHidden = true
            nextBtn.isEnabled = true
            nextBtn.isUserInteractionEnabled = true
            nextBtn.isHidden = false
        }
        if employeesAddedArr.count > 0 {
            nextBtn.isEnabled = true
            nextBtn.isUserInteractionEnabled = true
            nextBtn.isHidden = false
        }
        if empIndex == employeesAddedArr.count + 2 {
            nextBtn.isEnabled = false
            nextBtn.isUserInteractionEnabled = false
            nextBtn.isHidden = true
        }
    }

    // ... existing code ...
    
    fileprivate func clearSignatureViewData() {
        var base64 = ""
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateEmployeeSign"), object: nil, userInfo: ["index":empIndex, "rowIndex":rowIndex, "hasSignCleared": true
                                                                                                                          ])
        if empIndex > -1 &&  certificateData.count > empIndex {
            certificateData[empIndex].isSigned = false
            certificateData[empIndex].signatureImg = base64
        }
        
        if empIndex > -1 && empIndex == certificateData.count{
            
            if let isSignedFSR = UserDefaults.standard.value(forKey: "isSignedFSR") as? Bool, isSignedFSR {
               
                    hideShowImgVw(false)
                    
                if UserDefaults.standard.value(forKey: "FsrSign") as? String != nil {
                        UserDefaults.standard.setValue(nil, forKey: "FsrSign")
                        UserDefaults.standard.setValue(false, forKey: "isSignedFSR")
                    }
                
            }
            var k = 0
            for item in certificateData {
                
                certificateData[k].fsrSign = ""
                k = k + 1
            }
        }
        hideShowImgVw(true)
        signView.clearCanvas()
    }
    
    @IBAction func clearBtnAction(_ sender: UIButton) {
        if fromScreen == "PEFinishPopUpScreen" {
            
            clearSignatureViewData()
            
        }
        else {
            var base64 = ""
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateEmployeeSign"), object: nil, userInfo: ["index":empIndex, "rowIndex":rowIndex, "hasSignCleared": true
                                                                                                                              ])
            if empIndex > -1 && empIndex == employeesAddedArr.count + 1 {
                curentCertification?.fsrSignature = base64
            }
            
            if empIndex > -1 && empIndex == employeesAddedArr.count{
                curentCertification?.hatcheryManagerSign = base64
            }
            
            if rowIndex == 1 && employeesAddedArr.count > 0 && empIndex > -1 && employeesAddedArr.count > empIndex{
                var emp = employeesAddedArr[empIndex]
                emp.signBase64 = base64
                employeesAddedArr[empIndex] = emp
            }
            
            if empIndex > -1 && employeesAddedArr.count > empIndex{
                var emp = employeesAddedArr[empIndex]
                emp.signBase64 = base64
                employeesAddedArr[empIndex] = emp
            }
            hideShowImgVw(true)
            signView.clearCanvas()
        }
    }
    
    @IBAction func shippingBtnAction(_ sender: UIButton) {
        print(appDelegateObj.testFuntion())
    }
    
    // MARK: - METHODS
    
    func hideShowImgVw(_ hide:Bool){
        signImgVw.isHidden = hide
    }
    
    func showImgVw(_ hide:Bool){
        signImgVw.isHidden = !hide
    }
    
    func getEmpName(empobj:VaccinationEmployeeVM)-> String{
        var nameArr = [String]()
        if empobj.firstName != nil && empobj.firstName != ""{
            nameArr.append(empobj.firstName!)
        }
        if empobj.middleName != nil && empobj.middleName != ""{
            nameArr.append(empobj.middleName!)
        }
        if empobj.lastName != nil && empobj.lastName != ""{
            nameArr.append(empobj.lastName!)
        }
        
        let nameStr = "Device Operator Name: \( nameArr.joined(separator: " "))"
        
        return nameStr
    }
    
    
    func showHideBtn(flag:Bool){
        nextBtn.isHidden = flag
        nextBtn.isUserInteractionEnabled = !flag
        previousBtn.isHidden = flag
        previousBtn.isUserInteractionEnabled = !flag
    }
    
    func setConstraint(){
        operatorNameTopConstraint.constant = 10
        operatornameConstraint.constant = 21
    }
    
    func setBordeViewWithColor(_ view:UIView){
        view.layer.borderWidth  = 2
        view.layer.borderColor = UIColor.getBorderColorr().cgColor
        view.layer.cornerRadius = 18.5
    }
    
    func removeConstraint(){
        operatorNameTopConstraint.constant = 0
        operatornameConstraint.constant = 0
    }
    
    
    func SignatureViewDidCaptureSignature(view: SignatureView, signature: Signature?) {
        print(appDelegateObj.testFuntion())
        
    }
    
    fileprivate func handleEmpIndex(_ base64: String) {
        if empIndex > -1 {
            if certificateData.count > empIndex {
                isRunningBack = true
                certificateData[empIndex].isSigned = true
                certificateData[empIndex].signatureImg = base64
            }
            if empIndex == certificateData.count {
                curentCertification?.hatcheryManagerSign = base64
                certificateData[0].fsrSign = base64
                UserDefaults.standard.setValue(base64, forKey: "FsrSign")
                UserDefaults.standard.setValue(true, forKey: "isSignedFSR")
            }
        }
    }
    
    
    fileprivate func handleSignImageValidation(_ view: SignatureView) {
        signImage = view.captureSignatureFromView()!
        var base64 = ""
        if let sign = signImage{
            base64 = CodeHelper.sharedInstance.convertToBase64(image: sign ) ?? ""
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateEmployeeSign"), object: nil, userInfo: ["index":empIndex, "rowIndex":rowIndex, "sign": base64])
        if empIndex > -1 && empIndex == employeesAddedArr.count + 1 {
            
            curentCertification?.fsrSignature = base64
        }
        if empIndex > -1 && empIndex == employeesAddedArr.count{
            curentCertification?.hatcheryManagerSign = base64
        }
        
        if rowIndex == 1 && employeesAddedArr.count > 0 && empIndex > -1 && employeesAddedArr.count > empIndex{
            var emp = employeesAddedArr[empIndex]
            emp.signBase64 = base64
            employeesAddedArr[empIndex] = emp
        }
    }
    
    func SignatureViewDidFinishDrawing(view: SignatureView) {
        
        if fromScreen == "PEFinishPopUpScreen" {
            signImage = view.captureSignatureFromView()!
            var base64 = ""
            if let sign = signImage {
                base64 = CodeHelper.sharedInstance.convertToBase64(image: sign ) ?? ""
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UpdateEmployeeSign"), object: nil, userInfo: ["index":empIndex, "rowIndex":rowIndex, "sign": base64])
            handleEmpIndex(base64)
            blockSignature?(certificateData)
        } else {
            
            handleSignImageValidation(view)
        }
    }
}
