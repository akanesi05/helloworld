class BoardsController < ApplicationController
  before_action :set_board, only: %i[show edit update destroy]

  # GET /boards or /boards.json
  def index
    @boards = Board.all
  end

  # GET /boards/1 or /boards/1.json
  def show; end

  # GET /boards/new
  def new
    @board = Board.new
  end

  # GET /boards/1/edit
  def edit; end

  # POST /boards or /boards.json
  def create
   
    @board = Board.new(board_params)
    unless @board.save
      render :new
      
    end
    image_path = @board.image.current_path

    # 公式ドキュメントコピペここからhttps://docs.aws.amazon.com/ja_jp/rekognition/latest/dg/faces-detect-images.html
    require 'aws-sdk-rekognition'
    credentials = Aws::Credentials.new(
      ENV['AWS_ACCESS_KEY_ID'],
      ENV['AWS_SECRET_ACCESS_KEY']
    )

    # bucket = 'bucket' # the bucket name without s3://
    # photo  = 'input.jpg' # the name of file
  
    #client = Aws::Rekognition::Client.new(region: ENV['AWS_REGION'], credentials:)
    client   = Aws::Rekognition::Client.new(region: ENV['AWS_REGION'],credentials: credentials)
    attrs = {
      image: {
        bytes: File.read(image_path)
      }

    }
    image = MiniMagick::Image.open(image_path)
    image_width = image.width
    image_height = image.height
    
    response = client.detect_faces attrs
    puts 'Detected faces for: '
    response.face_details.each do |face_detail|
      puts 'All other attributes:'
      puts "  bounding_box.width:     #{face_detail.bounding_box.width}"
      puts "  bounding_box.height:    #{face_detail.bounding_box.height}"
      puts "  bounding_box.left:      #{face_detail.bounding_box.left}"
      puts "  bounding_box.top:       #{face_detail.bounding_box.top}"
    
    # コピペここまで
    #     original = MiniMagick::Image.read(File.read(img))
    image.combine_options do |edit|
      rect_x_ratio = face_detail.bounding_box.left
      rect_y_ratio = face_detail.bounding_box.top
      rect_width_ratio = face_detail.bounding_box.width
      rect_height_ratio = face_detail.bounding_box.height
  
      edit.fill('#ffffff')
      rect_x = image_width * rect_x_ratio
      rect_y = image_height * rect_y_ratio
      rect_width = rect_x + image_width * rect_width_ratio
      rect_height = rect_y + image_height * rect_height_ratio
   
      edit.draw("rectangle #{rect_x},#{rect_y},#{rect_width},#{rect_height}")
    end
  end

    image.write("./app/assets/images/result.jpg")
    File.open('./app/assets/images/result.jpg') do |file|
      @board.image = file
    end

    
    if @board.save
      redirect_to @board, notice: 'Board was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /boards/1 or /boards/1.json
  def update
    respond_to do |format|
      if @board.update(board_params)
        format.html { redirect_to board_url(@board), notice: 'Board was successfully updated.' }
        format.json { render :show, status: :ok, location: @board }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @board.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /boards/1 or /boards/1.json
  def destroy
    @board.destroy!

    respond_to do |format|
      format.html { redirect_to boards_url, notice: 'Board was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @board = Board.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def board_params
    params.require(:board).permit(:title, :board_image, :board_image_cache)
  end
end
