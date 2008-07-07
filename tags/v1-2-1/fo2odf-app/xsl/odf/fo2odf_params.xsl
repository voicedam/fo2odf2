<?xml version="1.0"?>

<!-- Contains all parameters used by "fo2odf.xsl" (and imported styles). -->

<!-- References in text:
[XSL1] ... XSL FO 1.0 specification
-->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Whether to compress ODF automatic styles, i. e. whether to generate "nice" style names and to make
one style:style element from style:style elements containing the same properties.
TODO Xalan-J can run out of memory for larger documents if this option is used - try to find out solution. -->
<xsl:param name="compress-odf-automatic-styles">yes</xsl:param><!-- yes/no -->

<!-- Whether to issue a log warning if an unknown attribute should be processed -->
<xsl:param name="warn-on-unknown-attribute">no</xsl:param><!-- yes/no -->

<!-- How many points (pt) one pixel (px) represents. In [XSL1] there is only recommendation to make it f.e. 1/90 of inch
(i.e. 90 DPI) which stands for 0.8 points. Nevertheless it seems that 0.75 is used quite often (which means 96 DPI).
TODO Couldn't be the current value of DPI obtained dynamically by an extension function?
-->
<xsl:param name="pixels-to-points-ratio">0.75</xsl:param>

<!-- How many points (pt) one pica (pc) represents. This param should not change as it's directly specified in [XSL1]
(i.e. 1pc = 12pt).
-->
<xsl:param name="picas-to-points-ratio">12</xsl:param>

<!-- Whether to display frames even for images which were not successfully loaded. -->
<xsl:param name="display-corrupt-images">yes</xsl:param><!-- yes/no -->
<xsl:param name="default-width-for-corrupt-images">50</xsl:param>
<xsl:param name="default-height-for-corrupt-images">40</xsl:param>

<!-- Default right margin of the left-aligned tabulator used for <fo:leader>-s. -->
<xsl:param name="default-right-margin-of-left-tab">100</xsl:param>

<!-- Default right margin of the right-aligned tabulator used for <fo:leader>-s. -->
<xsl:param name="default-right-margin-of-right-tab">50</xsl:param>

<!-- Sizes of named absolute font sizes. The [XSL1] recommends 1.2 ratio between "adjacent" sizes.
-->
<xsl:param name="named-font-size-xx-small">6.9pt</xsl:param>
<xsl:param name="named-font-size-x-small">8.3pt</xsl:param>
<xsl:param name="named-font-size-small">10pt</xsl:param>
<xsl:param name="named-font-size-medium">12pt</xsl:param>
<xsl:param name="named-font-size-large">14.4pt</xsl:param>
<xsl:param name="named-font-size-x-large">17.3pt</xsl:param>
<xsl:param name="named-font-size-xx-large">20.7pt</xsl:param>

<!-- System fonts definitions - these can't be obtained in XSLT stylesheet, so they are defined here and are customizable. -->
<xsl:attribute-set name="system-font-caption-properties">
	<xsl:attribute name="font-size">10pt</xsl:attribute>
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
	<xsl:attribute name="font-style">normal</xsl:attribute>
	<xsl:attribute name="font-variant">normal</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="system-font-small-caption-properties">
	<xsl:attribute name="font-size">9pt</xsl:attribute>
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="font-weight">normal</xsl:attribute>
	<xsl:attribute name="font-style">normal</xsl:attribute>
	<xsl:attribute name="font-variant">normal</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="system-font-menu-properties">
	<xsl:attribute name="font-size">10pt</xsl:attribute>
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="font-weight">normal</xsl:attribute>
	<xsl:attribute name="font-style">normal</xsl:attribute>
	<xsl:attribute name="font-variant">normal</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="system-font-message-box-properties">
	<xsl:attribute name="font-size">11pt</xsl:attribute>
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="font-weight">normal</xsl:attribute>
	<xsl:attribute name="font-style">normal</xsl:attribute>
	<xsl:attribute name="font-variant">normal</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="system-font-status-bar-properties">
	<xsl:attribute name="font-size">10pt</xsl:attribute>
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="font-weight">normal</xsl:attribute>
	<xsl:attribute name="font-style">normal</xsl:attribute>
	<xsl:attribute name="font-variant">normal</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="system-font-icon-properties">
	<xsl:attribute name="font-size">10pt</xsl:attribute>
	<xsl:attribute name="font-family">Arial</xsl:attribute>
	<xsl:attribute name="font-weight">normal</xsl:attribute>
	<xsl:attribute name="font-style">normal</xsl:attribute>
	<xsl:attribute name="font-variant">normal</xsl:attribute>
