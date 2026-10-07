// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  ->
// PowerCell must be a class so that multiple components holding references to the cell mutate the exact same shared physical battery state rather than disconnected copies.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        return charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, charge >= amount else {
            return false
        }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else {
            return
        }
        charge = min(charge + amount, 100)
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// let cell = PowerCell(charge: 100)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  ->
// Making runOnce() final enforces the Template Method pattern, guaranteeing subclasses cannot override or bypass the mandatory power consumption check and shift ritual.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        return "\(id): \(cell.level())% [\(cell.level().powerBar)]"
    }

    func performTask() -> Int {
        return 0
    }

    final func runOnce() -> Int {
        if cell.spend(powerCost) {
            return performTask()
        } else {
            return 0
        }
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        return "Welding seam sealed by \(id)."
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }

    override func performTask() -> Int { 15 }

    override var statusLine: String {
        return super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }

    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: Unknown drone kind '\(record.kind)' with ID '\(record.id)' skipped.")
    }
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0
    for _ in 0..<rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

let A = runShift(fleet, rounds: 3)

print("\n--- Shift Telemetry (3 Rounds) ---")
print("Total work units produced (A): \(A)")
print("Fleet status lines after shift:")
for drone in fleet {
    print("  \(drone.statusLine)")
}

var B = 0
for drone in fleet {
    B += drone.cell.level()
}

var C = 0
for drone in fleet {
    if drone.cell.level() >= drone.powerCost {
        C += 1
    }
}

print("Total remaining drone charge (B): \(B)")
print("Drones that could still run one more task (C): \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  ->
// Drone is a class (reference type); modifying its properties mutates heap storage in-place without reassigning 'self', so 'mutating' is neither needed nor allowed.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String {
        return id
    }

    var statusCode: Int {
        return Diagnosable.statusCode(for: cell.level())
    }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String {
        return id
    }

    var statusCode: Int {
        return Diagnosable.statusCode(for: chargeLevel)
    }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for sensor in sensorData {
    sensors.append(SensorModule(id: sensor.id, chargeLevel: sensor.charge))
}

// 4.3
// Why could [Drone] never have held the sensors?  ->
// An array of type [Drone] can only store instances of the Drone class hierarchy; SensorModule is a struct, and Swift does not support class inheritance for structs.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = ""
    for (index, component) in components.enumerated() {
        if index > 0 {
            report.append("\n")
        }
        report.append(component.diagnose())
    }
    return report
}

var initialComponents: [Diagnosable] = []
for drone in fleet {
    initialComponents.append(drone)
}
for sensor in sensors {
    initialComponents.append(sensor)
}

print("\n--- Diagnostics Report (Drones & Sensors) ---")
print(diagnosticsReport(initialComponents))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }

    /// Single canonical home of the Health Rule for Station ALMA-7
    static func statusCode(for value: Int) -> Int {
        if value < 20 {
            return 2
        } else if value <= 49 {
            return 1
        } else {
            return 0
        }
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String {
        return name
    }

    var statusCode: Int {
        return Diagnosable.statusCode(for: signalStrength)
    }

    func diagnose() -> String {
        return "[LEGACY HARDWARE] \(componentID): code \(statusCode) (signal: \(signalStrength))"
    }
}

var allStationComponents: [Diagnosable] = []
for drone in fleet {
    allStationComponents.append(drone)
}
for sensor in sensors {
    allStationComponents.append(sensor)
}
allStationComponents.append(beacon)

print("\n--- Full Station Diagnostics (Including Legacy Beacon) ---")
print(diagnosticsReport(allStationComponents))

var D = 0
for component in allStationComponents {
    D += component.statusCode
}
print("Sum of all component status codes (D): \(D)")

// 5.3
extension Int {
    var powerBar: String {
        let bars = min(max(self / 10, 0), 10)
        var barString = ""
        for _ in 0..<bars {
            barString.append("#")
        }
        for _ in 0..<(10 - bars) {
            barString.append(".")
        }
        return barString
    }
}


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

// Report 1
// Expectation: The author expected PatchDrone to subclass Drone and produce 30 work units in performTask().
// Actual behaviour: Fails to compile with error: Overriding declaration requires an 'override' keyword.
// Language rule: In Swift, overriding any method or property declared in a superclass strictly requires the 'override' keyword to prevent accidental collisions.
// Fix: Add the 'override' keyword to the performTask() method.
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}

