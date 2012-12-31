#!/usr/bin/env ruby
require 'google_search'

searches = {
	%w{
		fly.thruhere.net
		forsakenplanet.tk
	} => %w{
		forsaken
		forsaken+game
		game+forsaken
		forsaken+acclaim
		acclaim+forsaken
		linux+game
		game+linux
	},
	%w{
		fly.thruhere.net
	} => %w{
		source+port 
	}
}

def log url, link, page, query
	puts "#{url} link #{link} page #{page} in #{query}"
end

searches.each do |urls,queries|
	queries.each do |query|
		$stderr.puts "\tSearching for #{query}"
		urls_left = urls.dup
		all_links = []
		GoogleSearch.paginate(query) do |page,links|
			all_links += links
			links.each do |link|
				urls_left.each do |url|
					next unless link.href =~ /#{url}/
					urls_left.delete url
					index = all_links.index( link ) + 1
					log url, index, page, query
				end
			end
			urls_left.length > 0
		end
		urls_left.each do |url|
			log url, -1, -1, query
		end
	end
end
