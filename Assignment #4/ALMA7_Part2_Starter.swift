// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Deck Register

// 1.1 Deck
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case cargo
    case medbay
    case engine

    var evacuationPriority: Int {
        switch self {
        case .bridge:
            return 1
        case .medbay:
            return 2
        case .lab:
            return 3
        case .engine:
            return 4
        case .cargo:
            return 5
        }
    }
}

// Level 1.1 Tests
print("\n--- Level 1.1 Tests: Deck Register ---")
for deck in Deck.allCases {
    print("Deck [\(deck.rawValue)] -> Evacuation Priority: \(deck.evacuationPriority)")
}
print("Total recognizable decks count: \(Deck.allCases.count)")

// 1.2 AlarmLevel
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = max(0, min(mass / 500, AlarmLevel.red.rawValue))
        return AlarmLevel(rawValue: step) ?? .red
    }
}

// Level 1.2 Tests
print("\n--- Level 1.2 Tests: AlarmLevel ---")
print("level(forTotalMass: 0) -> \(AlarmLevel.level(forTotalMass: 0)) (rawValue: \(AlarmLevel.level(forTotalMass: 0).rawValue))")
print("level(forTotalMass: 940) -> \(AlarmLevel.level(forTotalMass: 940)) (rawValue: \(AlarmLevel.level(forTotalMass: 940).rawValue))")
print("level(forTotalMass: 4000) -> \(AlarmLevel.level(forTotalMass: 4000)) (rawValue: \(AlarmLevel.level(forTotalMass: 4000).rawValue))")


// MARK: Level 2 · The Manifest

// 2.1 ManifestEntry
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2 parseEntry(_:)
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line, separatedBy: ":")
    guard parts.isEmpty == false else {
        return .unknown(raw: line)
    }

    switch parts[0] {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: mass)
    case "container":
        guard parts.count == 3,
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: mass)
    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnit = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnit)
    default:
        return .unknown(raw: line)
    }
}

// 2.3 mass(of:)
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

// Level 2 Tests & Integrity fragment A
print("\n--- Level 2 Tests: Manifest Processing ---")
print("parseEntry(\"crate:101:120\") -> \(parseEntry("crate:101:120"))")
print("parseEntry(\"container:KZ-ALM-7:340\") -> \(parseEntry("container:KZ-ALM-7:340"))")
print("parseEntry(\"livestock:lab mice:12:2\") -> \(parseEntry("livestock:lab mice:12:2"))")
print("parseEntry(\"crate:104:abc\") -> \(parseEntry("crate:104:abc"))")

var manifestTotalMass = 0
var manifestUnknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    manifestTotalMass += mass(of: entry)
    switch entry {
    case .unknown:
        manifestUnknownCount += 1
    default:
        break
    }
}

print("Raw manifest parsed: total lines = \(rawManifest.count), unknown lines = \(manifestUnknownCount)")
let A = manifestTotalMass
print("Integrity fragment A = \(A)")


// MARK: Level 3 · Crew Snapshots

// 3.1 CrewSnapshot
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: self.name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2 Build the roster
var crewRoster: [CrewSnapshot] = []
for record in crewData {
    if let deck = Deck(rawValue: record.deck) {
        crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    } else {
        print("Warning: Unknown deck '\(record.deck)' for crew member \(record.name). Record skipped.")
    }
}

print("\n--- Level 3.1 & 3.2 Tests: Crew Snapshots ---")
print("Roster built count: \(crewRoster.count)")
for member in crewRoster {
    print("Member: \(member.name) on deck \(member.deck.rawValue) with oxygen \(member.oxygen)%")
}
var rookieTest = CrewSnapshot.rookie(named: "Novice")
print("Rookie created: \(rookieTest.name), deck: \(rookieTest.deck), oxygen: \(rookieTest.oxygen)%")
rookieTest.reviveInMedbay()
print("After reviveInMedbay: \(rookieTest.name), deck: \(rookieTest.deck), oxygen: \(rookieTest.oxygen)%")

// 3.3 Value-semantics demonstration (copy / plain parameter / inout)
print("\n--- Level 3.3 Tests: Value-Semantics Demonstration ---")

func modifySnapshotPlain(_ snapshot: CrewSnapshot) {
    var localCopy = snapshot
    localCopy.breathe(25)
    print("  [Inside plain function] localCopy oxygen lowered to: \(localCopy.oxygen)")
}

func modifySnapshotInout(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(25)
    print("  [Inside inout function] snapshot oxygen lowered to: \(snapshot.oxygen)")
}

