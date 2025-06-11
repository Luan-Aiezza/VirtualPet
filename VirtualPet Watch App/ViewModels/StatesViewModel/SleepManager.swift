import HealthKit
import Combine

/// SleepDataManager gerencia e observa os dados de sono do usuário via HealthKit para sincronizar o sono do pet virtual.
class SleepDataManager: ObservableObject {
    private let healthStore = HKHealthStore()
    public var observerQuery: HKObserverQuery?
    @Published var isUserInSleepMode: Bool = false
    @Published var averageSleepDuration: TimeInterval = 8 * 3600
    @Published var averageBedtime: DateComponents = DateComponents(hour: 23)

    init() {
        requestAuthorization()
        checkIfUserIsSleeping()
    }

    func requestAuthorization() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            if success {
                self.startObservingSleepChanges()
                self.fetchSleepData()
                self.checkIfUserIsSleeping()
            } else {
                print("HealthKit auth failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func startObservingSleepChanges() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }

        observerQuery = HKObserverQuery(sampleType: sleepType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer error: \(error.localizedDescription)")
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

        let startDate = Calendar.current.date(byAdding: .hour, value: -3, to: Date())!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)

        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { [weak self] _, samples, _ in
            guard let self = self else { return }

            let now = Date()
            let thirtyMinutesAgo = now.addingTimeInterval(-30 * 60)

            let sleepSamples = (samples as? [HKCategorySample])?.filter {
                ($0.value == HKCategoryValueSleepAnalysis.asleep.rawValue || $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue) &&
                $0.endDate >= thirtyMinutesAgo
            } ?? []

            DispatchQueue.main.async {
                self.isUserInSleepMode = !sleepSamples.isEmpty
                print("checkIfUserIsSleeping - isUserInSleepMode: \(self.isUserInSleepMode), samples count: \(sleepSamples.count)")
            }
        }

        healthStore.execute(query)
    }

    //Novo método!
    func fetchLastNightSleep(completion: @escaping (TimeInterval) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(0)
            return
        }

        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -1, to: now) else {
            completion(0)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType,
                                  predicate: predicate,
                                  limit: 50,
                                  sortDescriptors: nil) { _, samples, error in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                completion(0)
                return
            }

            let asleepSamples = samples.filter { $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue }
            let totalSleep = asleepSamples.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }

            DispatchQueue.main.async {
                print("fetchLastNightSleep - totalSleep: \(totalSleep) seconds")
                completion(totalSleep)
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

                print("fetchSleepData - averageSleepDuration: \(self.averageSleepDuration / 3600)h")
                print("fetchSleepData - averageBedtime: \(self.averageBedtime.hour ?? -1)h \(self.averageBedtime.minute ?? 0)m")
            }
        }

        healthStore.execute(query)
    }
}
