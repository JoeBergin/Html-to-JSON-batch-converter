<p>Here we reformat minimal, but strict, HTML to JSON and publish it as an instance of the Smallest Federated Wiki.</p>

<p>It will read a set of files with names such as FooBas.html and produce more or less equivalent wiki pages with titles such as Foo Bas. </p>

<p>This script is a modificatiion of the one Ward Cunningham used to translate the patterns of practice files from XHTML to JSON. </p>

<p>The script html-json.rb will translate a minimally processed set of text files into pages suitable for SFW as well as create a summary (index) page. It requires properly formatted html input, but doesn't need much refinement. It processes paragraphs, preformatted text, images and some other things. It will optionally tranform either bold or italic text into wiki links. So &lt;b>foo&lt;/b> becomes [[foo]], for example. Wiki page titles are taken from filenames - see the docs folder.</p>

<p>It attempts to capture as much of the original document and its markup as is possible, including some css defined attributes, without over burdening the look of the wiki page. It flattens lists (default) for example, but preserves tables.<p>

<p>It will optionally produce an index summary of the files it translates, suitable for inclusion in the wiki, with links to the pages. </p>

<p>For more on this, including the options, see the docs folder.</p>