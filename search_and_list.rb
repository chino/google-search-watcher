#!/usr/bin/env ruby
require './google_search'
puts "Usage: #{$0} search text" if ARGV.empty?
GoogleSearch.paginate(ARGV.join(' ')) do |page,offset,links|
	puts "== page #{page} ==\n"
	links.each_with_index do |link,i|
		puts "[#{offset+i+1}]\n" +
				"#{link.text}\n" +
				"-- http://google.com#{link.href}\n"
	end
end
