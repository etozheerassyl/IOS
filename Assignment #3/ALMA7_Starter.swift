// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · Decoding Telemetry

// 1.1 parseReading(_:)
// Valid only if: contains ':', sensor name not empty, value is Int,
// value >= 0 (except TEMP sensor which can be negative).
// Uses a single guard let with comma-separated conditions.
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueStr) = splitOnce(raw, by: ":"),
          sensor.isEmpty == false,
          let value = Int(valueStr),
          sensor == "TEMP" || value >= 0 else {
        return nil
    }
    return (sensor: sensor, value: value)
}

// 1.1 Tests
print("\n--- Level 1.1 Tests: parseReading ---")
print("parseReading(\"O2:87\"): \(String(describing: parseReading("O2:87")))")
print("parseReading(\"TEMP:-12\"): \(String(describing: parseReading("TEMP:-12")))")
print("parseReading(\"RAD:-1\"): \(String(describing: parseReading("RAD:-1")))")
print("parseReading(\":55\"): \(String(describing: parseReading(":55")))")
print("parseReading(\"TEMP:abc\"): \(String(describing: parseReading("TEMP:abc")))")

// 1.2 parseLog(_:)
// Returns all valid readings and count of corrupted lines.
// No map/filter/compactMap used.
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

// 1.2 Tests
print("\n--- Level 1.2 Tests: parseLog ---")
let parsedLog = parseLog(rawLog)
print("parseLog(rawLog) -> valid count: \(parsedLog.valid.count), invalid count: \(parsedLog.invalidCount)")
let sampleLogTest = parseLog(["O2:50", "CORRUPTED", "TEMP:22"])
print("parseLog(sampleLogTest) -> valid count: \(sampleLogTest.valid.count), invalid count: \(sampleLogTest.invalidCount)")

let A = parsedLog.invalidCount
print("Code fragment A = \(A)")


// MARK: Level 2 · Analysis

// 2.1 select(_:where:) and values(of:)
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

// Get all readings from O2 sensor using trailing closure and $0
let o2Readings = select(parsedLog.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)

// 2.1 Tests
print("\n--- Level 2.1 Tests: select & values ---")
print("O2 readings count: \(o2Readings.count), values: \(o2Values)")
let pressReadings = select(parsedLog.valid) { $0.sensor == "PRESS" }
print("PRESS values: \(values(of: pressReadings))")

// 2.2 stats(of:) and stats(_:)
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard values.isEmpty == false else { return nil }
    var currentMin = values[0]
    var currentMax = values[0]
    var sum = 0
    for value in values {
        if value < currentMin { currentMin = value }
        if value > currentMax { currentMax = value }
        sum += value
    }
    let average = Double(sum) / Double(values.count)
    return (min: currentMin, max: currentMax, average: average)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

// 2.2 Tests
print("\n--- Level 2.2 Tests: stats ---")
print("stats(3, 8, 1): \(String(describing: stats(3, 8, 1)))")
print("stats(): \(String(describing: stats()))")
print("stats(of: o2Values): \(String(describing: stats(of: o2Values)))")

let o2Stats = stats(of: o2Values)
let B = Int(o2Stats?.average ?? 0.0)
print("Code fragment B = \(B)")

// 2.3 · The Closure Ladder (5 sorts, descending by value)
print("\n--- Level 2.3 Tests: Closure Ladder ---")
// 1. Full closure syntax with types and return
let sort1 = parsedLog.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

// 2. Types inferred from context
let sort2 = parsedLog.valid.sorted(by: { a, b in
    return a.value > b.value
})

// 3. Implicit return
let sort3 = parsedLog.valid.sorted(by: { a, b in
    a.value > b.value
})

// 4. Shorthand argument names $0, $1
let sort4 = parsedLog.valid.sorted(by: {
    $0.value > $1.value
})

// 5. Trailing closure
let sort5 = parsedLog.valid.sorted {
    $0.value > $1.value
}

// Verification in code
func areReadingsEqual(_ first: [Reading], _ second: [Reading]) -> Bool {
    guard first.count == second.count else { return false }
    for i in 0..<first.count {
        if (first[i].sensor == second[i].sensor && first[i].value == second[i].value) == false {
            return false
        }
    }
    return true
}

let ladderAllMatch = areReadingsEqual(sort1, sort2) &&
                     areReadingsEqual(sort2, sort3) &&
                     areReadingsEqual(sort3, sort4) &&
                     areReadingsEqual(sort4, sort5)

print("Closure ladder: all 5 sort variations match exactly -> \(ladderAllMatch)")


