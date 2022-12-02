import Foundation

let i = try String(contentsOfFile: "1.txt")
let top3 = i.split(separator: "\n\n").lazy.map{s in s.split(separator: "\n").map{x in Int(x)!}.reduce(0, +)}.sorted(by: >).prefix(3)
print("top 3 \(top3)")
let sum = top3.reduce(0, +)
print("total: \(sum)")


