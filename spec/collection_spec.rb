#encoding:utf-8
require 'spec_helper'
describe GoldenRetriever::Collection do
	before :all do
		@collection=Articles::Collection.new(name: "My collection",
											document_class: Articles::Article,
											word_class: Articles::Word,
											docset_class: Articles::Docset
											)
		@collection.save
		
		@document_1=@collection.create_document(text: "Test word buttock maintenance", title: "Test title")
		@document_2=@collection.create_document(text: "Maintenace word immense value... value again!", title: "Other title")

		@collection.rehash
		@document_1.reload
		@document_2.reload
	end

	after(:all) do
		@collection.documents.destroy
		@collection.words.destroy
		@collection.destroy
	end

	it "should return created documents" do
		@document_1.should be_a_kind_of(Articles::Article)
		@document_2.should be_a_kind_of(Articles::Article)
	end

	it "should create documents of appropriate class" do
		@collection.documents.all? {|d| d.class == Articles::Article}.should be_true
	end

	it "should maintain list of documents" do
		@collection.documents.map(&:title_source).should =~ ["Test title", "Other title"]
		@collection.documents.map(&:text_source).should =~ ["Test word buttock maintenance", "Maintenace word immense value... value again!"]
	end

	it "should create save all uniq words from documents" do
		@collection.words.count.should eql(10)
		@collection.words.map(&:lemm).should =~ ["again", "buttock", "immens", "mainten", "maintenac", "other", "test", "titl", "valu", "word"]
	end 


	it "should weight documents in collection accordingly" do
		
		@document_1.text_weights.should_not be_nil
		@document_1.title_weights.should_not be_nil

		@document_1.weights.should_not be_nil
		@document_2.weights.should_not be_nil

		@document_1.weights.keys.should =~ @document_1.words
		@document_2.weights.keys.should =~ @document_2.words

	end

end