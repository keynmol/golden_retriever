require 'unicode_utils/downcase'
require 'unicode_utils/upcase'
require 'uri'

module GoldenRetriever
	module TextConversions
		class ChangeCase
			def initialize(options)
				@direction=options[:direction] || :down
				@use_source=options[:source] || false

			end

			def convert(text, instance=nil, text_source=nil)
				text=@use_source ? text_source : text
				@direction==:up ? UnicodeUtils.upcase(text) : UnicodeUtils.downcase(text)
			end
		end

		class RemoveHyperlinks
			def initialize(options)
				@use_source=options[:source] || false
			end

			def convert(text, instance=nil, text_source=nil)
				text=@use_source ? text_source : text				
				return text.gsub(URI.regexp,'')
			end
		end
	end
end