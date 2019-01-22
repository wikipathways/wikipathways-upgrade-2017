# Prerequisite

 - apache2
 - make
 - mysql

On Ubuntu 18.04

apt-get install mysql-server
apt-get install make
apt-get install apache2

# Installation

1. Run setup-site.sh to set up the site after doing an initial checkout
2. Modify [MediaWiki:Common.js](https://wikipathways.org/index.php/MediaWiki:Common.js) so that it executes after things are loaded.
	- Surround everything with
	```javascript
		mw.loader.using( ['mediawiki.user'] ).done( function() {
		… // everything in MediaWiki:Common.js right now
		} );
	```
	- Change ```addOnloadHook()``` to ```$(document.ready(…))```.  See [Legacy removals](https://www.mediawiki.org/wiki/ResourceLoader/Migration_guide_(users)#Legacy_removals) for more information.  For example, change
	```javascript
		addOnloadHook(CustomizeModificationsOfSidebar);
	```
	
	to

	```javascript
		$(document.ready( function() { CustomizeModificationsOfSidebar(); } );
	```
# Javascript changes
- Instances of ```wikipathways.username``` should be replaced with a "proper" mwjs fetching of the user name.  You can use ```mw.config.get("wgUserName")```.
# Pathway storage and presentation
*tbd*
# Code Layout
## Git submodules
*tbd*

For simple git actions across all submodules, the ```wpgit.sh``` provides some handy commands, for example:
```
    ./wpgit.sh status  #perform git status on all repos
```

## Clean repos
*tbd*
# Solving problems, fixing bugs
Since I like to have a concrete target when I write, I'll document how I'm solving a problem that Egon found.  This will demonstrate how I examine the code and give some idea of how to use the git submodules.
## [Clicking “et al.” does not have any effect](https://github.com/wikipathways/wikipathways.org/issues/65)
1) Once [the page](https://vm1.wikipathways.org/Pathway:WP528) in the bug loads I confirm that clicking any author's name brings up their user page.  Clicking “et al.” does not appear to work.
2) Checking the Javascript console, I see the following message: ```ReferenceError: AuthorInfo is not defined```
3) Mousing over “et al.” I see: ```javascript:AuthorInfo.showAllAuthors()```
4) Using ```git submodule foreach``` to invoke ```git grep```, we can search all the repositories in under a second.  When we do, we find it:
	```sh
	$ git submodule foreach 'git grep showAllAuthors || :'
	Entering 'extensions/BiblioPlus'
	Entering 'extensions/Cite'
	Entering 'extensions/CodeEditor'
	Entering 'extensions/ConfirmEdit'
	Entering 'extensions/ContributionScores'
	Entering 'extensions/EmbedVideo'
	Entering 'extensions/GPML'
	modules/AuthorInfo.js:			html += ", <a href='javascript:AuthorInfo.showAllAuthors()' " +
	modules/AuthorInfo.js:AuthorInfo.showAllAuthors = function() {
	Entering 'extensions/GPMLConverter'
	```
