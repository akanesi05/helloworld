class AddBoardImageCacheToBoards < ActiveRecord::Migration[7.1]
  def change
    add_column :boards, :board_image_cache, :string
  end
end
