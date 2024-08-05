class BoardsController < ApplicationController
  before_action :set_board, only: %i[ show edit update destroy ]

  # GET /boards or /boards.json
  def index
    @boards = Board.all
  end

  # GET /boards/1 or /boards/1.json
  def show
  end

  # GET /boards/new
  def new
    @board = Board.new
  end

  # GET /boards/1/edit
  def edit
  end

  # POST /boards or /boards.json
  def create
  @board = Board.new(board_params)

  #公式ドキュメントコピペここからhttps://docs.aws.amazon.com/ja_jp/rekognition/latest/dg/faces-detect-images.html
  require 'aws-sdk-rekognition'
  credentials = Aws::Credentials.new(
    ENV['AWS_ACCESS_KEY_ID'],
    ENV['AWS_SECRET_ACCESS_KEY']
  )
  
  # bucket = 'bucket' # the bucket name without s3://
  # photo  = 'input.jpg' # the name of file
  img = "/Users/mitsuiakane/Projects/my_reiru/helloworld/app/assets/images/aab.jpg"
  client   = Aws::Rekognition::Client.new(region: ENV['AWS_REGION'],credentials: credentials)
  # client = Aws::Rekognition::Client.new(credentials: credentials)
  attrs = {
    image: {
      bytes: File.read(img)
    }
    #   s3_object: {
    #     bucket: bucket,
    #     name: photo
    #   },
    # },
    # attributes: ['ALL']
  }
  response = client.detect_faces(attrs)
  puts "Detected faces for: "
  response.face_details.each do |face_detail|
    # low  = face_detail.age_range.low
    # high = face_detail.age_range.high
    # puts "The detected face is between: #{low} and #{high} years old"
    puts "All other attributes:"
    puts "  bounding_box.width:     #{face_detail.bounding_box.width}"
    puts "  bounding_box.height:    #{face_detail.bounding_box.height}"
    puts "  bounding_box.left:      #{face_detail.bounding_box.left}"
    puts "  bounding_box.top:       #{face_detail.bounding_box.top}"
    # puts "  age.range.low:          #{face_detail.age_range.low}"
    # puts "  age.range.high:         #{face_detail.age_range.high}"
    # puts "  smile.value:            #{face_detail.smile.value}"
    # puts "  smile.confidence:       #{face_detail.smile.confidence}"
    # puts "  eyeglasses.value:       #{face_detail.eyeglasses.value}"
    # puts "  eyeglasses.confidence:  #{face_detail.eyeglasses.confidence}"
    # puts "  sunglasses.value:       #{face_detail.sunglasses.value}"
    # puts "  sunglasses.confidence:  #{face_detail.sunglasses.confidence}"
    # puts "  gender.value:           #{face_detail.gender.value}"
    # puts "  gender.confidence:      #{face_detail.gender.confidence}"
    # puts "  beard.value:            #{face_detail.beard.value}"
    # puts "  beard.confidence:       #{face_detail.beard.confidence}"
    # puts "  mustache.value:         #{face_detail.mustache.value}"
    # puts "  mustache.confidence:    #{face_detail.mustache.confidence}"
    # puts "  eyes_open.value:        #{face_detail.eyes_open.value}"
    # puts "  eyes_open.confidence:   #{face_detail.eyes_open.confidence}"
    # puts "  mouth_open.value:       #{face_detail.mouth_open.value}"
    # puts "  mouth_open.confidence:  #{face_detail.mouth_open.confidence}"
    # puts "  emotions[0].type:       #{face_detail.emotions[0].type}"
    # puts "  emotions[0].confidence: #{face_detail.emotions[0].confidence}"
    # puts "  landmarks[0].type:      #{face_detail.landmarks[0].type}"
    # puts "  landmarks[0].x:         #{face_detail.landmarks[0].x}"
    # puts "  landmarks[0].y:         #{face_detail.landmarks[0].y}"
    # puts "  pose.roll:              #{face_detail.pose.roll}"
    # puts "  pose.yaw:               #{face_detail.pose.yaw}"
    # puts "  pose.pitch:             #{face_detail.pose.pitch}"
    # puts "  quality.brightness:     #{face_detail.quality.brightness}"
    # puts "  quality.sharpness:      #{face_detail.quality.sharpness}"
    # puts "  confidence:             #{face_detail.confidence}"
    puts "------------"
    puts ""
  end
  #コピペここまで

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
        format.html { redirect_to board_url(@board), notice: "Board was successfully updated." }
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
      format.html { redirect_to boards_url, notice: "Board was successfully destroyed." }
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
