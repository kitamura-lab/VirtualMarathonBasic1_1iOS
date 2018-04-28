//
//  ViewController.swift
//  VirtualMarathonBasic1_1iOS
//
//  Created by 北村泰彦 on 2018/04/26.
//  Copyright © 2018年 Yasuhiko Kitamura. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    // You don't need to modify the default init(nibName:bundle:) method.
    
    var mapView: GMSMapView!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var lastLocation: CLLocation?
    var totalDistance: Double = 0.0
    
    let cm = CourseManager()
    
    let label = UILabel()
    let dlabel = UILabel()
    
    let button = UIButton()
    
    var flag = false
    var timer: Timer!
    var startTime = Date()
    
    override func loadView() {

        let cm = CourseManager()
        print("CourseManager: \(totalDistance)")
        let current = cm.getLocation(dis: totalDistance)
        
        let camera = GMSCameraPosition.camera(withLatitude: current.coordinate.latitude, longitude: current.coordinate.longitude, zoom: 17.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        
        let path = GMSMutablePath()
        let course = cm.getCourse()
        for loc in course {
            path.add(CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
        }
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 5.0
        polyline.strokeColor = .red
        polyline.map = mapView
        
        let position = CLLocationCoordinate2D(latitude: current.coordinate.latitude, longitude: current.coordinate.longitude)
        let marker = GMSMarker(position: position)
        marker.title = "Here"
        marker.map = mapView
        
        mapView.isMyLocationEnabled = true
        view = mapView
        
        label.text = "00:00:00"
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 100, y: 30)
        label.backgroundColor = UIColor.white
        view.addSubview(label)
        
        dlabel.text = "000.00"
        dlabel.sizeToFit()
        dlabel.frame.origin = CGPoint(x: 200, y: 30)
        dlabel.backgroundColor = UIColor.white
        view.addSubview(dlabel)
        
        button.setTitle("START", for: .normal)
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.black, for: .normal)
        button.sizeToFit()
        button.frame.origin = CGPoint(x: 20, y: 30)
        button.addTarget(self, action: #selector(buttonEvent(sender:)), for: .touchUpInside)
        view.addSubview(button)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager() // インスタンスの生成
        locationManager.delegate = self // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        
    }
    
    func startTimer() {
        
        if timer != nil{
            // timerが起動中なら一旦破棄する
            timer.invalidate()
        }
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.01,
            target: self,
            selector: #selector(self.timerCounter),
            userInfo: nil,
            repeats: true)
        
        startTime = Date()
    }
    
    func stopTimer() {
        if timer != nil{
            timer.invalidate()
            
            //label.text = "00:00:00"
        }
    }
    
    @objc func timerCounter() {
        
        //if flag == 0 {return}
        //let now = Date()
        
        let currentTime = Date().timeIntervalSince(startTime)
        
        // fmod() 余りを計算
        let minute = (Int)(fmod((currentTime/60), 60))
        // currentTime/60 の余り
        let second = (Int)(fmod(currentTime, 60))
        // floor 切り捨て、小数点以下を取り出して *100
        let msec = (Int)((currentTime - floor(currentTime))*100)
        
        // %02d： ２桁表示、0で埋める
        let sMinute = String(format:"%02d", minute)
        let sSecond = String(format:"%02d", second)
        let sMsec = String(format:"%02d", msec)
        
        label.text = sMinute+":"+sSecond+":"+sMsec
    }

}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // 許可を求めるコードを記述する（後述）
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if flag == false {
            return
        }
        
        for location in locations {
            print("緯度:\(location.coordinate.latitude) 経度:\(location.coordinate.longitude) 取得時刻:\(location.timestamp.description)")
            
            currentLocation = location;
            
            if lastLocation == nil {
                lastLocation = currentLocation;
                //return;
            }
            let distance = currentLocation?.distance(from: lastLocation!)
            totalDistance += distance!
            
            //let cm = CourseManager()
            print("CourseManager: \(totalDistance)")
            let current = cm.getLocation(dis: totalDistance)
        
            let camera = GMSCameraPosition.camera(withLatitude: current.coordinate.latitude, longitude: current.coordinate.longitude, zoom: 17.0)
            //mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            mapView.camera = camera
            
            let position = CLLocationCoordinate2D(latitude: current.coordinate.latitude, longitude: current.coordinate.longitude)
            let marker = GMSMarker(position: position)
            marker.title = "Here"
            marker.map = mapView
            
            //mapView.isMyLocationEnabled = true
            view = mapView
            
            dlabel.text = String(format:"%.2f", totalDistance)
        }
    }
    
    @objc func buttonEvent(sender: UIButton) {
        print("ボタンが押された")
        print("このメソッドを呼び出したボタンの情報: \(sender)")
        //startTimer()
        if flag==false {
            flag = true
            startTimer()
            button.setTitle("STOP", for: .normal)
        }
        else {
            flag = false
            stopTimer()
            button.setTitle("START", for: .normal)
        }
    }
}	

