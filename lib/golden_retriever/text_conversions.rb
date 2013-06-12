require 'unicode_utils/downcase'
require 'unicode_utils/upcase'

module GoldenRetriever
	module TextConversions
		class ChangeCase
			def initialize(options)
				@direction=options[:direction] || :down

			end

			def convert(text)
				@direction==:up ? UnicodeUtils.upcase(text) : UnicodeUtils.downcase(text)
			end
		end
	end
end