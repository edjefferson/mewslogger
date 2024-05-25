require 'nokogiri'
require 'open-uri'
require 'csv'

datapoints = []
CSV.open("streets.csv","w") do |csv|
  url = "https://www.findmystreet.co.uk/street-list"
  boroughs = "Barking And Dagenham
  Barnet
  Bexley
  Brent
  Bromley
  Camden
  City Of London
  Croydon
  Ealing
  Enfield
  Greenwich
  Hackney
  Hammersmith And Fulham
  Haringey
  Harrow
  Havering
  Hillingdon
  Hounslow
  Islington
  Kensington And Chelsea
  Kingston Upon Thames
  Lambeth
  Lewisham
  Merton
  Newham
  Redbridge
  Richmond Upon Thames
  Southwark
  Sutton
  Tower Hamlets
  Waltham Forest
  Wandsworth
  City Of Westminster".split("\n")
  boroughs = boroughs.map {|b| b.strip}
  i = 0
  #puts boroughs.inspect
  page = Nokogiri::HTML(URI.open(url))
  page.css("select#selProviders/option").select {|o| o.attr("value").to_s.length > 0}.each do |s|
    provider_name = s.inner_text.strip.gsub("&","And").gsub(" upon "," Upon ").gsub("Westminster","City Of Westminster")
    if provider_name.include?("London")
      provider_name = "City Of London"
    end
    provider_code = s.attr("value").to_s.to_i
    #puts provider_name.inspect
    if boroughs.include?(provider_name)
      puts [provider_name,provider_code].inspect
      i+=1
      purl = "https://www.findmystreet.co.uk/street-list?Street=MEWS&providerId=#{provider_code}&Town=&Sort=sd-asc&SortLanguage=ENG&PageSize=0"
      page = Nokogiri::HTML(URI.open(purl))
      page.css("table.streets-list/tbody/tr").each do |row|
        data = [provider_name, row.css("a")[0].attr("href").to_s.split("usrn=")[-1]] + row.css("td").map {|c| c.inner_text.strip}[1..-1]
        datapoints << data
        puts data.inspect
      end
    end
    #sleep 100
  end
  puts i

  uspn = {}
  CSV.foreach("eggs.csv") do |row|
    uspn[row[0]] = [row[1],row[2]]
  end

  datapoints.each do |d|
    if uspn[d[1]]
      csv << d + uspn[d[1]]
      puts (d + uspn[d[1]]).inspect
    else
      csv << d
      puts (d).inspect
    end
  end
end

