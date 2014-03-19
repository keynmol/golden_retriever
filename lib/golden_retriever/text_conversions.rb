require 'unicode_utils/downcase'
require 'unicode_utils/upcase'
require 'uri'

module GoldenRetriever
	module TextConversions
		class ChangeCase
			def initialize(options)
				@direction=options[:direction] || :down

			end

			def convert(text, instance=nil)
				@direction==:up ? UnicodeUtils.upcase(text) : UnicodeUtils.downcase(text)
			end
		end

		class RemoveHyperlinks
			def initialize(options)
			end

			def convert(text, instance=nil)
				return text.gsub(URI.regexp,'')
			end
		end
	end
end