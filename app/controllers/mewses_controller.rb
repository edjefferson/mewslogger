class MewsesController < ApplicationController
  skip_before_action :verify_authenticity_token

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

      },
      token: session[:_csrf_token]
    }
  end

  def update
    puts params
  end
end
