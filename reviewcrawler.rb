require 'nokogiri'
require 'open-uri'
require 'csv'


class ReviewCrawler
	attr_reader :category, :retailer, :sku, :pn, :url, :price
	def initialize(category, retailer, sku, pn, url, price)
    @category = category
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
    when 'hhgregg'
      parser.css('div.pr-snapshot-body-wrapper span')[1].text.match(/\d.+/)
    when 'home depot'
      parser.css('span[itemprop="ratingValue"]')[0].text.match(/\d.+/)
    when 'lowes'
      parser.css('span.productRating img')[0]['title'].match(/([\d.]+)/)
    when 'pcrichard'
      parser.css('div.pr-snapshot-body-wrapper span')[1].text.match(/\d.+/)
    when 'costco'
      parser.css('meta[itemprop="ratingValue"]')[0]['content'].match(/\d.\d{2}/)
    when 'sears'
      parser.css('span[itemprop="ratingValue"]')[0].text.match(/\d.+/)
    end
  end

  def rating_count_lookup
    case retailer.downcase
    when 'best buy'
      parser.css('meta[itemprop="reviewCount"]')[0]['content']
    when 'hhgregg'
      parser.css('p.pr-snapshot-average-based-on-text')[0].text.match(/\d/)
    when 'home depot'
      parser.css('span[itemprop="reviewCount"]')[0].text.match(/\d+/)
    when 'lowes'
      parser.css('span.productRating')[0].text.match(/\d+/)
    when 'pcrichard'
      parser.css('span.count')[0].text.match(/\d+/)
    when 'costco'
      parser.css('meta[itemprop="reviewCount"]')[0]['content']
    when 'sears'
      parser.css('span[itemprop="reviewCount"]')[0].text.match(/\d+/)
    end
  end

end


contents = CSV.open "reviewcrawler-input.csv", headers: true, header_converters: :symbol
contents.each do |row|

  product = ReviewCrawler.new(row[:category], row[:retailer], row[:sku], row[:pn], row[:url], row[:price])

  puts product.category, product.retailer, product.sku, product.pn, product.url, product.price, product.avg_rating, product.rating_count

  CSV.open("reviewcrawler-output.csv", 'a+', headers: true, header_converters: :symbol) do |in_file|
    in_file << [product.category, product.retailer, product.sku, product.pn, product.url, product.price, product.avg_rating, product.rating_count]
  end
end