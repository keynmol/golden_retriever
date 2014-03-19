require 'mongoid'
require 'active_support/inflections'
require "golden_retriever/shingler"

module GoldenRetriever
	class Document
		include ::Mongoid::Document
		include Shingler::Document

		field :__collection_id, type: String
		field :weights

		def self.textual_attributes
			@__textual_fields
		end

		def self.textual(*fields)
			(@__textual_fields=fields).each { |field_name|
				field_name=field_name.to_s
				field (field_name+"_source").to_sym, type: String
				field field_name.to_sym, type: Array
				field (field_name+"_weights").to_sym, type: Hash

				self.send(:define_method, (field_name+"_source=").to_sym) {|str|
					self.send("#{field_name}=".to_sym, filter_words(tokenize(prepare_text(str))).map{|w| stem(w)}) 
					super(str)
				}
			}
		end

		def filter_words(text)
			self.class.filter_words(text, self)
		end

		def self.filter_words(text, instance)
			@__filters.nil? ? text : @__filters.reduce(text){|memo,obj| memo=obj.filter(memo, instance, text)}
		end

		def self.id_field
			:_id #TODO: generalize
		end

		def id
			_id
		end

		def self.stopwords(list)

		end

		def self.stem(word)
			@__stemmer.nil? ? word : @__stemmer.stem(word)
		end
		def stem(word)
			self.class.stem(word)
		end

		def self.tokenize(str)
			@__tokenizer.tokenize(str)
		end

		def tokenize(str)
			self.class.tokenize(str)
		end

		def prepare_text(str)
			self.class.prepare_text(str,self)
		end

		def self.prepare_text(str, instance)
			@__conversions.nil? ? str : @__conversions.reduce(str){|memo,obj| memo=obj.convert(memo, instance, str)}
		end

		def self.word_token(regex)
			@__tokenizer=Tokenizers::RegexTokenizer.new(regex)
		end

		def self.from_source(values)
			non_textual_values=values.select{|k,v| ! @__textual_fields.include?(k)}
			d=self.new(non_textual_values)
			textual_values=Hash[(values.keys.map(&:to_sym) & @__textual_fields).collect {|field_name| [(field_name.to_s+"_source").to_sym, values[field_name]]}]
			textual_values.each {|k,v|
				d.send("#{k}=".to_sym,v)
			}
			d
		end

		def self.stemming(type, options={})
			@__stemmer="GoldenRetriever::Stemmers::#{type.to_s.camelize}".constantize.new(options)

			if options[:keep_forms]
				@__stemming_keep_forms=true
			end
		end

		def self.filter(type, options={})			
			if type.is_a?(Symbol) 
				filter_class="GoldenRetriever::TextFilters::#{type.to_s.camelize}".constantize			
			elsif type.is_a?(Class)
				filter_class=type
			end

			@__filters||=[]
			@__filters<<filter_class.new(options)
		end

		def self.conversion(type, options={})
			if type.is_a?(Symbol) 
				conversion_class="GoldenRetriever::TextConversions::#{type.to_s.camelize}".constantize
			elsif type.is_a?(Class)
				conversion_class=type
			end

			@__conversions||=[]
			@__conversions<<conversion_class.new(options)
		end


		def words
			self.class.textual_attributes.reduce([]){|memo, obj| 
					ar=self.send(obj.to_sym);
					
					memo=ar.nil? ? memo : memo+ar
				}.uniq
		end

		def weight_of(word, field)
			self.send("#{field}_weights",word)
		end
	end
end