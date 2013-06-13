require 'lingua/stemmer'

module GoldenRetriever
	module Stemmers
		class Porter
			def initialize(options)
				@stemmer=::Lingua::Stemmer.new :language=>options[:language].to_s
			end

			def stem(text)
				@stemmer.stem(text)
			end
		end
	end
end

# if RUBY_PLATFORM != "java" then
#   require 'lingua/stemmer'

#   class String
#     @@stemmer=Lingua::Stemmer.new(language: "ru")

#     def stem
#       @@stemmer.stem(self)
#     end
#   end
# else
#   require 'stemmer'
#   Stemmable::stemmer_default_language='ru'
# end