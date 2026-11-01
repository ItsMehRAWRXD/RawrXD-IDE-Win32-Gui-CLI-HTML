# CMake generated Testfile for 
# Source directory: G:/~dev/rawrxd/Ship
# Build directory: G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test("All_Tests" "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship/RawrXD_TestRunner.exe")
set_tests_properties("All_Tests" PROPERTIES  LABELS "integration" TIMEOUT "60" WORKING_DIRECTORY "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship" _BACKTRACE_TRIPLES "G:/~dev/rawrxd/Ship/CMakeLists.txt;231;add_test;G:/~dev/rawrxd/Ship/CMakeLists.txt;0;")
add_test("Core_Infrastructure" "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship/RawrXD_TestRunner.exe" "--category" "CoreInfra")
set_tests_properties("Core_Infrastructure" PROPERTIES  LABELS "core" TIMEOUT "30" WORKING_DIRECTORY "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship" _BACKTRACE_TRIPLES "G:/~dev/rawrxd/Ship/CMakeLists.txt;237;add_test;G:/~dev/rawrxd/Ship/CMakeLists.txt;0;")
add_test("Hidden_Logic" "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship/RawrXD_TestRunner.exe" "--category" "HiddenLogic")
set_tests_properties("Hidden_Logic" PROPERTIES  LABELS "logic" TIMEOUT "30" WORKING_DIRECTORY "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship" _BACKTRACE_TRIPLES "G:/~dev/rawrxd/Ship/CMakeLists.txt;242;add_test;G:/~dev/rawrxd/Ship/CMakeLists.txt;0;")
add_test("AI_Systems" "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship/RawrXD_TestRunner.exe" "--category" "AIEngine")
set_tests_properties("AI_Systems" PROPERTIES  LABELS "ai" TIMEOUT "45" WORKING_DIRECTORY "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship" _BACKTRACE_TRIPLES "G:/~dev/rawrxd/Ship/CMakeLists.txt;247;add_test;G:/~dev/rawrxd/Ship/CMakeLists.txt;0;")
add_test("Tools_Integration" "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship/RawrXD_TestRunner.exe" "--category" "Tools")
set_tests_properties("Tools_Integration" PROPERTIES  LABELS "tools" TIMEOUT "30" WORKING_DIRECTORY "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship" _BACKTRACE_TRIPLES "G:/~dev/rawrxd/Ship/CMakeLists.txt;252;add_test;G:/~dev/rawrxd/Ship/CMakeLists.txt;0;")
add_test("Performance" "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship/RawrXD_TestRunner.exe" "--category" "Performance")
set_tests_properties("Performance" PROPERTIES  LABELS "perf" TIMEOUT "45" WORKING_DIRECTORY "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship" _BACKTRACE_TRIPLES "G:/~dev/rawrxd/Ship/CMakeLists.txt;257;add_test;G:/~dev/rawrxd/Ship/CMakeLists.txt;0;")
add_test("Stress_Tests" "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship/RawrXD_TestRunner.exe" "--category" "Stress")
set_tests_properties("Stress_Tests" PROPERTIES  LABELS "stress" TIMEOUT "120" WORKING_DIRECTORY "G:/~dev/rawrxd/evidence/WIN32IDE_RC_PREP_001/_rc05_cmake_scratch_ship" _BACKTRACE_TRIPLES "G:/~dev/rawrxd/Ship/CMakeLists.txt;262;add_test;G:/~dev/rawrxd/Ship/CMakeLists.txt;0;")
subdirs("tools")