// Claim 1: A copy of a snapshot modified — and original unchanged
var originalMember1 = CrewSnapshot.rookie(named: "Claim1")
print("Claim 1 - Before copy modification: original oxygen = \(originalMember1.oxygen)")
var copyOfMember1 = originalMember1
copyOfMember1.breathe(30)
print("Claim 1 - After copy modification: copy oxygen = \(copyOfMember1.oxygen), original oxygen = \(originalMember1.oxygen) (unchanged)")

// Claim 2: A snapshot passed into plain function — and original unchanged
var originalMember2 = CrewSnapshot.rookie(named: "Claim2")
print("Claim 2 - Before plain function call: original oxygen = \(originalMember2.oxygen)")
modifySnapshotPlain(originalMember2)
print("Claim 2 - After plain function call: original oxygen = \(originalMember2.oxygen) (unchanged)")

// Claim 3: The same call using inout — original changed
var originalMember3 = CrewSnapshot.rookie(named: "Claim3")
print("Claim 3 - Before inout function call: original oxygen = \(originalMember3.oxygen)")
modifySnapshotInout(&originalMember3)
print("Claim 3 - After inout function call: original oxygen = \(originalMember3.oxygen) (changed)")


// MARK: Level 4 · The Teleport Pod

// 4.1 TeleportPod
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // Classes do not receive an automatic memberwise initializer in Swift,
    // so we must define one explicitly to initialize all stored properties.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil && chargeLevel >= 20 else {
            return false
        }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    deinit {
        print("TeleportPod [\(id)] deinitialized")
    }
}

// 4.2 Charge ledger: load+fire three times, then fire an empty pod
print("\n--- Level 4.2 Tests: Charge Ledger ---")
let podP1 = TeleportPod(id: "P-1", chargeLevel: 100)
print("Initial pod P-1 charge: \(podP1.chargeLevel)")

// Step 1: load Timur, fire()
let timur = crewRoster[0]
let loadedTimur = podP1.load(timur)
let firedTimur = podP1.fire()
print("Step 1 (Timur loaded: \(loadedTimur), fired: \(firedTimur?.name ?? "none")): charge = \(podP1.chargeLevel)")

// Step 2: load Dana, fire()
let dana = crewRoster[1]
let loadedDana = podP1.load(dana)
let firedDana = podP1.fire()
print("Step 2 (Dana loaded: \(loadedDana), fired: \(firedDana?.name ?? "none")): charge = \(podP1.chargeLevel)")

// Step 3: load Nurlan, fire()
let nurlan = crewRoster[3]
let loadedNurlan = podP1.load(nurlan)
let firedNurlan = podP1.fire()
print("Step 3 (Nurlan loaded: \(loadedNurlan), fired: \(firedNurlan?.name ?? "none")): charge = \(podP1.chargeLevel)")

// Step 4: fire() again with an empty pod
let firedEmpty = podP1.fire()
print("Step 4 (Empty pod fired: \(firedEmpty?.name ?? "none")): charge = \(podP1.chargeLevel)")

let C = podP1.chargeLevel
print("Integrity fragment C = \(C)")

// 4.3 Reference-semantics demonstration
print("\n--- Level 4.3 Tests: Reference-Semantics Demonstration ---")
let podRefA = TeleportPod(id: "Pod-RefA", chargeLevel: 80)
let podRefB = podRefA
print("Pod Before: podRefA charge = \(podRefA.chargeLevel), podRefB charge = \(podRefB.chargeLevel)")
podRefB.chargeLevel = 25
print("Pod After mutating podRefB: podRefA charge = \(podRefA.chargeLevel), podRefB charge = \(podRefB.chargeLevel)")

var snapValA = CrewSnapshot.rookie(named: "ValA")
var snapValB = snapValA
print("Snapshot Before: snapValA oxygen = \(snapValA.oxygen), snapValB oxygen = \(snapValB.oxygen)")
snapValB.oxygen = 35
print("Snapshot After mutating snapValB: snapValA oxygen = \(snapValA.oxygen), snapValB oxygen = \(snapValB.oxygen)")

// RULE DEMONSTRATED:
// Classes share reference identity so mutating one variable modifies the shared instance on the heap,
// whereas structs are value types that create an independent copy on assignment so mutating one never affects the other.


// MARK: Level 5 · Station Systems

// 5.1 Station
final class Station {
    // 1. Stored (let)
    let callSign: String

