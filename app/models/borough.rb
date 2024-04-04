
require 'csv'

class Borough < ApplicationRecord
  has_many :mews_boroughs
  has_many :mews, through: :mews_boroughs

  def self.import_mews_borough_ppd
    Mews.all.each do |mews|
      mews.price_paid_data_points.each do |ppd|
        bname = ppd.borough.titleize
        borough = Borough.where(name: bname).first_or_create
        MewsBorough.where(mews_id: mews.id, borough_id: borough.id).first_or_create
      end
    end
  end

  def self.import_mews_borough_oson
    Mews.all.each do |mews|
      mews.os_open_names.each do |ppd|
        bname = ppd.district_borough.titleize
        borough = Borough.where(name: bname).first_or_create
        MewsBorough.where(mews_id: mews.id, borough_id: borough.id).first_or_create
      end
    end
  end

  def self.import_mews_borough_osm
    Mews.all.each do |mews|
      mews.osm_features.each do |ppd|
        bname = ppd.borough.titleize
        borough = Borough.where(name: bname).first_or_create
        MewsBorough.where(mews_id: mews.id, borough_id: borough.id).first_or_create
      end
    end
  end

  def self.group_borough(old_id,new_id)

    MewsBorough.where(borough_id: old_id).each do |mb|
      unless MewsBorough.find_by(mews_id: mb.mews_id, borough_id: new_id)
        mb.update(borough_id: new_id)
      else
        mb.delete
      end
    end
    Borough.find(old_id).delete
  end

  def export_mews
    CSV.open("#{self.name}.csv","w") do |csv|
      csv << ["id","name","lat","lng"]
      self.mews.each { |m|
        csv << [m.id,m.name,m.lat,m.lng]
      }
    end
  end
end
