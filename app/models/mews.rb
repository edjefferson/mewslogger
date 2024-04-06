require 'csv'

class Mews < ApplicationRecord
  has_many :mews_sources
  has_many :os_open_names, :through => :mews_sources
  has_many :osm_features, :through => :mews_sources
  has_many :price_paid_data_points, :through => :mews_sources
  has_many :mews_boroughs
  has_many :boroughs, through: :mews_boroughs
  has_many :mews_images


  reverse_geocoded_by :lat, :lng

  def self.import_os_open_name
    OsOpenName.left_outer_joins(:mews).where(mews: {id: nil}).each do |os|

      nearest = Mews.near([os.latitude,os.longitude],0.25, units: :km)
      nearest_match = nearest[0] ? nearest.select {|n| n.name.downcase.gsub( /\W/,"").gsub("saint","st") == os.name1.downcase.gsub( /\W/,"").gsub("saint","st")}[0] : nil

      unless nearest_match
        mews = self.where(
          name: os.name1,
          lat: os.latitude,
          lng: os.longitude
        ).first_or_create
      else
        mews = nearest_match
      end

      MewsSource.where(mews_id: mews.id, os_open_name_id: os.id).first_or_create
    end
  end

  def self.import_osm_feature
    OsmFeature.left_outer_joins(:mews).where(mews: {id: nil}).each do |osm|

      nearest = Mews.near([osm.latitude,osm.longitude],0.25, units: :km)
      nearest_match = nearest[0] ? nearest.select {|n| n.name.downcase.gsub( /\W/,"").gsub("saint","st") == osm.address.downcase.gsub( /\W/,"").gsub("saint","st")}[0] : nil

      unless nearest_match
        mews = self.where(
          name: osm.address,
          lat: osm.latitude,
          lng: osm.longitude
        ).first_or_create
      else
        mews = nearest_match
      end

      MewsSource.where(mews_id: mews.id, osm_feature_id: osm.id).first_or_create
    end
  end

  def self.import_price_paid_data
    PricePaidDataPoint.left_outer_joins(:mews).where(mews: {id: nil}).each do |osm|

      nearest = Mews.near([osm.latitude,osm.longitude],0.25, units: :km)
      nearest_match = nearest[0] ? nearest.select {|n| n.name.downcase.gsub( /\W/,"").gsub("saint","st") == osm.address.downcase.gsub( /\W/,"").gsub("saint","st")}[0] : nil

      unless nearest_match
        mews = self.where(
          name: osm.address.titleize,
          lat: osm.latitude,
          lng: osm.longitude
        ).first_or_create
      else
        mews = nearest_match
      end

      MewsSource.where(mews_id: mews.id, price_paid_data_point_id: osm.id).first_or_create
    end
  end

  def self.export_all
    CSV.open("mews_export.csv","w") do |csv|
      Mews.order(:id).includes(:boroughs).each do |m|
        #nearby = m.nearbys(0.25, units: :km)[0]
        #nearby_d = nearby ? m.distance_from([nearby.lat,nearby.lng]) : nil
        csv << [m.id, m.name, m.lat,m.lng, m.boroughs.map {|b| b.name}.join(", ")]
      end
    end
  end

  def self.import_update
    CSV.foreach("mews_update2.csv", headers: true) do |row|
      if row["new_id"]
        if row["id"] != row["new_id"]
          MewsSource.where(mews_id: row["id"]).update(mews_id: row["new_id"])
          Mews.find(row["id"]).delete
        else
          mews = Mews.find(row["id"])
          mews.update(name: row["new_name"], alt_name: row["alt_name"])
        end
      end
    end
  end

  def self.actual_mews_import
    CSV.foreach("actual_mews.csv", headers: true) do |row|
      mews = Mews.find(row["id"])

      if mews
        mews.update(actual_mews: row["Actual mews"])
      end
    end
  end

  def self.group_mews(old_id,new_id)
    mews = Mews.find(old_id)
    sources = MewsSource.where(mews_id: old_id)
    boroughs = mews.mews_boroughs
    if sources[0]
      sources.update(mews_id: new_id)
    end

    if boroughs[0]
      boroughs.each do |b|
        unless MewsBorough.find_by(mews_id: new_id, borough_id: b.borough_id) 
          b.update(mews_id: b.mews_id)
        else
          b.delete
        end
      end
    end
    Mews.find(old_id).delete
  end

  
end
