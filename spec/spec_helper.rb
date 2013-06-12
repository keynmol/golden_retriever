require 'rubygems'
require 'bundler/setup'

require 'golden_retriever' # and any other gems you need

RSpec.configure do |config|
  # some (optional) config here
end

  Mongoid.load!(File.expand_path(".","spec/mongoid.yml"), "test")

