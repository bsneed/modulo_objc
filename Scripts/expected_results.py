# expected_results.py
#
# This file contains verified test results that the testing script uses to
# decide if a test passes or fails.

# Constants and filenames
MODULO_SPEC_FILENAME = 'modulo.spec'
MODULO_DEPENDENCIES_PATH = 'dependencies'

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
MODULO_ADD_GIT_REPO_URL = 'git@github.com:setdirection/SDFoundation.git'
MODULO_ADD_DEPENDENCY_SPEC_FILE_CONTENT = """{
  "name" : "modulo-tests",
  "dependencies" : [
    {
      "name" : "SDFoundation",
      "initialBranch" : "master",
      "sourcePath" : "SDFoundation",
      "moduleURL" : "git@github.com:setdirection\/SDFoundation.git"
    }
  ],
  "dependenciesPath" : "dependencies"
}"""

# Branch
MODULO_BRANCH_NAME = 'awesome'
MODULO_BRANCH_SWITCH_OUTPUT = """Switched modulo-tests to branch awesome
Switched module SDFoundation to branch awesome

"""
MODULO_BRANCH_DEPENDENCY_REPO_FOLDER = 'dependencies/SDFoundation'
MODULO_BRANCH_EXAMPLE_STATUS = """On branch awesome
nothing to commit, working directory clean
"""

# Remove
MODULO_REMOVE_DEPENDENCY_NAME = 'SDFoundation'
MODULO_REMOVE_OUTPUT = """Cleared directory 'dependencies/SDFoundation'
Submodule 'dependencies/SDFoundation' (git@github.com:setdirection/SDFoundation.git) unregistered for path 'dependencies/SDFoundation'
rm 'dependencies/SDFoundation'
SDFoundation was removed.

"""
MODULO_REMOVE_DEPENDENCY_SPEC_FILE_CONTENT = """{
  "name" : "modulo-tests",
  "dependencies" : [

  ],
  "dependenciesPath" : "dependencies"
}"""

# Remove Failure One
MODULO_REMOVE_FAILURE_ONE_GIT_REPO_URL = 'git@github.com:setdirection/SDDataMap.git'
MODULO_REMOVE_FAILURE_ONE_DEPENDENCY_NAME = 'SDFoundation'
MODULO_REMOVE_FAILURE_ONE_OUTPUT = """Unable to remove SDFoundation.

The following modules still depend on it:
    SDDataMap

"""

# Remove Failure Two
MODULO_REMOVE_FAILURE_TWO_GIT_REPO_URL = 'git@github.com:setdirection/SDFoundation.git'
MODULO_REMOVE_FAILURE_TWO_DEPENDENCY_NAME = 'SDFoundation'
MODULO_REMOVE_FAILURE_TWO_DEPENDENCY_FOLDER = MODULO_DEPENDENCIES_PATH + "/" + MODULO_REMOVE_FAILURE_TWO_DEPENDENCY_NAME + "/"
MODULO_REMOVE_FAILURE_TWO_LICENSE_FILENAME = 'LICENSE'
MODULO_REMOVE_FAILURE_TWO_OUTPUT = """Unable to proceed.  The following modules have unpushed commits, stashes, or changes:
    SDFoundation

"""

# Update
MODULO_UPDATE_START_GIT_REPO_URL = 'git@github.com:setdirection/SDUmbrella.git'
MODULO_UPDATE_DEPENDENCY_GIT_REPO_URL = 'git@github.com:setdirection/SDDataMap.git'
MODULO_UPDATE_DEPENDENCY_OUTPUT = """"""
MODULO_UPDATE_DEPENDENCY_NAME = 'SDDataMap'
MODULO_UPDATE_DEPENDENCY_CASE_ONE_SPEC_CONTENT = """{
  "name" : "SDDataMap",
  "dependencies" : [
    {
      "name" : "SDFoundation",
      "dependenciesPath" : "..\/",
      "initialBranch" : "master",
      "moduleURL" : "git@github.com:setdirection\/SDFoundation.git",
      "sourcePath" : "SDFoundation"
    }
  ],
  "dependenciesPath" : "..\/",
  "initialBranch" : "master",
  "moduleURL" : "git@github.com:setdirection\/SDDataMap.git",
  "sourcePath" : "SDDataMap"
}
"""
MODULO_UPDATE_DEPENDENCY_CASE_TWO_SPEC_CONTENT = """{
  "name" : "SDDataMap",
  "dependencies" : [
    {
      "name" : "SDFoundation",
      "dependenciesPath" : "..\/",
      "initialBranch" : "master",
      "moduleURL" : "git@github.com:setdirection\/SDFoundation.git",
      "sourcePath" : "SDFoundation"
    },
    {
      "name" : "ios-shared",
      "initialBranch" : "master",
      "sourcePath" : "Source",
      "moduleURL" : "git@github.com:setdirection\/ios-shared.git"
    }
  ],
  "dependenciesPath" : "..\/",
  "initialBranch" : "master",
  "moduleURL" : "git@github.com:setdirection\/SDDataMap.git",
  "sourcePath" : "SDDataMap"
}
"""
MODULO_DEPENDENCY_SPEC_FILENAME = MODULO_DEPENDENCIES_PATH + "/" + MODULO_UPDATE_DEPENDENCY_NAME + "/" + MODULO_SPEC_FILENAME

# List
MODULO_DEFAULT_LIST_OUTPUT_SUFFIX = ' has no dependencies.'
MODULO_LIST_REMOVE_DEPENDENCY_NAME = 'SDUmbrella'
MODULO_LIST_OUTPUT = """modulo-tests depends on the following modules:

    SDFoundation  at dependencies/SDFoundation/SDFoundation
    ios-shared    at dependencies/ios-shared/ios-shared
    SDDataMap     at dependencies/SDDataMap/SDDataMap
    SDWebService  at dependencies/SDWebService/SDWebService
"""



