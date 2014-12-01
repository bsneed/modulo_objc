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
MODULO_ADD_GIT_REPO_URL = 'git@github.com:setdirection/SDActivityHUD.git'
MODULO_ADD_DEPENDENCY_SPEC_FILE_CONTENT = """{
  "name" : "modulo-tests",
  "dependencies" : [
    {
      "name" : "SDActivityHUD",
      "moduleURL" : "git@github.com:setdirection\/SDActivityHUD.git"
    }
  ],
  "dependenciesPath" : "dependencies"
}"""

# Remove
MODULO_REMOVE_DEPENDENCY_NAME = 'SDActivityHUD'
MODULO_REMOVE_OUTPUT = """Cleared directory 'dependencies/SDActivityHUD'
Submodule 'dependencies/SDActivityHUD' (git@github.com:setdirection/SDActivityHUD.git) unregistered for path 'dependencies/SDActivityHUD'
rm 'dependencies/SDActivityHUD'
SDActivityHUD was removed.

"""
MODULO_REMOVE_DEPENDENCY_SPEC_FILE_CONTENT = """{
  "name" : "modulo-tests",
  "dependencies" : [

  ],
  "dependenciesPath" : "dependencies"
}"""

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
MODULO_UPDATE_DEPENDENCY_CASE_TWO_SPEC_CONTENT = """"{
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
MODULO_DEPENDENCY_SPEC_FILENAME = "dependencies/" + MODULO_UPDATE_DEPENDENCY_NAME + "/" + MODULO_SPEC_FILENAME

# List
MODULO_DEFAULT_LIST_OUTPUT_SUFFIX = ' has no dependencies.'

