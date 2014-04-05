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
        user_id   = @presentation.user_id || "Sample"
        timestamp = Time.now.strftime("%Y%m%d%H%M%S")

        source_file_path = save_presentation_file(presentation_param[:file], user_id, timestamp)

        @presentation.save!

        Resque.enqueue(PresentationConversionWorker, source_file_path, user_id, @presentation.id, timestamp)
      end
    rescue
      @error = $!.to_s
      render "fail.json.jbuilder"
    else
      render "create.json.jbuilder"
    end
  end

  # GET /presentations/1/status
  def status
    @converted = ConvertedPresentation.where(presentation_id: params[:id]).first

    case @converted.status
    when ConvertedPresentation::COMPLETE
      @progress = 1.000

    when ConvertedPresentation::CONVERTING
      # FIXME: 유저 인덱스와 timestamp를 얻는 다른 방법 필요
      # FIXME: 혹은 결과 파일 path를 얻는 다른 방법 필요
      splited = @converted.file_name.split('_')
      timestamp = splited.last.split('.').first
      user_id = splited.first

      completed = Dir[Rails.root.join('public/results/', get_result_file_path(user_id, timestamp), '*')].count { |file| File.file?(file) }
      @progress = (completed.to_f / @converted.pages).round(3)

    when ConvertedPresentation::FAILED
      @message = "why?"
    end

    render "status.json.jbuilder"
  end

  def test
    render text: "test"
  end



  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def presentation_params
    params.require(:presentation).permit(:user_id, :title, :file)
  end

  def save_presentation_file(source_file, user_id, timestamp)
    raise "Need file." if source_file.nil?

    extention = source_file.original_filename.match(/\.[^\.]+$/).to_s

    unless (available_file_content_type(source_file.content_type) and available_file_extention(extention))
      raise "Only pdf, odp, ppt, pptx."
    end

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
