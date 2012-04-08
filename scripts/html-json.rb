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

@summary = []
@bold = false
@italics = false
@sumaryTitle = "Summary"

def convert title, doc
  puts title
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
  doc.css('img').each do |elem|  	
  		elem.replace doc.create_element('p', "Insert image: \"" + elem.attr('src') + "\" here.")
  end
  
  doc.css('a').each do |elem|
  	elem.replace doc.create_element('i', "[#{elem.attr('href')} #{elem.content}]")
  end
  
  retain = doc.css('h1') + doc.css('h2') + doc.css('h3') + doc.css('h4') + doc.css('h5') + doc.css('h6') + doc.css('pre') + doc.css('code') + doc.css('hr')
  
  retain.each do |elem|
  	elem.replace doc.create_element('p', elem)
  end
  story = doc.css('p').collect do |elem|
    paragraph clean(elem.inner_html)
  end
  page title, story
  @summary << paragraph("[[#{title}]]")
end

def summarize
  page @sumaryTitle, @summary
end

#############

for i in 0...ARGV.length 
	if ARGV[i] == '-b'
		@bold = true
	elsif ARGV[i] == '-i'
		@italics = true
	elsif ARGV[i] == '-t'
		@sumaryTitle = ARGV[i+1]
	end
end


Dir.glob('originals/*.html').each do |filename|
  File.open(filename) do |file|
    title = filename.gsub(/originals\//,'').gsub(/\.html/,'').gsub(/([a-z])([A-Z])/,'\1 \2')
    doc = Nokogiri::XML(file)
    convert title, doc
  end
end

if @sumaryTitle != nil
	summarize
end