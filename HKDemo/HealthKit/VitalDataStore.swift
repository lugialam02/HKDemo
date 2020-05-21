//
//  File.swift
//  HKDemo
//
//  Created by MacMini on 5/19/20.
//  Copyright © 2020 tma. All rights reserved.
//

import Foundation
import HealthKit

class VitalDataStore {
    public func fetchLatestHeartRateSample(completion: @escaping (_ samples: [HKQuantitySample]?) -> Void) {

        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }

        /// Predicate for specifiying start and end dates for the query
        let predicate = HKQuery.predicateForSamples(
            withStart: Date.distantPast,
            end: Date(),
            options: .strictEndDate)

        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)

        /// Create the query
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]) { (_, results, error) in

                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }

                completion(results as? [HKQuantitySample])
        }

        /// Execute the query in the health store
        let healthStore = HKHealthStore()
        healthStore.execute(query)
    }

    class func getLatestHeartRateSample(completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, nil)
            return
        }

        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)

        let limit = 1

        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (_, samples, error) in

                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {

                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKQuantitySample else {

                                                        completion(nil, error)
                                                        return
                                                }

                                                completion(mostRecentSample, nil)
                                            }
        }

        HKHealthStore().execute(sampleQuery)
    }

    class func getBodyTempSample(completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .bodyTemperature) else {
            completion(nil, nil)
            return
        }

        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)

        let limit = 1

        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (_, samples, error) in

                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {

                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKQuantitySample else {

                                                        completion(nil, error)
                                                        return
                                                }

                                                completion(mostRecentSample, nil)
                                            }
        }

        HKHealthStore().execute(sampleQuery)
    }
}
