name = ARGV[0]

require './text/build/libs/text.jar'
import 'engine.TeXt'

# source files
path = File.dirname(__FILE__)
book = File.join(path, 'book.cls')
file = File.join(path, "#{name}.tex")

# call TeXt to convert LaTeX into Markdown
text = TeXt.process([book, file].to_java(:String))
text = text.gsub('```sample', '```')
text = text.gsub('```chapel', '```')
data = text.lines
head = data.index{|v| v.start_with?("#")}
data.insert(head + 0, sprintf('[PDF版はこちら](%s.pdf)。', name))
data.insert(head + 1, 'このページは独自のLaTeX処理系[TeXt](https://github.com/nextzlog/book/tree/master/text)で生成されたものです。')

# output Markdown body
File.open(sprintf('%s.md', name), mode='w') do |file|
	data.each &file.method(:puts)
end
