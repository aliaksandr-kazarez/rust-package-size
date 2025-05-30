use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};

/// Simple struct to demonstrate data handling
#[repr(C)]
pub struct RustResult {
    pub success: bool,
    pub value: i32,
    pub message: *const c_char,
}

/// Initialize the SDK - demonstrates startup costs
#[no_mangle]
pub extern "C" fn rust_sdk_init() -> bool {
    // Simulate some initialization work
    println!("Rust SDK initialized successfully");
    true
}

/// Simple calculation function
#[no_mangle]
pub extern "C" fn rust_sdk_add(a: i32, b: i32) -> i32 {
    a + b
}

/// More complex function that allocates memory and returns a result
#[no_mangle]
pub extern "C" fn rust_sdk_process_string(input: *const c_char) -> RustResult {
    if input.is_null() {
        return RustResult {
            success: false,
            value: -1,
            message: std::ptr::null(),
        };
    }

    let c_str = unsafe { CStr::from_ptr(input) };
    let input_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => {
            return RustResult {
                success: false,
                value: -1,
                message: std::ptr::null(),
            };
        }
    };

    // Do some processing
    let processed = format!("Processed: {} (length: {})", input_str, input_str.len());
    let c_string = CString::new(processed).unwrap();
    let ptr = c_string.into_raw();

    RustResult {
        success: true,
        value: input_str.len() as i32,
        message: ptr,
    }
}

/// Free memory allocated by Rust
#[no_mangle]
pub extern "C" fn rust_sdk_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

/// Demonstrate CPU-intensive work
#[no_mangle]
pub extern "C" fn rust_sdk_fibonacci(n: c_int) -> i64 {
    fn fib(n: i64) -> i64 {
        match n {
            0 => 0,
            1 => 1,
            _ => fib(n - 1) + fib(n - 2),
        }
    }
    
    fib(n as i64)
}

/// Get SDK version
#[no_mangle]
pub extern "C" fn rust_sdk_version() -> *const c_char {
    let version = CString::new("1.0.0").unwrap();
    version.into_raw()
} 