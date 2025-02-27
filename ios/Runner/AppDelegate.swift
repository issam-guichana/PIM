import UIKit
import Flutter
import HealthKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    let healthStore = HKHealthStore()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        let healthChannel = FlutterMethodChannel(name: "healthkit_channel", binaryMessenger: controller.binaryMessenger)

        healthChannel.setMethodCallHandler { (call, result) in
            if call.method == "getHealthData" {
                self.getHealthData(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func getHealthData(result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(FlutterError(code: "HEALTHKIT_NOT_AVAILABLE", message: "HealthKit is not available on this device", details: nil))
            return
        }

        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let typesToRead: Set = [stepsType, heartRateType, caloriesType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                self.fetchHealthData(result: result)
            } else {
                result(FlutterError(code: "AUTH_FAILED", message: error?.localizedDescription ?? "HealthKit authorization failed", details: nil))
            }
        }
    }

    private func fetchHealthData(result: @escaping FlutterResult) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let group = DispatchGroup()
        var steps: Double = 0
        var heartRate: Double = 0
        var calories: Double = 0

        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

        group.enter()
        let stepsQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let quantity = result?.sumQuantity() {
                steps = quantity.doubleValue(for: HKUnit.count())
            } else {
                print("Erreur récupération des pas: \(error?.localizedDescription ?? "Inconnu")")
            }
            group.leave()
        }

        group.enter()
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            if let sample = samples?.first as? HKQuantitySample {
                heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            } else {
                print("Erreur récupération de la fréquence cardiaque: \(error?.localizedDescription ?? "Inconnu")")
            }
            group.leave()
        }

        group.enter()
        let caloriesQuery = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let quantity = result?.sumQuantity() {
                calories = quantity.doubleValue(for: HKUnit.kilocalorie())
            } else {
                print("Erreur récupération des calories: \(error?.localizedDescription ?? "Inconnu")")
            }
            group.leave()
        }

        healthStore.execute(stepsQuery)
        healthStore.execute(heartRateQuery)
        healthStore.execute(caloriesQuery)

        group.notify(queue: .main) {
            let data: [String: Any] = [
                "steps": steps,
                "heartRate": heartRate,
                "caloriesBurned": calories
            ]
            result(data)
        }
    }
}
