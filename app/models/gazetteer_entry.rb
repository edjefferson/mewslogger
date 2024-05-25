require 'csv'
class GazetteerEntry < ApplicationRecord
  has_one :mews_source
  has_one :mews, :through => :mews_source
  def self.import
    CSV.foreach("streets.csv", headers: true) do |row|
      g = self.where(usrn: row["usrn"]).first_or_create
      g.update(borough: row["borough"],
      	name: row["name"],
        match_name: row["match_name"],
        address1: row["address1"],
        address2: row["address2"],
        maintenace: row["maintenace"],
        ownership: row["ownership"],
        lat: row["lat"],
        lng: row["lng"])
    end
  end
end
