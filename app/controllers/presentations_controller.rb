class PresentationsController < ApplicationController
  # GET /presentations/1
  def show
    converted = ConvertedPresentation.find_by(presentation_id: params[:id])

    part_of_path = converted.file_name.split("_")
    basic_path = "results/#{part_of_path[0]}/#{part_of_path[1]}"

    @images = []
    converted.pages.times do |i|
      @images << "#{request.host}/#{basic_path}/#{converted.file_name}_#{i+1}.jpg"
    end

    render "show.json.jbuilder"
  end

  # GET /presentations/new
  def new
    @presentation = Presentation.new
  end

  # POST /presentations
  def create
    presentation_param = presentation_params
    @presentation = Presentation.new(presentation_param.except(:file))

    begin
      ActiveRecord::Base.transaction do
        file_name, pages = save_presentation_file(@presentation.title, presentation_param[:file], @presentation.user_id)

        @presentation.save!
        
        @converted = ConvertedPresentation.new(presentation_id: @presentation.id,
                                               file_name: file_name,
                                               pages: pages)
        @converted.save!
      end
    rescue
      @error = $!.to_s
      render "fail.json.jbuilder"
    else
      render "create.json.jbuilder"
    end
  end



  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def presentation_params
    params.require(:presentation).permit(:user_id, :title, :file)
  end

  def save_presentation_file(title, source_file, user_id)
    raise "Need file." if source_file.nil?

    extention    = source_file.original_filename.match(/\.(pdf|odp|ppt|pptx)/).to_s
    content_type = source_file.content_type

    raise "Only pdf, odp, ppt, pptx." unless available_file_content_type(content_type)

    user_id ||= "sample" # for test

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    source_file_name = "#{user_id}_#{timestamp}#{extention}"
    source_file_path = "#{Rails.root}/tmp/sources/#{source_file_name}"

    # 파일 저장
    File.open(source_file_path, 'wb') do |file|
      file.write(source_file.read)
    end

    # 파일 변환
    result_file_path = get_result_file_path(user_id, timestamp)
    Docsplit.extract_images(source_file_path, format: [:jpg], output: result_file_path)

    pages = Dir["#{result_file_path}/*"].count

    # 파일 업로드
    title = "#{title}_#{timestamp}"
    upload_source_file_to_google_drive(user_id, title, source_file_path, content_type)

    return source_file_name, pages
  end

  def available_file_content_type(content_type)
    available_content_type = [
      "application/vnd.ms-powerpoint",
      "application/mspowerpoint",
      "application/ms-powerpoint",
      "application/mspowerpnt",
      "application/vnd-mspowerpoint",
      "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      "application/vnd.oasis.opendocument.presentation",
      "application/x-vnd.oasis.opendocument.presentation",
      "application/pdf",
      "application/x-pdf",
      "application/acrobat",
      "applications/vnd.pdf",
      "text/pdf",
      "text/x-pdf"
    ]

    available_content_type.include? content_type
  end

  # 유저 모델이 구현되면 수정 필요
  # 현재는 돌아가지 않는 코드
  def upload_file_to_google_drive(user_id, title, file_path, content_type)
    # user = User.find(user_id)
    # access_token  = user.access_token
    # refresh_token = user.refresh_token
    # expires_in    = user.expires_in

    client = Google::APIClient.new
    client.authorization.update_token!({
      access_token: access_token,
      refresh_token: refresh_token,
      expires_in: expires_in
    })

    client.authorization.fetch_access_token! if client.authorization.refresh_token && client.authorization.expired?

    drive = client.discovered_api('drive', 'v2')

    file = drive.files.insert.request_schema.new({
      'title' => title,
      'description' => '',
      'mimeType' => content_type
    })

    media = Google::APIClient::UploadIO.new(file_path, content_type)
    result = client.execute(
      :api_method => drive.files.insert,
      :body_object => file,
      :media => media,
      :parameters => {
        'uploadType' => 'multipart',
        'alt' => 'json'
      }
    )
  end

  def get_result_file_path(user_id, timestamp)
    result_file_path = "#{Rails.root}/public/results/#{user_id}"
    Dir.mkdir(result_file_path) unless File.exists?(result_file_path)

    result_file_path <<= "/#{timestamp}"
    Dir.mkdir(result_file_path)

    puts result_file_path

    result_file_path
  end
end
