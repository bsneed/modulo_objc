#!/usr/bin/env python

import os
import sys
import subprocess
import tempfile
import shutil
import difflib

import expected_results

# Constants

MODULO_PATH = '/tmp/modulo'
TEST_DIR_PATH = '/tmp/modulo-tests'

# Globals

total_tests = 0
total_tests_passed = 0
total_tests_failed = 0
actual_test_dir = ''

# Utilities

def setup(temp_dir):
    global actual_test_dir
    
    # Clean up leftovers
    if os.path.exists(temp_dir):
        print "Deleting the test directory that already exists at " + temp_dir
        shutil.rmtree(temp_dir)

    # Create test directory and change to it
    print "Creating the test directory at " + temp_dir
    os.mkdir(temp_dir)
    print "Changing to the test directory at " + temp_dir
    os.chdir(temp_dir)
    
    # Read the current dir as the temp dir path can be different on filesystem
    actual_test_dir = os.getcwd()
    print "Actual test directory path: " + actual_test_dir
    
    # Initialize an empty git repo
    print "Creating empty git repo at " + actual_test_dir
    subprocess.call(['git', 'init'])

def tear_down(temp_dir):
    # Delete the temporary directory tree
    print
    print "Deleting the test directory at " + temp_dir
    shutil.rmtree(temp_dir)

def execute_modulo(args, test_command = True):
    # Get the name of the calling test function
    test_name = sys._getframe().f_back.f_code.co_name
    
    print
    if test_command:
        print "Preparing to execute test: " + test_name
    else:
        print "Setting up for test: " + test_name
    
    # Construct the command
    args.insert(0, MODULO_PATH)
    print "Command is: '" + ' '.join(args) + "'"
    
    # Execute the test on the command line
    test_output = ''
    try:
        test_output = subprocess.check_output(args)
    except subprocess.CalledProcessError as call_error:
        print '***'
        print "Error in test: " + test_name
        print "Return code: %d" % call_error.returncode
        print "Error output: " + call_error.output
        print '***'
        test_output = call_error.output

    return test_output

def print_failure(actual, expected):
        print "Actual:\n" + actual
        print "Expected:\n" + expected
        # print "Diff:\n" + ''.join(difflib.ndiff([expected], [actual]))

def compare_content(actual, expected, content_type, show_diff_on_fail = True):
    print "Comparing " + content_type
    if actual == expected:
        return True
    else:
        if show_diff_on_fail:
            print_failure(actual, expected)
        return False

def compare_file_content(filename, expected):
    try:
        file = open(filename, 'r')
    except IOError as error:
        print '***'
        print "Error in opening file: " + filename
        print "Error string: " + error.strerror
        print '***'
        return False
        
    file_content = file.read()
    file.close()
    return compare_content(file_content, expected, expected_results.MODULO_SPEC_FILENAME)

def update_test_stats(passed):
    global total_tests_passed
    global total_tests_failed
    
    if passed:
        print "PASSED"
        total_tests_passed += 1
    else:
        print "FAILED"
        total_tests_failed += 1

def print_stats():
    print
    print "Number of tests = %d" % total_tests
    print "Tests passed    = %d" % total_tests_passed
    print "Tests failed    = %d" % total_tests_failed

# Utilities

def update_dependency_via_clone():
    global actual_test_dir
    
    # Clone the dependency git repo
    print "Cloning " + expected_results.MODULO_UPDATE_DEPENDENCY_GIT_REPO_URL
    subprocess.call(['git', 'clone', expected_results.MODULO_UPDATE_DEPENDENCY_GIT_REPO_URL])
    
    # Read in the current spec file for this dependency to compare with fresh clone
    current_dependency_spec_file = open(expected_results.MODULO_DEPENDENCY_SPEC_FILENAME, 'r')
    current_dependency_spec_file_content = current_dependency_spec_file.read()
    current_dependency_spec_file.close()
    
    fresh_clone_dir_path = expected_results.MODULO_UPDATE_DEPENDENCY_NAME + '/'
    fresh_clone_spec_file_path =  fresh_clone_dir_path + expected_results.MODULO_SPEC_FILENAME
    fresh_clone_spec_file = open(fresh_clone_spec_file_path, 'r')
    fresh_clone_spec_file_content = fresh_clone_spec_file.read()
    fresh_clone_spec_file.close()
    
    # Sanity checks
    passed = compare_content(fresh_clone_spec_file_content, current_dependency_spec_file_content, 'initial state')
    if passed:
        case_one = compare_content(current_dependency_spec_file_content, expected_results.MODULO_UPDATE_DEPENDENCY_CASE_ONE_SPEC_CONTENT, 'case one', False)
        case_two = compare_content(current_dependency_spec_file_content, expected_results.MODULO_UPDATE_DEPENDENCY_CASE_TWO_SPEC_CONTENT, 'case two', False)
        
        passed = case_one != case_two
        
        if passed:
            updated_spec = ''
            if case_one:
                print "Updating for case one"
                updated_spec = expected_results.MODULO_UPDATE_DEPENDENCY_CASE_TWO_SPEC_CONTENT
            
            if case_two:
                print "Updating for case two"
                updated_spec = expected_results.MODULO_UPDATE_DEPENDENCY_CASE_ONE_SPEC_CONTENT
            
            # Update the clone repo with new spec
            os.chdir(fresh_clone_dir_path)
            
            print 'Updating dependency spec file in fresh clone'
            spec_file = open(expected_results.MODULO_SPEC_FILENAME, 'w')
            spec_file.write(updated_spec)
            spec_file.close()
            
            print "Executing git commands to modify dependency in " + os.getcwd()
            subprocess.call(['git', 'add', '.'])
            subprocess.call(['git', 'commit', '-m', 'Updated modulo.spec from test.'])
            subprocess.call(['git', 'push', 'origin', 'master'])
            
            # Return to working dir and delete the fresh clone
            os.chdir(actual_test_dir)
            print "Deleting tree at " + fresh_clone_dir_path
            shutil.rmtree(fresh_clone_dir_path)
            
            return (True, updated_spec)
    return (False, '')

