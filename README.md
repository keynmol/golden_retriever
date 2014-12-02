[![Build Status](https://travis-ci.org/keynmol/golden_retriever.png)](https://travis-ci.org/keynmol/golden_retriever)
# GoldenRetriever

A rather simple library for various experiments in information retrieval and data mining. Being oriented on text processing, it simplifies pre-processing offering tokenization, stemming, HTML tags removal.

## Installation

Add this line to your application's Gemfile:

    gem 'golden_retriever'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install golden_retriever

## Usage examples
Below is a basic example of defining a document with different text fields, conversion and sample word token(English word longer than 3 symbols in this example)

```ruby
Mongoid.load!("mongoid.yml", "test")

class Article < GoldenRetriever::Document
    textual :text, :title
    conversion :change_case, :direction => :down
    word_token /[a-zA-Z\-]{3,}/i
end

article=Article.from_source(text: "Now, to begin with, I know nothing about Lorem Ipsum. But that didn't stop me from writing this utterly horrible article. Evenmore - it won't stop you from reading and enjoying it", 
                            title: "On theoretical pecularities of Lorem Ipsum")

article.text
# => ["now", "begin", "with", "know", "nothing", "about", "lorem", "ipsum", "but", "that", "didn", "stop", "from", "writing", "this", "utterly", "horrible", "article", "evenmore", "won", "stop", "you", "from", "reading", "and", "enjoying"]
```
    
Here's another, more sophisticated example that defines a tweet:
```ruby
class Tweet < GoldenRetriever::Document
    textual :text
    
    conversion :remove_hyperlinks, :preliminary => true
    conversion :change_case, :direction => :down

    word_token /[@\#]{0,1}[a-zA-Z\-'\_]{3,}/i

    stemming :porter, language: "en"

    filter ::ExtractHashtagsAndMentions
    filter :stopwords, list: File.open(File.join(Rails.root, "lib","stopwords.txt")) {|f| f.lines.first.split(/\s/)}

    field :published, type: DateTime
    field :hashtags, type: Array

    field :retweets, type: Integer
    field :starred, type: Integer
    field :mentions, type: Array
    field :twitter_id, type: Integer
    field :author, type: String
    field :author_name, type: String
end
```
    
which demonstrates these key features of text-processing pipeline: multiple conversions, filters(both built-in and custom with side-effects, like forming a list of mentions and hashtags), stemming and custom word-tokens(in this case we account for mentions and hashtags which can be indexed as well).

```ruby
class ExtractHashtagsAndMentions
    def initialize(options)

    end

    def filter(words, instance, words_source)
        new_text=[]
        hashtags=[]
        mentions=[]

        words_source.each_with_index { |word,i|
            
            if word.start_with?("#")
                hashtags<<word[1..-1]
            elsif word.start_with?("@")
                mentions<<word[1..-1]
            else
                new_text<<words[i]
            end
        }
        unless instance.nil?
            instance.hashtags=hashtags
            instance.mentions=mentions
        end

        new_text
    end
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
