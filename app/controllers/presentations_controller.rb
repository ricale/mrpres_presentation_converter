class PresentationsController < ApplicationController
  before_action :cors
  skip_before_action :verify_authenticity_token

  # POST /presentations
  def create
    begin
      @presentation = Presentation.find(params[:presentation_id])

      ActiveRecord::Base.transaction do
        user_id   = @presentation.user_id
        timestamp = Time.now.strftime("%Y%m%d%H%M%S")

        source_file_path = save_presentation_file(params[:file], user_id, params[:presentation_id], timestamp)

        @presentation.save!

        Resque.enqueue(PresentationConversionWorker, source_file_path, user_id, @presentation.id, timestamp)
      end
    rescue
      @success = false
      @error   = $!.to_s
      render "fail.json.jbuilder"
    else
      @success = true
      render "create.json.jbuilder"
    end
  end

  # GET /presentations/1/status
  def status
    converted = ConvertedPresentation.where(presentation_id: params[:id]).last

    if converted.nil?
      @status = nil
      @progress = nil
      @message = "Not available Presentation ID"

    else
      @status = converted.status

      case @status
      when ConvertedPresentation::COMPLETE
        @progress = 1.000

      when ConvertedPresentation::CONVERTING
        # FIXME: 유저 인덱스와 timestamp를 얻는 다른 방법 필요
        # FIXME: 혹은 결과 파일 path를 얻는 다른 방법 필요
        splited = converted.file_name.split('_')
        timestamp = splited.last.split('.').first
        user_id = splited.first

        completed = Dir[Rails.root.join('public/results/', get_result_file_path(user_id, timestamp), '*')].count { |file| File.file?(file) }
        @progress = (completed.to_f / converted.total_pages).round(3)

      when ConvertedPresentation::FAILED
        @message = "why?"
      end
    end

    render "status.json.jbuilder"
  end


  private

  def cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def save_presentation_file(source_file, user_id, presentation_id, timestamp)
    raise "Need file." if source_file.nil?

    content_type = source_file.content_type
    extention    = source_file.original_filename.match(/\.[^\.]+$/).to_s

    unless (available_file_content_type(content_type) and available_file_extention(extention))
      raise "Only pdf, odp, ppt, pptx."
    end

    $redis.set("presentation_mime_type:#{presentation_id}", content_type)

    source_file_path = "#{Rails.root}/tmp/sources/#{user_id}_#{timestamp}#{extention}"

    # 파일 저장
    File.open(source_file_path, 'wb') do |file|
      file.write(source_file.read)
    end

    source_file_path
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

  def available_file_extention(extention)
    available_extention = [".pdf", ".odp", ".ppt", ".pptx"]

    available_extention.include? extention
  end

  # duplicated
  def get_result_file_path(user_id, timestamp)
    "#{Rails.root}/public/results/#{user_id}/#{timestamp}"
  end
end
