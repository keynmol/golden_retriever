require 'rubygems'
require 'bundler/setup'

require 'golden_retriever' # and any other gems you need

RSpec.configure do |config|
	# some (optional) config here
end

Mongoid.load!(File.expand_path(".","spec/mongoid.yml"), "test")

module Articles
	class Article < GoldenRetriever::Document
		textual :text, :title
		field :published, type: DateTime
		field :authority, type: Integer
		word_token /[a-zA-Z\-]{3,}/i
		stemming :porter, language: "en"		
		conversion :change_case
	end
	
	class Collection < GoldenRetriever::Collection
		weighting :tf_idf, type: "ntc", merging: ->(weights){ weights.values.max }
	end

	class Docset < GoldenRetriever::Docset
	end

	class Word < GoldenRetriever::Word
	end

end