<p>Some caveats. </p>

<p>The wiki is not intended to look like a standard web page. In many ways complex markup gets in the way of usefulness. The value of the wiki is in its content, edit-ability, and sharing, not its presentation. </p>

<p>HOWEVER...</p>

<p>This was done to help authors move existing ordinary text and simple html into a format the Smallest Federated Wiki can present. While it requires correctly formatted html input, that can be easily produced with a tool like Markdown if you keep it simple, as you should. </p>

<p>On the other hand, if you have html, this tries to capture as much of your content as possible (within the limitations of the tools and my time to refine this). It will capture lists, tables, headings, etc, that should probably not appear in the wiki, but might not do too much damage to the experience if used in limited ways. For an interactive document (one meant to be updated by the community - i.e. federated) such complex markup gets in the way. </p>

<p>Note that this currently assumes you have access to the server for SFW, as it simply writes files that the wiki knows how to present. It is a batch processor for background application. The produced files may need some tweaking when first presented. </p>

<hr />

<p>Note the limitations of the tool. It tries to capture most tags within paragraphs. Many tags are normally NOT put in paragraph markers in normal use (headings, tables, ...) and so we modify the document tree before translation to add them if needed.  </p>

<p>It won't deal with frame-sets, but if you have the html for the individual frames it will handle them. </p>

<p>If you get garbage from this, try to run your html through a validator. </p>

<p>Two good projects might be (1) "flatten" tables. i.e. pull out the content for simpler presentation.(b) transform lists into multiple paragraphs, one per list item.  (done by default in the latest version) </p>
