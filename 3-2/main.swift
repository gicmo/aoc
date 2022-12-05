import Foundation

func charValue(_ ch: Character) -> Int {
    guard let v = ch.asciiValue else {
        return 0
    }

    var r: Int

    // tiny bit sloppy w.r.t. integer underflow
    if v > 96 {
        r = Int(v - Character("a").asciiValue!) + 1
    } else {
        r = Int(v - Character("A").asciiValue!) + 27
    }

    return r
}

var sum: Int = 0
var ln: Int = 1
var common: Set<Character> = []

while let line = readLine() {
    let ls = Set(Array(line))

    if common.count > 0 {
        common = common.intersection(ls)
    } else {
        common = ls
    }

    if ln % 3 == 0 {
        ln = 0

        precondition(common.count == 1, "Need exactly one common element not \(common.count)")
        sum += charValue(common.first!)

        common = Set<Character>() 
    }

    ln += 1
}

print(sum)
