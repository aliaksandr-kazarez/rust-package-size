import XCTest
@testable import RustSPMSDK

final class RustSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize the SDK before each test
        XCTAssertTrue(RustSDK.shared.initialize())
    }
    
    func testSDKInitialization() {
        // Test that SDK can be initialized
        let result = RustSDK.shared.initialize()
        XCTAssertTrue(result)
    }
    
    func testAddition() {
        // Test basic arithmetic function
        let result = RustSDK.shared.add(5, 3)
        XCTAssertEqual(result, 8)
        
        // Test with negative numbers
        let negativeResult = RustSDK.shared.add(-5, 3)
        XCTAssertEqual(negativeResult, -2)
    }
    
    func testStringProcessing() {
        // Test string processing function
        let input = "Hello, Rust!"
        let result = RustSDK.shared.processString(input)
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.value, Int32(input.count))
        XCTAssertNotNil(result.message)
        XCTAssertTrue(result.message!.contains("Processed: Hello, Rust!"))
        XCTAssertTrue(result.message!.contains("length: 13"))
    }
    
    func testEmptyStringProcessing() {
        // Test with empty string
        let result = RustSDK.shared.processString("")
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.value, 0)
        XCTAssertNotNil(result.message)
        XCTAssertTrue(result.message!.contains("length: 0"))
    }
    
    func testFibonacci() {
        // Test fibonacci calculation
        XCTAssertEqual(RustSDK.shared.fibonacci(0), 0)
        XCTAssertEqual(RustSDK.shared.fibonacci(1), 1)
        XCTAssertEqual(RustSDK.shared.fibonacci(5), 5)
        XCTAssertEqual(RustSDK.shared.fibonacci(10), 55)
    }
    
    func testVersion() {
        // Test version string
        let version = RustSDK.shared.version()
        XCTAssertEqual(version, "1.0.0")
    }
    
    func testBenchmark() {
        // Test benchmark functionality
        let avgTime = RustSDK.shared.benchmark(iterations: 100)
        XCTAssertGreaterThan(avgTime, 0)
        print("Average time per add operation: \(avgTime) ms")
    }
    
    func testAsyncFibonacci() async {
        // Test async fibonacci calculation
        let result = await RustSDK.shared.fibonacciAsync(8)
        XCTAssertEqual(result, 21)
    }
    
    func testPerformance() {
        // Performance test for add function
        measure {
            for i in 0..<1000 {
                _ = RustSDK.shared.add(Int32(i), Int32(i + 1))
            }
        }
    }
} 