// MARK: Level 3 · Temperature Stabilization

// 3.1 Protocols as values
func heatUp(_ t: Int) -> Int {
    t + 5
}

func coolDown(_ t: Int) -> Int {
    t - 3
}

func hold(_ t: Int) -> Int {
    t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

// 3.1 Tests
print("\n--- Level 3.1 Tests: Protocols as values ---")
print("heatUp(10): \(heatUp(10))")
print("coolDown(30): \(coolDown(30))")
print("hold(20): \(hold(20))")
let protoBelow = chooseProtocol(for: 15)
let protoAbove = chooseProtocol(for: 28)
let protoSafe  = chooseProtocol(for: 20)
print("chooseProtocol(for: 15)(15) -> \(protoBelow(15))")
print("chooseProtocol(for: 28)(28) -> \(protoAbove(28))")
print("chooseProtocol(for: 20)(20) -> \(protoSafe(20))")

// 3.2 runUntilStable
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var currentTemp = start
    var steps = 0
    while (currentTemp < 18 || currentTemp > 24) && steps < maxSteps {
        let protocolFunc = chooseProtocol(for: currentTemp)
        currentTemp = protocolFunc(currentTemp)
        steps += 1
    }
    let isStable = currentTemp >= 18 && currentTemp <= 24
    return (finalTemp: currentTemp, steps: steps, isStable: isStable)
}

// 3.2 Tests
print("\n--- Level 3.2 Tests: runUntilStable ---")
print("runUntilStable(from: 31): \(runUntilStable(from: 31))")
print("runUntilStable(from: -100, maxSteps: 5): \(runUntilStable(from: -100, maxSteps: 5))")
print("runUntilStable(from: 20): \(runUntilStable(from: 20))")

// Code fragment C: steps for lowest valid temperature in log
let tempReadings = select(parsedLog.valid) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)
let lowestTemp = stats(of: tempValues)?.min ?? 0
let stableResultForLowestTemp = runUntilStable(from: lowestTemp)
let C = stableResultForLowestTemp.steps
print("Lowest valid TEMP: \(lowestTemp), steps to stabilize: \(C)")
print("Code fragment C = \(C)")


// MARK: Level 4 · The Crew

// 4.1 oxygenLevel(of:)
// One line using optional chaining
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

// 4.1 Tests
print("\n--- Level 4.1 Tests: oxygenLevel ---")
print("oxygenLevel(of: Timur): \(String(describing: oxygenLevel(of: crew[0])))")
print("oxygenLevel(of: Dana): \(String(describing: oxygenLevel(of: crew[1])))")
print("oxygenLevel(of: Nurlan): \(String(describing: oxygenLevel(of: crew[3])))")

// 4.2 status(of:)
// Uses guard let and ?? operator
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }
    if level < 20 {
        return "\(member.name): \(level)% CRITICAL"
    } else {
        return "\(member.name): \(level)% OK"
    }
}

// 4.2 Tests & Crew Status Printing
print("\n--- Level 4.2 Tests: Crew Status ---")
for member in crew {
    print(status(of: member))
}

// 4.3 Oxygen Transfer
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let available = max(0, source)
    let capacity = max(0, 100 - target)
    let actualTransfer = min(amount, available, capacity)
    source -= actualTransfer
    target += actualTransfer
    return actualTransfer
}

// 4.3 Tests & Lab -> Hab transfer of 30 units
print("\n--- Level 4.3 Tests: transferOxygen ---")
var testSource = 50
var testTarget = 90
let testTransferred = transferOxygen(from: &testSource, to: &testTarget, amount: 25)
print("Test transfer 25 (capacity 10): transferred \(testTransferred), source: \(testSource), target: \(testTarget)")

var negativeSource = 20
var negativeTarget = 20
let testNegative = transferOxygen(from: &negativeSource, to: &negativeTarget, amount: -10)
print("Negative transfer: transferred \(testNegative), source: \(negativeSource), target: \(negativeTarget)")

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let transferred = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Transferred \(transferred) units from Lab (\(labTank.level)%) to Hab (\(habTank.level)%)")
}

let D = hab.oxygenTank?.level ?? 0
print("Code fragment D = \(D)")

// 4.4 evacuationOrder(_:roster:)
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var foundMembers: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        foundMembers.append(member)
    }
    let sortedMembers = foundMembers.sorted(by: { $0.priority < $1.priority })
    var sortedNames: [String] = []
    for member in sortedMembers {
        sortedNames.append(member.name)
    }
    return sortedNames
}

