# Makefile help copied from https://github.com/ianstormtaylor/makefile-help

.PHONY: help
# Show this help prompt.
help:
	@ echo
	@ echo '  Usage:'
	@ echo ''
	@ echo '    make <target> [flags...]'
	@ echo ''
	@ echo '  Targets:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?: *[^=]*$$/{ print "   ", $$1, comment }' $(MAKEFILE_LIST) | column -t -s ':' | sort
	@ echo ''
	@ echo '  Flags:'
	@ echo ''
	@ awk '/^#/{ comment = substr($$0,3) } comment && /^[a-zA-Z][a-zA-Z0-9_-]+ ?\?=/{ print "   ", $$1, $$2, comment }' $(MAKEFILE_LIST) | column -t -s '?=' | sort
	@ echo ''

# Composer automation adapted from
# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md

# Download composer
composer: composer-setup.php
	# Downloading composer
	@EXPECTED=$(shell wget -q -O - https://composer.github.io/installer.sig);  \
	ACTUAL=$(shell php -r "echo hash_file('sha384', 'composer-setup.php');"); \
	if [ "$$EXPECTED" != "$$ACTUAL" ]; then                                   \
		>&2 echo 'ERROR: Invalid installer signature';                    \
		rm composer-setup.php;                                            \
		exit 1;                                                           \
	fi

	@php composer-setup.php --quiet
	@mv composer.phar composer

composer-setup.php:
	# Downloading composer-setup.php
	@php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"

# Remove links from mediawiki checkout
delinkifyMediaWiki:
	# Removing MediaWiki symlinks
	@test -e "mediawiki/.htaccess" && rm -f "mediawiki/.htaccess" || true
	@test -e "mediawiki/images" && rm -rf "mediawiki/images" || true
	@test -e "mediawiki/vendor" && rm -rf "mediawiki/vendor" || true
	@for i in ${topdirLinkTargets} ${subdirLinkTargets}; do \
	    test -L "mediawiki/$$i" && rm "mediawiki/$$i" || true; \
	done;
	@touch $@
	@rm -f linkifyMediaWiki

# Add links to mediawiki checkout
linkifyMediaWiki:
	# Adding MediaWiki symlinks
	@test -L "mediawiki/.htaccess" || ln -s ../htaccess "mediawiki/.htaccess"
	@for i in ${topdirLinkTargets}; do \
	    test -L "mediawiki/$$i" || ln -s ../$$i "mediawiki/$$i"; \
	done;
	@for i in ${subdirLinkTargets}; do \
	    test -L "mediawiki/$$i" || ln -s ../../$$i "mediawiki/$$i"; \
	done;
	@touch $@
	@rm -f delinkifyMediaWiki

# Linkify configuration files to /etc
setupConfLinks:
	# Linkifying the configuration files
	@test -d conf || ( >&2 echo 'ERROR: no conf directory'; exit 1 )
	@export PWD=`pwd`;                                                                  \
	cd conf &&                                                                          \
	find . -type f -a \! -name '*~' |                                                   \
	  xargs -i{} sudo sh -c "cd /etc; test ! -e {} && ln -s $$PWD/{} {}" || true
	@cd conf &&                                                                         \
	find . -type f -a \! -name '*~' |                                                   \
	  xargs -i{} sudo sh -c "cd /etc; test ! -L {} && (                                 \
	  >&2 echo \"/etc/{} is not a symlink. (touch setupLinks to bypass this)\"; false )" || true
	@touch $@

.PHONY: updateCheckout
# Pull in all updates from git
updateCheckout: ${reallyDeploy}
	# Updating checkout and submodules from git
	git pull
	git submodule foreach git reset --hard
	git submodule update --init --recursive

.PHONY: setup
# Set up the site <-------------------------- Main entry point
setup: composer setupConfLinks delinkifyMediaWiki updateCheckout linkifyMediaWiki
	# Done.

.PHONY: reallyDeploy
# Set the "really do this" deploy flag file
reallyDeploy:
	touch ${reallyDeploy}

.PHONY: distclean
# Revert to a naked checkout
distclean: delConfLinks delinkifyMediaWiki
	# Removing ignored files setup creates
	@rm -f composer setupConfLinks composer-setup.php ${reallyDeploy}

.PHONY: delConfLinks
# Remove links to configurations
delConfLinks:
	# Removing links to configuraion
	@export PWD=`pwd`;                                                                  \
	cd conf &&                                                                          \
	find . -type f -a \! -name '*~' |                                                   \
	  xargs -i{} sudo sh -c "cd /etc; test -L {} && rm -f {}" || true

# files to link to in the top dir
topdirLinkTargets := composer.lock vendor composer.local.json LocalSettings.php package-lock.json images

# Directories to link to that are in subdirectories
subdirLinkTargets := $(shell echo extensions/* skins/*)

# Secret flag file
reallyDeploy := $(trim .run "make reallyDeploy" to continue)

