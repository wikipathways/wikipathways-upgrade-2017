#!/bin/bash -e

gitdir=$(git rev-parse --show-toplevel)
if [ -f "$gitdir/hooks/post-checkout" -a ! -e "$gitdir/hooks/keep-post-checkout" ]; then
	rm -f "$gitdir/hooks/post-checkout"
fi

if [ -f "$gitdir/hooks/post-rewrite" -a ! -e "$gitdir/hooks/keep-post-rewrite" ]; then
	rm -f "$gitdir/hooks/post-rewrite"
fi
