#!/usr/bin/ruby
require 'rubygems'
require 'nokogiri'
require 'json'

def random
  (1..16).collect {(rand*16).floor.to_s(16)}.join ''
end

def slug title
  title.gsub(/\s/, '-').gsub(/[^A-Za-z0-9-]/, '').downcase()
end

#clean curly quotes and remove non-breaking spaces
def clean text
  text.gsub(/’/,"'").gsub(/&nbsp;/,' ')
end

# clean multiple (internal) spaces-newlines-tabs to single spaces. 
def shrinkWhitespace text
	text.gsub(/\s+/, ' ').gsub(/\t+/, ' ').gsub(/\n/,' ');
end

# put spaces in bumpy words to be compatible with SFW
def deBumpy text
	if @deBump
		text.gsub(/([a-z])([A-Z])/,'\1 \2')
	else
		text
	end
end

# unused here, but translate back to original form
def decode_base64( text )
	text.unpack( "m" )[0]
end

# encode a file's contents in base_64 - found on web
def encode_base64( bin )
	[ bin ].pack( "m" ).gsub( /\s/, "" )
end

##########
# remove image tags from nodes known to have them to
# retain rest of paragraphs that contain images
def cleanImages elem
	if elem.inner_html.to_s =~ /(.*?)<img.*?src="(.*?)".*?>(.*?)$/  
			$1 + " " + $3 #" (image: " + $2 + ") " + $3
  	elsif
		elem.content.to_s =~ /(.*?)<img.*?src="(.*?)".*?>(.*?)$/  
			$1 + " " + $3 #" (image: " + $2 + ") " + $3 
  	end
end

# modify file paths relative to . rather than originals
def appendBase filename
	if filename =~ /^\.\.\/(.*)$/
		"./" + $1
	elsif filename =~ /^\.\/(.*)$/
		@imageBase + $1
	elsif filename =~ /^http.*?$/
		filename
	else
		@imageBase + filename
	end
end

# produce json from an img tag for a local file when possible
def image imageRef
#puts 'processing ' + imageRef
	if imageRef =~ /(.*?)\.(jpg|gif|png|JPG|GIF|PNG)/
		filename, type = $1, $2
#		puts filename + '--->' + type
		fullname = filename+'.' + type
		contents = File.open(appendBase(fullname), "rb").read
		bin = encode_base64 contents
		{ 'type' => 'image', 
			'id' => random(), 
			'url' => "data:image/#{type};base64,#{bin}",
			'caption' => fullname 
		}
	else
		puts "No match for: " + imageRef+ ". Assume manual insertion."
		paragraph "Insert image: " + imageRef
	end
	rescue
		puts "Exception for: " + imageRef + ". Assume external link."
		paragraph "[#{imageRef} #{imageRef}]"
end

# unused - turn a naked url into an external link
def url text
  text.gsub(/(http:\/\/)?([a-zA-Z0-9._-]+?\.(net|com|org|edu)(\/[^ )]+)?)/,'[http:\/\/\2 \2]')
end

# create the journal "create" entry
def create title
  {'type' => 'create', 'id' => random, 'item' => {'title' => title}}
end 

# create a wiki paragraph
def paragraph text
  {'type' => 'paragraph', 'text' => text, 'id' => random()}
end

# create a wiki page (json) with empty journal
def page title, story
  page = {'title' => title, 'story' => story, 'journal' => [create(title)]}
  File.open("../pages/#{slug(title)}", 'w') do |file| 
    file.write JSON.pretty_generate(page)
  end
end

# create a wiki page (json) with provided journal
def pageWithJournal title, story, journal
  page = {'title' => title, 'story' => story, 'journal' => journal}
  File.open("../pages/#{slug(title)}", 'w') do |file| 
    file.write JSON.pretty_generate(page)
  end
end

# ask if a node is contained within a paragraph already
def inParagraph? node
	while node != nil and node.name != 'document' and node.name != 'p'
		node = node.parent
	end
	node != nil and node.name == 'p'
end
  
