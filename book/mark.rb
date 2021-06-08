name = ARGV[0]

require './text/build/libs/text.jar'
import 'engine.TeXt'

# source files
path = File.dirname(__FILE__)
book = File.join(path, 'book.cls')
file = File.join(path, "#{name}.tex")

# call TeXt to convert LaTeX into Markdown
text = TeXt.process([book, file].to_java(:String))

# replace EPS to SVG
text = text.gsub('.eps', '.svg')

text = text.gsub('\\hfill', '')
text = text.gsub('\\bm', '\\boldsymbol')
text = text.gsub('\\coloneqq', ':=')

data = text.lines
head = data.index{|v| v.start_with?("===")}
data.insert(head + 1, sprintf('[PDF版](%s.pdf)', name))

# output Markdown body
File.open(sprintf('%s.md', name), mode='w') do |file|
	data.each &file.method(:puts)
end
