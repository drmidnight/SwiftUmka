import XCTest
@testable import Umka

final class UmkaTests: XCTestCase {
    func testExample() {
        struct Color {
            let r, g, b, a: UInt8
        }
        
        struct Vector2 {
            let x, y: Float32
        }
        var filename = "/Users/cmorello/Developer/Swift/CUmka/Sources/Umka/test.um"
        let umka = Umka.init(fileName:filename, stackSize: 1024*1024)
        defer { umka.free() }
        umka.addFunc(name: "printFunc") { slot, val in
            guard let message: String  = slot?.pointee.ptrAsString() else { return }
            print(message)
        }
        
        // doesn't work. Buffer ptr is 8bit chunks and need to load 32bit slices
        umka.addFunc(name: "testVec2Struct") { slot, val in
            guard let vec: Vector2 = slot?.pointee.ptrAsType() else { return }
            print(vec)
        }
        
        umka.addFunc(name: "testColorStruct") { slot, val in
            guard let color: Color = slot?.pointee.ptrAsType() else { return }
            print(color)
        }
        
        umka.addFunc(name: "testMultiParam") { slot, val in
            guard let test: Double = slot?[0].realVal,
                  let message = slot?[1].ptrAsString() else { return }
            print(test, message)
        }
        
        let compileSuccess = umka.compile()
        if compileSuccess == false {
            print(umka.getError())
        }
        
        let funcInt = umka.getFunc(funcName: "testCall")
        let pass = umka.call(funcInt)
        if pass == false { 
            print(umka.getError())
        }
       
        print(umka.getVersion())
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
