class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick, MiniMagick, or Vips support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  # include CarrierWave::Vips

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_allowlist
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg"
  # end
  
  # Special handling for remote URLs
  def url
    # Get the raw value directly from the model for URLs
    raw_value = model.read_attribute(mounted_as)
    
    # If it starts with http, it's a remote URL - return it directly
    if raw_value.to_s.start_with?("http")
      raw_value
    # If it's a normal file upload that's been processed
    elsif file&.respond_to?(:url)
      # Make sure the URL is relative to the public folder
      file_path = super
      file_path&.gsub(/^public/, '')
    # Fallback to the raw value
    else
      raw_value
    end
  end
  
  # This prevents CarrierWave from trying to process URL-based images
  def blank?
    file.nil? && model.read_attribute(mounted_as).to_s.start_with?("http")
  end
  
  # Skip processing for URLs and return them directly
  def cache!(new_file = sanitized_file)
    if new_file.is_a?(String) && new_file.to_s.start_with?("http")
      # Don't process remote URLs
      return
    end
    super
  end
  
  def store!(new_file = sanitized_file)
    if new_file.is_a?(String) && new_file.to_s.start_with?("http")
      # Don't process remote URLs
      return
    end
    super
  end
end
