name = ARGV[0]

require './text/build/libs/text.jar'
java_import 'engine.TeXt'

# source files
path = File.dirname(__FILE__)
book = File.join(path, 'book.cls')
file = File.join(path, "#{name}.tex")

# call TeXt to convert LaTeX into Markdown
text = TeXt.process([book, file].to_java(:String))
text = text.gsub('```sample', '```')
text = text.gsub('```chapel', '```')
data = text.lines

matter = data.index{|v| v.start_with?("---")}
data.insert(matter + 1, "pdf: #{name}.pdf")

header = data.index{|v| v.start_with?("#")}
unless header.nil?
	data.insert(header + 0, '* TOC')
	data.insert(header + 1, '{:toc}')
end

# output Markdown body
File.open(sprintf('%s.md', name), mode='w') do |file|
	data.each &file.method(:puts)
end
