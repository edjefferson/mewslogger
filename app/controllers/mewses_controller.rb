class MewsesController < ApplicationController
  before_action :authenticate_admin!
  def index
  end
  def all_mews
    render json: {
      mewses: Mews.all.includes(:boroughs,:mews_images).map { |m| 
        {
          id: m.id,
          name: m.name,
          lat: m.lat,
          lng: m.lng,
          boroughs: m.boroughs.map {|b| b.name},
          visited: m.visited,
          visited_at: m.visited_at,
          images: m.mews_images.map {|i| i.image.thumb.url}
        }

      }
    }
  end

  def update
    puts params
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