// 4.4 Tests
print("\n--- Level 4.4 Tests: evacuationOrder ---")
let evacuation1 = evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster)
print("Evacuation Order 1: \(evacuation1)")
let evacuation2 = evacuationOrder("Unknown1", "Nurlan", "Aigerim", roster: roster)
print("Evacuation Order 2: \(evacuation2)")


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code:
/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/

// SABOTEUR CODE ANALYSIS:
// Problem 1: `member.module!` force-unwraps `member.module`.
//   - Breaking data: A crew member in open space whose `module` is `nil` (e.g. Nurlan).
//   - Consequence: Fatal crash `Unexpectedly found nil while unwrapping an Optional value`.
//
// Problem 2: `member.module!.oxygenTank!` force-unwraps `oxygenTank`.
//   - Breaking data: A crew member in a module without an oxygen tank (e.g. Dana in Dock).
//   - Consequence: Fatal crash attempting to unwrap `nil`.
//
// Problem 3: `oxygenLevel(of: member)!` force-unwraps `Int?`.
//   - Breaking data: Any crew member without an active oxygen tank (Dana or Nurlan).
//   - Consequence: Fatal crash because `oxygenLevel(of:)` returns `nil`.
//
// Problem 4 (LOGIC BUG):
//   `for member in crew { if oxygenLevel(of: member)! < 20 { result = member.name } }`
//   The loop does not stop when finding a critical member; it continues iterating and
//   overwrites `result`. Thus, it returns the LAST critical member instead of the FIRST!
//   - Breaking data: Any crew list with 2 or more critical members (e.g. [CritA, CritB]).
//   - Consequence: In correct logic it must return CritA, but saboteur code returns CritB.
//
// Problem 5: `return result!` force-unwraps `result`.
//   - Breaking data: A crew where no member has oxygen < 20% (all are safe/OK).
//   - Consequence: Fatal crash unwrapping `nil` because `result` remains `nil`.

