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
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let typesToRead: Set = [stepsType, heartRateType, caloriesType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                self.fetchHealthData(result: result)
            } else {
                result(FlutterError(code: "AUTH_FAILED", message: "HealthKit authorization failed", details: nil))
            }
        }
    }

    private func fetchHealthData(result: @escaping FlutterResult) {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let group = DispatchGroup()

        var steps: Double = 0
        var heartRate: Double = 0
        var calories: Double = 0

        group.enter()
        let stepsQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            group.leave()
        }

        group.enter()
        let heartRateQuery = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, hrResult, _ in
            heartRate = hrResult?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
            group.leave()
        }

        group.enter()
        let caloriesQuery = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, calResult, _ in
            calories = calResult?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            group.leave()
        }

        self.healthStore.execute(stepsQuery)
        self.healthStore.execute(heartRateQuery)
        self.healthStore.execute(caloriesQuery)

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
