# TROUBLESHOOTING

## warning: implicit conversion loses integer precision: 'const size_t' (aka 'const unsigned long') to 'int' [-Wshorten-64-to-32]

In Xcode `Implicit conversion loses integer precision` warnings, by setting `Implicit Conversion to 32 Bit Type` to `No` in the project's build settings.


## faiss-mobile/faiss/faiss/utils/simdlib_emulated.h:127:20: warning: 'sprintf' is deprecated: This function is provided for compatibility reasons only.  Due to security concerns inherent in the design of sprintf(3), it is highly recommended that you use snprintf(3) instead. [-Wdeprecated-declarations]

`ptr += sprintf(ptr, fmt, u16[i]);`

Solution is to use `-Wno-deprecated-declarations` flag.
