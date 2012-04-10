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

def clean text
  text.gsub(/’/,"'").gsub(/&nbsp;/,' ')
end

def shrinkWhitespace text
	text.gsub(/\s+/, ' ').gsub(/\t+/, ' ').gsub(/\n/,' ');
end

def url text
  text.gsub(/(http:\/\/)?([a-zA-Z0-9._-]+?\.(net|com|org|edu)(\/[^ )]+)?)/,'[http:\/\/\2 \2]')
end

def create title
  {'type' => 'create', 'id' => random, 'item' => {'title' => title}}
end 

def paragraph text
  {'type' => 'paragraph', 'text' => text, 'id' => random()}
end

def page title, story
  page = {'title' => title, 'story' => story, 'journal' => [create(title)]}
  File.open("../pages/#{slug(title)}", 'w') do |file| 
    file.write JSON.pretty_generate(page)
  end
end

# The main conversion routine
def convert title, doc
  puts title
  
  # transform images into manual instructions
  doc.css('img').each do |elem|  	
  		elem.replace doc.create_element('p', "Insert image: \"" + elem.attr('src') + "\" here.")
  end
  
  # anchors. local-file to wiki page refs, global-http to external refs
  doc.css('a').each do |elem|
  	if elem.content != nil and elem.content.strip.length > 0
  		if elem.attr('href').lstrip.index(".") == 0
  			elem.replace doc.create_element('text',"[[#{shrinkWhitespace(elem.content.strip)}]]")
  		else
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
  "P37" => 'i',
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
    @lists = Nokogiri::XML::NodeSet.new(doc) # empty set
  else
  	@lists = doc.css('ul') + doc.css('ol')
  end
  
  # capture these in paragraphs if not already in paragraphs
  retain = doc.css('h1') + doc.css('h2') + doc.css('h3') + doc.css('h4') + doc.css('h5') + doc.css('h6') + doc.css('pre') + doc.css('code') + doc.css('hr') + @lists + doc.css('table')
  
	  def inParagraph? node
		while node != nil and node.name != 'document' and node.name != 'p'
			node = node.parent
		end
		node != nil and node.name == 'p'
	  end
  
  retain.each do |elem|
  	if ! inParagraph?(elem)
  		elem.replace doc.create_element('p', elem)
  	end
  end
  
  # apply styles to spans
  doc.css('span').each do |elem|
  	c = elem.attr("class")
  	w = @spanStyles[c]
  	if w != nil
  		elem.content = doc.create_element(w, elem.content)
#  		puts 'trans ' + c + ' to ' + w
  	end
  end
  
  # make links of bold/italics (after span processing!!!)
  if @bold
	  doc.css('b').each do |elem|
		elem.content = "[[#{elem.content}]]" 
	  end
  end 
  if @italics
	  doc.css('i').each do |elem|
		elem.content = "[[#{elem.content}]]" 
	  end
  end
  
  # apply styles to paragraphs
  doc.css('p').each do |elem|
  	c = elem.attr("class")
  	w = @paragraphStyles[c]
  	if w != nil
  		elem.content = doc.create_element(w, elem.content)
#  		puts 'trans ' + c + ' to ' + w
  	end
  end
  
  #handle list items if flattening
  if @flatten
  	doc.css('li').each do |elem|
  		elem.replace doc.create_element('p', elem.content)
  	end
  end
  
  # create the wiki story from all the paragraphs
  story = doc.css('p').collect do |elem|
    paragraph clean(elem.inner_html)
  end
  page title, story
  
  # update the summary
  @summary << paragraph("[[#{title}]]")
end

def summarize
  page "Index of " + @sumaryTitle, @summary
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
@summary = []
@bold = false
@italics = false
@sumaryTitle = nil

for i in 0...ARGV.length 
	if ARGV[i] == '-b'
		@bold = true
	elsif ARGV[i] == '-f'
		@flatten = false
	elsif ARGV[i] == '-i'
		@italics = true
	elsif ARGV[i] == '-t'
		@sumaryTitle = ARGV[i+1]
	elsif ARGV[i] == '-h'
		puts '-b to transform bold to wiki link'
		puts '-f to prevent flattening of lists'
		puts '-i to transform italic to wiki link'
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