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
        let healthChannel = FlutterMethodChannel(
            name: "healthkit_channel",
            binaryMessenger: controller.binaryMessenger
        )
        
        healthChannel.setMethodCallHandler { (call, result) in
            if call.method == "getHealthData" {
                print("[AppDelegate] Méthode Flutter appelée : getHealthData")
                self.getHealthData(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func getHealthData(result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("[AppDelegate] HealthKit non disponible sur cet appareil.")
            result(
                FlutterError(
                    code: "HEALTHKIT_NOT_AVAILABLE",
                    message: "HealthKit non disponible",
                    details: nil
                )
            )
            return
        }
        
        // Types à lire : pas, FC, calories, sommeil
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        
        let typesToRead: Set = [stepsType, heartRateType, caloriesType, sleepType]
        
        print("[AppDelegate] Demande d'autorisation pour lire : \(typesToRead)")
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if let error = error {
                print("[AppDelegate] Erreur lors de la demande d'autorisation : \(error.localizedDescription)")
                result(
                    FlutterError(
                        code: "AUTH_FAILED",
                        message: "Échec de l'autorisation HealthKit",
                        details: error.localizedDescription
                    )
                )
                return
            }
            
            if success {
                print("[AppDelegate] Autorisation accordée, récupération des données...")
                self.fetchHealthData(result: result)
            } else {
                print("[AppDelegate] Autorisation refusée par l'utilisateur.")
                result(
                    FlutterError(
                        code: "AUTH_DENIED",
                        message: "L'utilisateur a refusé l'accès à HealthKit",
                        details: nil
                    )
                )
            }
        }
    }
    
    private func fetchHealthData(result: @escaping FlutterResult) {
        // Début de la journée (minuit) jusqu'à maintenant
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        // Prédicat pour la période souhaitée
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Variables pour stocker les résultats
        var steps: Double = 0
        var heartRate: Double = 0
        var calories: Double = 0
        var sleep: Double = 0
        
        // Types
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // Pour synchroniser les requêtes asynchrones
        let group = DispatchGroup()
        
        // -----------------------
        // RÉCUPÉRATION DES PAS
        // -----------------------
        group.enter()
        let stepsQuery = HKStatisticsQuery(
            quantityType: stepsType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, stats, error in
            defer { group.leave() }
            if let error = error {
                print("[AppDelegate] Erreur stepsQuery : \(error.localizedDescription)")
            }
            if let quantity = stats?.sumQuantity() {
                steps = quantity.doubleValue(for: HKUnit.count())
                print("[AppDelegate] PAS (depuis minuit) : \(steps)")
            } else {
                print("[AppDelegate] Aucune valeur pour steps.")
            }
        }
        healthStore.execute(stepsQuery)
        
        // -----------------------
        // RÉCUPÉRATION DE LA FC
        // (dernier échantillon)
        // -----------------------
        group.enter()
        let heartRateQuery = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [
                NSSortDescriptor(
                    key: HKSampleSortIdentifierStartDate,
                    ascending: false
                )
            ]
        ) { _, samples, error in
            defer { group.leave() }
            if let error = error {
                print("[AppDelegate] Erreur heartRateQuery : \(error.localizedDescription)")
            }
            if let sample = samples?.first as? HKQuantitySample {
                heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                print("[AppDelegate] Dernière FC (depuis minuit) : \(heartRate) BPM")
            } else {
                print("[AppDelegate] Aucune valeur pour heartRate.")
            }
        }
        healthStore.execute(heartRateQuery)
        
        // -----------------------
        // RÉCUPÉRATION DES CALORIES BRÛLÉES
        // (somme cumulée)
        // -----------------------
        group.enter()
        let caloriesQuery = HKStatisticsQuery(
            quantityType: caloriesType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, stats, error in
            defer { group.leave() }
            if let error = error {
                print("[AppDelegate] Erreur caloriesQuery : \(error.localizedDescription)")
            }
            if let quantity = stats?.sumQuantity() {
                // On récupère les kilocalories (kcal)
                calories = quantity.doubleValue(for: HKUnit.kilocalorie())
                print("[AppDelegate] CALORIES (depuis minuit) : \(calories) kcal")
            } else {
                print("[AppDelegate] Aucune valeur pour calories.")
            }
        }
        healthStore.execute(caloriesQuery)
        
        // -----------------------
        // RÉCUPÉRATION DU SOMMEIL
        // (tous les segments InBed/Asleep)
        // -----------------------
        group.enter()
        let sleepQuery = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: 0,
            sortDescriptors: nil
        ) { _, samples, error in
            defer { group.leave() }
            if let error = error {
                print("[AppDelegate] Erreur sleepQuery : \(error.localizedDescription)")
            }
            if let samples = samples as? [HKCategorySample], !samples.isEmpty {
                for sample in samples {
                    if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue ||
                       sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        let duration = sample.endDate.timeIntervalSince(sample.startDate) / 3600.0
                        sleep += duration
                    }
                }
                print("[AppDelegate] SOMMEIL (depuis minuit) : \(sleep) heures")
            } else {
                print("[AppDelegate] Aucune valeur pour le sommeil.")
            }
        }
        healthStore.execute(sleepQuery)
        
        // -----------------------
        // FIN DES REQUÊTES
        // -----------------------
        group.notify(queue: .main) {
            let data: [String: Any] = [
                "steps": steps,
                "heartRate": heartRate,
                "calories": calories,
                "sleep": sleep
            ]
            print("[AppDelegate] Données finales envoyées à Flutter : \(data)")
            result(data)
        }
    }
}
