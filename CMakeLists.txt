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

if(WIN32)
set(RELY_LIBS
    "-l${ICU4C_LIBRARY}"
    "-l${CTEMPLATE_LIBRARY}"
    "-l${LIBETPAN_LIBRARY}"
    "-l${TIDY_LIBRARY}"
    "-l${LIBXML_LIBRARY}"
    "-l${ZLIB_LIBRARY}"
)
# target_link_libraries(${PROJECT_NAME} ${OTHER_LINK_FLAGS} ${RELY_LIBS})
endif()

add_subdirectory (src)
add_subdirectory (tests)
add_subdirectory (unittest)

