require 'csv'
class PricePaidDataPoint < ApplicationRecord
  has_one :mews_source
  has_one :mews, :through => :mews_source

  def self.import
    data = []
    CSV.foreach("price_paid_jan2024.csv") do |row|
      data << {
        postcode: row[0],
        address: row[1],
        borough: row[2],
        latitude: row[3],
        longitude: row[4]
      }
    end
    self.upsert_all(data)
  end

  def self.get_missing_lats
    PricePaidDataPoint.where("latitude = longitude").each do |pp|
      
      search = Geocoder.search("#{pp.address}, #{pp.borough}, London, UK")
      if search.first
        pp.update(latitude: search.first.coordinates[0],longitude: search.first.coordinates[1])
      end
    end
  end

  def self.export_missing_lats
    CSV.open("pp_missing_lat.csv","w") do |csv|
      PricePaidDataPoint.where(latitude: nil).each do |pp|
        csv << [pp.id,pp.postcode,pp.address,pp.borough]
      end
    end
  end

  def self.import_missing_lats
    CSV.foreach("missing_lats_pp_correct.csv") do |row|
      ppd = PricePaidDataPoint.find(row[0])
      ppd.update(latitude: row[4],longitude: row[5])
    end
  end
end
