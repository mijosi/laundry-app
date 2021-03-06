//
//  ReportManager.swift
//  laudry app
//
//  Created by Michalina Simik on 2/17/16.
//  Copyright © 2016 Michalina Simik. All rights reserved.
//

import Foundation

class ReportManager {
    static let sharedInstance = ReportManager()
    let defaultUser = NSUserDefaults.standardUserDefaults()
    
    func addReservation(laundry: Machine, reservedTime: NSDate, completion: (NSError?) -> Void) {
        let reservation = Reservation()
        reservation.machineId = laundry.machineId
        reservation.username = Profile.userProfiles.getDefaultUser().username
            //Profile.userProfiles.currentUser!.username
        reservation.reservedTime = reservedTime
        reservation.orderNumber = laundry.orderNumber
        DynamoDB.save(reservation) { (error) -> Void in
            if error != nil {
                print("error in adding resa: \(error)")
            } else {
                self.saveNotification(reservation, machine: nil)
            }
            completion(error)
        }
    }
    
    
    func getReservationsForUser(username: String, completion: ([Reservation]?, NSError?) -> Void) {
        DynamoDB.search(Reservation.self, parameterName: "username", parameterValue: username, matchMode: .Exact) { (reservations, error) -> Void in
            //--------------------
            if let reservations = reservations {
                let dateToCompare = NSDate().dateByAddingTimeInterval(Double(-900))
                for each in reservations {
                    if each.reservedTime.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
                        DynamoDB.delete(each) { (error) -> Void in
                            //-----------
                }   }   }
                
                DynamoDB.search(Reservation.self, parameterName: "username", parameterValue: username, matchMode: .Exact) { (reservations, error) -> Void in
                    //------------
                
                    if var reservations = reservations {
                        reservations.sortInPlace({ (reservation1: Reservation, reservation2: Reservation) -> Bool in
                            return reservation1.reservedTime.compare(reservation2.reservedTime) == NSComparisonResult.OrderedAscending
            })   }   }   }
            completion(reservations, error)
        }
    }
    
    
    func getReservationForMachineAndUser(machineId: String, username: String, completion: (Reservation?, NSError?) -> Void) {
        DynamoDB.search(Reservation.self, parameters: ["machineId": machineId, "username": username, "cancel": false], matchMode: .Exact){ (reservations, error) -> Void in
            var error = error
            if error == nil && reservations?.count > 1 {
                error = NSError(domain: "laundry", code: 500, userInfo: [NSLocalizedDescriptionKey : "too many reservations found"])
            }
            completion(reservations?.first, error)
        }
    }
    
    
    func getReservationForMachine(machineId: String, completion: ([Reservation]?, NSError?) -> Void) {
        DynamoDB.search(Reservation.self, parameters: ["machineId": machineId, "cancel": false], matchMode: .Exact) { (reservations, error) -> Void in
            //--------------------
            if let reservations = reservations {
                let dateToCompare = NSDate().dateByAddingTimeInterval(Double(-900))
                for each in reservations {
                    if each.reservedTime.compare(dateToCompare) == NSComparisonResult.OrderedAscending {
                        DynamoDB.delete(each) { (error) -> Void in
                            // ------------- ?
                        }
                    }
                }
                DynamoDB.search(Reservation.self, parameterName: "machineId", parameterValue: machineId, matchMode: .Exact) { (reservations, error) -> Void in
                    //------------
                }
            }
            completion(reservations, error)
        }
    }
    
    
    func addCancelledReservation(reservation: Reservation, completion: (NSError?) -> Void) {
        reservation.cancel = true
        DynamoDB.save(reservation) { (error) -> Void in
            completion(error)
        }
    }
    
    
    func addReport(machine: Machine, completion: (NSError?) -> Void) {
        let report = Report()
        report.machineId = machine.machineId
        report.machineType = machine.machineType
        report.timeFinished = machine.workEndDate
        report.username = machine.usernameUsing
        report.orderNumber = machine.orderNumber
        DynamoDB.save(report) { (error) -> Void in
            if error != nil {
                print("cannot add report: \(error)")
            }
            completion(error)
    }   }
    
    
    func getReporsForUser(username: String, completion: ([Report]?, NSError?) -> Void) {
        DynamoDB.search(Report.self, parameterName: "username", parameterValue: username, matchMode: .Exact) { (reports, error) -> Void in
            //--------------------
            completion(reports, error)
        }}

    func saveNotification(reservation: Reservation?, machine: Machine?) {
        let notification = UILocalNotification()
        notification.alertAction = "ok"
        notification.soundName = UILocalNotificationDefaultSoundName
        
        if let reservation = reservation {
            notification.alertBody = "machine # \(reservation.orderNumber) is reserved for you in 15 min"
            notification.fireDate = reservation.reservedTime.dateByAddingTimeInterval(-900)
        } else if let machine = machine {
            notification.alertBody = "your laundry is done!"
            notification.fireDate = machine.workEndDate
        }
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    
}