# The main conversion routine
def convert title, doc
  puts title
  
  if @capturePageTitle
	  doc.css('title').each do |elem|
		elem.replace doc.create_element('p', doc.create_element('h1',elem.content))
	  end
  end
  
  # transform images into paragraphs
  doc.css('img').each do |elem| 
	if !inParagraph? elem
		elem.replace doc.create_element('p', elem)
	end
  end
  
  # anchors. local-file to wiki page refs, global-http to external refs
  doc.css('a').each do |elem|
  	if elem.content != nil and elem.content.strip.length > 0
  		if elem.attr('href').lstrip.index(".") == 0 #local
  			elem.replace doc.create_element('text',"[[#{deBumpy(shrinkWhitespace(elem.content.strip))}]]")
  		else #global
  			elem.replace doc.create_element('text', "[#{elem.attr('href')} #{shrinkWhitespace(elem.content.strip)}]")
  		end
  	else 
  		elem.replace doc.create_element('text', ' ')
  	end
  end
  
  # translate paragraph class into markup (sample data included)
  # tailor this to your own document set
  @paragraphStyles = {
  "P9" => 'i',
  "P10" => 'i',
  "P20" => 'i',
  "P29" => 'i',
  "P30" => 'i',
  'P34' => 'b',
  "P37" => 'small',
  'P41' => 'i',
  'P42' => 'i',
  'P43' => 'i',
  'P44' => 'i',
  'P72' => 'i',
  'P87' => 'i',
  'AASeparator' => 'center',
  'AAExample' => 'i',
  'AAProblem' => 'b',
  'AASource' => 'i'
  }
  
  # translate span class into markup (sample data included)
  # tailor this to your own document set
  @spanStyles = {
  'T5' => 'i',
  'T6' => 'b',
  'T7' => 'b',
  'T8' => 'b',
  'T9' => 'b',
  'T10' => 'i',
  'T11' => 'i',
  'T12' => 'i',
  'T13' => 'i',
  'T14' => 'i',
  'T33' => 'i',
  'T34' => 'i',
  'T35' => 'i',
  'T47' => 'i',
  'T51' => 'i',
  'T52' => 'i',
  'T67' => 'i',
  'AAPatRef' => 'b'
  }
  
  if @flatten
    @lists = doc.css('dl') # Nokogiri::XML::NodeSet.new(doc) # empty set
  else
  	@lists = doc.css('ul') + doc.css('ol') + doc.css('dl')
  end
  
  # capture these in paragraphs if not already in paragraphs
  @retain = 
  	doc.css('h1') + 
  	doc.css('h2') + 
  	doc.css('h3') + 
  	doc.css('h4') + 
  	doc.css('h5') + 
  	doc.css('h6') + 
  	doc.css('pre') + 
  	doc.css('code') + 
  	doc.css('hr') + 
  	doc.css('table') + 
  	doc.css('blockquote') + 
  	@lists
  
  @retain.each do |elem|
  	if ! inParagraph?(elem)
  		elem.replace doc.create_element('p', elem)
  	end
  end
  
  # apply styles to spans
  doc.css('span').each do |elem|
  	classAttr = elem.attr("class")
  	which = @spanStyles[classAttr]
  	if which != nil
  		elem.content = doc.create_element(which, elem.content)
#  		puts 'trans ' + classAttr + ' to ' + which
  	end
  end
  
  # make links of bold/italics (after span processing!!!)
  if @italics and @bold
	  (doc.css('i') + doc.css('b')).each do |elem|
		elem.content = "[[#{elem.content}]]" 
	  end  
  elsif @italics # just italics
	  doc.css('i').each do |elem|
		elem.content = "[[#{deBumpy(elem.content)}]]" 
	  end
  elsif @bold #just bold
	  doc.css('b').each do |elem|
		elem.content = "[[#{deBumpy(elem.content)}]]" 
	  end
  end
  
  # apply styles to paragraphs
  doc.css('p').each do |elem|
  	classAttr = elem.attr("class")
  	which = @paragraphStyles[classAttr]
  	if which != nil
  		elem.content = doc.create_element(which, elem.content)
