require 'rubygems'
require 'mechanize'

class GoogleSearch
class << self

	@@agent = Mechanize.new
	def agent; @@agent; end

	def search query, start_at_result = 0 # first link is 0 not 1
		url = "https://google.com/search?q=#{query}&start=#{start_at_result}"
		page = @@agent.get url
		results = page.links.select{|l| l.href =~ %r{^/url\?q=} }
		Backoff.decrease
		results
	end

	def search_with_retry query, offset
		loop do
			begin
				return search query, offset
			rescue
				$stderr.puts "\tError while searching #{query}: #{$!}"
				Backoff.increase
			end
		end
	end

	def paginate query, offset=0
		page = 0
		loop do
			page += 1
			links = search_with_retry query, offset
			return if links.empty? # TODO some pages can be empty apparently...
			continue = yield page, offset, links
			offset += links.length
			return unless continue
		end
	end

	##
	# Maintains a backoff timer in a file between runs
	#
	
	class Backoff
	class << self
	
		@@file = File.dirname __FILE__ + "/backoff.value"
	
		def get; File.read(@@file).chomp.to_i rescue 1 end
	
		def set value
			f = File.open(@@file,'w+')
			f.puts value
			f.close
			value
		end
	
		def increase
			value = get
			value = 1 if value < 1
			value *= 2
			set value
			$stderr.puts "\tBackoff kicked in sleeping for #{value}"
			sleep value
		end
	
		def decrease
			value = get
			return unless value > 1
			value /= 2
			$stderr.puts "\tLowering backoff counter to #{value}"
			set value
		end
	
	end
	end

end
end
