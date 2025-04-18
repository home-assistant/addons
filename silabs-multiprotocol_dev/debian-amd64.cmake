SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR x86_64)
SET(CMAKE_SYSTEM_VERSION 1)

# Specify the cross compiler
SET(CMAKE_C_COMPILER /usr/bin/x86_64-linux-gnu-gcc)
SET(CMAKE_CXX_COMPILER /usr/bin/x86_64-linux-gnu-g++)

# Search for programs only in the build host directories
SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers only in the target directories
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
