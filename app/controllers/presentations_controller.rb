class PresentationsController < ApplicationController
  # GET /presentations/1
  def show
    converted = ConvertedPresentation.find_by(presentation_id: params[:id])

    root_url = "http://localhost:9000"
    part_of_path = converted.file_name.split("_")
    basic_path = "results/#{part_of_path[0]}/#{part_of_path[1]}"

    @images = []
    converted.pages.times do |i|
      @images << "#{root_url}/#{basic_path}/#{converted.file_name}_#{i+1}.jpg"
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

  def save_presentation_file(uploaded_file, user_id)
    unless uploaded_file.original_filename.match(/\.(pdf|odp|ppt|pptx)/)
      raise "only pdf, odp, ppt, pptx"
    end

    user_id ||= "sample"
    source_file_name = "#{user_id}_#{Time.now.strftime("%Y%m%d%H%M%S")}"
    result_file_path = "#{user_id}/#{Time.now.strftime("%Y%m%d%H%M%S")}"

    File.open(Rails.root.join('tmp', 'sources', source_file_name), 'wb') do |file|
      file.write(uploaded_file.read)
    end

    Docsplit.extract_images("#{Rails.root}/tmp/sources/#{source_file_name}",
                            format: [:jpg],
                            output: "public/results/#{result_file_path}")

    pages = Dir[Rails.root.join('public/results/', result_file_path, '*')].count { |file| File.file?(file) }

    return source_file_name, pages
  end
end