// Rewritten safe versions without `!`:
func reportOxygen(for member: CrewMember) -> String {
    guard let module = member.module, let tank = module.oxygenTank else {
        return "\(member.name): no oxygen tank available"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

// Level 5 Tests & Logic Bug Fix Proof
print("\n--- Level 5 Tests: Saboteur Code Fixes ---")
print("reportOxygen(for: Timur): \(reportOxygen(for: crew[0]))")
print("reportOxygen(for: Dana): \(reportOxygen(for: crew[1]))")
print("reportOxygen(for: Nurlan): \(reportOxygen(for: crew[3]))")

print("firstCritical(in: starter crew): \(String(describing: firstCritical(in: crew)))")

// Proof that the logic bug is fixed:
// With two critical members, the saboteur's code would return "Crit2" (last critical).
// Our fixed function correctly returns "Crit1" (first critical).
let critTank1 = Tank(level: 10)
let critTank2 = Tank(level: 15)
let critMod1 = Module(name: "Breach1", oxygenTank: critTank1)
let critMod2 = Module(name: "Breach2", oxygenTank: critTank2)
let twoCriticalCrew = [
    CrewMember(name: "Crit1_Alice", role: "Specialist", priority: 1, module: critMod1),
    CrewMember(name: "Crit2_Bob",   role: "Specialist", priority: 2, module: critMod2)
]
let firstFound = firstCritical(in: twoCriticalCrew)
print("Logic bug fix proof -> expected 'Crit1_Alice', got: \(firstFound ?? "none")")

// Test when nobody is critical:
let allSafeTank = Tank(level: 80)
let safeMod = Module(name: "SafeRoom", oxygenTank: allSafeTank)
let safeCrew = [CrewMember(name: "SafeSam", role: "Medic", priority: 1, module: safeMod)]
print("firstCritical when all safe -> expected nil, got: \(String(describing: firstCritical(in: safeCrew)))")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("\n==============================")
print("LAUNCH CODE: \(launchCode)")
print("==============================\n")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var fireCount = 0
    return { level in
        if level < threshold {
            fireCount += 1
            print("Alarm #\(fireCount)")
            return true
        } else {
            return false
        }
    }
}

// Bonus Tests
print("--- Bonus Tests: makeAlarm ---")
let alarm = makeAlarm(threshold: 20)
print("alarm(12): \(alarm(12))") // Alarm #1 -> true
print("alarm(40): \(alarm(40))") // false
print("alarm(5): \(alarm(5))")   // Alarm #2 -> true

let alarmHigh = makeAlarm(threshold: 50)
print("alarmHigh(30): \(alarmHigh(30))") // Alarm #1 -> true
print("alarmHigh(60): \(alarmHigh(60))") // false


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    - Variable Scope:
      In `if let`, the unwrapped constant exists solely inside the body of the `if` block.
      In `guard let`, the unwrapped constant is scoped to the entire enclosing scope AFTER the guard statement.
    - Mandatory Early Exit:
      A `guard` statement strictly requires an `else` branch that must exit the current scope
      (via `return`, `throw`, `break`, `continue`, or `fatalError()`). The compiler guarantees that execution
      cannot fall through if the condition fails.
    - Eliminating the "Pyramid of Doom":
      Sequential `if let` checks cause deep nested indentation, pushing the happy-path code
      further to the right and separating preconditions from their handling.
      `guard let` keeps the happy path flat and unindented at the root level ("early return" pattern).

      Example where if let makes the code noticeably worse:
      // Using if let (nested pyramid of doom):
      func handleOxygenLevelBad(member: CrewMember) {
          if let module = member.module {
              if let tank = module.oxygenTank {
                  if tank.level > 0 {
                      print("\(member.name) has \(tank.level)% oxygen")
                  } else {
                      print("Tank empty")
                  }
              } else {
                  print("No tank")
              }
          } else {
              print("No module")
          }
      }

      // Using guard let (clean, flat, easy to read and maintain):
      func handleOxygenLevelGood(member: CrewMember) {
          guard let module = member.module else { print("No module"); return }
          guard let tank = module.oxygenTank else { print("No tank"); return }
          guard tank.level > 0 else { print("Tank empty"); return }
          print("\(member.name) has \(tank.level)% oxygen")
      }


 2. Why can't you pass [Int] to stats(_ values: Int...)?
    - A variadic parameter (`Int...`) in Swift expects a comma-separated list of individual `Int`
      arguments at the call site (e.g. `stats(1, 2, 3)`), not an array instance `[Int]`.
    - Swift does not have an automatic collection "splat" or unpacking operator to expand an array
      into variadic arguments at the call site.
    - If you pass an array `someArray` to `stats(...)`, the compiler tries to match `[Int]` against
      the expected element type `Int`, resulting in a type mismatch error:
      "Cannot pass value of type '[Int]' to variadic parameter expecting 'Int'".
    - That is why the overload `stats(of values: [Int])` is explicitly provided.


 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    - Reason:
      Swift enforces the "Law of Exclusivity" (Memory Safety Rule) regarding in-out parameters.
      Passing the same variable as `inout` to two distinct parameters of the same function call
      creates overlapping, simultaneous write access to the same memory location.
    - What bug does this prevent:
      It prevents memory aliasing conflicts, data races, and undefined behavior. If both `from`
      and `to` pointed to the same variable `x`, mutating one would mutate the other simultaneously,
      corrupting intermediate calculations (e.g., deducting 5 and adding 5 could produce inconsistent states,
      or violating capacity checks).


 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    - Reason:
      The nil-coalescing operator `??` requires that the default expression on the right-hand side
      evaluates to the same type as the wrapped value of the Optional on the left-hand side.
    - Here, `oxygenLevel(of: dana)` has type `Int?` (its wrapped type is `Int`).
      The right-hand side `"no data"` has type `String`.
      Swift is a strongly, statically typed language and cannot reconcile `Int` and `String`
      into a single homogeneous return type for the expression.


 5. Full type of chooseProtocol and how to read it:
    - Full type:
      (Int) -> (Int) -> Int
    - How to read it:
      `chooseProtocol` is a function that accepts one argument of type `Int` (representing temperature)
      and returns a function of type `(Int) -> Int` (a protocol function that takes an `Int` temperature
      and returns a modified `Int` temperature).
      Because the function arrow `->` is right-associative in Swift, `(Int) -> (Int) -> Int` is equivalent
      to `(Int) -> ((Int) -> Int)`.


 Bonus. Where does the alarm counter live after makeAlarm returns?
    - The counter physically lives in HEAP memory.
    - Normally, local variables declared inside a function are allocated on the call stack and destroyed
      when the function scope returns.
    - However, when an escaping closure captures a mutable local variable (`var fireCount`), Swift detects
      that the variable's lifetime must outlive the `makeAlarm` stack frame.
    - Swift automatically promotes (boxes) the captured variable onto the HEAP.
    - The returned closure holds a strong reference to this heap-allocated box, allowing `fireCount` to persist
      and retain its state across subsequent calls to the closure.
*/