</xsl:attribute-set>

<!-- Sizes of named border widths. [XSL1] tells it's user agent dependent... -->
<xsl:param name="named-border-width-thin">1pt</xsl:param>
<xsl:param name="named-border-width-medium">2pt</xsl:param>
<xsl:param name="named-border-width-thick">3pt</xsl:param>

<!-- Default values of properties taken directly from [XSL1] ("C.2 Property Table: Part I").
Naming convention: f.e. parameter for default property of "font-size" is called "default-font-size". 

Notes:
- Original values put to a comment if changed to some more suitable value for XSLT processing.
- Not all values are really used but serve rather as a documentation.
-->
<xsl:param name="default-absolute-position">auto</xsl:param>
<xsl:param name="default-active-state">no, a value is required</xsl:param>
<xsl:param name="default-alignment-adjust">auto</xsl:param>
<xsl:param name="default-alignment-baseline">auto</xsl:param>
<xsl:param name="default-auto-restore">false</xsl:param>
<xsl:param name="default-azimuth">center</xsl:param>
<xsl:param name="default-background">not defined for shorthand properties</xsl:param>
<xsl:param name="default-background-attachment">scroll</xsl:param>
<xsl:param name="default-background-color">transparent</xsl:param>
<xsl:param name="default-background-image">none</xsl:param>
<xsl:param name="default-background-position">0% 0%</xsl:param>
<xsl:param name="default-background-position-horizontal">0%</xsl:param>
<xsl:param name="default-background-position-vertical">0%</xsl:param>
<xsl:param name="default-background-repeat">repeat</xsl:param>
<xsl:param name="default-baseline-shift">baseline</xsl:param>
<xsl:param name="default-blank-or-not-blank">any</xsl:param>
<xsl:param name="default-block-progression-dimension">auto</xsl:param>
<xsl:param name="default-border">see individual properties</xsl:param>
<xsl:param name="default-border-after-color">the value of the 'color' property</xsl:param>
<xsl:param name="default-border-after-precedence">fo:table: 6, fo:table-cell: 5, fo:table-column: 4, fo:table-row: 3, fo:table-body: 2, fo:table-header: 1, fo:table-footer: 0</xsl:param>
<xsl:param name="default-border-after-style">none</xsl:param>
<xsl:param name="default-border-after-width">medium</xsl:param>
<xsl:param name="default-border-before-color">the value of the 'color' property</xsl:param>
<xsl:param name="default-border-before-precedence">fo:table: 6, fo:table-cell: 5, fo:table-column: 4, fo:table-row: 3, fo:table-body: 2, fo:table-header: 1, fo:table-footer: 0</xsl:param>
<xsl:param name="default-border-before-style">none</xsl:param>
<xsl:param name="default-border-before-width">medium</xsl:param>
<xsl:param name="default-border-bottom">see individual properties</xsl:param>
<xsl:param name="default-border-bottom-color">the value of the 'color' property</xsl:param>
<xsl:param name="default-border-bottom-style">none</xsl:param>
<xsl:param name="default-border-bottom-width">medium</xsl:param>
<xsl:param name="default-border-collapse">collapse</xsl:param>
<xsl:param name="default-border-color">see individual properties</xsl:param>
<xsl:param name="default-border-end-color">the value of the 'color' property</xsl:param>
<xsl:param name="default-border-end-precedence">fo:table: 6, fo:table-cell: 5, fo:table-column: 4, fo:table-row: 3, fo:table-body: 2, fo:table-header: 1, fo:table-footer: 0</xsl:param>
<xsl:param name="default-border-end-style">none</xsl:param>
<xsl:param name="default-border-end-width">medium</xsl:param>
<xsl:param name="default-border-left">see individual properties</xsl:param>
<xsl:param name="default-border-left-color">the value of the 'color' property</xsl:param>
<xsl:param name="default-border-left-style">none</xsl:param>
<xsl:param name="default-border-left-width">medium</xsl:param>
<xsl:param name="default-border-right">see individual properties</xsl:param>
<xsl:param name="default-border-right-color">the value of the 'color' property</xsl:param>
<xsl:param name="default-border-right-style">none</xsl:param>
<xsl:param name="default-border-right-width">medium</xsl:param>
<xsl:param name="default-border-separation">.block-progression-direction="0pt" .inline-progression-direction="0pt"</xsl:param>
<xsl:param name="default-border-spacing">0pt</xsl:param>
<xsl:param name="default-border-start-color">the value of the 'color' property</xsl:param>
<xsl:param name="default-border-start-precedence">fo:table: 6, fo:table-cell: 5, fo:table-column: 4, fo:table-row: 3, fo:table-body: 2, fo:table-header: 1, fo:table-footer: 0</xsl:param>
<xsl:param name="default-border-start-style">none</xsl:param>
<xsl:param name="default-border-start-width">medium</xsl:param>
<xsl:param name="default-border-style">see individual properties</xsl:param>
<xsl:param name="default-border-top">see individual properties</xsl:param>
<xsl:param name="default-border-top-color">the value of the 'color' property</xsl:param>
<xsl:param name="default-border-top-style">none</xsl:param>
<xsl:param name="default-border-top-width">medium</xsl:param>
<xsl:param name="default-border-width">see individual properties</xsl:param>
<xsl:param name="default-bottom">auto</xsl:param>
<xsl:param name="default-break-after">auto</xsl:param>
<xsl:param name="default-break-before">auto</xsl:param>
<xsl:param name="default-caption-side">before</xsl:param>
<xsl:param name="default-case-name">none, a value is required</xsl:param>
<xsl:param name="default-case-title">none, a value is required</xsl:param>
<xsl:param name="default-character">N/A, value is required</xsl:param>
<xsl:param name="default-clear">none</xsl:param>
<xsl:param name="default-clip">auto</xsl:param>
<xsl:param name="default-color">#000000<!-- depends on user agent --></xsl:param>
<xsl:param name="default-color-profile-name">N/A, value is required</xsl:param>
<xsl:param name="default-column-count">1</xsl:param>
<xsl:param name="default-column-gap">12.0pt</xsl:param>
<xsl:param name="default-column-number">see prose</xsl:param>
<xsl:param name="default-column-width">see prose</xsl:param>
<xsl:param name="default-content-height">auto</xsl:param>
<xsl:param name="default-content-type">auto</xsl:param>
<xsl:param name="default-content-width">auto</xsl:param>
<xsl:param name="default-country">none</xsl:param>
<xsl:param name="default-cue">not defined for shorthand properties</xsl:param>
<xsl:param name="default-cue-after">none</xsl:param>
<xsl:param name="default-cue-before">none</xsl:param>
<xsl:param name="default-destination-placement-offset">0pt</xsl:param>
<xsl:param name="default-direction">ltr</xsl:param>
<xsl:param name="default-display-align">auto</xsl:param>
<xsl:param name="default-dominant-baseline">auto</xsl:param>
<xsl:param name="default-elevation">level</xsl:param>
<xsl:param name="default-empty-cells">show</xsl:param>
<xsl:param name="default-end-indent">0pt</xsl:param>
<xsl:param name="default-ends-row">false</xsl:param>
<xsl:param name="default-extent">0.0pt</xsl:param>
<xsl:param name="default-external-destination">empty string</xsl:param>
<xsl:param name="default-float">none</xsl:param>
<xsl:param name="default-flow-name">an empty name</xsl:param>
<xsl:param name="default-font">see individual properties</xsl:param>
<xsl:param name="default-font-family">depends on user agent</xsl:param>
<xsl:param name="default-font-selection-strategy">auto</xsl:param>
<xsl:param name="default-font-size">12pt<!-- medium --></xsl:param>
<xsl:param name="default-font-size-adjust">none</xsl:param>
<xsl:param name="default-font-stretch">normal</xsl:param>
<xsl:param name="default-font-style">normal</xsl:param>
<xsl:param name="default-font-variant">normal</xsl:param>
<xsl:param name="default-font-weight">normal</xsl:param>
<xsl:param name="default-force-page-count">auto</xsl:param>
<xsl:param name="default-format">1</xsl:param>
<xsl:param name="default-glyph-orientation-horizontal">0deg</xsl:param>
<xsl:param name="default-glyph-orientation-vertical">auto</xsl:param>
<xsl:param name="default-grouping-separator">no separator</xsl:param>
<xsl:param name="default-grouping-size">no grouping</xsl:param>
<xsl:param name="default-height">auto</xsl:param>
<xsl:param name="default-hyphenate">false</xsl:param>
<xsl:param name="default-hyphenation-character">The Unicode hyphen character U+2010</xsl:param>
<xsl:param name="default-hyphenation-keep">auto</xsl:param>
<xsl:param name="default-hyphenation-ladder-count">no-limit</xsl:param>
<xsl:param name="default-hyphenation-push-character-count">2</xsl:param>
<xsl:param name="default-hyphenation-remain-character-count">2</xsl:param>
<xsl:param name="default-id">see prose</xsl:param>
<xsl:param name="default-indicate-destination">false</xsl:param>
<xsl:param name="default-initial-page-number">auto</xsl:param>
<xsl:param name="default-inline-progression-dimension">auto</xsl:param>
<xsl:param name="default-internal-destination">empty string</xsl:param>
<xsl:param name="default-intrusion-displace">auto</xsl:param>
<xsl:param name="default-keep-together">.within-line=auto, .within-column=auto, .within-page=auto</xsl:param>
<xsl:param name="default-keep-with-next">.within-line=auto, .within-column=auto, .within-page=auto</xsl:param>
<xsl:param name="default-keep-with-previous">.within-line=auto, .within-column=auto, .within-page=auto</xsl:param>
<xsl:param name="default-language">none</xsl:param>
<xsl:param name="default-last-line-end-indent">0pt</xsl:param>
<xsl:param name="default-leader-alignment">none</xsl:param>
<xsl:param name="default-leader-length">leader-length.minimum=0pt, .optimum=12.0pt, .maximum=100%</xsl:param>
<xsl:param name="default-leader-pattern">space</xsl:param>
<xsl:param name="default-leader-pattern-width">use-font-metrics</xsl:param>
<xsl:param name="default-left">auto</xsl:param>
<xsl:param name="default-letter-spacing">normal</xsl:param>
<xsl:param name="default-letter-value">auto</xsl:param>
<xsl:param name="default-linefeed-treatment">treat-as-space</xsl:param>
<xsl:param name="default-line-height">normal</xsl:param>
<xsl:param name="default-line-height-shift-adjustment">consider-shifts</xsl:param>
<xsl:param name="default-line-stacking-strategy">max-height</xsl:param>
<xsl:param name="default-margin">not defined for shorthand properties</xsl:param>
<xsl:param name="default-margin-bottom">0pt</xsl:param>
<xsl:param name="default-margin-left">0pt</xsl:param>
<xsl:param name="default-margin-right">0pt</xsl:param>
<xsl:param name="default-margin-top">0pt</xsl:param>
<xsl:param name="default-marker-class-name">an empty name</xsl:param>
<xsl:param name="default-master-name">an empty name</xsl:param>
<xsl:param name="default-master-reference">an empty name</xsl:param>
<xsl:param name="default-max-height">0pt</xsl:param>
<xsl:param name="default-maximum-repeats">no-limit</xsl:param>
<xsl:param name="default-max-width">none</xsl:param>
<xsl:param name="default-media-usage">auto</xsl:param>
<xsl:param name="default-min-height">0pt</xsl:param>
<xsl:param name="default-min-width">depends on UA</xsl:param>
<xsl:param name="default-number-columns-repeated">1</xsl:param>
<xsl:param name="default-number-columns-spanned">1</xsl:param>
<xsl:param name="default-number-rows-spanned">1</xsl:param>
<xsl:param name="default-odd-or-even">any</xsl:param>
<xsl:param name="default-orphans">2</xsl:param>
<xsl:param name="default-overflow">auto</xsl:param>
<xsl:param name="default-padding">not defined for shorthand properties</xsl:param>
<xsl:param name="default-padding-after">0pt</xsl:param>
<xsl:param name="default-padding-before">0pt</xsl:param>
<xsl:param name="default-padding-bottom">0pt</xsl:param>
<xsl:param name="default-padding-end">0pt</xsl:param>
<xsl:param name="default-padding-left">0pt</xsl:param>
<xsl:param name="default-padding-right">0pt</xsl:param>
<xsl:param name="default-padding-start">0pt</xsl:param>
<xsl:param name="default-padding-top">0pt</xsl:param>
<xsl:param name="default-page-break-after">auto</xsl:param>
<xsl:param name="default-page-break-before">auto</xsl:param>
<xsl:param name="default-page-break-inside">auto</xsl:param>
<xsl:param name="default-page-height">27.9cm<!-- auto --></xsl:param>
<xsl:param name="default-page-position">any</xsl:param>
<xsl:param name="default-page-width">21cm<!-- auto --></xsl:param>
<xsl:param name="default-pause">depends on user agent</xsl:param>
<xsl:param name="default-pause-after">depends on user agent</xsl:param>
<xsl:param name="default-pause-before">depends on user agent</xsl:param>
<xsl:param name="default-pitch">medium</xsl:param>
<xsl:param name="default-pitch-range">50</xsl:param>
<xsl:param name="default-play-during">auto</xsl:param>
<xsl:param name="default-position">static</xsl:param>
<xsl:param name="default-precedence">false</xsl:param>
<xsl:param name="default-provisional-distance-between-starts">24.0pt</xsl:param>
<xsl:param name="default-provisional-label-separation">6.0pt</xsl:param>
<xsl:param name="default-reference-orientation">0</xsl:param>
<xsl:param name="default-ref-id">none, value required</xsl:param>
<xsl:param name="default-region-name">see prose</xsl:param>
<xsl:param name="default-relative-align">before</xsl:param>
<xsl:param name="default-relative-position">static</xsl:param>
<xsl:param name="default-rendering-intent">auto</xsl:param>
<xsl:param name="default-retrieve-boundary">page-sequence</xsl:param>
<xsl:param name="default-retrieve-class-name">an empty name</xsl:param>
<xsl:param name="default-retrieve-position">first-starting-within-page</xsl:param>
<xsl:param name="default-richness">50</xsl:param>
<xsl:param name="default-right">auto</xsl:param>
<xsl:param name="default-role">none</xsl:param>
<xsl:param name="default-rule-style">solid</xsl:param>
<xsl:param name="default-rule-thickness">1.0pt</xsl:param>
<xsl:param name="default-scaling">uniform</xsl:param>
<xsl:param name="default-scaling-method">auto</xsl:param>
<xsl:param name="default-score-spaces">true</xsl:param>
<xsl:param name="default-script">auto</xsl:param>
<xsl:param name="default-show-destination">replace</xsl:param>
<xsl:param name="default-size">auto</xsl:param>
<xsl:param name="default-source-document">none</xsl:param>
<xsl:param name="default-space-after">space.minimum=0pt, .optimum=0pt, .maximum=0pt, .conditionality=discard, .precedence=0</xsl:param>
<xsl:param name="default-space-before">space.minimum=0pt, .optimum=0pt, .maximum=0pt, .conditionality=discard, .precedence=0</xsl:param>
<xsl:param name="default-space-end">space.minimum=0pt, .optimum=0pt, .maximum=0pt, .conditionality=discard, .precedence=0</xsl:param>
<xsl:param name="default-space-start">space.minimum=0pt, .optimum=0pt, .maximum=0pt, .conditionality=discard, .precedence=0</xsl:param>
<xsl:param name="default-span">none</xsl:param>
<xsl:param name="default-speak">normal</xsl:param>
<xsl:param name="default-speak-header">once</xsl:param>
<xsl:param name="default-speak-numeral">continuous</xsl:param>
<xsl:param name="default-speak-punctuation">none</xsl:param>
<xsl:param name="default-speech-rate">medium</xsl:param>
<xsl:param name="default-src">none, value required</xsl:param>
<xsl:param name="default-start-indent">0pt</xsl:param>
<xsl:param name="default-starting-state">show</xsl:param>
<xsl:param name="default-starts-row">false</xsl:param>
<xsl:param name="default-stress">50</xsl:param>
<xsl:param name="default-suppress-at-line-break">auto</xsl:param>
<xsl:param name="default-switch-to">xsl-any</xsl:param>
<xsl:param name="default-table-layout">auto</xsl:param>
<xsl:param name="default-table-omit-footer-at-break">false</xsl:param>
<xsl:param name="default-table-omit-header-at-break">false</xsl:param>
<xsl:param name="default-target-presentation-context">use-target-processing-context</xsl:param>
<xsl:param name="default-target-processing-context">document-root</xsl:param>
<xsl:param name="default-target-stylesheet">use-normal-stylesheet</xsl:param>
<xsl:param name="default-text-align">start</xsl:param>
<xsl:param name="default-text-align-last">relative</xsl:param>
<xsl:param name="default-text-altitude">use-font-metrics</xsl:param>
<xsl:param name="default-text-decoration">none</xsl:param>
<xsl:param name="default-text-depth">use-font-metrics</xsl:param>
<xsl:param name="default-text-indent">0pt</xsl:param>
<xsl:param name="default-text-shadow">none</xsl:param>
<xsl:param name="default-text-transform">none</xsl:param>
<xsl:param name="default-top">auto</xsl:param>
<xsl:param name="default-treat-as-word-space">auto</xsl:param>
<xsl:param name="default-unicode-bidi">normal</xsl:param>
<xsl:param name="default-vertical-align">baseline</xsl:param>
<xsl:param name="default-visibility">visible</xsl:param>
<xsl:param name="default-voice-family">depends on user agent</xsl:param>
<xsl:param name="default-volume">medium</xsl:param>
<xsl:param name="default-white-space">normal</xsl:param>
<xsl:param name="default-white-space-collapse">true</xsl:param>
<xsl:param name="default-white-space-treatment">ignore-if-surrounding-linefeed</xsl:param>
<xsl:param name="default-widows">2</xsl:param>
<xsl:param name="default-width">auto</xsl:param>
<xsl:param name="default-word-spacing">normal</xsl:param>
<xsl:param name="default-wrap-option">wrap</xsl:param>
<xsl:param name="default-writing-mode">lr-tb</xsl:param>
<xsl:param name="default-xml-lang">not defined for shorthand properties</xsl:param>
<xsl:param name="default-z-index">auto</xsl:param>

</xsl:stylesheet>