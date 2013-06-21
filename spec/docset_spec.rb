#encoding:utf-8
require 'spec_helper'
describe GoldenRetriever::Docset do
	before :all do
		@collection=Articles::Collection.new(name: "My collection",
											document_class: Articles::Article,
											word_class: Articles::Word,
											docset_class: Articles::Docset
											)
		@collection.save
		
		@collection.create_document(text: "Test word buttock maintenance", title: "Test title")
		@collection.create_document(text: "Maintenace word immense value... value again!", title: "Other title")
		@collection.create_document(text: "Maintenace word immense value... value again!", title: "Even more titles")



		@collection.rehash
	end

	after(:all) do
		@collection.documents.destroy
		@collection.words.destroy
		@collection.docsets.destroy
		@collection.destroy
	end

	it "can be created from list of document ids" do
		@docset=@collection.create_docset("Test docset", @collection.documents.map(&:id))
		@docset.documents.count.should eql(3)
	end

	it "can be created from list of document ids" do
		@docset=@collection.create_docset("Test docset", @collection.documents.map(&:id))
		@docset.documents.count.should eql(3)
	end

	it "can be created using a block selector" do
		@docset=@collection.create_docset("Test docset") {|d| d.title.length<3}
		@docset.documents.count.should eql(2)
		@docset.documents.all?{|d| d.title.length<3}.should be_true

	end
end