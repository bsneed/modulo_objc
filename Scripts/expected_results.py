# expected_results.py
#
# This file contains verified test results that the testing script uses to
# decide if a test passes or fails.

# Constants and filenames
MODULO_SPEC_FILENAME = 'modulo.spec'

# Default / Help
MODULO_DEFAULT_OUTPUT = """usage: modulo [--version] [--help] 

The most commonly used modulo commands are:
   init       Initializes modulo for use.
   set        Sets a specified key/value pair in modulo.spec.
   add        Adds the specified module as a dependency.
   remove     Removes the specified module as a dependency.
   update     Updates the specified module, or all modules.
   branch     Switches all modules with write access to the specified branch.
   list       Shows all module dependencies in a flat listing.

"""

# Init
MODULO_INIT_OUTPUT_PREFIX = 'Initialized modulo spec in '
MODULO_INIT_SPEC_FILE_CONTENT = """{
  "name" : "modulo-tests",
  "dependenciesPath" : "dependencies"
}"""

# Add
MODULO_ADD_DEFAULT_OUTPUT = """usage: modulo add <git repo url> [--branch <branch>] [--verbose]
       modulo add --help
"""
MODULO_ADD_GIT_REPO_URL = 'git@github.com:setdirection/SDActivityHUD.git'
