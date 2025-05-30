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
    // Removed println! to reduce binary size (fmt is heavy)
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

    // Simple processing without format! macro (which adds size)
    let len = input_str.len();
    
    // Create a simpler response message
    let response = b"Processed string\0";
    let message_ptr = response.as_ptr() as *const c_char;

    RustResult {
        success: true,
        value: len as i32,
        message: message_ptr,
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

/// Demonstrate CPU-intensive work (iterative version is smaller)
#[no_mangle]
pub extern "C" fn rust_sdk_fibonacci(n: c_int) -> i64 {
    if n <= 1 {
        return n as i64;
    }
    
    let mut a: i64 = 0;
    let mut b: i64 = 1;
    
    for _ in 2..=n {
        let temp = a + b;
        a = b;
        b = temp;
    }
    
    b
}

/// Get SDK version (using static string to avoid allocations)
#[no_mangle]
pub extern "C" fn rust_sdk_version() -> *const c_char {
    b"1.0.0\0".as_ptr() as *const c_char
} 