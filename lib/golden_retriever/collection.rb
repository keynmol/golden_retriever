module GoldenRetriever
	class Collection
		include Mongoid::Document
		field :name, type: String
		field :document_class, type: String
		field :word_class, type: String
		field :docset_class, type: String

		class << self
			attr_reader :__weighting, :__weighting_merging
		end


		def initialize(*args)
			super
		end


		def self.weighting(type,options={})
			if type.is_a?(Symbol)
				@__weighting="GoldenRetriever::Weighting::#{type.to_s.camelize}".constantize.new(options)
				@__weighting_merging=options[:merging] if options[:merging]
			end
		end

		def document_class
			super.constantize
		end

		def word_class
			super.constantize
		end

		def docset_class
			super.constantize
		end

		def add_document(document)
			id=document.id
			document_words=document.words
			existing_words=self.words(document_words)
			missing_words=document_words - existing_words.map(&:lemm)

			existing_words.each {|word|
				word.documents<<id
				word.count+=1
				word.save
			}


			missing_words.each {|word|
				w=word_class.create(:lemm => word, :__collection_id => self._id, :documents=>[id], :count=>1)
				w.save
			}

			document.__collection_id=self._id.to_s
			document.save
		end

		def documents
			self.document_class.where(:__collection_id=>self._id)
		end

		def words(lemmas=nil)
			base=self.word_class.where(:__collection_id=>self._id)
			
			if lemmas
				base=base.in(:lemm=>lemmas)
			end

			base
		end


		def weighting
			self.class.__weighting
		end

		def weighting_merging
			self.class.__weighting_merging

		end

		def docsets
			docset_class.where(:__collection_id => self._id)
		end

		def rehash
			documents.each {|document|

				d_words=self.words.in(:lemm => document.words)
				freqs=Hash[d_words.map{|w| [w.lemm, w.count]}]
				
				weights={}

				words_to_merge=Hash.new {|h,k| h[k]=[]}

				partial_weights={}

				document_class.textual_attributes.each {|attr|
					attr_weights=weighting.weight(document.send(attr), freqs, documents.count)
					document.send("#{attr}_weights=".to_sym, attr_weights)
					weights.merge!(attr_weights)
					attr_weights.keys.map {|w| words_to_merge[w]<<attr}
					partial_weights[attr]=attr_weights
				}

				if weighting_merging
					words_to_merge.select{|k,v| v.length>1}.map {|w, attrs| weights[w]=weighting_merging.call(Hash[attrs.zip(attrs.collect {|attr| partial_weights[attr][w]})])}
				end

				document.weights=weights
				document.save
			}
		end

		def create_document(*args)
			d=document_class.from_source(*args)
			add_document(d)
			d
		end

		def create_docset(name, doclist=nil)
			if doclist.is_a?(Array)
				if doclist.all? {|d| d.class==document_class}
					ds=docset_class.new(name: name, document_class: document_class, __collection_id: self._id, doclist: doclist.map(&:id))
					ds.save
					return ds
				else #TODO: check if all the ids are of the same allowed type
					ds=docset_class.new(name: name, document_class: document_class, __collection_id: self._id, doclist: doclist)
					ds.save
					return ds
				end
			elsif doclist.is_a?(Mongoid::Criteria)
				ids=doclist.map(&:id) #hopefully doesn't keep all instances in memory
				create_docset(name,ids)
			elsif block_given?
				#TODO: empty docsets or not empty docsets?
				selected_documents=documents.select {|d| yield d}.map &:id
				ds=docset_class.new(name: name, document_class: document_class, __collection_id: self._id, doclist: selected_documents)
				ds.save
				return ds
			else
				raise Exception
			end

		end


	end
end
