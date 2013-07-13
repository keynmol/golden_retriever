module GoldenRetriever
	module Shingler
		module Document
			def shingles(options={})
				hashing=options[:hashing] && options[:hashing].to_sym||:no
				length=options[:length] && options[:length].to_i || 4
				allowed_attributes=options[:attributes] && (self.class.textual_attributes & options[:attributes]) || self.class.textual_attributes
				shingles=Set.new

				allowed_attributes.each {|attribute|
					text=self.send(attribute)
					(0..text.size).each { |index|
						break if index+length>text.size
						words=text[index...index+length]

						shingle=case hashing
									when :space then
										words.join(' ')
									when :md5 then
										Digest::MD5.hexdigest words.join('')
									else
										words
								end
					shingles << shingle #unless shingles.include? shingle
				}
			}

			shingles
		end
	end
end
end