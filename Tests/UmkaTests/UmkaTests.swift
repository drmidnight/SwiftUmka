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
        
        let source = """
        import "std.um"


        type (
            Vector2 = struct {x, y: real32}
            Color   = struct {r, g, b, a: uint8}
        )

        fn printFunc(msg: str)
        fn testMultiParam(msg: str, val:real32)
        fn testColorStruct(color: Color)
        fn testVec2Struct(v: Vector2)

        fn main() {
            printFunc("Printing")
            testMultiParam("testMulti", 32)
            testColorStruct(Color{ 90,  90,  90, 255})
            testVec2Struct(Vector2{ 90,  90 })
            std.println("Test standard lib")
        }

        """
        
        let umka = Umka(sourceString: source, stackSize: 1024*1024, fileSystemEnabled: true, implLibsEnabled: true)
        defer { umka.free() }
        
        umka.addFunc(name: "printFunc") { slot, val in
            guard let message: String  = slot?.pointee.ptrAsString() else { return }
            print(message)
        }
        
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
        
        let funcInt = umka.getFunc(funcName: "main")
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
