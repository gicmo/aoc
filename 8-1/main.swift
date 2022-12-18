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
var result = Matrix(repeating: false, rows: mat.nRows, cols: mat.nCols)

// rows, front to back
for r in 0..<mat.nRows {
    maxHeight = -1
    for c in 0..<mat.nCols {
        let h = Int(mat[r, c])
        if h > maxHeight {
            maxHeight = h
            result[r, c] = true
        }
    }
}


// rows, back to front
for r in 0..<mat.nRows {
    maxHeight = -1
    for c in (0..<mat.nCols).reversed() {
        let h = Int(mat[r, c])
        if h > maxHeight {
            maxHeight = h
            result[r, c] = true
        }
    }
}


// cols, top to bottom
for c in 0..<mat.nCols {
    maxHeight = -1
    for r in 0..<mat.nRows {
        let h = Int(mat[r, c])
        if h > maxHeight {
            maxHeight = h
            result[r, c] = true
        }
    }
}

// cols, bottom to top
for c in 0..<mat.nCols {
    maxHeight = -1
    for r in (0..<mat.nRows).reversed() {
        let h = Int(mat[r, c])
        if h > maxHeight {
            maxHeight = h
            result[r, c] = true
        }
    }
}

// result
var candidates = 0
for r in 0..<result.nRows {
    for c in 0..<result.nCols {
        if result[r, c] {
            candidates += 1
        }
    }
}

print(candidates)
