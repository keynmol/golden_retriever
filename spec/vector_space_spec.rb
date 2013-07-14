require 'spec_helper'

describe GoldenRetriever::VectorSpace do
	
	before(:all) do
		@collection=Articles::Collection.new(name: "My collection",
											document_class: Articles::Article,
											word_class: Articles::Word,
								 			docset_class: Articles::Docset
							  				)
		@collection.save

		@the_time=Time.now # USE TIMECOP ALREADY
		 
		@document_1=@collection.create_document(text: "Test word buttock maintenance", 
												title: "Test title", 
												published: @the_time,
												authority: 5
												)
		@document_2=@collection.create_document(text: "Maintenace word immense value... value again!", 
												title: "Other title",
												authority: 10, 
												published: @the_time+5.hours)

		@collection.rehash
		@document_1.reload
		@document_2.reload  
	end

	after(:all) do
		@collection.documents.destroy
		@collection.words.destroy
		@collection.destroy
	end

	it "can be created from collection" do
		@collection.vector_space.should be_a_kind_of(GoldenRetriever::VectorSpace)
	end

	it "allows selecting and ordering documents" do
		@collection.vector_space(documents: ->{ where(:authority.gt => 6) }).count.should eql(1)
	end

	it "allows adding string prefixes to words columns names" do
		@collection.vector_space(word_prefix: "word::").header.should =~ @collection.vector_space.words.map{|w| "word::"+w}
	end

	it "allows generic transformation of words column names" do
		@collection.vector_space(word_prefix: ->(word) {word.upcase} ).header.should =~ @collection.vector_space.words.map(&:upcase)
	end


	it "defaults to boolean space with all words" do
		words=@collection.words.map(&:lemm)
		vs=@collection.vector_space

		vs.words.should =~ words
		vs.boolean?.should be_true
		vs.header.should =~ vs.words

		@collection.vector_space.all? {|v| 
			v.all? {|value| [0,1].include?(value)} && v.length==words.length

		}.should be_true
	end

	it "allows selecting words" do
		@collection.vector_space(words: -> { where(:count.gt=>1) }).words.should =~ @collection.words.where(:count.gt=>1).map(&:lemm)
	end

	it "creates weighted space" do
		vs=@collection.vector_space(mode: :weighted, 
									documents: ->{ order_by(published: 1) }
									)
		vs.first.should =~ @document_1.weights.values + (vs.words - @document_1.words).map{0} #fill missing words with nils. Ugly, I know
	end

	it "adds additional fields to vectors" do
		@collection.vector_space.additional_fields.should eql([])
		@collection.vector_space(fields: [:published]).additional_fields.should =~ [:published]
		vs=@collection.vector_space(fields: [:published])

		vs.header.should=~vs.words+vs.additional_fields

		vs.all?{|d| d.length==vs.words.length+1 && d.any? {|f| f.is_a?(DateTime)} }.should be_true
	end

	it "generates valid CSVs" do
		vs=@collection.vector_space(word_prefix: "word::", fields: [:authority, :published])
		csv=vs.to_csv
		ars=CSV.parse(csv).drop(1) # drop header
		ars.should =~ vs.entries.map {|d| d.map(&:to_s)} #account for type mismatch
	end

	
end