module GoldenRetriever
	class Docset
		include Mongoid::Document
		
		field :doclist, type: Array
		field :__collection_id, type: String
		field :name, type: String

		field :document_class, type: String

		def document_class
			super.constantize
		end

		def documents
			document_class.where(:__collection_id => self.__collection_id).in(document_class.id_field => self.doclist)
		end
		
	end
end
