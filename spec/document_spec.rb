#encoding:utf-8
require 'spec_helper'
describe GoldenRetriever::Document do
	before do
		@article_class = Class.new(GoldenRetriever::Document) do
			textual :text, :title

			word_token /([a-zA-Z\-]{3,})/i
		end

		@source_text = "A text for testing, no more lorem ipsum bullcrap."
		@source_title = "Article title"

	end

	it "should save and return list of textual attributes for a class" do
		@article_class.textual_attributes.should include(:text, :title)
		@article_class.textual_attributes.length.should eql(2)
	end

	it "should tokenize text according to regular expression" do
		d=@article_class.from_source(:text=> @source_text, :title => @source_title)

		d.text.should eql(["text","for","testing","more","lorem","ipsum","bullcrap"])
		d.title.should eql(["Article","title"])
	end

	it "should create documents from partial data" do
		d=@article_class.from_source(:text => "test data")

		d.text_source.should eql("test data")
	end

	it "should change case of the text with respect to unicode characters" do
		@article_class_downcased=@article_class.clone
		
		@article_class_downcased.class_exec {
			conversion :change_case, :direction => :down
			word_token /([а-яА-Я\-]{3,})/i
		}

		d=@article_class_downcased.from_source(:text => "ТесТОВый теКст С Разными РегиСТРАМИ")
		d.text.should eql(["тестовый","текст","разными","регистрами"])
	end

	it "should allow creating itself from source" do
		d=@article_class.from_source(:text=> @source_text, :title => @source_title)
		d.should be_a_kind_of(GoldenRetriever::Document)
	end

	it "should give access to both original text and the irified version" do
		d=@article_class.from_source(:text=> @source_text, :title => @source_title)

		d.should respond_to :text
		d.should respond_to :title
		d.should respond_to :text_source
		d.should respond_to :title_source

	end
end