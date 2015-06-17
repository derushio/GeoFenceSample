//
//  ViewController.swift
//  GeoFenceSample
//
//  Created by 中塩成海 on 2015/06/16.
//  Copyright (c) 2015年 Derushio. All rights reserved.
//  Supporting Files/Info.plist, AppDelegate.swiftに注意
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
// CLLocationManagerDelegateを実装（これによりlocationManagerのdelegateをselfに設定できる）
    
    @IBOutlet weak var geoFenceStatusLabel: UILabel!
    @IBOutlet weak var gpsStatusLabel: UILabel!
    
    @IBOutlet weak var latEdit: UITextField!
    @IBOutlet weak var lngEdit: UITextField!
    @IBOutlet weak var radiusEdit: UITextField!
    // IBOutlet storyboardから関連付けられているオブジェクト
    // weakは関連付けられたオブジェクトが削除されたら自分も自動的に削除する
    
    var locationManager: CLLocationManager?
    // ロケーション情報を管理するオブジェクト
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        // locationManagerをCLLocationManagerという型を元にインスタンス（実体化/生成）
        
        locationManager?.delegate = self
        // locationManagerのdelegateを自分に設定
        
        locationManager?.requestAlwaysAuthorization()
        // 画面外での検知を許可
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        // ロケーション更新頻度を最適化してもらう
        
        locationManager?.startUpdatingLocation()
        // 自分のロケーション変化を検知スタート（これをコメントアウトするとバッテリー消費量が減る)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 機能の許可情報が変わっていた場合は
        switch (status) {
        case CLAuthorizationStatus.Denied:
            // 許可されていない場合は
            
            manager.requestWhenInUseAuthorization()
            // 許可をリクエストする
            break
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        // ロケーションモニタリングがスタートしたら
        geoFenceStatusLabel.text = "GeoFenceStart"
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // ロケーション情報が更新されたら
        
        var location = locations.last as! CLLocation
        var lat = String(format: "%2.6f", location.coordinate.latitude)
        var lng = String(format: "%2.6f", location.coordinate.longitude)
        gpsStatusLabel.text = "LocationChange " + lat + ", " + lng
        // ロケーションを表示する
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        // GeoFence内に入ったら
        
        geoFenceStatusLabel.text = "GeoFence:In"
        // 表示する
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        // GeoFence内から出たら
        
        geoFenceStatusLabel.text = "GeoFence:Out"
        // 表示する
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        // 失敗したら
        
        gpsStatusLabel.text = "Error"
        // エラーを表示する
    }
    
    @IBAction func onStartGeoFenceClick(sender: AnyObject) {
        if (locationManager != nil) {
            for region in locationManager!.monitoredRegions {
                locationManager!.stopMonitoringForRegion(region as! CLCircularRegion)
            }
        }
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        // 既に登録されている情報を削除
        
        
        var lat = NSString(string: latEdit.text).doubleValue
        var lng = NSString(string: lngEdit.text).doubleValue
        var radius = NSString(string: radiusEdit.text).doubleValue
        // EditTextFieldから情報を取得
        
        if (0 < lat && 0 < lng && 0 < radius) {
            // 何も入れられてない場合は0が返ってくる
            
            var target = CLLocationCoordinate2DMake(lat, lng)
            var identifier = "Point"
            // ターゲット情報を記述
            
            var region = CLCircularRegion(circularRegionWithCenter: target, radius: radius, identifier: identifier)
            // ターゲット情報を元にCLCirclarRegionをインスタンス
            
            locationManager?.startMonitoringForRegion(region)
            // locationManagerにregionのモニタリングを開始させる
            
            var localNotification = UILocalNotification();
            localNotification.alertBody = "目的地に着きました";
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.alertAction = "OK";
            localNotification.regionTriggersOnce = true;
            localNotification.region = region;
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification);
            // 画面外にいるときはノーティフィケーションに通知する
        } else {
            geoFenceStatusLabel.text = "TextFieldError"
            // テキストフィールドがおかしいことを通知する
        }
    }
}