    // 2. Stored (var) with observers
    var hullIntegrity: Int {
        willSet {
            print("Hull integrity will change from \(hullIntegrity) to \(newValue)")
        }
        didSet {
            if hullIntegrity < 0 {
                hullIntegrity = 0
            } else if hullIntegrity > 100 {
                hullIntegrity = 100
            }
        }
    }

    // Stored dictionary of oxygen readings by deck
    var oxygenByDeck: [Deck: Int]

    // 3. Lazy stored property
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        var report = "Diagnostics Report for Station [\(self.callSign)]:"
        for (deck, oxy) in self.oxygenByDeck {
            report += "\n - Deck \(deck.rawValue): \(oxy)%"
        }
        return report
    }()

    // 4. Computed, read-only (written without the get keyword)
    var totalOxygen: Int {
        var sum = 0
        for oxy in oxygenByDeck.values {
            sum += oxy
        }
        return sum
    }

    // 5. Computed, get + set
    var averageOxygen: Int {
        get {
            guard oxygenByDeck.isEmpty == false else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = 100
        var dict: [Deck: Int] = [:]
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                dict[deck] = reading.oxygen
            }
        }
        self.oxygenByDeck = dict
    }
}

// Level 5 Tests & Integrity fragment B
print("\n--- Level 5.1 Tests: Station Systems ---")
let station = Station(callSign: "ALMA-7", readings: deckReadings)
print("Station created with \(station.oxygenByDeck.count) valid decks.")
print("Total oxygen: \(station.totalOxygen)")
let B = station.averageOxygen
print("Integrity fragment B (initial averageOxygen) = \(B)")

// Proving lazy property:
print("Checking diagnostics before access (scan message should not appear yet):")
print("Accessing station.fullDiagnostics for the first time:")
print(station.fullDiagnostics) // Prints "Running full scan..."
print("Accessing station.fullDiagnostics for the second time (should NOT print scan message):")
print(station.fullDiagnostics)

// 5.2 The clamp trap: 130, then -40, then 55
print("\n--- Level 5.2 Tests: The Clamp Trap ---")
station.hullIntegrity = 130
print("After assigning 130: hullIntegrity = \(station.hullIntegrity)")

station.hullIntegrity = -40
print("After assigning -40: hullIntegrity = \(station.hullIntegrity)")

station.hullIntegrity = 55
print("After assigning 55: hullIntegrity = \(station.hullIntegrity)")

// Why assigning inside didSet does not loop forever:
// In Swift, assigning a value to a property inside its own `didSet` observer does not
// trigger property observers recursively. The runtime suppresses observer re-invocation
// on direct self-assignment within observers to prevent infinite recursion.


// MARK: Level 6 · Incident Reports

/*
// ==================== INCIDENT REPORT ANALYSIS ====================

// Report 1:
// var roster = crewRoster
// for var member in roster {
//     member.oxygen -= 10
// }
// print(roster[0].oxygen)   // author expected the crew to have lost oxygen
//
// 1. Expectation: The author expected roster[0].oxygen to decrease by 10.
// 2. Actual behaviour: roster[0].oxygen is unchanged (remains 62).
// 3. Language rule: Structs are value types (copy-on-assignment). The loop variable
//    `member` is a local copy of each element. Mutating `member` mutates only that local copy.
// 4. Fix: Mutate elements directly through the array indices:
//    for i in 0..<roster.count {
//        roster[i].oxygen -= 10
//    }

// Report 2:
// let podA = TeleportPod(id: "A", chargeLevel: 100)
// let podB = podA
// podB.chargeLevel = 0
// print(podA.chargeLevel)   // author expected 100
//
// 1. Expectation: The author expected podA.chargeLevel to remain 100.
// 2. Actual behaviour: Prints 0.
// 3. Language rule: Classes are reference types. Assigning `podB = podA` copies the reference
//    pointer, not the object. Both point to the exact same instance in heap memory.
// 4. Fix: If a separate pod is needed, instantiate a distinct TeleportPod instance:
//    let podB = TeleportPod(id: "B", chargeLevel: podA.chargeLevel)

// Report 3:
// struct Logbook {
//     var entries: [String] = []
//     func add(_ entry: String) {
//         entries.append(entry)
//     }
// }
//
// 1. Expectation: A method to append an entry to the logbook.
// 2. Actual behaviour: Does not compile!
//    Compiler error: "Cannot use mutating member on immutable value: 'self' is immutable"
// 3. Language rule: In structs, instance methods cannot mutate stored properties unless marked `mutating`.
// 4. Fix: Mark `add` with `mutating`:
//    mutating func add(_ entry: String) { entries.append(entry) }

// Report 4:
// let snapshot = CrewSnapshot.rookie(named: "Dana")
// snapshot.oxygen = 40
//
// let pod = TeleportPod(id: "B", chargeLevel: 50)
// pod.chargeLevel = 10
//
// 1. Expectation: The author assumed `let` behaves identically for structs and classes.
// 2. Actual behaviour: `snapshot.oxygen = 40` does NOT compile (error: 'snapshot' is a 'let' constant).
//    However, `pod.chargeLevel = 10` compiles and runs successfully!
// 3. Language rule:
//    - For a struct (value type), `let` freezes the entire struct value and all of its properties.
//    - For a class (reference type), `let` freezes only the reference pointer itself (identity).
//      The properties of the class instance on the heap remain mutable if declared with `var`.
// 4. Fix: Declare `snapshot` with `var`:
//    var snapshot = CrewSnapshot.rookie(named: "Dana")
//    snapshot.oxygen = 40
*/

