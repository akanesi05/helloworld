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

    # 公式ドキュメントコピペここからhttps://docs.aws.amazon.com/ja_jp/rekognition/latest/dg/faces-detect-images.html
    require 'aws-sdk-rekognition'
    credentials = Aws::Credentials.new(
      ENV['AWS_ACCESS_KEY_ID'],
      ENV['AWS_SECRET_ACCESS_KEY']
    )

    # bucket = 'bucket' # the bucket name without s3://
    # photo  = 'input.jpg' # the name of file
    img = '/Users/mitsuiakane/Projects/my_reiru/helloworld/app/assets/images/aab.jpg'
    client = Aws::Rekognition::Client.new(region: ENV['AWS_REGION'], credentials:)
    # client = Aws::Rekognition::Client.new(credentials: credentials)
    attrs = {
      image: {
        bytes: File.read(img)
      }

    }
    response = client.detect_faces(attrs)
    puts 'Detected faces for: '
    response.face_details.each do |face_detail|
      puts 'All other attributes:'
      puts "  bounding_box.width:     #{face_detail.bounding_box.width}"
      puts "  bounding_box.height:    #{face_detail.bounding_box.height}"
      puts "  bounding_box.left:      #{face_detail.bounding_box.left}"
      puts "  bounding_box.top:       #{face_detail.bounding_box.top}"
    end
    # コピペここまで
    #     original = MiniMagick::Image.read(File.read(img))

    gc = MiniMagick::Draw.new

    gc.fill_opacity(0)
    gc.fill('transparent')
    gc.stroke('red')
    gc.stroke_width(3)

    # Draw rectangle
    ulx = original.columns * response.face_details.first.bounding_box.left
    uly = original.rows * response.face_details.first.bounding_box.top
    w = original.columns * response.face_details.first.bounding_box.width
    h = original.rows * response.face_details.first.bounding_box.height

    gc.rectangle(ulx, uly, ulx + w, uly + h)
    gc.draw(original)

    # new_image = original.blur_image(0.0, 10.0)
    original.write("/Users/mitsuiakane/Projects/peace/app/assets/images/result.jpg")

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
