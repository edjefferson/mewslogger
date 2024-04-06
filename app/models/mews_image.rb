class MewsImage < ApplicationRecord
  mount_uploader :image, MewsImageUploader
end
