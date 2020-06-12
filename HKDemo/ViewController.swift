//
//  ViewController.swift
//  HKDemo
//
//  Created by MacMini on 5/15/20.
//  Copyright © 2020 tma. All rights reserved.
//

import UIKit
import HealthKit
import FirebaseCrashlytics

class ViewController: UIViewController {
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var bloodTypeLabel: UILabel!

    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var bodyTempLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!

    
    
    let userHealthProfile = UserHealthProfile()
    let userVital         = UserVital()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func connectHealth(_ sender: Any) {
        authorizeHealthKit()
    }

    @IBAction func reloadData(_ sender: Any) {
        updateData()
    }

    func updateData() {
        loadAndDisplayProfile();
        loadAndDisplayAgeSexAndBloodType()
        loadAndDisplayHealthVital();
    }

    // MARK: - Authorize
    func authorizeHealthKit() {
        HealthKitManager.authorizeHealthKit { (authorized, error) in
            if authorized {
                print("HealthKit Successfully Authorized.")
                self.showAlert(title: "", message: "Access to Health App Successfully", buttonTitle: "OK")
            } else {
                print("HealthKit Fail Authorized.")
                self.showAlert(title: "", message: "Unable to access to Health App", buttonTitle: "OK")
            }
        }
    }

    // MARK: - Profile
    func loadAndDisplayProfile() {
        loadAndDisplayAgeSexAndBloodType()
        loadMostRecentHeight()
        loadMostRecentWeight()
    }

    func loadAndDisplayAgeSexAndBloodType() {
        do {
            let userAgeSexAndBloodType = try ProfileDataStore.getAgeSexAndBloodType()
            userHealthProfile.age = userAgeSexAndBloodType.age
            userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
            userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType

            updateProfileUI()
        } catch let error {
            self.displayAlert(for: error)
        }
    }

    private func loadMostRecentHeight() {

        //1. Use HealthKit to create the Height Sample Type
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            print("Height Sample Type is no longer available in HealthKit")
            return
        }

        ProfileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in

            guard let sample = sample else {

                if let error = error {
                    self.displayAlert(for: error)
                }

                return
            }

            //2. Convert the height sample to meters, save to the profile model,
            //   and update the user interface.
            let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
            self.userHealthProfile.heightInMeters = heightInMeters
            self.updateProfileUI()
        }
    }

    private func loadMostRecentWeight() {

        //1. Use HealthKit to create the Height Sample Type
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            print("Body Mass Sample Type is no longer available in HealthKit")
            return
        }

        ProfileDataStore.getMostRecentSample(for: weightSampleType) { (sample, error) in

            guard let sample = sample else {

                if let error = error {
                    self.displayAlert(for: error)
                }

                return
            }

            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.userHealthProfile.weightInKilograms = weightInKilograms
            self.updateProfileUI()
        }
    }

    // MARK: - Health Vital
    func loadAndDisplayHealthVital() {
        loadHeartRate()
        loadBodyTemp()
    }

    func loadHeartRate() {
        VitalDataStore.getLatestHeartRateSample { (sample, error) in
            if ((error) != nil) {
                self.displayAlert(for: error!)
                return;
            }

            guard let sampleData:HKQuantitySample = sample else { return }

            self.userVital.heartRate = sampleData.quantity.doubleValue(for: HKUnit(from: "count/min"))
            self.dispatchUpdateUI()
        }
    }

    func loadBodyTemp() {
        VitalDataStore.getBodyTempSample { (sample, error) in
            if ((error) != nil) {
                self.displayAlert(for: error!)
                return;
            }

            guard let sampleData:HKQuantitySample = sample else { return }

            // .degreeCelsius() *C
            // . degreeFahrenheit *
            self.userVital.bodyTemp = sampleData.quantity.doubleValue(for: .degreeCelsius())
            self.dispatchUpdateUI()
        }
    }

    // MARK: - Update UI
    func updateProfileUI() {
        if let age = userHealthProfile.age {
            ageLabel.text = "\(age)"
        }

        if let biologicalSex = userHealthProfile.biologicalSex {
            sexLabel.text = biologicalSex.stringRepresentation
        }

        if let bloodType = userHealthProfile.bloodType {
            bloodTypeLabel.text = bloodType.stringRepresentation
        }
        
        if let weight = userHealthProfile.weightInKilograms {
          let weightFormatter = MassFormatter()
            weightLabel.text = weightFormatter.string(fromValue: weight, unit: .kilogram)
        }
        
        if let height = userHealthProfile.heightInMeters {
          let heightFormatter = LengthFormatter()
            heightLabel.text = heightFormatter.string(fromValue: height, unit: .meter)
        }
        
        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
            bmiLabel.text = String(format: "%.02f", bodyMassIndex)
        }
    }

    func updateVitalUI() {
        if let bodyTemp = userVital.bodyTemp {
            bodyTempLabel.text = "\(bodyTemp)"
        }

        if let heartRate = userVital.heartRate {
            heartRateLabel.text = "\(heartRate)"
        }
    }

    func dispatchUpdateUI() {
        DispatchQueue.main.async {
            self.updateProfileUI()
            self.updateVitalUI()
        }
    }

    // MARK: - Tool Methods - Alert
    func showAlert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            })
            alert.addAction(okAction)

            self.present(alert, animated: true, completion: nil)
        }
    }

    func displayAlert(for error: Error) {
        self.showAlert(title: "", message: error.localizedDescription, buttonTitle: "OK")
    }
}

