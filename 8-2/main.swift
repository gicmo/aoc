import Foundation
import Common

func parseInput() -> Matrix<UInt8> {
    var buffer: [UInt8] = []
    var nCols = 0
    var nRows = 0
    while let line = readLine() {
        let nums = line.map { v in UInt8(String(v))! }
        if nCols == 0 {
            nCols = nums.count
        } else {
            assert(nCols == nums.count)
        }
        buffer.append(contentsOf: nums)
        nRows += 1
    }
    print(nCols, nRows, buffer.count)
    return Matrix(data: buffer, rows: nRows, cols: nCols)
}

let mat = parseInput()
print(mat)

// dumb and naive version, with repetitions
var maxHeight = -1
var result = Matrix(repeating: 0, rows: mat.nRows, cols: mat.nCols)

func scenicScore(forest m: Matrix<UInt8>, row r: UInt8, col c: UInt8) -> Int {
    let height = m[r, c]
    var score = 1
    
    debugPrint("height: \(height) at \(r) \(c)")
   
    debugPrint("looking up [\(score)]")
    var trees = 0
    for v in (0..<r).reversed() {
        trees += 1
        let h = m[v, c]
        debugPrint("  checking \(h) at \(v)")
        if h >= height {
            break
        }
    }
  
    score *= trees
    
    debugPrint("looking down [\(score)]")
    trees = 0
    for v in ((r+1)..<m.nRows) {
        trees += 1
        let h = m[v, c]
        debugPrint("  checking \(h) at \(v)")
        if h >= height {
            break
        }
    }
    
    score *= trees
    
    debugPrint("looking left [\(score)]")
    trees = 0
    for v in (0..<c).reversed() {
        trees += 1
        let h = m[r, v]
        debugPrint("  checking \(h) at \(v)")
        if h >= height {
            break
        }
    }
    
    score *= trees
    
    debugPrint("looking right [\(score)]")
    trees = 0
    for v in ((c+1)..<m.nCols) {
        trees += 1
        let h = m[r, v]
        debugPrint("  checking \(h) at \(v)")
        if h >= height {
            break
        }
    }
    
    score *= trees
        
    return score
}

var candidate = 0
for r in 0..<mat.nRows {
    for c in 0..<mat.nCols {
        let score = scenicScore(forest: mat, row: r, col: c)
        if score > candidate {
            debugPrint("FOUND CANDIDATE AT \(r), \(c) [\(score)]")
            candidate = score
        }
    }
}

print(candidate)
