class MewsImage < ApplicationRecord
  mount_uploader :image, MewsImageUploader

  belongs_to :mews
end
