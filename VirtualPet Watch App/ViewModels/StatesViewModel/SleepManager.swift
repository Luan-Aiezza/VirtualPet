import HealthKit
import Foundation

class SleepDataManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var averageSleepDuration: TimeInterval = 8 * 3600 // fallback 8h
    @Published var averageBedtime: DateComponents = DateComponents(hour: 23) // fallback 23h

    init() {
        requestAuthorization()
    }

    func requestAuthorization() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            if success {
                self.fetchSleepData()
            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
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
