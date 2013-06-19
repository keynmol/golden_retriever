[![Build Status](https://travis-ci.org/keynmol/golden_retriever.png)](https://travis-ci.org/keynmol/golden_retriever)
# GoldenRetriever

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'golden_retriever'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install golden_retriever

## Usage

	Mongoid.load!("mongoid.yml", "test")

	class Article < GoldenRetriever::Document
		textual :text, :title
		conversion :change_case, :direction => :down
		word_token /([a-zA-Z\-]{3,})/i
	end

	article=Article.from_source(text: "Now, to begin with, I know nothing about Lorem Ipsum. But that didn't stop me from writing this utterly horrible article. Evenmore - it won't stop you from reading and enjoying it", 
								title: "On theoretical pecularities of Lorem Ipsum")

	article.text
	# => ["now", "begin", "with", "know", "nothing", "about", "lorem", "ipsum", "but", "that", "didn", "stop", "from", "writing", "this", "utterly", "horrible", "article", "evenmore", "won", "stop", "you", "from", "reading", "and", "enjoying"]


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
