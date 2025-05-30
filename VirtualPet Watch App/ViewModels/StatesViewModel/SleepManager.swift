import HealthKit
import Combine

class SleepDataManager: ObservableObject {
    private let healthStore = HKHealthStore()
    private var observerQuery: HKObserverQuery?
    @Published var isUserInSleepMode: Bool = false
    @Published var averageSleepDuration: TimeInterval = 8 * 3600
    @Published var averageBedtime: DateComponents = DateComponents(hour: 23)

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            if success {
                self.startObservingSleepChanges()
                self.fetchSleepData()
            } else {
                print("🚫 HealthKit auth failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func startObservingSleepChanges() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        observerQuery = HKObserverQuery(sampleType: sleepType, predicate: nil) { [weak self] _, completionHandler, error in
            guard error == nil else {
                print("❌ Observer error: \(error!.localizedDescription)")
                return
            }

            self?.checkIfUserIsSleeping()
            completionHandler()
        }

        if let query = observerQuery {
            healthStore.execute(query)
        }
    }

    func checkIfUserIsSleeping() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let startDate = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)

        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: 1,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { [weak self] _, samples, _ in
            guard let self = self,
                  let sample = samples?.first as? HKCategorySample else { return }

            DispatchQueue.main.async {
                self.isUserInSleepMode = sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue
                print("🛏️ Sleep mode status updated: \(self.isUserInSleepMode)")
            }
        }

        healthStore.execute(query)
    }

    func fetchSleepData() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
                                                    end: Date(), options: .strictEndDate)

        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: nil) { _, samples, _ in
            guard let samples = samples as? [HKCategorySample] else { return }

            let inBedSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue }

            let durations = inBedSamples.map { $0.endDate.timeIntervalSince($0.startDate) }
            let bedtimes = inBedSamples.map { Calendar.current.dateComponents([.hour, .minute], from: $0.startDate) }

            DispatchQueue.main.async {
                if !durations.isEmpty {
                    self.averageSleepDuration = durations.reduce(0, +) / Double(durations.count)
                }
                if !bedtimes.isEmpty {
                    let hour = bedtimes.map { $0.hour ?? 0 }.reduce(0, +) / bedtimes.count
                    let minute = bedtimes.map { $0.minute ?? 0 }.reduce(0, +) / bedtimes.count
                    self.averageBedtime = DateComponents(hour: hour, minute: minute)
                }

                print("💤 Média de sono: \(self.averageSleepDuration / 3600)h, horário médio: \(self.averageBedtime.hour ?? -1)h")
            }
        }

        healthStore.execute(query)
    }
}
