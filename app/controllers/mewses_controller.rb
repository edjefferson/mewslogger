class MewsesController < ApplicationController
  before_action :authenticate_admin!
  def index
  end
  def all_mews
    render json: {
      mewses: Mews.all.includes(:boroughs).map { |m| 
        {
          id: m.id,
          name: m.name,
          lat: m.lat,
          lng: m.lng,
          boroughs: m.boroughs.map {|b| b.name}
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
  end
end
