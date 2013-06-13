module GoldenRetriever
	class Collection
		include Mongoid::Document
		
		def self.weighting(type)
			if type.is_a?(Symbol)
				@__weighting="GoldenRetriever::Weighting::#{type.to_s.camelize}".constantize.new(options)
			end
		end
	end
end
