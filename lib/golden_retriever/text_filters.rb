module GoldenRetriever
	module TextFilters
		class Stopwords
			def initialize(options)
				@stopwords=options[:list]
			end
			
			def filter(text,document=nil)
				text.delete_if {|word| @stopwords.include? word}
				text
			end
		end
	end
end