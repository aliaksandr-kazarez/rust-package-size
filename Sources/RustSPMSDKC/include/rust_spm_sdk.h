#ifndef RUST_SPM_SDK_H
#define RUST_SPM_SDK_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Result structure for complex operations
typedef struct {
    bool success;
    int32_t value;
    const char* message;
} RustResult;

/// Initialize the SDK
bool rust_sdk_init(void);

/// Simple addition function
int32_t rust_sdk_add(int32_t a, int32_t b);

/// Process a string and return result
RustResult rust_sdk_process_string(const char* input);

/// Free memory allocated by Rust (no-op in ultra-minimal version)
void rust_sdk_free_string(char* ptr);

/// Calculate fibonacci number (CPU intensive)
int64_t rust_sdk_fibonacci(int32_t n);

/// Get SDK version
const char* rust_sdk_version(void);

#ifdef __cplusplus
}
#endif

#endif // RUST_SPM_SDK_H 