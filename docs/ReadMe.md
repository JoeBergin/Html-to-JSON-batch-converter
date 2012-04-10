<p>Here we reformat minimal, but strict, HTML to JSON and publish it as an instance of the Smallest Federated Wiki.</p>

<p>It will read a set of files with names such as FooBas.html and produce more or less equivalent wiki pages with titles such as Foo Bas. </p>

<p>This script is a modificatiion of the one Ward Cunningham used to translate the patterns of practice files from XHTML to JSON. </p>

<p>The script html-json.rb will translate a minimally processed set of text files into pages suitable for SFW as well as create a summary (index) page. It requires properly formatted html input, but doesn't need much refinement. It processes paragraphs, preformatted text, and images. It will optionally tranform either bold or italic text into wiki links. So &lt;b>foo&lt;/b> becomes [[foo]], for example. Wiki page titles are taken from filenames - see below.</p>

<p> A correctly formatted &lt;pre> ...&lt;/pre> tag will be wrapped in a paragraph but otherwise preserved, similarly for the code tag. Likewise headings (H1..H6) will be preserved in the same way. Note that the wiki itself seems to show H1 and H2 tags as H3 instead to avoid overwhelming the small page format. </p>

<p>It will translate anchor tags within paragraphs into wiki external links [href text] or internal links [[text]] depending on the form of the href. If the href starts with a period, as in ./mumble, it assumes the link is to point to another wiki page and creates an internal link. Otherwise, say if it starts out http://, it will create an external link.</p>

<p> Horizontal rules are preserved. </p>

<p> Lists (ul and ol) are flattened by default. List items are transformed into individual paragraphs. If you give the -f option, lists are instead preserved as lists. However, this makes for large wiki paragraphs - a negative. Note that flattening loses the bullets/numbering usually associated with lists. </p>

<p> Tables are preserved. </p>

<p>Ugly/beautiful markup (span, etc) within paragraphs will be preserved, which may NOT look good in the wiki. Beware, but wiki will likely ignore it anyway. </p>

<p> But, paragraph and span classes can be transformed into simpler markup that will likely look better in the wiki. Prior to running the script, you edit a map of paragraph class attributes and separately a map of span class attributes, giving the markup equivalent (bold, or italic, say) and the transformation will be done. Sample data is provided in the script, based on a document set of my own. The Critique.html sample file in the originals folder comes from this set. </p>

<p>Note, however, that some of the inserted markup (headings, pre, etc) is currently handled a bit strangely in SFW. When you first view the page, you actully see the markup as text. But if you double click the paragraph and immediately save, it will thereafter be interpreted correctly. It is an open issue in SFW that will be addressed at some point.</p>

<p> Note, as well, that it requires strict html, as the parser is an XML parser. This means, for example, that break tags need to be: &lt;br/>. The parser gets very confused and produces garbage if you give it lenient input. Every tag needs to be closed properly. </p>

<p> Note also that if your headings, pre, hr, code, list, and table tags already appear in paragraphs (they normally don't), they will be doubled in the output. I will likely fix this in the future. UPDATE: fixed</p>

<p>If you already have correctly formatted html files, you don't need to do anything except attend to the filenames so you get the page titles you desire. You should rename any input file so that it's filename is a captialized bumpy word with an html extension. For example mumblefoo.txt might become MumbleFoo.html before processing. The page title will then be Mumble Foo.  </p>

<p>Page names in a federated wiki should be intention revealing. Ward Cunningham suggests multiple word names, rather than simple one word names. Names starting with a capital letter are also preferred. When you create a page, using this or any other mechanism, think about how it will be federated (forked, copied...). Ths script warns against poor names, though imperfectly. Ideally names should be relatively unique. So "PatternsOfPracticeSummary" is much to be preferred over "Summary" or even "Table Of Contents". The latter is too generic. This means attending carefully to your file names (which become page titles) prior to running the script. 
</p>

<p>The script is intended to be run from the scripts folder. The script has three arguments. -b will transform text within bold tags into wiki links. -i will transform italic tags into links. If you use both it will work, unless you have text that is both bold and italic. Then the [[ ... ]] will be added twice. It will work, but look ugly.</p>

<p>If you use the -t argument, then the following arg is a string with suffix of the title of the summary page. By default no index page is produced. I ran the sample inputs with -t 'My Files'. The string "Index of" is prepended to your argument consistent with the naming concept above. </p>

<p> The -h option will print the options. </p>

<p>The script reads a set of files from ./scripts/originals and produces its output into ../pages (which must exist). The summary, if any, is also placed there. The originals are not modified. </p>

<hr/>

<p>If you have a straight text file to process, do this first. Use markdown (http://daringfireball.net/projects/markdown/) to add paragraph markers, or do it by hand. Markdown transforms blank lines into paragraph breaks and correctly formats them. Assure that your img tags are correctly fomatted (strict): &lt;img src="mumble.gif"/>. Add &lt;html>&lt;body> to the beginning and &lt;/body>&lt;/html> to the end. The file should now be ok for this script to process. Don't bother with any other markdown options than blank lines, or the produced json may not work well in the wiki. Code fragments, headings, and other things specifically mentioned here are ok. </p>

<p> Ignore the content distributed with this (originals folder). They are just test files I use to develop this. The references are from my pedagogical patterns book - in prep. </p>