# Tests

def test_default():
    output = execute_modulo([])
    passed = compare_content(output, expected_results.MODULO_DEFAULT_OUTPUT, 'output')
    update_test_stats(passed)

def test_init():
    global actual_test_dir
    
    output = execute_modulo(['init'])
    expected = expected_results.MODULO_INIT_OUTPUT_PREFIX + actual_test_dir + '\n'
    passed = compare_content(output, expected, 'output')
    if passed:
        passed = os.path.exists(expected_results.MODULO_SPEC_FILENAME)
        if passed:
            passed = compare_file_content(expected_results.MODULO_SPEC_FILENAME, expected_results.MODULO_INIT_SPEC_FILE_CONTENT)
    update_test_stats(passed)

def test_list_default():
    global actual_test_dir
    
    output = execute_modulo(['list'])
    expected = os.path.basename(actual_test_dir) + expected_results.MODULO_DEFAULT_LIST_OUTPUT_SUFFIX + '\n'
    passed = compare_content(output, expected, 'output')
    update_test_stats(passed)

def test_add_dependency():
    output = execute_modulo(['add', expected_results.MODULO_ADD_GIT_REPO_URL])
    passed = os.path.exists(expected_results.MODULO_SPEC_FILENAME) and os.path.isdir(expected_results.MODULO_DEPENDENCIES_PATH)
    if passed:
        passed = compare_file_content(expected_results.MODULO_SPEC_FILENAME, expected_results.MODULO_ADD_DEPENDENCY_SPEC_FILE_CONTENT)
    update_test_stats(passed)

def test_branch():
    global actual_test_dir
    
    output = execute_modulo(['branch', 'awesome'])
    passed = compare_content(output, expected_results.MODULO_BRANCH_SWITCH_OUTPUT, 'output')
    if passed:
        os.chdir(expected_results.MODULO_BRANCH_DEPENDENCY_REPO_FOLDER)
        output = subprocess.check_output(['git', 'status'])
        os.chdir(actual_test_dir)
        passed = compare_content(output, expected_results.MODULO_BRANCH_EXAMPLE_STATUS, 'output')
    update_test_stats(passed)

def test_remove_dependency():
    output = execute_modulo(['remove', expected_results.MODULO_REMOVE_DEPENDENCY_NAME])
    passed = compare_content(output, expected_results.MODULO_REMOVE_OUTPUT, 'output')
    if passed:
        passed = compare_file_content(expected_results.MODULO_SPEC_FILENAME, expected_results.MODULO_REMOVE_DEPENDENCY_SPEC_FILE_CONTENT)
    update_test_stats(passed)

def test_update_dependency():
    output = execute_modulo(['add', expected_results.MODULO_UPDATE_START_GIT_REPO_URL], False)
    # Update one of the dependencies via a separate clone
    (clone_passed, spec_after_update) = update_dependency_via_clone()
    passed = clone_passed
    if passed:
        output = execute_modulo(['update'])
        passed = compare_file_content(expected_results.MODULO_DEPENDENCY_SPEC_FILENAME, spec_after_update)
    else:
        print "*** Error in the clone"
    update_test_stats(passed)

def test_list():
    output = execute_modulo(['remove', expected_results.MODULO_LIST_REMOVE_DEPENDENCY_NAME], False)
    output = execute_modulo(['list'])
    passed = compare_content(output, expected_results.MODULO_LIST_OUTPUT, 'output')
    update_test_stats(passed)

# Main
if __name__ == "__main__":
    if not os.path.exists(MODULO_PATH):
        print "modulo doesn't exist at " + MODULO_PATH + " as expected. Aborting."
        exit(0)

    start_dir = os.getcwd()
    setup(TEST_DIR_PATH)
    
    # Set up tests. The ordering is important to the expected results.
    all_tests = (test_default, test_init, test_list_default, test_add_dependency, test_branch, test_remove_dependency, test_update_dependency, test_list)
    total_tests = len(all_tests)
    
    # Execute tests
    print
    print "Starting tests for " + MODULO_PATH + " at " + actual_test_dir
    
    for a_test in all_tests:
        a_test()
    
    # Clean up
    os.chdir(start_dir)
    tear_down(TEST_DIR_PATH)
    
    # Print results
    print_stats()

