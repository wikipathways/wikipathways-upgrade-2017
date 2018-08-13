<?php
/**
 * Hooks for ontologyTags extension
 *
 * @file
 * @ingroup Extensions
 */
namespace WikiPathways\OntologyTags;

use Parser;
use ParserOptions;
use ParserOutput;
use Title;
use Revision;
use Status;
use User;
use WikiPage;
use WikiPathways\Pathway;

class Hook {
	public static function onRegistration() {
		global $wgAjaxExportList;

		// Register AJAX functions
		$wgAjaxExportList[] = "WikiPathways\\OntologyTags\\OntologyTagsFunctions::getOntologyTags";
	}
	public static function onParserFirstCallInit( Parser &$parser ) {
		$parser->setHook( "OntologyTags", 'WikiPathways\\OntologyTags\\OntologyTagsDisplays::tag' );
	}

}
