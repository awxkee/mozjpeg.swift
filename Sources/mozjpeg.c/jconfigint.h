#define BUILD "20180328"
#define INLINE __attribute__((always_inline))
#define PACKAGE_NAME "mozjpeg"
#define VERSION "3.3.2"
#ifdef __SIZEOF_SIZE_T__
  #define SIZEOF_SIZE_T __SIZEOF_SIZE_T__
#else
  #error Cannot determine the size of size_t
#endif
