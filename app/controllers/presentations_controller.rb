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
    @presentation = Presentation.new(presentation_params.except(:file))

    begin
      ActiveRecord::Base.transaction do
        file_name, pages = save_presentation_file(params[:presentation][:file], @presentation.user_id)

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

  def save_presentation_file(source_file, user_id)
    raise "Need file." if source_file.nil?

    extention = source_file.original_filename.match(/\.(pdf|odp|ppt|pptx)/).to_s

    raise "Only pdf, odp, ppt, pptx." if extention.blank?

    user_id ||= "sample"

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    source_file_name = "#{user_id}_#{timestamp}#{extention}"
    source_file_path = "#{Rails.root}/tmp/sources/#{source_file_name}"

    File.open(source_file_path, 'wb') do |file|
      file.write(source_file.read)
    end

    result_file_path = get_result_file_path(user_id, timestamp)
    Docsplit.extract_images(source_file_path, format: [:jpg], output: result_file_path)

    pages = Dir["#{result_file_path}/*"].count

    return source_file_name, pages
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
