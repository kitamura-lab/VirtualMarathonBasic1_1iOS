//
//  CourseManager.swift
//  VirtualMarathonBasic1_1iOS
//
//  Created by 北村泰彦 on 2018/04/26.
//  Copyright © 2018年 Yasuhiko Kitamura. All rights reserved.
//

import Foundation
import GoogleMaps

class CourseManager {
    
    var course: [CLLocation] = [CLLocation]()
    var courseDistance: [Double] = [Double]()
    
    init() {
        var csvArr: [String] = [String]()
        if let csvPath = Bundle.main.path(forResource: "KobeCourse", ofType: "txt") {
            do {
                let csvStr = try String(contentsOfFile:csvPath, encoding:String.Encoding.utf8)
                csvArr = csvStr.components(separatedBy: .newlines)
                //print(csvArr)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        for i in csvArr {
            //var latlng: [String] = [String]()
            let latlng = i.components(separatedBy: ",")
            if latlng.count == 2 {
                let location = CLLocation(latitude: NSString(string: latlng[0]).doubleValue, longitude: NSString(string: latlng[1]).doubleValue)
                course.append(location)
            }
        }
        
        courseDistance.append(0.0)
        var distance = 0.0
        for i in 0...course.count-2 {
            //print(i,course.count)
            distance += course[i].distance(from: course[i+1])
            courseDistance.append(distance)
        }
        
    }
    
    func getLocation(dis: Double) -> CLLocation {
        if dis >= courseDistance[courseDistance.count-1] {
            return course[course.count]
        }
        
        var index = 0
        for cd in courseDistance {
            if dis < cd {
                break
            }
            index = index+1
        }
        
        let lat = course[index-1].coordinate.latitude + (course[index].coordinate.latitude - course[index-1].coordinate.latitude) * (dis - courseDistance[index-1]) / (courseDistance[index] - courseDistance[index-1]);
        let lng = course[index-1].coordinate.longitude + (course[index].coordinate.longitude - course[index-1].coordinate.longitude) * (dis - courseDistance[index-1]) / (courseDistance[index] - courseDistance[index-1]);

        let location = CLLocation(latitude: lat, longitude: lng)
        return location
    }
    
    func getCourse() -> [CLLocation] {
        return course
    }
    
    func test() -> CLLocation {
        
        return course[0]
    }
}
