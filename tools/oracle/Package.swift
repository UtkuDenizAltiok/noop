// swift-tools-version: 5.9
import PackageDescription

// Oracle for android/.../LiftMetricsParityOracleTest.kt: prints what the REAL Swift LiftMetrics computes for
// that test's fixture, in its exact format. Run through run.sh, which sets NOOP_REPO.
let repo = Context.environment["NOOP_REPO"] ?? "../../.."

let package = Package(
    name: "LiftOracle",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "\(repo)/Packages/StrandAnalytics"),
        .package(path: "\(repo)/Packages/WhoopStore"),
    ],
    targets: [
        .executableTarget(name: "LiftOracle", dependencies: [
            .product(name: "StrandAnalytics", package: "StrandAnalytics"),
            .product(name: "WhoopStore", package: "WhoopStore"),
        ]),
    ]
)
