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


  def self.fix_boroughs
    Mews.left_outer_joins(:boroughs).where(boroughs: {id: nil}).each do |m|
      borough = m.mews_sources.where.not(gazetteer_entry_id: nil)[0].gazetteer_entry.borough
      b = Borough.where(name: borough)
      m.boroughs << b
    end
  end
  
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

  def self.import_gazetter_entries
    GazetteerEntry.left_outer_joins(:mews).where(mews: {id: nil}).each do |osm|

      nearest = Mews.near([osm.lat,osm.lng],0.25, units: :km)
      nearest_match = nearest[0] ? nearest.select {|n| n.name.downcase.gsub( /\W/,"").gsub("saint","st") == osm.match_name.downcase.gsub( /\W/,"").gsub("saint","st")}[0] : nil

      unless nearest_match
        mews = self.where(
          name: osm.match_name.titleize,
          lat: osm.lat,
          lng: osm.lng
        ).first_or_create
      else
        mews = nearest_match
      end

      MewsSource.where(mews_id: mews.id, gazetteer_entry: osm.id).first_or_create
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
    CSV.foreach("mews_update3.csv", headers: true) do |row|
      if row["new_id"] && Mews.where(id: row["id"])[0]
        puts "egg"
        if row["id"] != row["new_id"] 
          MewsSource.where(mews_id: row["id"]).update(mews_id: row["new_id"])
          Mews.find(row["id"]).delete
        else
          mews = Mews.find(row["id"])
          mews.update(name: row["name"], alt_name: row["alt_name"])
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

  def self.mews_score
    borough_counts = {}
    boroughs_done = {}
    Mews.all.each do |m|
      m.boroughs.each do |b|
        boroughs_done[b.name] = 0 unless boroughs_done[b.name]
        borough_counts[b.name] = 0 unless borough_counts[b.name]
        borough_counts[b.name] += 1
      end
    end
    boroughs_done["Redbridge"] = 10
    boroughs_done["Kensington And Chelsea"] = 10
    puts borough_counts
    borough_remaining = borough_counts.dup

    while borough_remaining.map {|k,v| v }.sum > 0
      borough_scores = boroughs_done.map {|k,v| 
        score = v * 10/borough_counts[k]
        [k,score]
      }.sort_by{|v| v[1]}.to_h
      #puts borough_scores

      next_borough = borough_scores.select {|k,v| v == borough_scores[borough_scores.keys[0]]}.keys.sample
      if borough_remaining[next_borough] >= 10
        borough_remaining[next_borough] -= 10
        boroughs_done[next_borough] += 10
      else
        boroughs_done[next_borough] += borough_remaining[next_borough]
        borough_remaining[next_borough] = 0
      end
      puts next_borough
      #puts borough_scores
    end
  end
  
end
