class ReviewCrawler
	attr_reader: :retailer, :sku, :partnumber
	def inititialize(retailer, sku, partnumber)
		@retailer = retailer
		@sku = sku
		@partnumber = partnumber
	end

  

end