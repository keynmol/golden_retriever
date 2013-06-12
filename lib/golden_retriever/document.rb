require 'mongoid'

module GoldenRetriever
	class Document
		include ::Mongoid::Document

		def self.textual_attributes
			@__textual_fields
		end

		def self.textual(*fields)
			(@__textual_fields=fields).each { |field_name|
				field_name=field_name.to_s
				field (field_name+"_source").to_sym, type: String
				field field_name.to_sym, type: Array
				field ("weighted_"+field_name).to_sym, type: Hash

				# define_method((field_name+"_source=").to_sym) {}
				self.send(:define_method, (field_name+"_source=").to_sym) {|str| self.send("#{field_name}=".to_sym, tokenize(str)); super(str)}
			}
		end

		def self.tokenize(str)
			@__tokenizer.tokenize(str)
		end

		def tokenize(str)
			self.class.tokenize(str)
		end

		def self.word_token(regex)
			@__tokenizer=Tokenizers::RegexTokenizer.new(regex)
		end

		def self.from_source(values)
			values=Hash[@__textual_fields.collect {|field_name| [(field_name.to_s+"_source").to_sym, values[field_name]]}]

			d=self.new
			values.each {|k,v|
				d.send("#{k}=".to_sym,v)
			}
			d
		end

		def words
			self.class.textual_attributes.reduce([]){|memo, obj| memo+=self.send(obj.to_sym)}
		end
	end
end