let patchDrone = PatchDrone(id: "P-1", cell: PowerCell(charge: 50))
print("\n[Report 1 Fixed] PatchDrone task units: \(patchDrone.performTask())")

// Report 2
// Expectation: The author expected HeavyWelder to inherit from WelderDrone and override runOnce() to return 999.
// Actual behaviour: Fails to compile with two fatal errors:
//   1. 'Inheritance from a final class 'WelderDrone''
//   2. 'Instance method overrides a 'final' instance method 'runOnce()''
// Language rule: A class marked 'final' cannot be subclassed, and a method marked 'final' cannot be overridden in any subclass. This protects the invariant shift ritual.
// Fix: Subclass Drone directly (since WelderDrone is final) and override performTask() instead of runOnce(), preserving the shift ritual.
final class HeavyWelder: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int {
        return 999
    }
}

let heavyWelder = HeavyWelder(id: "HW-1", cell: PowerCell(charge: 100))
print("[Report 2 Fixed] HeavyWelder runOnce: \(heavyWelder.runOnce()), remaining charge: \(heavyWelder.cell.level())")

// Report 3
// Expectation: The author expected to call weldSeam() on the first drone in reportFleet.
// Actual behaviour: Fails to compile with error: Value of type 'Drone' has no member 'weldSeam'.
// Language rule: Swift enforces static type checking. Since reportFleet is typed as [Drone], the compiler only permits calling members declared on Drone. Subclass-specific methods require a runtime conditional downcast.
// Why as? returns an optional: as? returns an optional because dynamic downcasting can fail at runtime if the instance is not actually of the target subclass type, safely returning nil instead of trapping.
// Fix: Use conditional binding with a downcast: if let welder = first as? WelderDrone { print(welder.weldSeam()) }
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print("[Report 3 Fixed] \(welder.weldSeam())")
}

// Report 4
// Expectation: The author expected parts[0].label() to print "thruster T-1".
// Actual behaviour: Compiles successfully, but prints "generic component" (lies!).
// Language rule: When a method is defined only in a protocol extension (and not declared as a requirement in the protocol definition), calls on existential protocol types use static dispatch based on the protocol type (Labelled), ignoring the conforming struct's custom implementation.
// Fix: Add 'func label() -> String' to the protocol Labelled definition so it becomes a protocol requirement with dynamic witness table dispatch.
protocol Labelled {
    var componentID: String { get }
    func label() -> String
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("[Report 4 Fixed] \(parts[0].label())")


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("\n==============================")
print("MISSION CODE: \(missionCode)")
print("==============================\n")


// MARK: Bonus

// 1. Two ways to forbid using Drone directly (abstract base class simulation):
// Runtime Failure Approach:
// Inside Drone.init (or Drone.performTask), inspect the runtime dynamic type:
//   guard type(of: self) != Drone.self else {
//       fatalError("Drone is an abstract base class and cannot be instantiated directly.")
//   }
// Or in Drone.performTask():
//   fatalError("Abstract method performTask() must be overridden by a concrete subclass.")
// This crashes with a clear message as soon as someone calls Drone(id:cell:) or runs its task directly.

// Compile-Time Prevention Approach:
// Make the designated initializer inaccessible outside subclass declarations using access control or a witness token:
//   class AbstractDrone {
//       fileprivate struct SubclassAuthorization { fileprivate init() {} }
//       fileprivate init(id: String, cell: PowerCell, auth: SubclassAuthorization) { ... }
//   }
// Because external callers cannot instantiate 'SubclassAuthorization' or access a 'fileprivate' initializer from other files, attempting 'Drone(id:cell:)' causes an immediate compile-time error.

// 2. Protocol-based fleet redesign where WelderDrone is a struct:
protocol RepairDroneProtocol: Diagnosable {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    var statusLine: String { get }
    func performTask() -> Int
    mutating func runOnce() -> Int
}

extension RepairDroneProtocol {
    var componentID: String { id }
    var statusCode: Int { Diagnosable.statusCode(for: cell.level()) }
    var powerCost: Int { 10 }
    var statusLine: String { "\(id): \(cell.level())% [\(cell.level().powerBar)]" }
    func performTask() -> Int { 0 }

