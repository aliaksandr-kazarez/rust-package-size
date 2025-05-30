# Rust SPM SDK

A sample Rust-based SDK compiled for iOS and packaged as a Swift Package Manager (SPM) package. This project demonstrates how to create a cross-platform Rust library that can be consumed by iOS applications to evaluate runtime footprint and performance characteristics.

## 🚀 Features

- **Cross-platform Rust library** compiled for iOS devices and simulators
- **Swift Package Manager integration** for easy iOS app integration
- **C FFI bindings** for seamless Swift interop
- **Memory-safe** string processing and data handling
- **Performance benchmarking** utilities
- **Async/await support** for CPU-intensive operations
- **Universal binary** supporting both Intel and Apple Silicon simulators

## 📦 What's Included

### Rust Library Functions
- `rust_sdk_init()` - SDK initialization
- `rust_sdk_add(a, b)` - Simple arithmetic for benchmarking
- `rust_sdk_process_string(input)` - String processing with memory allocation
- `rust_sdk_fibonacci(n)` - CPU-intensive calculation
- `rust_sdk_version()` - Version information
- `rust_sdk_free_string(ptr)` - Memory management

### Swift API
- `RustSDK.shared.initialize()` - Initialize the SDK
- `RustSDK.shared.add(_:_:)` - Add two numbers
- `RustSDK.shared.processString(_:)` - Process strings with automatic memory management
- `RustSDK.shared.fibonacci(_:)` - Calculate fibonacci numbers
- `RustSDK.shared.fibonacciAsync(_:)` - Async fibonacci calculation
- `RustSDK.shared.benchmark(iterations:)` - Performance benchmarking
- `RustSDK.shared.version()` - Get SDK version

## 🛠 Setup and Build

### Prerequisites

1. **Rust toolchain**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   source ~/.cargo/env
   ```

2. **Xcode** (for iOS targets and tools)

3. **iOS targets** (will be installed automatically by the build script):
   - `aarch64-apple-ios` (iOS devices)
   - `x86_64-apple-ios` (Intel simulator)
   - `aarch64-apple-ios-sim` (Apple Silicon simulator)

### Building the SDK

1. **Clone and navigate to the project**:
   ```bash
   git clone <your-repo-url>
   cd rust-spm-sdk
   ```

2. **Build Rust libraries for iOS**:
   ```bash
   ./build-ios.sh
   ```
   This will:
   - Install required iOS targets
   - Compile Rust code for all iOS platforms
   - Create universal binaries
   - Show library sizes for footprint analysis

3. **Create XCFramework**:
   ```bash
   ./create-xcframework.sh
   ```
   This will:
   - Package compiled libraries into an XCFramework
   - Include proper iOS and Simulator support
   - Generate required metadata

## 📱 Integration in iOS Project

### Via Swift Package Manager

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL
3. Select the version/branch
4. Add to your target

### Via Local Package

```swift
// Package.swift
dependencies: [
    .package(path: "/path/to/rust-spm-sdk")
]
```

### Usage Example

```swift
import RustSPMSDK

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the SDK
        guard RustSDK.shared.initialize() else {
            print("Failed to initialize Rust SDK")
            return
        }
        
        // Basic operations
        let sum = RustSDK.shared.add(5, 3)
        print("5 + 3 = \(sum)")
        
        // String processing
        let result = RustSDK.shared.processString("Hello, Rust!")
        print("Processed: \(result.message ?? "nil")")
        print("Length: \(result.value)")
        
        // Async operations
        Task {
            let fib = await RustSDK.shared.fibonacciAsync(20)
            print("Fibonacci(20) = \(fib)")
        }
        
        // Performance benchmarking
        let avgTime = RustSDK.shared.benchmark(iterations: 1000)
        print("Average operation time: \(avgTime) ms")
        
        // Version info
        print("SDK Version: \(RustSDK.shared.version())")
    }
}
```

## 🔬 Runtime Footprint Analysis

### Library Sizes

After building, check the sizes of the compiled libraries:

```bash
ls -lh target/ios-universal/
```

### Framework Size

Check the final XCFramework size:

```bash
du -sh RustCore.xcframework
```

### Memory Usage

The SDK includes benchmarking utilities to measure:
- Function call overhead
- Memory allocation patterns
- CPU performance characteristics

### Optimization Notes

The build is configured for maximum optimization:
- Link-time optimization (LTO) enabled
- Single codegen unit for better optimization
- Panic = abort to reduce binary size
- Release profile optimizations

## 🧪 Testing

Run the test suite to verify functionality:

```bash
swift test
```

Tests include:
- Basic functionality verification
- Memory management validation
- Performance benchmarking
- Async operation testing

## 📊 Performance Characteristics

### What This SDK Measures

1. **Static Library Size**: The actual size added to your app binary
2. **Runtime Memory**: Memory overhead during SDK operations
3. **Initialization Time**: Time to initialize Rust runtime
4. **Function Call Overhead**: Performance cost of FFI calls
5. **CPU Performance**: Rust vs Swift performance comparison

### Typical Results

Based on this simple SDK:
- **Static library size**: ~200KB - 2MB (depending on Rust features used)
- **Initialization overhead**: <1ms
- **Function call overhead**: <0.01ms per call
- **Memory overhead**: Minimal for simple operations

## 🔧 Customization

### Adding New Functions

1. **Add Rust function** in `src/lib.rs`:
   ```rust
   #[no_mangle]
   pub extern "C" fn my_new_function(input: i32) -> i32 {
       input * 2
   }
   ```

2. **Update C header** in `include/rust_spm_sdk.h`:
   ```c
   int32_t my_new_function(int32_t input);
   ```

3. **Add Swift wrapper** in `Sources/RustSPMSDK/RustSDK.swift`:
   ```swift
   public func myNewFunction(_ input: Int32) -> Int32 {
       return my_new_function(input)
   }
   ```

4. **Rebuild**:
   ```bash
   ./build-ios.sh
   ./create-xcframework.sh
   ```

### Dependency Management

Add Rust dependencies in `Cargo.toml`:
```toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.0", features = ["rt"] }
```

**Note**: Each dependency will increase the final binary size.

## 📋 Project Structure

```
rust-spm-sdk/
├── Cargo.toml                 # Rust project configuration
├── Package.swift              # SPM package manifest
├── build-ios.sh              # Build script for iOS targets
├── create-xcframework.sh     # XCFramework creation script
├── src/
│   └── lib.rs                # Main Rust library
├── include/
│   └── rust_spm_sdk.h       # C header for FFI
├── Sources/
│   ├── RustSPMSDK/
│   │   └── RustSDK.swift    # Swift wrapper API
│   └── RustSPMSDKC/
│       └── include/         # C module headers
├── Tests/
│   └── RustSPMSDKTests/
│       └── RustSDKTests.swift
└── RustCore.xcframework/     # Generated XCFramework
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## 📝 License

This project is available under the MIT License. See LICENSE file for details.

## 🔍 Troubleshooting

### Common Issues

1. **Build fails with "target not found"**:
   ```bash
   rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim
   ```

2. **XCFramework creation fails**:
   - Ensure Xcode command line tools are installed
   - Check that both device and simulator libraries exist

3. **Swift package resolution fails**:
   - Clean derived data in Xcode
   - Delete Package.resolved and retry

### Getting Help

- Check the GitHub issues for common problems
- Review the test suite for usage examples
- Consult the Rust FFI documentation for advanced use cases 