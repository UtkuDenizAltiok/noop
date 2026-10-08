import Foundation

// Dependency stand-ins control completion order. They do not evaluate physiology or storage.
enum FixtureIdentity {
    @TaskLocal static var value = 0
}

final class FixtureGate: @unchecked Sendable {
    private let lock = NSLock()
    private let workerRelease = DispatchSemaphore(value: 0)
    private var started = false
    private var startWaiters: [CheckedContinuation<Void, Never>] = []
    private var asyncRelease: CheckedContinuation<Void, Never>?

    func waitForStart() async {
        await withCheckedContinuation { continuation in
            lock.lock()
            if started {
                lock.unlock()
                continuation.resume()
            } else {
                startWaiters.append(continuation)
                lock.unlock()
            }
        }
    }

    private func markStarted() {
        lock.lock()
        started = true
        let waiters = startWaiters
        startWaiters.removeAll()
        lock.unlock()
        for waiter in waiters { waiter.resume() }
    }

    func pauseRead() async {
        await withCheckedContinuation { continuation in
            lock.lock()
            asyncRelease = continuation
            lock.unlock()
            markStarted()
        }
    }

    func pauseWorker() {
        markStarted()
        workerRelease.wait()
    }

    func releaseWork() {
        lock.lock()
        let continuation = asyncRelease
        asyncRelease = nil
        lock.unlock()
        if let continuation { continuation.resume() }
        else { workerRelease.signal() }
    }
}

struct FixtureSample: Sendable { let identity: Int }
enum FixtureMode: Sendable { case dayRelative, baselineRelative }
enum PuffinExperiment { static let stressPersonalBaselineEnabled = false }

@MainActor
final class Repository {
    let point: String
    let gate: FixtureGate
    let freshEmpty: Bool
    init(point: String, gate: FixtureGate, freshEmpty: Bool) {
        self.point = point; self.gate = gate; self.freshEmpty = freshEmpty
    }
    private func pause(_ at: String) async {
        if FixtureIdentity.value == 1 && point == at { await gate.pauseRead() }
    }
    func series(key: String, source: String) async -> [(day: String, value: Double)] {
        await pause("series")
        return [("fixture", Double(FixtureIdentity.value))]
    }
    func hrSamples(from: Int, to: Int, limit: Int) async -> [FixtureSample] {
        await pause("hr")
        return freshEmpty && FixtureIdentity.value == 2 ? [] : [.init(identity: FixtureIdentity.value)]
    }
    func rrIntervals(from: Int, to: Int, limit: Int) async -> [FixtureSample] {
        await pause("rr")
        return [.init(identity: FixtureIdentity.value)]
    }
    func gravitySamplesUnion(from: Int, to: Int, limit: Int) async -> [FixtureSample] {
        await pause("gravity")
        return []
    }
    func mode() async -> FixtureMode {
        await pause("mode")
        return FixtureIdentity.value == 1 ? .baselineRelative : .dayRelative
    }
}

enum DaytimeStressMode {
    @MainActor static func selected(repo: Repository, startOfToday: Date, calendar: Calendar,
                                   personalBaseline: Bool) async -> FixtureMode { await repo.mode() }
}

enum FixtureWorker {
    // Set only before a case starts, clear only after both tasks have completed.
    nonisolated(unsafe) static var point = ""
    nonisolated(unsafe) static var gate: FixtureGate?
}

enum DaytimeStress {
    static let minHourHRSamples = 1
    struct Result: Sendable {
        let identity: Int
        static let empty = Result(identity: 0)
    }
    static func analyze(hr: [FixtureSample], rr: [FixtureSample], gravity: [FixtureSample],
                        tzOffsetSeconds: Int, mode: FixtureMode, includeTimeline: Bool) -> Result {
        let identity = hr.first?.identity ?? 0
        if identity == 1 && FixtureWorker.point == "core" { FixtureWorker.gate?.pauseWorker() }
        return Result(identity: identity)
    }
}
enum StressIndex {
    struct Components: Sendable { let identity: Int }
    static func components(rr: [FixtureSample]) -> Components? {
        let identity = rr.first?.identity ?? 0
        if identity == 1 && FixtureWorker.point == "advanced" { FixtureWorker.gate?.pauseWorker() }
        return Components(identity: identity)
    }
}
enum HRVFreqDomain {
    struct Bands: Sendable { let identity: Int }
    static func freqDomain(rr: [FixtureSample]) -> Bands? { Bands(identity: rr.first?.identity ?? 0) }
}

@main
struct FixtureMain {
    @MainActor static func main() async {
        for point in ["series", "hr", "rr", "gravity", "mode", "core", "advanced"] {
            let gate = FixtureGate()
            let empty = point == "advanced"
            FixtureWorker.point = point; FixtureWorker.gate = gate
            let repo = Repository(point: point, gate: gate, freshEmpty: empty)
            let screen = FixtureScreen(repo: repo)
            let old = Task { @MainActor in
                await FixtureIdentity.$value.withValue(1) { await screen.load() }
            }
            await gate.waitForStart()
            old.cancel()
            await FixtureIdentity.$value.withValue(2) { await screen.load() }
            let fresh = screen.snapshot
            gate.releaseWork()
            await old.value
            print("\(point): fresh=\(fresh) late=\(screen.snapshot) preserved=\(fresh == screen.snapshot)")
        }
        FixtureWorker.point = ""; FixtureWorker.gate = nil
        let gate = FixtureGate()
        let screen = FixtureScreen(repo: Repository(point: "", gate: gate, freshEmpty: false))
        await FixtureIdentity.$value.withValue(2) { await screen.load() }
        print("control: \(screen.snapshot)")
    }
}