// Fixed and working versions of the incident reports:
print("\n--- Level 6 Tests: Fixed Incident Reports ---")
// Fix 1:
var fixedRoster = crewRoster
for i in 0..<fixedRoster.count {
    fixedRoster[i].oxygen -= 10
}
print("Fixed Report 1: roster[0].oxygen = \(fixedRoster[0].oxygen) (successfully decreased by 10)")

// Fix 2:
let fixedPodA = TeleportPod(id: "FixedA", chargeLevel: 100)
let fixedPodB = TeleportPod(id: "FixedB", chargeLevel: fixedPodA.chargeLevel)
fixedPodB.chargeLevel = 0
print("Fixed Report 2: fixedPodA charge = \(fixedPodA.chargeLevel) (remained 100)")

// Fix 3:
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var sampleLog = Logbook()
sampleLog.add("Incident documented")
print("Fixed Report 3: sampleLog entries count = \(sampleLog.entries.count)")

// Fix 4:
var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
fixedSnapshot.oxygen = 40
let fixedPod = TeleportPod(id: "FixedPod", chargeLevel: 50)
fixedPod.chargeLevel = 10
print("Fixed Report 4: snapshot oxygen = \(fixedSnapshot.oxygen), pod charge = \(fixedPod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    // Blocks external callers from reading, replacing, or modifying the entries array directly
    private var entries: [String] = []

    // Blocks external callers from resetting isSealed; read-only from outside
    private(set) var isSealed: Bool = false

    // Allows external callers to read the number of stored log entries
    var entryCount: Int {
        entries.count
    }

    // Allows external callers to safely append log entries while the recorder is open
    func record(_ entry: String) -> Bool {
        guard isSealed == false else { return false }
        entries.append(entry)
        return true
    }

    // Allows external callers to seal the recorder permanently
    func seal() {
        isSealed = true
    }

    // Blocks external modules but allows companion functions in this same file to access raw entries
    fileprivate func rawEntries() -> [String] {
        entries
    }
}

// A free function elsewhere in the file that uses the fileprivate helper:
func auditTranscript(of recorder: FlightRecorder) -> String {
    var transcript = "=== BLACK BOX AUDIT TRANSCRIPT (Sealed: \(recorder.isSealed)) ==="
    for entry in recorder.rawEntries() {
        transcript += "\n[LOG ENTRY]: \(entry)"
    }
    return transcript
}

// Level 7 Tests & Proof of Protection
print("\n--- Level 7 Tests: Flight Recorder ---")
let flightBox = FlightRecorder()
_ = flightBox.record("03:14 Engine telemetry nominal")
_ = flightBox.record("03:22 Teleport sequence initiated")
print("Before sealing: entryCount = \(flightBox.entryCount), isSealed = \(flightBox.isSealed)")
flightBox.seal()
let recordAfterSeal = flightBox.record("03:25 Unauthorized log after seal")
print("Record attempt after seal succeeded: \(recordAfterSeal)")
print(auditTranscript(of: flightBox))

/*
// Attempt to break the black box from outside the type:
// 1. Trying to clear entries:
// flightBox.entries.removeAll()
// -> Compiler Error: 'entries' is inaccessible due to 'private' protection level

// 2. Trying to unseal the recorder:
// flightBox.isSealed = false
// -> Compiler Error: Cannot assign to property: 'isSealed' setter is inaccessible
*/


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("\n==============================")
print("INTEGRITY CODE: \(integrityCode)")
print("==============================\n")