5) From here, we can see that the GPML extension should be loading ```modules/AuthorInfo.js``` in order to provide the function.  It appears that this is missing.

	Also, since we know it is in the [GPML extension's repository](https://github.com/wikipathways/mediawiki-extensions-WikiPathways-GPML), we can narrow our work to that repository. Using ```git grep``` again, we check to make sure that the file is in the list of files available to [ResourceLoader](https://www.mediawiki.org/wiki/ResourceLoader):
	```sh
	$ cd extensions/GPML
	$ git grep -n AuthorInfo.js
	extension.json:64:				"AuthorInfo.js"
	```
6) To find the module for the AuthorInfo.js file, we examine the file ```extension.json``` in the GPML extension. From here, we can see that if ResourceLoader is told to load the [wpi.AuthorInfo](https://github.com/wikipathways/mediawiki-extensions-WikiPathways-GPML/blob/ee4558fe5682d0e342f7366063fcaf60ec3788b9/extension.json#L62) module, then it will send the [AuthorInfo.js](https://github.com/wikipathways/mediawiki-extensions-WikiPathways-GPML/blob/master/modules/AuthorInfo.js) file:
	```sh :results output
	$ jq -c '.ResourceModules | to_entries[] | \
		select( .value.scripts | index("AuthorInfo.js") )| \
		.key' extensions/GPML/extension.json
	"wpi.AuthorInfo"
	```
7) Using git grep only on the ```GPML``` extension, we find that the ```wpi.AuthorInfo``` module is called just before we return from [```WikiPathways\GPML\AuthorInfoList::render()```](https://github.com/wikipathways/mediawiki-extensions-WikiPathways-GPML/blob/master/src/AuthorInfoList.php#L169):
	```
	$ cd extensions/GPML
	$ git grep -n wpi.AuthorInfo
	extension.json:62:		"wpi.AuthorInfo": {
	src/AuthorInfoList.php:182:		$parser->getOutput()->addModules( "wpi.AuthorInfo" );
	src/Content.php:249:			[ "wpi.AuthorInfo", "wpi.Pathway", "wpi.toggleButton", "wpi.PageEditor" ]
	```
8) MediaWiki is told in ```WikiPathways\GPML\Hook::onParserFirstCallInit()``` to call ```WikiPathways\GPML\AuthorInfoList::render()``` when it comes across the ```<AuthorInfo>``` [tag](https://www.mediawiki.org/wiki/Manual:Tag_extensions) in wikitext:
	```
	$ git grep -n B 2 AuthorInfoList::render
	src/Hook.php-54-	public static function onParserFirstCallInit( Parser &$parser ) {
	src/Hook.php-55-		$parser->setHook(
	src/Hook.php:56:			"AuthorInfo", "WikiPathways\\GPML\\AuthorInfoList::render"
	```
9) We can't find the ```<AuthorInfo>``` tag anywhere in GPML, so let's look in the other extensions:
	```
	$ pwd
	…/new.wikipathways.org/extensions/GPML
	$ git grep ‘<AuthorInfo'
	$ cd ..
	$ git submodule foreach -q 'git grep "<AuthorInfo" || :'
	$
	```
10) Since it isn't invoked anywhere (```<AuthorInfo>``` is kept for backwards compatibility just in case anyone used it in wikitext somewhere), let's look at the other match back in step 7.  There we saw that the ```wpi.AuthorInfo``` module is also included in ```WikiPathways\GPML\Content::fillParserOutput()``` but is this ever called?

	Let's do a brute force check:
	```
	$ curl https://vm1.wikipathways.org/Pathway:WP528?debug=true |  grep wpi.AuthorInfo
		<script>(window.RLQ=window.RLQ||[]).push(function(){mw.loader.load(["wpi.PathwayLoader.js","wpi.openInPathVisio","wpi.Dropdown","wpi.CurationTags","wpi.AuthorInfo","wpi.XrefPanel","wpi.Pathway","wpi.toggleButton","wpi.PageEditor","mediawiki.action.view.postEdit","site","mediawiki.page.startup","mediawiki.user","mediawiki.hidpi","mediawiki.page.ready","jquery.tablesorter","mediawiki.searchSuggest","ext.biblioPlus.qtip.config","skins.vector.js"]);});</script>
	```
	*(Note the use of ```?debug=true``` to keep MediaWiki from minimizing the output and allowing us to read it.)*

	This shows us that it is at least referenced in the output.
11) Adding ```?debug=true``` to the url we want to check ([like this](https://vm1.wikipathways.org/Pathway:WP528?debug=true)) and then loading it in the browser forces each javascript file to be loaded seperately.  *When we do this, it looks clicking “et al.” works without a problem.*
12) We visit the page again without ```?debug=true``` and [purge the cache](https://www.mediawiki.org/wiki/Manual:Purge). The problem re-appears

	At this point, we conclude that we found a bug in MediaWiki's handling of javascript files.
13) *(2 days later)* After having a chance to sleep on it, we remember that ResourceLoader is [minifying](https://en.wikipedia.org/wiki/Minification_(programming)) the javascript and, in the process changing the global name ```AuthorInfo```. Since we want to keep the old behavior (and we aren't JS natives), we consult the documentation for [developers migrating to ResourceLoader](https://www.mediawiki.org/wiki/ResourceLoader/Migration_guide_for_extension_developers), especially the bit on [global scope](https://www.mediawiki.org/wiki/ResourceLoader/Migration_guide_for_extension_developers#Global_scope) and discover that we can fix this by looking for ```AuthorInfo``` in our js file and [replace it with ```document.AuthorInfo```.](https://github.com/wikipathways/mediawiki-extensions-WikiPathways-GPML/commit/1abab68ab6be9425531be1c50a2cf1d8bb404031)


# Other Documents
- [Converting AuthorInfo to ResourceLoader](./docs/ConvertingToResourceLoader.org)
- [MediaWiki conventions](./docs/MediaWiki_conventions.org)
