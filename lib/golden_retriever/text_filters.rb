module GoldenRetriever
	module TextFilters
		class Stopwords
			def initialize(options)
				@stopwords=options[:list]
				@use_source=options[:source] || false
			end
			
			def filter(words,document=nil, words_source)
				words=@use_source ? words_source : words
				words.delete_if {|word| @stopwords.include? word}
				words
			end
		end
	end
end