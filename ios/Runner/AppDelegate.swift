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
            result(FlutterError(code: "HEALTHKIT_NOT_AVAILABLE", message: "HealthKit non disponible", details: nil))
            return
        }
        
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let typesToRead: Set = [stepsType, heartRateType, caloriesType, sleepType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if let error = error {
                result(FlutterError(code: "AUTH_FAILED", message: "Échec de l'autorisation HealthKit", details: error.localizedDescription))
                return
            }
            if success {
                self.fetchHealthData(result: result)
            } else {
                result(FlutterError(code: "AUTH_DENIED", message: "L'utilisateur a refusé l'accès à HealthKit", details: nil))
            }
        }
    }
    
    private func fetchHealthData(result: @escaping FlutterResult) {
        let now = Date()
        let startOfYesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: now))
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: now, options: .strictStartDate)
        
        let group = DispatchGroup()
        var steps: Double = 0
        var heartRate: Double = 0
        var calories: Double = 0
        var sleep: Double = 0
        
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // 🔹 Récupération des PAS
        group.enter()
        let stepsQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            defer { group.leave() }
            if let quantity = result?.sumQuantity() {
                steps = quantity.doubleValue(for: HKUnit.count())
            }
        }
        healthStore.execute(stepsQuery)
        
        // 🔹 Récupération de la FRÉQUENCE CARDIAQUE (dernier échantillon)
        group.enter()
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            defer { group.leave() }
            if let sample = samples?.first as? HKQuantitySample {
                heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
        }
        healthStore.execute(heartRateQuery)
        
        // 🔹 Récupération des CALORIES BRÛLÉES
        group.enter()
        let caloriesQuery = HKStatisticsQuery(quantityType: caloriesType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            defer { group.leave() }
            if let quantity = result?.sumQuantity() {
                calories = quantity.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        healthStore.execute(caloriesQuery)
        
        // 🔹 Récupération de TOUTES les périodes de sommeil
        group.enter()
        let sleepQuery = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 0, sortDescriptors: nil) { _, samples, error in
            defer { group.leave() }
            if let samples = samples as? [HKCategorySample] {
                for sample in samples {
                    if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ||
                        sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        sleep += sample.endDate.timeIntervalSince(sample.startDate) / 3600 // Convertir en heures
                    }
                }
            }
        }
        healthStore.execute(sleepQuery)
        
        // 🔹 Une fois toutes les requêtes terminées, on envoie les données à Flutter
        group.notify(queue: .main) {
            let data: [String: Any] = [
                "steps": steps,
                "heartRate": heartRate,
                "calories": calories,
                "sleep": sleep
            ]
            result(data)
        }
    }
}
