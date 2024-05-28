class MewsesController < ApplicationController
  before_action :authenticate_admin!

  def show
    @mews = Mews.find(params[:id])
    @mews_sources = @mews.mews_sources.map { |s|
      if s.os_open_name_id
        {
          popup: "os_open_name",
          latlng: [s.os_open_name.latitude,s.os_open_name.longitude]
        }
      elsif s.osm_feature_id
        {
          popup: "OSM",
          latlng: [s.osm_feature.latitude, s.osm_feature.longitude]
        }
      elsif s.price_paid_data_point_id
        {
          popup: "price_paid_data",
          latlng: [s.price_paid_data_point.latitude, s.price_paid_data_point.longitude]

        }
      elsif s.gazetteer_entry_id
        {
          popup: "gazetteer",
          latlng: [s.gazetteer_entry.lat,s.gazetteer_entry.lng]
        }
      end
    }
  end

  def visited
    respond_to do |format|
      format.csv { send_data Mews.to_csv, filename: "mews-visited-#{DateTime.now.strftime("%d%m%Y%H%M")}.csv"}
    end
  end
   
  def all_mews
    render json: {
      mewses: Mews.all.includes(:boroughs,:mews_images).map { |m| 
        {
          id: m.id,
          name: m.name,
          lat: m.lat,
          lng: m.lng,
          notes: m.notes,
          boroughs: m.boroughs.map {|b| b.name},
          visited: m.visited,
          visited_at: m.visited_at,
          images: m.mews_images.map {|i| i.image.thumb.url}
        }

      }
    }
  end

  def update_notes
    puts params
    mews = Mews.find(params[:mews_id])
    mews.notes = params[:text]
    mews.save!
  end

  def toggle_visited
    mews = Mews.find(params[:mews_id])
    mews.visited = params[:visited]
    mews.visited_at = Time.at(params[:time_now].to_f/1000) unless mews.visited_at
    mews.save!
  end

  def upload_image
    m = MewsImage.new
    m.mews_id = params[:mews_id]
    m.image = params[:image]

    m.save!
    render json: {
      thumb_url: m.image.thumb.url
    }
  end
end
