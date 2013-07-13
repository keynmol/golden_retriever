module GoldenRetriever
	module Weighting
		class WrongWeightingType<Exception; end
		
		class TfIdf
			def initialize(options)
				@bm25=(options[:type]=="bm25")
				options[:type]||="ntn"
				@pass_maxtf=false
				@pass_averagetf=false
				if !@bm25
					raise WrongWeightingType if options[:type].length!=3
					
					@term_frequency=case options[:type][0]
										when "n" then :natural
										when "l" then :log
										when "a" then begin @pass_maxtf=true; :augmented end
										when "b" then :boolean
										when "L" then begin @pass_averagetf=true; :log_average end
									end

					@document_frequency=case options[:type][1]
											when "n" then :none
											when "t" then :idf
											when "p" then :prob_idf
										end
					@normalization = case options[:type][2]
										when "n" then :none
										when "c" then :cosine
									end
					
					@term_frequency=method (@term_frequency.to_s+"_tf").to_sym
					@document_frequency=method (@document_frequency.to_s+"_df").to_sym
					@normalization=method (@normalization.to_s+"_norm").to_sym

				end
			end

			def weight(text, document_freqs, collection_size)
				unless @bm25
					hist_tf=Hash.new(0)
					text.map {|word| hist_tf[word]+=1}
					max_tf=hist_tf.values.max
					average_tf=hist_tf.values.inject(:+).to_f/hist_tf.length
					if @pass_maxtf || @pass_averagetf
						additional=@pass_maxtf ? max_tf : average_tf
						weights=Hash[hist_tf.map {|word, tf| [word, @term_frequency.call(tf, additional) * @document_frequency.call(document_freqs[word],collection_size)]}]
					else
						weights=Hash[hist_tf.map {|word, tf| [word,@term_frequency.call(tf) * @document_frequency.call(document_freqs[word],collection_size)]}]
					end
				end

				@normalization.call(weights)

			end

			def natural_tf(tf)
				tf
			end

			def log_tf(tf)
				Math.log(tf)
			end

			def augmented_tf(tf, maxtf)
				0.5 + (0.5*tf)/maxtf
			end

			def boolean_tf(tf)
				tf > 0 ? 1 : 0
			end

			def log_average_tf(tf,averagetf)
				(1+Math.log(tf))/(1+Math.log(averagetf))
			end

			def none_df(df, collection_size)
				1
			end

			def idf_df(df,collection_size)
				Math.log(collection_size.to_f/df)
			end

			def prob_idf(df,collection_size)
				[0,Math.log((collection_size-df).to_f/df)]
			end

			def cosine_norm(weights)
				if weights.size>0
					norm=1/Math.sqrt(weights.values.map{|w| w*w}.inject(:+))
					Hash[weights.map{|k,v| [k,v*norm]}]
				else
					{}
				end
			end

			def none_norm(weights)
				weights
			end
		end
	end
end