# find lib directory
# find the absolute path of ${LIBNAME} from ${FINDPATH}
# and store the result to ${${LIBNAME} before the last dot parts and toupper}_LIBRARY 
macro(my_libfind LIBNAME FINDPATH)

string(FIND ${LIBNAME} "." FIND_OUT)
message("FIND_OUT:${FIND_OUT}")
if(${FIND_OUT} EQUAL -1)
    string(TOUPPER ${LIBNAME} U_LIBNAME)
    set(FIND_LIB_NAME ${U_LIBNAME}_LIBRARY)
else()
    string(SUBSTRING ${LIBNAME} 0 ${FIND_OUT} TMP)
    string(TOUPPER ${TMP} U_LIBNAME)
    set(FIND_LIB_NAME ${U_LIBNAME}_LIBRARY)
    
endif()
message("FIND_LIB_NAME:${FIND_LIB_NAME}")
find_library(${FIND_LIB_NAME} 
    NAMES ${LIBNAME}
    PATHS ${FINDPATH}
)

if(NOT ${FIND_LIB_NAME})
    message(FATAL_ERROR "ERROR: Could not find ${LIBNAME}")
else()
    message(STATUS "Found ${LIBNAME}")
endif()

endmacro(my_libfind)

# find the include directory
# if ${DIR_PREFIX} is NULL_PRE store the result into ${${filename} before of the last dot and toupper}_INCLUDE_DIR
# if ${DIR_PREFIX} is not NULL_PRE store the result into ${${DIR_PREFIX} toupper}_INCLUDE_DIR
# ${FINDPATH} the find directorys
# ${DIR_PREFIX} Relative to ${CMAKE_CURRENT_SOURCE_DIR} child directory name
macro(my_find_path filename FINDPATH DIR_PREFIX)
if(${DIR_PREFIX} STREQUAL  "NULL_PRE")
    message("NULL_PRE")

    set(FIND_NAMES ${filename})
    string(REGEX MATCH "[^\\<>\*\|\?:\/]*(\.)" TMP ${filename})
    string(REGEX MATCH "[^\.]*" PRE_FILENAME ${TMP})
    message("TMP:${TMP},PRE_FILENAME:${PRE_FILENAME}")
    string(TOUPPER ${PRE_FILENAME} DEST_NAME)
else()
    string(TOUPPER ${DIR_PREFIX} DEST_NAME)
    set(FIND_NAMES "${DIR_PREFIX}/${filename}")
endif()
message("FIND_NAMES:${FIND_NAMES}")
# string(TOUPPER ${DIR_PREFIX} DEST_NAME)

set(RESULT_FIND ${DEST_NAME}_INCLUDE_DIR)
find_path(${RESULT_FIND}
    NAMES ${FIND_NAMES}
    PATHS ${FINDPATH}
)
if(NOT ${RESULT_FIND})
    message(FATAL_ERROR "ERROR: Could not find the path of ${filename}")
else()
    message(STATUS "Found the path of ${filename}")
endif()

endmacro(my_find_path)

IF(APPLE)
  set(CMAKE_CXX__FLAGS "-std=c++11 -stdlib=libc++")
  set(CMAKE_EXE_LINKER_FLAGS "-lc++ -stdlib=libc++")
  
  set(additional_lib_searchpath
    "${CMAKE_CURRENT_SOURCE_DIR}/Externals/ctemplate-osx/lib"
    "${CMAKE_CURRENT_SOURCE_DIR}/Externals/libetpan-osx/lib"
  )
  
  execute_process(COMMAND xcrun --sdk macosx --show-sdk-path OUTPUT_VARIABLE sdkpath)
  string(STRIP "${sdkpath}" sdkpath)
  set(additional_includes
    "${CMAKE_CURRENT_SOURCE_DIR}/Externals/ctemplate-osx/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/Externals/libetpan-osx/include"
    /usr/include/tidy
    /usr/include/libxml2
    "${sdkpath}/usr/include/tidy"
    "${sdkpath}/usr/include/libxml2"
  )
  message(STATUS "${additional_includes}")
  
  set(mac_libraries iconv)
  
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(CMAKE_CXX_FLAGS "-std=gnu++0x")
  
  set(additional_includes
    /usr/include/tidy
    /usr/include/libxml2
  )
  
  set(icu_libraries icudata icui18n icuio icule iculx icutest icutu icuuc)
  set(linux_libraries ${icu_libraries} pthread uuid)
ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(additional_lib_searchpath "${CMAKE_CURRENT_SOURCE_DIR}/../Externals/lib")
    set(additional_includes
    "${CMAKE_CURRENT_SOURCE_DIR}/../Externals/include")
ENDIF()

