cmake_minimum_required (VERSION 2.6)
project (mailcore2) 

# set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
# include(findpath)

set(MY_DEFINE_MACRO
"-DMAILCORE_DLL"
"-DZLIB_DLL"
"-D_WINDLL"
)
add_definitions(${MY_DEFINE_MACRO})

add_subdirectory (src)
add_subdirectory (tests)
add_subdirectory (unittest)

