class BasesController < ApplicationController
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(params[:base])
    if @ubase.save
      # 保存に成功した場合は、ここに記述した処理が実行されます。
    else
      render :new
    end
  end
  
  private
  
    def base_params
      params.require(:base).permit(:base_name, :attendance_type)
    end
    
end
