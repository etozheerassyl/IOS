import Foundation

let firstName: String = "Yerassyl"
let lastName: String = "Sabitov"
let birthYear: Int = 2006
let currentYear: Int = 2026

let age: Int = currentYear - birthYear

let isStudent: Bool = true
let height: Double = 1.85
let city: String = "Almaty"

let hobby: String = "VFX and 3D modeling"
let numberOfHobbies: Int = 4
let favouriteNumber: Int = 7
let isHobbyCreative: Bool = true

let studentDescription = isStudent ? "currently a student" : "not a student"
let creativeDescription = isHobbyCreative ? "a creative hobby" : "not a creative hobby"

let futureGoals: String = "become a billionaire"
let 🛞Role: String = "Developer"

var lifeStory: String = """
My full name is \(firstName) \(lastName). I am \(age) y.o., born in \(birthYear), and my hometown is \(city).
I am \(studentDescription) with a height of \(height)m.
I enjoy \(hobby), which is \(creativeDescription).
I have \(numberOfHobbies) hobbies in total, and my favourite number is \(favouriteNumber).
"""

lifeStory += "As a \(🛞Role), in the future, I want to \(futureGoals)."

print(lifeStory)
