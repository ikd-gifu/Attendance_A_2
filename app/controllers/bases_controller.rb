class BasesController < ApplicationController
  
  def new
    @base = Base.new
  end
  
  def index
    @bases = Base.paginate(page: params[:page])
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to bases_path
    else
      render :new
    end
  end
  
  private
  
    def base_params
      params.require(:base).permit(:base_name, :attendance_type)
    end
    
end