#  		puts 'trans ' + classAttr + ' to ' + which
  	end
  end
  
  #handle list items if flattening
  if @flatten
  	doc.css('li').each do |elem|
  		elem.replace doc.create_element('p', elem.content)
  	end
  end
  
  # create the wiki story from all the paragraphs
  # special processing for images
  story = []
  doc.css('p').each do |elem|  
  	sawImage = false
	if elem.inner_html.to_s =~ /.*?<img.*?src="(.*?)\.(jpg|gif|png|JPG|GIF|PNG)"/  
			fullname = $1 + '.' + $2
#  			puts 'got image from inner ' + fullname
			theImage = image fullname
  			story << theImage unless theImage == nil
  			sawImage = true
  	elsif
		elem.content.to_s =~ /.*?<img.*?src="(.*?)\.(jpg|gif|png|JPG|GIF|PNG)"/  
			fullname = $1 + '.' + $2
#  			puts 'got image from content ' + fullname
			theImage = image fullname
  			story << theImage unless theImage == nil
  			sawImage = true
  	end
  	if !sawImage
  		newPara = clean(elem.inner_html).strip
		if newPara != nil and newPara != ""
			story << (paragraph newPara) 
		end
	else
		newPara = cleanImages(elem).strip
		if newPara != nil and newPara != ""
			story << (paragraph newPara)
		end
	end
	
  end
  
  journal = [create title]  
  if @fullJournal
  	story.each do |para|
		journal << {
			'type' => 'add',
			'id' => para['id'],
			'item' => para
		}
	end
  	pageWithJournal title, story, journal
  else
  	page title, story
  end
  
  
  # update the summary
  @summary << paragraph("[[#{title}]]")
end

def summarize
  if @fullJournal
  	summaryJournal = [create "Index of " + @sumaryTitle]
  	@summary.each do |para|
  	summaryJournal << {
  		'type' => 'add',
  		'id' => para['id'],
  		'item' => para
  		}  	
  	end
  	pageWithJournal "Index of " + @sumaryTitle, @summary, summaryJournal
  else
  	page "Index of " + @sumaryTitle, @summary
  end
end

def warn s
	puts "#######  " + s
end

def numberOfWords title
	ct = 0
	title.each_byte do |c|
		ct +=1 if c.chr.downcase != c.chr
	end
	return ct
end

#############
@flatten = true
@fullJournal = false
@summary = []
@bold = false
@italics = false
@sumaryTitle = nil
@deBump = false
@capturePageTitle = false
@imageBase = "./originals/"

for i in 0...ARGV.length 
	if ARGV[i] == '-b'
		@bold = true
	elsif ARGV[i] == '-d'
		@deBump = true
	elsif ARGV[i] == '-p'
		@capturePageTitle = true
	elsif ARGV[i] == '-j'
		@fullJournal = true
	elsif ARGV[i] == '-f'
		@flatten = false
	elsif ARGV[i] == '-i'
		@italics = true
	elsif ARGV[i] == '-t'
		@sumaryTitle = ARGV[i+1]
	elsif ARGV[i] == '-h'
		puts '-b to transform bold to wiki link'
		puts "-d transform BumpyWords into space seperated phrases. e.g. Bumpy Words"
		puts '-f to prevent flattening of lists'
		puts '-i to transform italic to wiki link'
		puts '-j to produce a full journal in the output files'
		puts '-p to capture the html page title as a paragraph'
		puts '-t \'name\' to produce a summary with given suffix'
		puts '-h produces this text'
		exit
	end
end


Dir.glob('originals/*.html').each do |filename|
  File.open(filename) do |file|
    title = filename.gsub(/originals\//,'').gsub(/\.html/,'').gsub(/([a-z])([A-Z])/,'\1 \2')
    doc = Nokogiri::XML(file)
    if numberOfWords(title) <= 1
    	warn '"' + title + '"' + " is a single word or has no caps. Consider multi-word titles."
    end
    convert title, doc
  end
end

if @sumaryTitle != nil
	summarize
end