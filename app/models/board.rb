class Board < ApplicationRecord
  # mount_uploader :image, ImageUploader
  mount_uploader :board_image, ImageUploader
  mount_uploader :board_image, ImageUploader
 mount_uploader :image, ImageUploader
 def image_presence
  errors.add(:image, "をアップロードしてください") unless image.present?
  end

end
