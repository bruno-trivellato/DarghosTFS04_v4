cmake_minimum_required(VERSION 2.8)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

project(tfs)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${CMAKE_MODULE_PATH})

# Initialize CXXFLAGS.
set(CMAKE_CXX_FLAGS                "-Wall -Werror")
set(CMAKE_CXX_FLAGS_DEBUG          "-O0 -g")
set(CMAKE_CXX_FLAGS_MINSIZEREL     "-Os -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE        "-O4 -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g")

include(FindCXX11)

# Find packages.
find_package(LibXml2 REQUIRED)
find_package(GMP REQUIRED)
find_package(MySQL)
find_package(LuaJIT)
find_package(ZLIB)
find_package(OpenSSL)

#if (LUAJIT_FOUND)
#    add_definitions(-D__LUAJIT__)
#else()
    find_package(Lua)
#endif()

# Darghos Definitions
add_definitions(-D__DARGHOS_CUSTOM__ -D__DARGHOS_EMERGENCY_DDOS__ -D__NO_CRYPTOPP__ -D__USE_MYSQL__ -D__WAR_SYSTEM__ -D__NO_CRYPTOPP__ -D__TFS_NEWEST_REVS_FIXIES__)

find_package(Boost 1.42.0 COMPONENTS system thread filesystem regex REQUIRED)

include(src/CMakeLists.txt)
add_executable(tfs ${tfs_SRC})

include_directories(${LIBXML2_INCLUDE_DIR} ${MYSQL_INCLUDE_DIR} ${LUA_INCLUDE_DIR} ${Boost_INCLUDE_DIRS} ${GMP_INCLUDE_DIR} ${ZLIB_INCLUDE_DIRS} ${OPENSSL_INCLUDE_DIRS})
target_link_libraries(tfs ${LIBXML2_LIBRARIES} ${MYSQL_CLIENT_LIBS} ${LUA_LIBRARIES} ${Boost_LIBRARIES} ${Boost_THREAD_LIBRARY} ${GMP_LIBRARIES} ${ZLIB_LIBRARIES} ${OPENSSL_LIBRARIES})
