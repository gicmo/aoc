import Foundation

let i = try String(contentsOfFile: "1.txt")
let x = i.split(separator: "\n\n").lazy.map{s in s.split(separator: "\n").map{x in Int(x)!}.reduce(0, +)}.max()!
print(x)


