//
//  UserHealthProfile.swift
//  HKDemo
//
//  Created by MacMini on 5/19/20.
//  Copyright © 2020 tma. All rights reserved.
//

import Foundation
import HealthKit

enum ProfileDataError: Error {
  
  case missingBodyMassIndex
  
  var localizedDescription: String {
    switch self {
    case .missingBodyMassIndex:
      return "Unable to calculate body mass index with available profile data."
    }
  }
}

class UserHealthProfile {
  
  var age: Int?
  var biologicalSex: HKBiologicalSex?
  var bloodType: HKBloodType?
  var heightInMeters: Double?
  var weightInKilograms: Double?

  var bodyMassIndex: Double? {

    guard let weightInKilograms = weightInKilograms,
      let heightInMeters = heightInMeters,
      heightInMeters > 0 else {
        return nil
    }

    return (weightInKilograms/(heightInMeters*heightInMeters))
  }
}
