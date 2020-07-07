//
//  LoginManager.swift
//  Sneni
//
//  Created by Daman on 24/06/20.
//  Copyright © 2020 Taran. All rights reserved.
//

import UIKit
import AuthenticationServices


public class AppleLoginData: NSObject {
    
    public var email : String?
    public var userId : String?
    public var givenName : String?
    public var familyName : String?

    public init(email: String?,userId: String?,givenName:String?,familyName: String? ) {
        
      self.email = email
      self.userId = userId
      self.givenName = givenName
      self.familyName = familyName
        
    }
      
    override init() {
        super.init()
    }
    
}

//To be able to subclass it, the base class WDBaseViewController needs to be defined as open instead of public in the framework you are using.
open class RoyoLoginManager: UIViewController, ASAuthorizationControllerDelegate {
 
    public typealias AppLoginCompletion = (AppleLoginData) -> ()
    var appLoginCompletion: AppLoginCompletion?
    public func loginWithAppleButtonPressed(completion: @escaping AppLoginCompletion) {
        
        if #available(iOS 13.0, *) {
            self.appLoginCompletion = completion
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
            
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK:- ASAuthorizationControllerDelegate`

    @available(iOS 13.0, *)
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            let obj:AppleLoginData = AppleLoginData(email: email, userId: userIdentifier, givenName: fullName?.givenName ?? "", familyName: fullName?.familyName ?? "")
            
            self.appLoginCompletion?(obj)
            
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
        }
        else if let appleIDCredential = authorization.credential as?  ASPasswordCredential {
            let userIdentifier = appleIDCredential.user

            let obj:AppleLoginData = AppleLoginData(email: "", userId: userIdentifier, givenName: "", familyName: "")
            
            self.appLoginCompletion?(obj)
        }
        
    }
    
    @available(iOS 13.0, *)
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}