    mutating func runOnce() -> Int {
        if cell.spend(powerCost) {
            return performTask()
        } else {
            return 0
        }
    }
}

struct WelderDroneStruct: RepairDroneProtocol {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
    func weldSeam() -> String { "Struct welder seam sealed by \(id)." }
}

// Demonstration of protocol-based design:
var bonusWelder = WelderDroneStruct(id: "W-BONUS", cell: PowerCell(charge: 50))
let bonusWork = bonusWelder.runOnce()
print("Bonus Demonstration: Struct Welder produced \(bonusWork) units, remaining charge: \(bonusWelder.cell.level())%")

// 3. Comparison of Class vs Protocol Design:
// A class-based hierarchy provides object identity and allows 'final' methods to strictly enforce invariants (like the shift ritual) across subclasses, but it cannot prevent direct base instantiation at compile time and couples types into a rigid single-inheritance hierarchy.
// The protocol-oriented design naturally prevents abstract base instantiation (protocols cannot be instantiated directly), favors lightweight, thread-safe value types (structs), and allows composable behaviors without inheritance lock-in.
// For Station ALMA-7, the protocol-oriented design is the cleaner and more idiomatic Swift architecture; however, if drones had to share mutable state across multiple systems without copying, reference semantics (classes) would be required to prevent state divergence.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    Answer:
    Classes are reference types stored on the heap. When a method modifies an
    instance property of a class, it mutates the heap-allocated object in-place;
    the reference pointer held in `self` does not change. Therefore, class methods
    never mutate `self` and do not require (and are not permitted to use) the `mutating` keyword.
    In contrast, structs are value types where `self` is an immutable copy by default.
    To mutate a stored property, a struct method must be marked `mutating`, which signals
    to the Swift compiler that `self` is passed as an implicit `inout` parameter that can
    modify the calling value. Because classes are inherently capable of in-place mutation,
    they satisfy a `mutating func` protocol requirement with a regular (non-mutating) method.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Answer:
    - What inheritance does that protocols cannot:
      Inheritance allows a subclass to directly inherit stored property memory layout
      (`let id: String`, `let cell: PowerCell`) and concrete stored state without
      redeclaring storage in every subtype. Furthermore, inheritance allows base classes
      to enforce mandatory behavioral invariants using `final` methods (such as `final func runOnce()`),
      preventing any subclass from overriding or bypassing the execution algorithm.
    - What protocols do that inheritance cannot:
      Protocols can unify completely unrelated types across different paradigms—allowing
      both reference types (`class Drone`) and value types (`struct SensorModule`, `struct LegacyBeacon`)
      to conform to the exact same contract (`Diagnosable`). Additionally, a type can conform
      to multiple protocols (composition), whereas Swift classes are strictly limited to single inheritance.

 3. What exactly does `final` prevent, and what did it protect in runOnce()?
    Answer:
    The `final` keyword prevents subclasses from overriding a method, property, or subscript
    (or prevents a class from being subclassed entirely).
    In `runOnce()`, marking the method `final` protected the station from rogue or malformed
    subclasses (such as `HeavyWelder` in Report 2) bypassing the battery cost requirement.
    It guarantees that no matter what kind of drone is executed, the two-step shift ritual
    (spend battery charge first, produce work units only if the spend succeeds) is strictly
    and immutably executed every time. It also enables compiler optimizations via static dispatch.

 4. In Report 4, why did the protocol extension's method win?
    Answer:
    In Report 4, `label()` was defined solely in the `extension Labelled`, and was NOT declared
    as a requirement inside the `protocol Labelled { ... }` declaration.
    In Swift, only methods declared as protocol requirements are added to the protocol witness
    table and dynamically dispatched at runtime. Methods defined purely in protocol extensions
    are dispatched statically (direct dispatch) based on the compile-time type of the variable.
    Because the array was typed as `[Labelled]`, the compiler evaluated calls to `label()`
    using static dispatch resolving to `Labelled.label()`, completely ignoring `Thruster`'s
    implementation. Adding `func label() -> String` to the protocol declaration adds it to the
    witness table, allowing the struct's implementation to be called dynamically.
*/
