cmake_minimum_required(VERSION 2.8)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(tfs)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

include(cotire)

# Initialize CXXFLAGS.
set(CMAKE_CXX_FLAGS                "-Wall -Wno-strict-aliasing")
set(CMAKE_CXX_FLAGS_DEBUG          "-O0 -g")
set(CMAKE_CXX_FLAGS_MINSIZEREL     "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE        "-Ofast -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g")

include(FindCXX11)

# Find packages.
find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBXML2 REQUIRED libxml-2.0)
find_package(GMP REQUIRED)
find_package(ZLIB)
find_package(OpenSSL)

# Use pkg-config for Lua
pkg_check_modules(LUA REQUIRED lua5.1)

# Use mysql_config for MySQL
execute_process(COMMAND mysql_config --libs OUTPUT_VARIABLE MYSQL_LIBS OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND mysql_config --cflags OUTPUT_VARIABLE MYSQL_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND mysql_config --include OUTPUT_VARIABLE MYSQL_INCLUDE_DIRS OUTPUT_STRIP_TRAILING_WHITESPACE)

# Darghos Definitions
add_definitions(-D__DARGHOS_CUSTOM__ -D__DARGHOS_EMERGENCY_DDOS__ -D__NO_CRYPTOPP__ -D__USE_MYSQL__ -D__WAR_SYSTEM__ -D__NO_CRYPTOPP__ -D__TFS_NEWEST_REVS_FIXIES__)
#add_definitions(-D__DARGHOS_CUSTOM__ -D__DARGHOS_EMERGENCY_DDOS__ -D__NO_CRYPTOPP__ -D__USE_MYSQL__ -D__WAR_SYSTEM__ -D__TFS_NEWEST_REVS_FIXIES__ -D__DARGHOS_PVP_SYSTEM__ -D__DARGHOS_CUSTOM_SPELLS__ -D__LOGIN_SERVER__)

set(Boost_USE_STATIC_LIBS   OFF)
set(Boost_USE_MULTITHREADED ON)

find_package(Boost 1.42.0 COMPONENTS thread system filesystem regex REQUIRED)

include(src/CMakeLists.txt)
add_executable(tfs ${tfs_SRC})

include_directories(${LIBXML2_INCLUDE_DIRS} ${MYSQL_INCLUDE_DIRS} ${LUA_INCLUDE_DIRS} ${Boost_INCLUDE_DIRS} ${GMP_INCLUDE_DIR} ${ZLIB_INCLUDE_DIRS} ${OPENSSL_INCLUDE_DIRS})

find_package(Threads REQUIRED)

if(WIN32 AND __COMPILER_GNU)
    # mingw-gcc fails to link boost::thread
    add_definitions(-DBOOST_THREAD_USE_LIB)
endif(WIN32 AND __COMPILER_GNU)

target_link_libraries(tfs ${LIBXML2_LDFLAGS} ${MYSQL_LIBS} ${LUA_LDFLAGS} ${CMAKE_THREAD_LIBS_INIT} ${Boost_LIBRARIES} ${GMP_LIBRARIES} ${ZLIB_LIBRARIES} ${OPENSSL_LIBRARIES})
