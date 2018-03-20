require 'nokogiri'
require 'csv'
require 'uri'
require 'curb'

print "Cсылка на страницу категории: "
url_category = gets.chomp

print "Имя файла: "
file_name = gets.chomp

unless url_category =~ URI::regexp && 
	   Curl.get(url_category).status.to_i == 200
  puts "Ошибка URL!"
  exit
end

html_category = Curl.get(url_category).body_str
doc_category = Nokogiri::HTML(html_category)
data = []
links = doc_category.xpath("//a[@class='product_img_link']").map {|e| e[:href]}
links.each do |link|
  html = Curl.get(link).body_str
  doc = Nokogiri::HTML(html)
  name = doc.xpath("//h1[@class='nombre_producto']").text.strip
  image = doc.xpath("//img[@id='bigpic']").first['src']
  doc.xpath("//ul[@class='attribute_labels_lists']/li").each do |el|
    gr = el.xpath("span[@class='attribute_name']").text.strip
    price = el.xpath("span[@class='attribute_price']").text.strip
    data.push(
      name:  "#{name} #{gr}",
      price: price,
      image: image
     )
  end
end

CSV.open("#{file_name}.csv","w") do |wr|
 data.each do |el|
   wr << [el[:name], el[:price], el[:image]]
 end
end
