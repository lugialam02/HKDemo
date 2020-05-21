//
//  InterfaceController.swift
//  HKDemo WatchKit Extension
//
//  Created by MacMini on 5/15/20.
//  Copyright © 2020 tma. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {
    // MARK: - Properties
    var healthStore: HKHealthStore?
    var lastHeartRate = 0.0
    let beatCountPerMinute = HKUnit(from: "count/min")
    var isAuthorized = false
    
    @IBOutlet weak var heartRateSpeedLabel: WKInterfaceLabel!
    @IBOutlet weak var bpmLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let sampleType: Set<HKSampleType> = [HKSampleType.quantityType(forIdentifier: .heartRate)!]
            
        healthStore = HKHealthStore()
            
        healthStore?.requestAuthorization(toShare: sampleType, read: sampleType, completion: { (success, error) in
            if success {
                self.isAuthorized = true
                self.startHeartRateQuery(quantityTypeIdentifier: .heartRate)
            } else {
                self.isAuthorized = false
            }
        })
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if self.isAuthorized {
            self.startHeartRateQuery(quantityTypeIdentifier: .heartRate)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        //        // 1
        //        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        //
        //        // 2
        //        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
        //            query, samples, deletedObjects, queryAnchor, error in
        //
        //        // 3
        //            guard let samples = samples as? [HKQuantitySample] else { return }
        //
        //            self.process(samples, type: quantityTypeIdentifier)
        //        }
        //
        //        // 4
        //        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        //
        //        query.updateHandler = updateHandler
        //
        //        // 5
        //        healthStore?.execute(query)
        
        let heartRate = HKQuantityType.quantityType(forIdentifier: quantityTypeIdentifier)
        let sort = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        let sampleQuery = HKSampleQuery(sampleType: heartRate!, predicate: nil, limit: 1, sortDescriptors: sort, resultsHandler: { [unowned self] (query, results, error) in
            self.process(results as! [HKQuantitySample], type: quantityTypeIdentifier)
        })
        
        healthStore?.execute(sampleQuery)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: beatCountPerMinute)
                print("❤ Last heart rate was: \(lastHeartRate)")
            }
            
            updateHeartRateLabel()
            updateHeartRateSpeedLabel()
        }
    }
    
    private func updateHeartRateLabel() {
        let heartRate = String(Int(lastHeartRate))
        bpmLabel.setText(heartRate)
    }
    
    private func updateHeartRateSpeedLabel() {
        switch lastHeartRate {
        case _ where lastHeartRate > 130:
            heartRateSpeedLabel.setText("High")
            heartRateSpeedLabel.setTextColor(.red)
        case _ where lastHeartRate > 100:
            heartRateSpeedLabel.setText("Moderate")
            heartRateSpeedLabel.setTextColor(.yellow)
        default:
            heartRateSpeedLabel.setText("Low")
            heartRateSpeedLabel.setTextColor(.blue)
        }
    }
}
