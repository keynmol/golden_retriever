require 'csv'

module GoldenRetriever
	class VectorSpace

		include Enumerable
		include Options

		def initialize(collection,options={})
			@collection=collection      
			
			if options[:words] && options[:words].is_a?(Proc) 
				criteria=@collection.words.instance_exec(&(options[:words]))
				@words_criteria=criteria if criteria.is_a?(Mongoid::Criteria)			
			else
				@words_criteria=@collection.words
			end

			@words=@words_criteria.map(&:lemm)#.to_a

			if options[:documents] && options[:documents].is_a?(Proc) 
				criteria=@collection.documents.instance_exec(&(options[:documents]))
				@documents_criteria=criteria if criteria.is_a?(Mongoid::Criteria)			
			else
				@documents_criteria=@collection.documents
			end


			@additional_fields=options[:fields] || []

			@prefix=options[:word_prefix] || ""

			@mode=allowed_option(options[:mode], [:boolean, :weighted]) #TODO: add `count` mode
		end

		def additional_fields
			@additional_fields
		end

		def words
			@words
		end

		def boolean?
			@mode==:boolean
		end

		def weighted?
			@mode==:weighted
		end

		def header
			words_columns=case @prefix
							when "" then @words
							when Proc then @words.map(&@prefix)
							when String then @words.map {|w| @prefix+w}
							end
			words_columns+additional_fields
		end

		def add_document_id?
			@add_document_id
		end

 
		def each
			@documents_criteria.each{|document|
				a=Array.new(@words.length, 0)
				shared_words=(document.words & @words)
				unless shared_words.empty?
					inds=shared_words.collect {|word| @words.index(word)}
					if boolean?
						inds.each{|ind| a[ind]=1}
					elsif weighted?
						shared_words.each{|word| a[@words.index(word)]=document.weights[word]}
					end

					yield additional_fields.map{|f| document.send(f)}+a

				end
			}
		end

		def to_csv(options={})
			csv_block= ->(csv){
				csv << header
				self.each {|l| 
					csv << l
				}
			}

			if options[:file]
				CSV.open(options[:file], "w", options, &csv_block)
			else
				CSV.generate(options,&csv_block)
			end
		end
	end
end  