require 'resque'
require 'google/api_client'

class PresentationConversionWorker
  @queue = :presentation_queue 
  def self.perform(source_file_path, user_id, presentation_id, timestamp)
    pages = Docsplit.extract_length(source_file_path)
    file_name = source_file_path.split('/').last.split(".").first
    converted = ConvertedPresentation.create!(presentation_id: presentation_id,
                                              file_name: file_name,
                                              total_pages: pages)

    convert_presentation(user_id, timestamp, source_file_path)

    converted.update_attributes!(status: ConvertedPresentation::COMPLETE)

    upload_source_file_to_google_drive(user_id, presentation_id, source_file_path)

  rescue => e
    puts "#{e.inspect} #{e.backtrace.first}"

  else
    puts "complete PresentationConversionWorker"
    $redis.del("presentation_mime_type:#{presentation_id}")
  end

  private

  def self.convert_presentation(user_id, timestamp, source_file_path)
    result_file_path = get_result_file_path(user_id, timestamp)
    Docsplit.extract_images(source_file_path, format: [:jpg], output: result_file_path)
  end

  # 유저 모델이 구현되면 수정 필요
  # 현재는 돌아가지 않는 코드
  def self.upload_source_file_to_google_drive(user_id, presentation_id, file_path)
    user = User.find(user_id)
    access_token  = user.access_token
    refresh_token = user.refresh_token
    expires_in    = user.expires_in

    return if user.access_token.nil?

    title = Presentation.find(presentation_id).title

    client = Google::APIClient.new
    client.authorization.update_token!({
      access_token:  access_token,
      refresh_token: refresh_token,
      expires_in:    expires_in
    })

    client.authorization.fetch_access_token! if client.authorization.refresh_token && client.authorization.expired?

    content_type = $redis.get("presentation_mime_type:#{presentation_id}")

    drive = client.discovered_api('drive', 'v2')
    file  = drive.files.insert.request_schema.new({
      'title'       => title,
      'description' => '',
      'mimeType'    => content_type
    })

    media  = Google::APIClient::UploadIO.new(file_path, content_type)
    result = client.execute(
      api_method:  drive.files.insert,
      body_object: file,
      media:       media,
      parameters: {
        'uploadType' => 'multipart',
        'alt' => 'json'
      }
    )

    puts result.data.to_hash
  end

  def self.get_result_file_path(user_id, timestamp)
    result_file_path = "#{Rails.root}/public/results/#{user_id}"
    Dir.mkdir(result_file_path) unless File.exists?(result_file_path)

    result_file_path <<= "/#{timestamp}"
    Dir.mkdir(result_file_path)

    result_file_path
  end
end
