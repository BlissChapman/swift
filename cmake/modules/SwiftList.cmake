include(SwiftUtils)

function(list_subtract lhs rhs result_var_name)
  set(result)
  foreach(item IN LISTS lhs)
    list(FIND rhs "${item}" index)
    if(${index} EQUAL -1)
      list(APPEND result "${item}")
    endif()
  endforeach()
  set("${result_var_name}" "${result}" PARENT_SCOPE)
endfunction()

function(list_intersect lhs rhs result_var_name)
  set(result)
  foreach(item IN LISTS lhs)
    list(FIND rhs "${item}" index)
    if(NOT ${index} EQUAL -1)
      list(APPEND result "${item}")
    endif()
  endforeach()
  set("${result_var_name}" "${result}" PARENT_SCOPE)
endfunction()

function(list_union lhs rhs result_var_name)
  set(result)
  foreach(item IN LISTS lhs rhs)
    list(FIND result "${item}" index)
    if(${index} EQUAL -1)
      list(APPEND result "${item}")
    endif()
  endforeach()
  set("${result_var_name}" "${result}" PARENT_SCOPE)
endfunction()

function(_list_add_string_suffix input_list suffix result_var_name)
  set(result)
  foreach(element ${input_list})
    list(APPEND result "${element}${suffix}")
  endforeach()
  set("${result_var_name}" "${result}" PARENT_SCOPE)
endfunction()

function(_list_escape_for_shell input_list result_var_name)
  set(result "")
  foreach(element ${input_list})
    string(REPLACE " " "\\ " element "${element}")
    set(result "${result}${element} ")
  endforeach()
  set("${result_var_name}" "${result}" PARENT_SCOPE)
endfunction()

function(list_replace input_list old new)
  set(replaced_list)
  foreach(item ${${input_list}})
    if(${item} STREQUAL ${old})
      list(APPEND replaced_list ${new})
    else()
      list(APPEND replaced_list ${item})
    endif()
  endforeach()
  set("${input_list}" "${replaced_list}" PARENT_SCOPE)
endfunction()

function(list_has_duplicates l outvar)
  set(LCOPY "${l}")
  list(REMOVE_DUPLICATES "${LCOPY}")
  list(LENGTH l L_LENGTH)
  list(LENGTH LCOPY LCOPY_LENGTH)

  if (${L_LENGTH} EQUAL ${LCOPY_LENGTH})
    set(${outvar} FALSE PARENT_SCOPE)
  else()
    set(${outvar} TRUE PARENT_SCOPE)
  endif()
endfunction()

function(precondition_list_is_set l)
  list_has_duplicates(${l} HAS_DUPLICATES)
  precondition(HAS_DUPLICATES NEGATE
    MESSAGE "List ${l} has duplicate elements and thus is not a set. Contents: ${${l}}")
endfunction()

function(precondition_list_is_disjoint)
  set(TOP)
  foreach(l ${ARGN})
    # First do a precondition check that TOP and l are disjoint.
    list_intersect(TOP l TOP_L_INTERSECTION)
    list(LENGTH TOP_L_INTERSECTION TOP_L_INTERSECTION_LENGTH)
    precondition_binary_op(EQUAL ${TOP_L_INTERSECTION_LENGTH} 0)
    # Then union l into TOP so that we can check the next list.
    list_union(TOP l TOP)
  endforeach()
endfunction()
