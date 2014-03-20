module GoldenRetriever
	class Tools
		class << self
			def dot_product(vec1,vec2)
			
			end

			def norm(vec)
				if vec.is_a?(Hash)
					Math.sqrt(vec.values.map{|w| w*w}.inject(:+))
				else
					Math.sqrt(vec.map{|w| w*w}.inject(:+))
				end
			end

			def normalise(vec)
				n=1.0/norm(vec)
				if vec.is_a?(Hash)
					vec.map{|k,v| [k,v*n]}
				else
					vec.map{|v| v*n}
				end
			end
			
			def cos(vec1,vec2)
				
			end
		end
	end
end