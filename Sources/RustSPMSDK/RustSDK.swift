import Foundation
import RustSPMSDKC

/// Swift wrapper for the ultra-minimal Rust SDK
public class RustSDK {
    
    /// Result type for SDK operations
    public struct SDKResult {
        public let success: Bool
        public let value: Int32
        public let message: String?
        
        internal init(from rustResult: RustResult) {
            self.success = rustResult.success
            self.value = rustResult.value
            if let messagePtr = rustResult.message {
                self.message = String(cString: messagePtr)
                // Note: No need to free memory in ultra-minimal version
                // The Rust side uses static strings only
            } else {
                self.message = nil
            }
        }
    }
    
    /// Shared instance
    public static let shared = RustSDK()
    
    private var isInitialized = false
    
    private init() {}
    
    /// Initialize the SDK
    /// - Returns: True if initialization was successful
    public func initialize() -> Bool {
        guard !isInitialized else { return true }
        
        let result = rust_sdk_init()
        if result {
            isInitialized = true
        }
        return result
    }
    
    /// Add two numbers
    /// - Parameters:
    ///   - a: First number
    ///   - b: Second number
    /// - Returns: Sum of a and b
    public func add(_ a: Int32, _ b: Int32) -> Int32 {
        return rust_sdk_add(a, b)
    }
    
    /// Process a string through the ultra-minimal Rust SDK
    /// - Parameter input: Input string to process
    /// - Returns: SDK result containing processing information
    /// - Note: Ultra-minimal version returns static messages only
    public func processString(_ input: String) -> SDKResult {
        let cString = input.withCString { cStr in
            return rust_sdk_process_string(cStr)
        }
        return SDKResult(from: cString)
    }
    
    /// Calculate fibonacci number (demonstrates CPU-intensive work)
    /// - Parameter n: The fibonacci index
    /// - Returns: The fibonacci number at index n
    public func fibonacci(_ n: Int32) -> Int64 {
        return rust_sdk_fibonacci(n)
    }
    
    /// Get the SDK version
    /// - Returns: Version string (static, no allocation)
    public func version() -> String {
        guard let versionPtr = rust_sdk_version() else {
            return "Unknown"
        }
        // No need to free - ultra-minimal version uses static strings
        return String(cString: versionPtr)
    }
}

// MARK: - Convenience Extensions

public extension RustSDK {
    
    /// Async wrapper for fibonacci calculation
    /// - Parameter n: The fibonacci index
    /// - Returns: The fibonacci number at index n
    func fibonacciAsync(_ n: Int32) async -> Int64 {
        return await withCheckedContinuation { continuation in
            Task.detached {
                let result = self.fibonacci(n)
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Benchmark the ultra-minimal SDK performance
    /// - Parameter iterations: Number of iterations to run
    /// - Returns: Average time per operation in milliseconds
    func benchmark(iterations: Int = 1000) -> Double {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<iterations {
            _ = add(Int32(i), Int32(i + 1))
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let totalTime = (endTime - startTime) * 1000 // Convert to milliseconds
        
        return totalTime / Double(iterations)
    }
    
    /// Test all ultra-minimal SDK functions
    /// - Returns: Performance summary
    func performanceTest() -> String {
        let addTime = benchmark(iterations: 10000)
        let fibTime = measureTime { _ = fibonacci(20) }
        let stringTime = measureTime { _ = processString("test") }
        
        return """
        Ultra-Minimal SDK Performance:
        - Add operations: \(String(format: "%.6f", addTime))ms avg
        - Fibonacci(20): \(String(format: "%.3f", fibTime))ms
        - String processing: \(String(format: "%.3f", stringTime))ms
        - Version: \(version())
        """
    }
    
    private func measureTime<T>(operation: () -> T) -> Double {
        let start = CFAbsoluteTimeGetCurrent()
        _ = operation()
        let end = CFAbsoluteTimeGetCurrent()
        return (end - start) * 1000 // Convert to milliseconds
    }
} 