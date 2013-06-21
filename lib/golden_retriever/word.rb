module GoldenRetriever
	class Word
		include Mongoid::Document
		
		field :documents, type: Array, default: []
		field :forms, type: Hash, default: {}
		field :count, type: Integer, default: 0
		field :idf, type: Float, default: 0.0

		field :__collection_id, type: String

		field :lemm, type: String

		
	end
end
