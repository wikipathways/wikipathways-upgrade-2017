# @(#) wpgit version 1.0.0 09/17/2018
#
#  USAGE:
#    ./wpgit.sh status
#
# DESCRIPTION:
#   WikiPathways modular repository management utility.
#   This script is only for developers.
#
# Requirments:
#   - git
#
# By Alex Pico (alex.pico@gladstone.ucsf.edu)
# Adapted from cy.sh by Keiichiro Ono (kono at ucsd edu)
#
###############################################################################

# Repository names
REPOSITORIES=(. mediawiki vendor skins/Vector extensions/GPML extensions/GPMLConverter extensions/OntologyTags extensions/WikiPathways) 

# Command Name
CMDNAME="./$(basename $0)"

# Error Message
ERROR_MESSAGE="Usage: $CMDNAME [-h] [action]"

# Help
HELP='Cytoscape build helper script'

#######################################
# Handling command-line arguments     #
#######################################
while getopts 'hd:' OPT
do
  case $OPT in
    h)  FLG_H=1
        echo "$HELP: $ERROR_MESSAGE"
        exit 0
        ;;
    ?)  echo $ERROR_MESSAGE 1>&2
        exit 1 ;;
  esac
done

shift $(($OPTIND - 1))

COMMAND=$1
TARGET_DIR=$2

if [[ -z $COMMAND ]]; then
  echo "COMMAND is required. $ERROR_MESSAGE" 1>&2
  exit 1
fi

###############################################################################
# Functions
###############################################################################
#function pull {
#        echo "------------------------------------------------------------------------"
#  for REPO in "${REPOSITORIES[@]}"; do
#    pushd $REPO > /dev/null
#    echo "Downloading changes from upstream: $REPO"
#    git pull
#    popd > /dev/null
#                echo "------------------------------------------------------------------------"
#  done
#}

function status {
        echo "------------------------------------------------------------------------"
  for REPO in "${REPOSITORIES[@]}"; do
    pushd $REPO > /dev/null || { echo Could not find subproject; exit 1; }
    echo "- $REPO:"
                echo
    git status
    popd > /dev/null
                echo "------------------------------------------------------------------------"
  done

}

###############################################################################
# Main workflow
###############################################################################

# Save current directory location
START_DIR=$(pwd)

case $COMMAND in
  #pull )    pull ;;
  status )  status ;;

  * )      echo "Invalid command $COMMAND: $ERROR_MESSAGE"
          exit 1;;
esac

