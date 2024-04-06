CarrierWave.configure do |config|
  config.cache_storage = :file
  config.root = Rails.root.join('tmp')
  config.cache_dir = 'carrierwave'
  config.sftp_host = ENV["FTP_HOST"]
  config.sftp_user = ENV["FTP_USER"]
  config.sftp_folder = ENV["FTP_FOLDER"]
  config.sftp_url = ENV["FTP_URL"]
  config.sftp_options = {
    :password => ENV["FTP_PASSWD"],
    :port     => ENV["FTP_PORT"]
  }
end