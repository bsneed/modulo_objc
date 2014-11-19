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
    # Clean up leftovers
    if os.path.exists(temp_dir):
        print "Deleting the test directory that already exists at " + temp_dir
        shutil.rmtree(temp_dir)

    # Create test directory and change to it
    print "Creating the test directory at " + temp_dir
    os.mkdir(temp_dir)
    print "Changing to the test directory at " + temp_dir
    os.chdir(temp_dir)

def tear_down(temp_dir):
    # Delete the temporary directory tree
    print
    print "Deleting the test directory at " + temp_dir
    shutil.rmtree(temp_dir)

def execute_test(test_args):
    print
    print "Executing test: " + sys._getframe().f_back.f_code.co_name
    test_args.insert(0, MODULO_PATH)
    # command = MODULO_PATH + ' ' + test_args
    print "Command is: '" + ' '.join(test_args) + "'"
    test_output = ''
    try:
        test_output = subprocess.check_output(test_args)
    except subprocess.CalledProcessError as call_error:
        print "****Error in test " + test_name + ". Return code: " + call_error.returncode
        print "    Return code: " + call_error.returncode
        print "    Output: " + call_error.output

    return test_output

def print_failure(actual, expected):
        print "Actual:\n" + actual
        print "Expected:\n" + expected
        # print "Diff:\n" + ''.join(difflib.ndiff([expected], [actual]))

def compare_content(actual, expected, content_type):
    print "Comparing " + content_type
    if actual == expected:
        return True
    else:
        print_failure(actual, expected)
        return False

def compare_file_content(filename, expected):
    file = open(filename, 'r')
    file_content = ''.join(file.readlines())
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

# Tests

def test_default():
    output = execute_test([])
    passed = compare_content(output, expected_results.MODULO_DEFAULT_OUTPUT, 'output')
    update_test_stats(passed)

def test_init():
    global actual_test_dir
    output = execute_test(['init'])
    expected = expected_results.MODULO_INIT_OUTPUT_PREFIX + actual_test_dir + '\n'
    passed = compare_content(output, expected, 'output')
    if passed:
        passed = os.path.exists(expected_results.MODULO_SPEC_FILENAME)
        if passed:
            passed = compare_file_content(expected_results.MODULO_SPEC_FILENAME, expected_results.MODULO_INIT_SPEC_FILE_CONTENT)
    update_test_stats(passed)

# Main
if __name__ == "__main__":
    if not os.path.exists(MODULO_PATH):
        print "modulo doesn't exist at " + MODULO_PATH + " as expected. Aborting."
        exit(0)

    start_dir = os.getcwd()
    setup(TEST_DIR_PATH)
    
    # Read the current dir as the temp dir path can be different on filesystem
    actual_test_dir = os.getcwd()
    
    # Set up tests
    all_tests = (test_default, test_init)
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

