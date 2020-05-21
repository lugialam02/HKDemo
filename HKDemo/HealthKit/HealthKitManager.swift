//
//  File.swift
//  HKDemo
//
//  Created by MacMini on 5/15/20.
//  Copyright © 2020 tma. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {
    private enum HealthkitSetupError: Error {
      case notAvailableOnDevice
      case dataTypeNotAvailable
    }
    
    // Validates if the HealthKit framework has the authorization to read
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        //1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
          completion(false, HealthkitSetupError.notAvailableOnDevice)
          return
        }
        
        //2. Prepare the data types that will interact with HealthKit
        // bodyTemperature, heartRate, BMI, height, BM
        guard   let bodyTemperature = HKObjectType.quantityType(forIdentifier: .bodyTemperature),
                let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
            else {
            
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
        //3. Prepare a list of types you want HealthKit to read and write
//        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
//                                                        activeEnergy,
//                                                        HKObjectType.workoutType()]
        
        let healthKitTypesToRead: Set<HKObjectType> = [bodyTemperature,
                                                       heartRate,
                                                       height,
                                                       bodyMassIndex,
                                                       bodyMass,
                                                       dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       HKObjectType.workoutType()]
        
        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: nil,
                                             read: healthKitTypesToRead) { (success, error) in
          completion(success, error)
        }
    }
}
