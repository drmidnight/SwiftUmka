
import CUmka
import Foundation

/*
 TODO: Add remaining api
 UMKA_API void umkaSetHook           (void *umka, UmkaHookEvent event, UmkaHookFunc hook);
 UMKA_API void *umkaAllocData        (void *umka, int size, UmkaExternFunc onFree);
 UMKA_API void umkaIncRef            (void *umka, void *ptr);
 UMKA_API void umkaDecRef            (void *umka, void *ptr);
 UMKA_API void *umkaGetMapItem       (void *umka, UmkaMap *map, UmkaStackSlot key);
 UMKA_API int  umkaGetDynArrayLen    (const void *array);
 */

public struct Umka {
    let _umka = CUmka.umkaAlloc()
    
    public init(fileName: String? = nil, sourceString: String? = nil, stackSize: Int32, locale: String? = nil, argc: Int32 = 0, fileSystemEnabled: Bool = false, implLibsEnabled: Bool = false, warningCallback: UmkaWarningCallback? = nil) {
        let umkaOk = CUmka.umkaInit(_umka, fileName, sourceString, stackSize, locale, argc, nil, fileSystemEnabled, implLibsEnabled, warningCallback)
        if umkaOk {
            print("Umka Loaded")
        } else {
            fatalError("Unable to load Umka")
        }
    }
    
    public func compile() -> Bool {
        return CUmka.umkaCompile(_umka)
    }
    
    public func run() -> Bool {
        return CUmka.umkaRun(_umka)
    }
    
    public func call(_ entryOffset: Int32, numParamSlots: Int32 = 0, params: UnsafeMutablePointer<UmkaStackSlot>? = nil, result: UnsafeMutablePointer<UmkaStackSlot>? = nil) -> Bool {
        return CUmka.umkaCall(_umka, entryOffset, numParamSlots, params, result)
    }
    
    public func free() {
        CUmka.free(_umka)
    }
    
    public func getError() -> String {
        var error: UmkaError = UmkaError()
        CUmka.umkaGetError(_umka, &error)
        let errorMsg = withUnsafePointer(to: error.msg) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        
        let fileName = withUnsafePointer(to: error.fileName) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        
        let functionName = withUnsafePointer(to: error.fnName) {
            $0.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: $0)) {
                String(cString: $0)
            }
        }
        
        if errorMsg != "" {
            let line = error.line
            let pos = error.pos
            
            return "\(fileName) \(functionName) [\(line):\(pos)] \(errorMsg)"
        } else {
            return ""
        }
        
    }
    
    public func asm(buf: String, size: Int32) {
        var buffer = buf.cString(using: .utf8)
        CUmka.umkaAsm(_umka, &buffer, size)
    }
    
    public func addModule(fileName: String? = nil,sourceString: String? = nil) -> Bool {
        return CUmka.umkaAddModule(self._umka, fileName, sourceString)
    }
    
    @discardableResult
    public func addFunc(name: String, entry: UmkaExternFunc) -> Bool {
        return CUmka.umkaAddFunc(self._umka, name, entry)
    }

    public func getFunc(moduleName: String? = nil, funcName: String) -> Int32 {
        return CUmka.umkaGetFunc(_umka, moduleName, funcName)
    }
    
    public func getCallStack(depth: Int32, nameSize: Int32, offset: inout Int32, fileName: inout String, fnName: inout String, line: inout Int32) -> Bool {
        return CUmka.umkaGetCallStack(_umka, depth, nameSize, &offset, &fileName, &fnName, &line)
    }
    
    public func getVersion() -> String {
        return String(cString: CUmka.umkaGetVersion())
    }
    
}


extension UmkaStackSlot {
    
    /// Returns the ptrVal as a string (unsafe-ish)
    public func ptrAsString() -> String? {
        let ptr = self.ptrVal.assumingMemoryBound(to: UInt8.self)
        defer { ptr.deallocate() }
        let length = MemoryLayout.size(ofValue: ptr)
        let bytes = UnsafeBufferPointer(start: ptr, count: length)
        let message = String(bytes: bytes, encoding: .utf8)
       
        return message
    }
    
    /// Casts the ptrVal to expected type (unsafe-ish)
    public func ptrAsType<T>() -> T? {
        guard var ptr = self.ptrVal else { return nil }
        
        let result: T? = withUnsafeBytes(of: &ptr) { bytePtr in
            let ptrCast = bytePtr.load(as: T.self)
            return ptrCast
        }
        
        return result
    }
    
}
