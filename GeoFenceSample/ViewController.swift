//
//  ViewController.swift
//  GeoFenceSample
//
//  Created by 中塩成海 on 2015/06/16.
//  Copyright (c) 2015年 Derushio. All rights reserved.
//  Supporting Files/Info.plistに注意
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var geoFenceStatusLabel: UILabel!
    @IBOutlet weak var gpsStatusLabel: UILabel!
    
    @IBOutlet weak var latEdit: UITextField!
    @IBOutlet weak var lngEdit: UITextField!
    @IBOutlet weak var radiusEdit: UITextField!
    
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch (status) {
        case CLAuthorizationStatus.Denied:
            manager.requestWhenInUseAuthorization()
            break
            
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        geoFenceStatusLabel.text = "GeoFenceStart"
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location = locations.last as! CLLocation
        var lat = String(format: "%2.6f", location.coordinate.latitude)
        var lng = String(format: "%2.6f", location.coordinate.longitude)
        gpsStatusLabel.text = "LocationChange " + lat + ", " + lng
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        geoFenceStatusLabel.text = "GeoFence:In"
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        geoFenceStatusLabel.text = "GeoFence:Out"
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        gpsStatusLabel.text = "Error"
    }
    
    @IBAction func onStartGeoFenceClick(sender: AnyObject) {
        if (locationManager != nil) {
            for region in locationManager!.monitoredRegions {
                locationManager!.stopMonitoringForRegion(region as! CLCircularRegion)
            }
        }
        
        
        var lat = NSString(string: latEdit.text).doubleValue
        var lng = NSString(string: lngEdit.text).doubleValue
        var radius = NSString(string: radiusEdit.text).doubleValue
        
        if (0 < lat && 0 < lng && 0 < radius) {
            var target = CLLocationCoordinate2DMake(lat, lng)
            var identifier = "Point"
            
            var region = CLCircularRegion(center: target, radius: radius, identifier: identifier)
            locationManager?.startMonitoringForRegion(region)
        } else {
            geoFenceStatusLabel.text = "TextFieldError"
        }
    }

}

