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
		@article_class.textual_attributes.should =~ [:text, :title]
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

	it "should not stem if stemming is not specified" do
		d=@article_class.from_source(:text=>"words of words of words of thunders")

		d.text.should eql(["words","words","words","thunders"])
	end

	it "should stem if any stemmer is specified" do
		@article_class_stemmed=@article_class.clone
		
		@article_class_stemmed.class_exec {
			stemming :porter, language: "en"
		}
		d=@article_class_stemmed.from_source(:text=>"words of thunderous stemming abilities")
		d.text.should eql(["word","thunder","stem","abil"])

		@article_class_stemmed.class_exec {
			stemming :porter, language: "ru"
			word_token /([а-яА-Я\-]{3,})/i

		}
		d=@article_class_stemmed.from_source(:text=>"слова русского языка с трудом поддаются стеммингу")
		d.text.should eql(["слов", "русск", "язык", "труд", "подда", "стемминг"])

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

	it "should filter words according to specified stopwords list" do
		@article_class_stopwords=@article_class.clone
		@article_class_stopwords.class_exec {
			filter :stopwords, list: ["a", "you","is", "of"]
		}
		d=@article_class_stopwords.from_source(:text=>"What we want from you is a glimpse of compassion")		
		d.text.should_not include("a","you","is","of")
		d.text.should include("glimpse","compassion","from","want","What")
	end

	it "should allow custom filtering classes with side effects" do
		get_hashtags_filter=Class.new {
			def initialize(options)

			end

			def filter(text, instance)
				new_text=[]
				hashtags=[]
				text.each { |word|
					
					if word.start_with?("#")
						hashtags<<word[1..-1]
					else
						new_text<<word
					end
				}
				instance.hashtags=hashtags
				new_text
			end
		}
		@article_class_custom_filter=@article_class.clone
		@article_class_custom_filter.class_exec{
			word_token /([a-zA-Z\-]{3,}|\#[a-zA-Z\-]{3,})/i
			filter get_hashtags_filter
			field :hashtags
		}

		d=@article_class_custom_filter.from_source(:text => "Regular text but with #hashtags")
		d.text.should_not include("hashtags")
		d.hashtags.should eql(["hashtags"])
	end

	it "should allow custom conversion classes with side effects" do
		get_language_conversion=Class.new {
			def initialize(options)
				@percentage=options[:percentage].to_f/100
			end

			def convert(text, instance)
				# first detect the language
				english_letters=text.downcase.count("a-z").to_f/text.length
				if english_letters>@percentage
					instance.language=:en
				else
					instance.language=:ru
				end
		
				text.tr("прстклоеПРСТКЛОЕ", "prstkloePRSTKLOE")
			end
		}
		@article_class_custom_conversion=@article_class.clone
		@article_class_custom_conversion.class_exec{
			word_token /([a-zA-Z\-а-яА-Я]{3,})/i
			conversion get_language_conversion, :percentage => 50
			field :language
		}

		english_document=@article_class_custom_conversion.from_source(:text => "Regular text in english")
		english_document.language.should eql(:en)

		russian_document=@article_class_custom_conversion.from_source(:text => "Просто стекло")
		russian_document.language.should eql(:ru)
		russian_document.text.should_not include("стекло", "Просто")

	end

	it "should provide URLs removing conversion" do
		@article_class_remove_url=@article_class.clone
		@article_class_remove_url.class_exec{
			conversion :remove_hyperlinks
		}
		d=@article_class_remove_url.from_source(:text => "http://google.ru word")
		d.text.should eql(["word"])
	end

end