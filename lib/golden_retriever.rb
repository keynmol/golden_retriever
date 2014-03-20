module GoldenRetriever
	module Options
		def allowed_option(value,list)
			if list.include?(value)
				value
			else
				list.first
			end
		end
	end
end


require "golden_retriever/version"
require "golden_retriever/document"
require "golden_retriever/collection"
require "golden_retriever/docset"
require "golden_retriever/word"
require "golden_retriever/tokenizers" 
require "golden_retriever/text_conversions"
require "golden_retriever/text_filters"
require "golden_retriever/stemmers"
require "golden_retriever/weighting"
require "golden_retriever/tools"
require "golden_retriever/shingler"
require "golden_retriever/vector_space"