Here are some ways to use the html-json converter and some suggestions for other things. 

First thing is to realize that you can tailor this to your own document set. Your html docs may have "special needs" that require it. I will describe a scenario below. It would be relatively easy to make it parse XHTML or XML docs, for example. 

Next, the html you have must be very clean and complete. In particular all tags must be properly closed, including single part tags such as img and br tags. 

If you aren't sure, run your documents through a checker first. For example, use: <http://validator.w3.org/> or the one built into SIGIL (more below). If that is impossible, note that nokogiri on which this depends also has a lenient mode that might help you, but you are on your own for that. 

Next, realize that the SFW wants small pages with few (and small) graphics, and little markup. Paragraphs should also be small, but lists are normally treated as one paragraph, which makes it hard to pull out and rearrange things on the wiki. The tool will automatically flatten all but definition lists by default, though you can prevent this with an option. 

If you have large pages you can do this, which is pretty effective: Download a copy of SIGIL, which is an ePubl preparation system (open source Google project). It isn't perfect, but is improving. Create a new ePub and use the option to import an external (html) document. Sigil will itself do some cleanup of it, and it has a built-in html checker which is very helpful. But to get small documents from a large one, you can use options there to break a long document into "chapters" which are just xhtml docs. You can then grab the xhtml version and do minor edits to get html. The big win is that breaking it up requires only a few mouse presses and giving the new piece a filename. 

You can do some cleanup in SIGIL also as the find/replace options are regular expression based, so you can do quite a lot. An along the way, you might also get an ePub to read on your mobile device or sell in one of the markets. 

The html-json translator is intended to work offline in batch mode, but I keep a version of SFW running on my laptop and just copy the files produced by it from the originals into the server pages folder so that I can see what it is producing in a real server. It isn't hard to understand the json directly, but seeing it is helpful. A script could automate the move, of course, but I normally just use copy/paste. 

If you don't like what you see in SFW, you have two options. First is to modify the original documents in some way, and the other is to modify the translator so it produces what you like. Sometimes one or the other of these is easier. 

Note that the SFW page titles are taken from the filenames in this translator. So a file named MySpecialPage.html will become "My Special Page" in the json produced, with filename my-special-page. Keep this in mind during your document preparation. But if you have some other requirements on page names you can always add a map to the translator to translate filenames into the page titles you prefer. You might also be able to build this map automatically. In the preparation of the Seminars site we had this problem. The pattern names were things like Breaks and these were H1 headings in the individual files. But the filenames were just numbers like 17.html. A pre run through the directory matched the filenames to the headings and built the map. See the repo at <https://github/JoeBergin/Seminars/> for the translator used there. It was the inspiration for this, more general, one. 

If you have an existing wiki that you want to publish as a SFW, you may need to modify your server so that it produces cleaner html. You can also add a line or two so that any page produced is also written to a file. I found this easy to do for one of my projects and much easier than editing a hundred or so ugly html pages. 

If you have a word/open-office doc you can have it produce html from which to start. Unfortunately the html is likely to be ugly and require some cleanup. 

If you have text docs, you can use markdown to add paragraph markers and then manually add simple html and body tags to enclose a page. 

-----

[Batch processing scripts](https://github.com/JoeBergin/Batch-SFW-Scripts) <br/>

>	append file 
>
>	clean journal 
>
>	create summary 
>
>	rename page 
>
>	split page 

[Sigil](http://code.google.com/p/sigil/) <br/>
[nokogiri](http://nokogiri.org/) <br/>
[markdown](http://daringfireball.net/projects/markdown/)