message(STATUS "CMAKE_SYSTEM_NAME:${CMAKE_SYSTEM_NAME}")
IF(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  find_package(PkgConfig)
  pkg_check_modules (GLIB2 glib-2.0)
ENDIF()

IF(APPLE)
    find_library(FOUNDATIONFRAMEWORK NAMES Foundation)
    find_library(SECURITYFRAMEWORK NAMES Security)
    find_library(CORESERVICESFRAMEWORK NAMES CoreServices)
ENDIF()

# detect ctemplate
if(NOT APPLE)
  
  # detect icu

  find_path(ICU4C_INCLUDE_DIR
    NAMES unicode/utf8.h
    PATHS ${additional_includes}
  )
  
  my_libfind(icudt ${additional_lib_searchpath})
  my_libfind(icuin ${additional_lib_searchpath})
  my_libfind(icuio ${additional_lib_searchpath})
  my_libfind(icule ${additional_lib_searchpath})
  my_libfind(iculx ${additional_lib_searchpath})
  my_libfind(icutu ${additional_lib_searchpath})
  my_libfind(icuuc ${additional_lib_searchpath})
  
  set(ICU4C_LIBRARY
  ${ICUDT_LIBRARY}
  ${ICUIN_LIBRARY}
  ${ICUIO_LIBRARY}
  ${ICULE_LIBRARY}
  ${ICULX_LIBRARY}
  ${ICUTU_LIBRARY}
  ${ICUUC_LIBRARY}
  )
  # find_library(ICU4C_LIBRARY
    # NAMES icudt.lib icuin.lib icuio.lib icule.lib iculx.lib icutu.lib icuuc.lib
    # PATHS ${additional_lib_searchpath}
  # )
  message(STATUS "ICU4C_LIBRARY:${ICU4C_LIBRARY}")
  if(NOT ICU4C_INCLUDE_DIR OR NOT ICU4C_LIBRARY)
    message(FATAL_ERROR "ERROR: Could not find icu4c")
  else()
    message(STATUS "Found icu4c")
  endif()
  
endif()

IF(ANDROID)
  message(STATUS "Android platform")
ELSE()

my_find_path(template.h ${additional_includes} ctemplate)

my_libfind(libctemplate.lib ${additional_lib_searchpath})

if(NOT CTEMPLATE_INCLUDE_DIR OR NOT LIBCTEMPLATE_LIBRARY)
  message(FATAL_ERROR "ERROR: Could not find ctemplate")
else()
  message(STATUS "Found ctemplate")
endif()


# detect libetpan

my_find_path(libetpan.h ${additional_includes} libetpan)

my_libfind(libetpan ${additional_lib_searchpath})

if(NOT LIBETPAN_INCLUDE_DIR OR NOT LIBETPAN_LIBRARY)
  message(FATAL_ERROR "ERROR: Could not find libetpan")
else()
  message(STATUS "Found libetpan")
endif()


# detect tidy

my_find_path(tidy.h ${additional_includes} NULL_PRE)
message("TIDY_INCLUDE_DIR:${TIDY_INCLUDE_DIR}")
my_libfind(libtidy.lib ${additional_lib_searchpath})
message("LIBTIDY_LIBRARY:${LIBTIDY_LIBRARY}")

if(NOT TIDY_INCLUDE_DIR OR NOT LIBTIDY_LIBRARY)
  message(FATAL_ERROR "ERROR: Could not find tidy")
else()
  message(STATUS "Found tidy")
endif()


# detect uuid
# if(NOT WIN32)

    # find_path(UUID_INCLUDE_DIR
      # NAMES uuid/uuid.h
      # PATHS ${additional_includes}
    # )

    # if(NOT UUID_INCLUDE_DIR)
      # message(FATAL_ERROR "ERROR: Could not find uuid")
    # else()
      # message(STATUS "Found uuid")
    # endif()

# endif(WIN32)


# detect libxml2

my_find_path(xmlreader.h ${additional_includes} libxml)
my_libfind(libxml2.lib ${additional_lib_searchpath})
if(NOT LIBXML_INCLUDE_DIR OR NOT LIBXML2_LIBRARY)
  message(FATAL_ERROR "ERROR: Could not find libxml2")
else()
  message(STATUS "Found libxml2")
endif()


# detect zlib

my_find_path(zlib.h ${additional_includes} NULL_PRE)
my_libfind(zlib.lib ${additional_lib_searchpath})
if(NOT ZLIB_INCLUDE_DIR OR NOT ZLIB_LIBRARY)
  message(FATAL_ERROR "ERROR: Could not find zlib")
else()
  message(STATUS "Found zlib")
endif()

ENDIF() # Android platform

if(WIN32)
my_libfind(libeay32MD.lib ${additional_lib_searchpath})
my_libfind(libetpan.lib ${additional_lib_searchpath})
my_libfind(libsasl2.lib ${additional_lib_searchpath})
my_libfind(ssleay32MD.lib ${additional_lib_searchpath})
my_libfind(pthreadVC2.lib "${additional_lib_searchpath}/x86")
endif()

if(WIN32)
set(RELY_LIBS
    "${ICU4C_LIBRARY}"
    "${LIBCTEMPLATE_LIBRARY}"
    "${LIBETPAN_LIBRARY}"
    "${LIBTIDY_LIBRARY}"
    "${LIBXML2_LIBRARY}"
    "${ZLIB_LIBRARY}"
    "${LIBEAY32MD_LIBRARY}"
    "${LIBSASL2_LIBRARY}"
    "${SSLEAY32DB_LIBRARY}"
    "${PTHREADVC2_LIBRARY}"
    Ws2_32.lib
    Crypt32.lib
)
message(STATUS "ZLIB_LIBRARY:${ZLIB_LIBRARY}")
message(STATUS "find_file RELY_LIBS:${RELY_LIBS}")
# target_link_libraries(${PROJECT_NAME} ${OTHER_LINK_FLAGS} ${RELY_LIBS})
endif()