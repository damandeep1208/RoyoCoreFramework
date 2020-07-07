//
//  RKLocationManager.swift
//  InPerson
//
//  Created by CB Macmini_3 on 17/12/15.
//  Copyright © 2015 Rico. All rights reserved.
//

import Foundation
import CoreLocation
import AFNetworking

public struct Location {
    public var currentLat : Double?
    public var currentLng : Double?
    public var currentFormattedAddr : String?
    public var currentCity : String?
}

public struct DeviceTime {
    
    public var currentTime : String {
        get{
            return  localTimeFormatter.string(from: Date())
        }
    }
    
    public var currentDate : String{
        get{
            return localDateFormatter.string(from: Date())
        }
    }
    
    public var currentZone : String {
        get {
            return NSTimeZone.local.identifier
        }
    }
    
    public func convertCreatedAt (createdAt : String?) -> Date?{
        return localDateTimeFormatter.date(from: createdAt ?? "")
    }
    
    public var localTimeZoneFormatter = DateFormatter()
    public var localTimeFormatter = DateFormatter()
    public var localDateFormatter = DateFormatter()
    public var localDateTimeFormatter = DateFormatter()
    
    public func setUpTimeFormatters(){
        localTimeFormatter.dateFormat = "h:mm a"
        localDateFormatter.dateFormat = "MMM dd yyyy"
        localDateTimeFormatter.dateFormat = "MMM dd yyyy h:mm a Z"
        
    }
}

open class LocationManager: NSObject, CLLocationManagerDelegate {
    
    public let locationManager = CLLocationManager()
    public var currentLocation : Location? = Location()
    public var currentTime : DeviceTime? = DeviceTime()
    public var currentPlacemark: CLPlacemark?
    public static let sharedInstance = LocationManager()
    public var isFirstTime : Bool = true
    public var isLocationServicesEnabled : Bool {
        get {
            return CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .denied
        }
    }
    var trackingStarted = false
    func fireObserver() {
        NotificationCenter.default.post(name: NSNotification.Name("LocationFetched"), object: nil)
    }
    
    public func startTrackingUser(){
        
//        if SKAppType.type.isJNJ {
//            return
//        }
        currentTime?.setUpTimeFormatters()
        // Ask for Authorisation from the User.
//        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
       trackingStarted = false
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.startUpdatingLocation()
                self.isFirstTime = true
                trackingStarted = true
            }
            else if status == .notDetermined {
                //handled in didChangeAuthorization delegate
            }
            else {
                NotificationCenter.default.post(name: NSNotification.Name("LocationNotFetched"), object: nil)
            }
        } else {
            print("Location not on")
            NotificationCenter.default.post(name: NSNotification.Name("LocationNotFetched"), object: nil)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        NotificationCenter.default.post(name: NSNotification.Name("LocationNotFetched"), object: nil)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if !trackingStarted {
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                locationManager.startUpdatingLocation()
                self.isFirstTime = true
                trackingStarted = true
            }
            else {
                NotificationCenter.default.post(name: NSNotification.Name("LocationNotFetched"), object: nil)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if self.isFirstTime {
            
            let locValue = (manager.location?.coordinate) ?? CLLocationCoordinate2D()
            self.currentLocation?.currentLat = locValue.latitude
            self.currentLocation?.currentLng = locValue.longitude
            
            guard let location = locations.last else{
                return
            }
            self.currentLocation?.currentLat = location.coordinate.latitude
            self.currentLocation?.currentLng = location.coordinate.longitude
//            LocationSingleton.sharedInstance.selectedLatitude = location.coordinate.latitude
//            LocationSingleton.sharedInstance.selectedLongitude = location.coordinate.longitude
            
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in
                if let placeMark = placemarks?.first {
                    self.formatAddress(placeMark: placeMark)
                    
                    NotificationCenter.default.post(name: NSNotification.Name("LocationFetched"), object: nil)
                }
            }
            
            locationManager.stopUpdatingLocation()
            self.isFirstTime = false
            
        }

    }
       
    private func formatAddress (placeMark : CLPlacemark){
        
        let address = "\(/placeMark.thoroughfare), \(/placeMark.locality), \(/placeMark.subLocality), \(/placeMark.administrativeArea), \(/placeMark.postalCode), \(/placeMark.country)"

        //Nitin
       // let address = "\(/placeMark.name), \(/placeMark.locality)"

        self.currentLocation?.currentFormattedAddr = address
        self.currentPlacemark = placeMark
//        if let place = LocationSingleton.sharedInstance.selectedAddress {
//            print(place)
//        } else {
//            LocationSingleton.sharedInstance.selectedAddress = placeMark
//        }
        
        guard let city = placeMark.addressDictionary?["City"] as? String else{
            if let city = placeMark.subAdministrativeArea{
                self.currentLocation?.currentCity = city
            }
            else if let city = placeMark.administrativeArea{
                self.currentLocation?.currentCity = city
            }
            else if let city = placeMark.country{
                self.currentLocation?.currentCity = city
            }
            return
        }
        self.currentLocation?.currentCity = city
        
    }
 
}



