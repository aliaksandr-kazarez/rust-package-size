#![no_std]

// C types without libc dependency
type CChar = i8;
type CInt = i32;

/// Simple struct to demonstrate data handling
#[repr(C)]
pub struct RustResult {
    pub success: bool,
    pub value: i32,
    pub message: *const CChar,
}

/// Ultra-minimal panic handler using stable features
#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}

/// Initialize the SDK - minimal implementation
#[no_mangle]
pub extern "C" fn rust_sdk_init() -> bool {
    true
}

/// Simple calculation function
#[no_mangle]
pub extern "C" fn rust_sdk_add(a: i32, b: i32) -> i32 {
    a + b
}

/// Minimal string length calculation without std
unsafe fn strlen(s: *const CChar) -> usize {
    let mut len = 0;
    while *s.add(len) != 0 {
        len += 1;
    }
    len
}

/// More complex function with minimal string processing
#[no_mangle]
pub extern "C" fn rust_sdk_process_string(input: *const CChar) -> RustResult {
    if input.is_null() {
        return RustResult {
            success: false,
            value: -1,
            message: core::ptr::null(),
        };
    }

    // Calculate string length manually
    let len = unsafe { strlen(input) };
    
    // Static response message (no allocation)
    static RESPONSE: &[u8] = b"Processed\0";
    let message_ptr = RESPONSE.as_ptr() as *const CChar;

    RustResult {
        success: true,
        value: len as i32,
        message: message_ptr,
    }
}

/// Free memory - no-op since we don't allocate
#[no_mangle]
pub extern "C" fn rust_sdk_free_string(_ptr: *mut CChar) {
    // No-op: we don't allocate memory anymore
}

/// Iterative fibonacci - minimal implementation
#[no_mangle]
pub extern "C" fn rust_sdk_fibonacci(n: CInt) -> i64 {
    if n <= 1 {
        return n as i64;
    }
    
    let mut a: i64 = 0;
    let mut b: i64 = 1;
    
    let mut i = 2;
    while i <= n {
        let temp = a + b;
        a = b;
        b = temp;
        i += 1;
    }
    
    b
}

/// Get SDK version - static string, no allocation
#[no_mangle]
pub extern "C" fn rust_sdk_version() -> *const CChar {
    static VERSION: &[u8] = b"1.0.0\0";
    VERSION.as_ptr() as *const CChar
} 