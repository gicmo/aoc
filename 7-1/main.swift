import Foundation
import RegexBuilder

enum Command {
    case ChangeDirectory(String)
    case ListDir
}

enum Entry {
    case Directory(String)
    case File(String, UInt)
}

let entryName = Regex {
    OneOrMore(
        CharacterClass(
            .anyOf("."),
            ("a"..."z"),
            ("A"..."Z")
        )
    )
}

func parseCmdLine(_ line: String) -> Command {
    let regex = Regex {
        "$ "
        ChoiceOf {
            Regex {
                "cd "
                TryCapture {
                    ChoiceOf {
                        entryName
                        "/"
                        ".."
                    }
                } transform: { arg in
                    Command.ChangeDirectory(String(arg))
                }
            }
            Regex {
                "ls"
            }
        }
    }
    
    guard let match = line.wholeMatch(of: regex) else {
        print("failed to match command line \(line)")
        exit(1)
    }
    
    if let cmd = match.output.1 {
        return cmd
    } else {
        return Command.ListDir
    }
}

func parseEntryLine(_ line: String) -> Entry {
    let name = Reference(String.self)
    let size = Reference(UInt.self)
    
    let regex = Regex {
        ChoiceOf {
            Regex {
                "dir "
                TryCapture {
                    entryName
                } transform: { name in
                    Entry.Directory(String(name))
                }
            }
            Regex {
                TryCapture(OneOrMore(.digit), as: size, transform: { num in UInt(num) })
                " "
                TryCapture(entryName, as: name, transform: { str in String(str) })
            }
        }
    }
    
    guard let match = line.wholeMatch(of: regex) else {
        print("failed to parse dir entry '\(line)'")
        exit(1)
    }

    if let dirEntry = match.output.1 {
        return dirEntry
    }
    
    let n = match[name]
    let s = match[size]
    
    return Entry.File(n, s)
}

struct Directory {
    let path: [String]
    let entries: [Entry]
}

struct DirBuilder {
    var entries: [Entry] = []
    var cwd: [String] = ["/"]
    
    mutating func changeDir(to name: String) {
        precondition(entries.isEmpty, "changeDir with non-empty entries")

        if name == "/" {
            cwd.removeAll()
            cwd.append("/")
        } else if name == ".." {
            guard let e = cwd.popLast() else {
                print("here be dragons")
                exit(1)
            }
            // cd .. at / is /
            if e == "/" {
                cwd.append(e)
            }
        } else {
            cwd.append(name)
        }
        
        print("CWD: \(cwd)")
    }
    
    mutating func addEntry(_ entry: Entry) {
        entries.append(entry)
    }
    
    mutating func finish() -> Directory {
        let res = Directory(path: self.cwd, entries: self.entries)
        self.entries = []
        return res
    }
}

var listDir = false
var builder = DirBuilder()
var dirs: [Directory] = []

func finishDir() {
    let dir = builder.finish()
    print("BUILT dir \(dir)")
    dirs.append(dir)
    listDir = false
}

while let line = readLine() {
    
    if line.starts(with: "$") {
        if listDir {
            finishDir()
        }

        let cmd = parseCmdLine(line)
        print(cmd)

        switch cmd {
        case .ListDir:
            listDir = true
        case .ChangeDirectory(let name):
            builder.changeDir(to: name)
        }

    } else if listDir {
        let entry = parseEntryLine(line)
        print(entry)
        builder.addEntry(entry)
    } else {
        preconditionFailure("here be drangons")
    }
}

if listDir {
    finishDir()
}

// sort by longest path first
dirs.sort { a, b in
    a.path.count > b.path.count
}

var sizes: [[String]: UInt] = [:]

// calcuate the total sizes
for d in dirs {
    var size: UInt = 0
    
    for e in d.entries {
        switch e {
        case .File(_, let s):
            size += s
        case .Directory(let name):
            let path = d.path + [name]
            guard let s = sizes[path] else {
                print("should know about \(path)")
                exit(1)
            }
            size += s
        }
    }
    sizes[d.path] = size
}

let limit = UInt(100000)
let smallDirs = sizes.map { path, size in size }.filter { size in size <= limit }
print(smallDirs)

let totalSize = smallDirs.reduce(0, +)
print("sum of dirs with size at most \(limit): \(totalSize)")
