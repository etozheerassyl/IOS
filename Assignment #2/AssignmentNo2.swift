import Foundation

let fruits = ["apple", "mango", "kiwi", "banana", "orange"]

var favoriteNumbers: Set<Int> = [7, 99, 141, 67, 69]

favoriteNumbers.insert(121)

print(favoriteNumbers)

let programmingLanguages: [String: Int] = [
    "Swift": 2014,
    "Java": 1995,
    "Python": 1991
]

print(programmingLanguages["Swift"]!)

var colors = ["yellow", "green", "blue", "red"]

colors[1] = "purple"

print(colors)

Set1 = [1,2,3,4]
Set2 = [3,4,5,6]

let set1: Set<Int> = [1,2,3,4]
let set2: Set<Int> = [3,4,5,6]

let intersection = set1.intersection(set2)

print(intersection)

var scores: [String: Int] = [
    "Yerassyl": 92,
    "Cristiano": 99,
    "Lionel": 51
]

scores.updateValue(95, forKey: "Yerassyl")

print(scores)

let fruits1 = ["apple", "banana"]
let fruits2 = ["cherry", "date"]

let allFruits = fruits1 + fruits2

print(allFruits)

var populations: [String: Int] = [
    "Kazakhstan": 20000000,
    "USA": 34000000,
    "Japan": 1230000
]

populations.updateValue(8400000, forKey: "Germany")

print(populations)

Animals1 = ["cat", "dog"]
Animals2 = ["dog", "mouse"]

let animals1: Set<String> = ["cat", "dog"]
let animals2: Set<String> = ["dog", "mouse"]

let union = animals1.union(animals2)
let sub = union.subtracting(animals2)

print(sub)

let studentGrades: [String: [Int]] = [
    "Yerassyl": [92,95,89],
    "Cristiano": [99,99,100],
    "Lionel": [51,56,76]
]

print(studentGrades["Yerassyl"]![1])
