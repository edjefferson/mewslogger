require 'csv'

class OsOpenName < ApplicationRecord
  has_one :mews_source
  has_one :mews, :through => :mews_source

  def self.import
    files = []
    Dir.foreach("imports/Data").each do |d|
      if d.end_with?("csv")
        files << d
      end
    end
    files.sort!
    ons = []
    start = false
    files.each do |f|
      puts "#{f} #{ons.count}"
      start = true if f == "TL20.csv"
      if start
        CSV.foreach("imports/Data/" + f) do |row|
          if row[-7] == "London" && (row[2].to_s.downcase.include?("mews") || (row[4] && row[4].downcase.include?("mews")))
            
            ons << {os_id: row[0],
              names_uri: row[1],
              name1: row[2],
              name1_lang: row[3],
              name2: row[4],
              name2_lang:row[5], 
              os_type: row[6], 
              local_type: row[7],
              geometry_x: row[8],
              geometry_y: row[9],
              most_detail_view_res: row[10],
              least_detail_view_res: row[11],
              mbr_xmin: row[12],
              mbr_ymin: row[13],
              mbr_xmax: row[14],
              mbr_ymax: row[15],
              postcode_district: row[16],
              postcode_district_uri: row[17],
              populated_place: row[18],
              populated_place_uri: row[19],
              populated_place_type: row[20],
              district_borough: row[21],
              district_borough_uri: row[22],
              district_borough_type:row[23], 
              county_unitary: row[24],
              county_unitary_uri: row[25],
              county_unitary_type: row[26],
              region: row[27],
              region_uri: row[28],
              country: row[29],
              country_uri: row[30],
              related_spatial_object: row[31],
              same_as_dbpedia: row[32],
              same_as_geonames: row[33],
            }
            print "#{ons.count} \r"
          end
        end
      end
    end
    self.upsert_all ons
  end

  def self.export_for_lat_lng_conversion
    CSV.open("os_names_northing_easting.csv","w") do |csv|
      self.all.each do |o|
        csv << [o.id, o.geometry_x,o.geometry_y]
      end
    end
  end

  def self.import_lat_lngs
    CSV.foreach("os_names_lat_lng.csv", headers: true) do |row|
      self.find(row["id"]).update(latitude: row["latitude"],longitude: row["longitude"])
    end
  end

end
