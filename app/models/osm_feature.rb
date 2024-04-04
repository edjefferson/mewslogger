require 'csv'
class OsmFeature < ApplicationRecord
  has_one :mews_source

  has_one :mews, :through => :mews_source

  def self.import
    data = []
    CSV.foreach("osm_jan24.csv") do |row|
      data << {
        feature_type: row[0],
        osm_id: row[1],
        address: row[2],
        latitude: row[3],
        longitude: row[4],
        borough: row[5],
        tags: row[6]
      }
    end
    self.upsert_all(data)
  end
end
