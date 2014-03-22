module GoldenRetriever
	module Tokenizers
		class RegexTokenizer
			def initialize(regex)
				@regex=regex
			end

			def regex
				@regex
			end

			def tokenize(text)
				text.scan(/(#{@regex})/).flatten
			end
		end
	end
end