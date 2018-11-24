#!/bin/bash -e

# in sub-shell so we don't have to switch dirs when we're done.
(
    export PWD=`pwd`;
    cd conf &&
    find . -type f -a \! -name '*~' |
	xargs -i{} sudo sh -c "cd /etc; rm -f {}; ln -s $PWD/{} {}" ||
	echo No conf directory!
)
