class MewsSource < ApplicationRecord
  belongs_to :mews
  belongs_to :os_open_name, optional: true
  belongs_to :osm_feature, optional: true
  belongs_to :price_paid_data_point, optional: true
end