// MARK: Bonus

print("--- Bonus: Lifetime Experiment & Identity ---")
// 1 & 2: Lifetime experiment with do block
var escapingPodReference: TeleportPod?
do {
    print("Entering do { } scope...")
    let scopedPod = TeleportPod(id: "SCOPED-01", chargeLevel: 60)
    escapingPodReference = scopedPod
    print("Exiting do { } scope (scopedPod variable goes out of scope, but reference remains)...")
}
print("Outside do scope: escapingPodReference is still alive (pod id: \(escapingPodReference?.id ?? \"none\")).")
print("Releasing final reference (escapingPodReference = nil)...")
escapingPodReference = nil
// deinit fires immediately on the line above because the reference count drops to 0!

// 3: Identity operator === function
func areIdenticalPods(_ first: TeleportPod, _ second: TeleportPod) -> Bool {
    first === second
}

let alphaPod = TeleportPod(id: "POD-X", chargeLevel: 50)
let betaPod = alphaPod
let gammaPod = TeleportPod(id: "POD-X", chargeLevel: 50)

print("alphaPod === betaPod (same reference): \(areIdenticalPods(alphaPod, betaPod))")
print("alphaPod === gammaPod (different instances with identical properties): \(areIdenticalPods(alphaPod, gammaPod))")


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    - Structs: Swift automatically synthesizes a `memberwise initializer` for any struct
      that does not declare its own custom initializers. This memberwise init receives parameters
      for all stored properties in declaration order.
    - Classes: Classes do NOT get a memberwise initializer automatically. Swift only generates
      a default parameterless `init()` if every stored property has a default initial value.
      Since `TeleportPod` has properties like `id: String` without default values, Swift enforces
      a designated initializer to guarantee that memory is fully initialized before use.

 2. What does `mutating` do to self, and why do classes never need it?
    - For structs (value types), `self` is treated as an immutable constant inside methods by default.
      The `mutating` keyword tells the compiler that `self` is passed as an implicit `inout` parameter,
      enabling the method to mutate stored properties or assign a completely new instance to `self` (`self = ...`).
    - Classes have reference semantics. Calling a method on a class instance modifies the object stored
      in heap memory; it never mutates the reference pointer variable itself. Because `self` as a pointer
      is not reassigned, classes never require `mutating`.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
    - For a struct: `let` freezes the entire struct value in memory. Because structs are value types,
      immutability is transitive: freezing the struct instance freezes every single one of its stored properties,
      even those declared with `var`. Hence, `snapshot.oxygen = 40` cannot compile.
    - For a class: `let` freezes ONLY the reference pointer itself (the identity). You cannot reassign
      the variable to point to another object on the heap. However, the instance itself remains mutable:
      any stored property declared with `var` (`chargeLevel`) can be mutated without restriction.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
    - Why `var`: A `lazy` stored property is not initialized during instance creation; its initial value
      is computed and stored upon its FIRST access. Because accessing the property mutates the instance by
      writing the calculated value into memory, it must be declared as `var`.
    - When it changes behaviour: If the computation of the property relies on mutable state or external
      side effects that change between instance initialization and property access.
      For example, if `fullDiagnostics` reads `oxygenByDeck` or logs a message, accessing it later produces
      a result reflecting the state at the time of access (or never executes side effects if unread),
      whereas an eager stored property would evaluate strictly at initialization time.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
    - `private` restricts visibility strictly to the enclosing type declaration and extensions in the same file.
    - In `FlightRecorder`, the helper method `rawEntries()` is needed by the top-level free function
      `auditTranscript(of:)`. If `rawEntries()` were marked `private`, `auditTranscript(of:)` would fail
      to compile because it is outside the `FlightRecorder` class declaration.
    - `fileprivate` is the exact right access level: it allows any declaration within the same source file
      to access the helper, while keeping it strictly hidden from outside files and modules.

 Bonus. On which line does deinit fire, and why can't === be used on CrewSnapshot?
    - Line where deinit fires: `deinit` fires on the line `escapingPodReference = nil`, where the last
      strong reference to the `TeleportPod` instance is released, dropping the reference count to 0.
    - Why `===` cannot be used on CrewSnapshot:
      The `===` (identity) operator checks whether two references point to the exact same memory address
      on the heap. It is only defined for class instances (`AnyObject`). Structs are value types; they do
      not have an object identity or a heap address, only their values. Therefore, comparing structs with
      `===` is a compile-time type error.
*/
