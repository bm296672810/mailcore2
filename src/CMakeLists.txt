set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(public-headers)
include(core)
include(async)
include(objc)
include(LibFindMacros)
include(findpath)

IF(APPLE)
  execute_process(COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/../scripts/get-mac.sh"
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../scripts")
ENDIF()

file(GLOB_RECURSE
  source_files
  *.h
  *.m
  *.c
)

SET_SOURCE_FILES_PROPERTIES(
  ${source_files}
  PROPERTIES LANGUAGE C
)

file(COPY
  ${public_headers}

  DESTINATION
  "${CMAKE_CURRENT_BINARY_DIR}/include/MailCore"
)

include_directories("${CMAKE_CURRENT_BINARY_DIR}/include"
  ${async_includes}
  ${core_includes}
  ${objc_includes}
  ${additional_includes}
  ${GLIB2_INCLUDE_DIRS}
)

add_library(MailCore SHARED
  ${core_files}
  ${async_files}
  ${objc_files}
)

message(STATUS "RELY_LIBS:${RELY_LIBS}")
target_link_libraries(MailCore ${RELY_LIBS})