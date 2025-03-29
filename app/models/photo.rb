# == Schema Information
#
# Table name: photos
#
#  id             :bigint           not null, primary key
#  caption        :text
#  comments_count :integer          default(0)
#  image          :string
#  likes_count    :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  owner_id       :bigint           not null
#
# Indexes
#
#  index_photos_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
class Photo < ApplicationRecord
  mount_uploader :image, ImageUploader

  belongs_to :owner, class_name: "User", counter_cache: true

  has_many :comments, dependent: :destroy

  has_many :likes, dependent: :destroy

  has_many :fans, through: :likes

  validates :caption, presence: true

  validates :image, presence: true

  scope :latest, -> { order(created_at: :desc) }
  
  # Helper method to get image URL regardless of storage type
  def image_url
    # For Cloudinary/remote URLs, return the raw value
    if read_attribute(:image).to_s.start_with?("http")
      read_attribute(:image)
    # For uploaded files, use CarrierWave's URL method with a prefixed slash
    elsif image.present? && image.file.present?
      # Ensure the path starts with a slash for proper routing
      path = image.url
      path.start_with?('/') ? path : "/#{path}"
    end
  end
end
