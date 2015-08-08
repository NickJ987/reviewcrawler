require 'nokogiri'
require 'open-uri'
require 'csv'


class ReviewCrawler
	attr_reader: :retailer, :sku, :pn, :url, :price
	def inititialize(retailer, sku, pn, url, price)
		@retailer = retailer
		@sku = sku
		@pn = pn
		@url = url
		@price = price
	end

  def parser
    @parser ||= Nokogiri::HTML(open(url))
  end


  def avg_rating
    begin
      avg_rating_lookup
    rescue
      "na"
    else
      avg_rating_lookup
    end
  end

  def rating_count
    begin
      rating_count_lookup
    rescue
      "na"
    else
      rating_count_lookup
    end
  end

private

  def avg_rating_lookup
    case retailer.downcase
    when 'best buy'
      parser.css('span.average-score')[0].text.match(/\d.+/)
    end
  end

  def rating_count_lookup
    case retailer.downcase
    when 'best buy'
      parser.css('meta[itemprop="reviewCount"]')[0]['content']
    end
  end

end


contents = CSV.open "reviewcrawler-input.csv", headers: true, header_converters: :symbol
contents.each do |row|

  product = ReviewCrawler.new(row[:retailer], row[:sku], row[:pn], row[:url], row[:price])

  puts product.retailer, product.sku, product.pn, product.url, product.price, product.avg_rating, product.rating_count

  CSV.open("reviewcrawler-output.csv", 'a+', headers: true, header_converters: :symbol) do |in_file|
    in_file << [product.retailer, product.sku, product.pn, product.url, product.price, product.avg_rating, product.rating_count]
  end
end