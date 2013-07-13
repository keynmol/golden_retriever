#encoding:utf-8
require 'spec_helper'
describe GoldenRetriever::Shingler::Document do

	before(:all) do
		@collection=Articles::Collection.new(name: "My collection",
											document_class: Articles::Article,
											word_class: Articles::Word,
											docset_class: Articles::Docset
		)
		@collection.save
		@document=@collection.create_document(text: "Maintenace word immense value... value again!", title: "Other title for shingles")
		@document_shingles=[
							%w(maintenac word immens valu),
							%w(word immens valu valu),
							%w(immens valu valu again),
							%w(other titl for shingl)
						]

	end

	after(:all) do

	end

	it "should correctly extract set of shingles from multi-fielded document" do
		@document.shingles.to_a.should =~ @document_shingles
	end

	it "should allow different types of shingle hashing" do
		@document.shingles(hashing: "md5").to_a.should =~ @document_shingles.map{|sh| Digest::MD5.hexdigest sh.join("")}
		@document.shingles(hashing: "space").to_a.should =~ @document_shingles.map{|sh| sh.join(" ")}
	end

	it "should allow specifying list of attributes to extract shingles from" do
		@document.shingles(attributes: [:text]).should_not include(%w(other titl for shingl))
		@document.shingles(attributes: [:title]).to_a.should =~ [%w(other titl for shingl)]
	end
end