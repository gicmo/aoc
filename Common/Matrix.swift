import Foundation

public struct Matrix<Element> {
    // we store data in row-major
    private var data: [Element]
    public let nRows: UInt8
    public let nCols: UInt8
    
    public typealias Index = Int
    
    public init(data: [Element], rows: UInt8, cols: UInt8) {
        precondition(data.count == Int(rows) * Int(cols), "\(data.count) != \(rows) * \(cols)")
        self.data = data
        self.nRows = rows
        self.nCols = cols
    }
    
    public init(data: [Element], rows: Int, cols: Int) {
        precondition(rows < UInt8.max && cols < UInt8.max)
        self.init(data:data, rows:UInt8(rows), cols:UInt8(cols))
    }
   
    public init(repeating repeatedValue: Element, rows: UInt8, cols: UInt8) {
        let data = Array(repeating: repeatedValue, count: Int(rows) * Int(cols))
        self.init(data:data, rows:rows, cols:cols)
    }
    
    public var count: Int {
        get {
            return Int(self.nRows) * Int(self.nCols)
        }
    }
    
    internal func getIndex(row: UInt8, col: UInt8) -> Index {
       return Int(row) * Int(nCols) + Int(col)
    }
   
    public subscript(_ row: UInt8, _ col: UInt8) -> Element {
        get {
            precondition(row < self.nRows && col < self.nCols)
            let idx = getIndex(row: row, col: col)
            return self.data[idx]
        }
        set(newValue) {
            precondition(row < self.nRows && col < self.nCols)
            let idx = getIndex(row: row, col: col)
            self.data[idx] = newValue
        }
    }
    
    public subscript(_ index: Index) -> Element {
        
        get {
            precondition(index < self.data.count)
            return self.data[index]
        }
        
        set {
            precondition(index < self.data.count)
            self.data[index] = newValue
        }
    }
    
}

extension Matrix where Element: Equatable {
    public func firstIndex(of element: Element) -> Index? {
        for (idx, val) in self.data.enumerated() {
            if val == element {
                return idx
            }
        }
        
        return nil
    }
}

extension Matrix: CustomStringConvertible {
    public var description: String {
        get {
            var str = ""

            for r in 0..<self.nRows {
                for c in 0..<self.nCols {
                    let s = "\(self[r, c])"
                    
                    s.withCString { cs in
                        str += String(format: "%3s ", cs)
                    }
                    
                    //str += String(format: "%3@ ", s)
                }
                str += "\n"
            }
            return str
        }
    }
}
