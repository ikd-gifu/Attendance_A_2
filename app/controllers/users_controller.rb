class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :index, :users_at_work, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show

  def index
    @users = User.paginate(page: params[:page])
  end

  #CSVインポート
  def import
    if params[:file].blank?
      flash[:danger] = "インポートするCSVファイルを選択してください。"
      redirect_to users_url
    elsif
      File.extname(params[:file].original_filename) != ".csv"
      flash[:danger] = "csvファイルのみ読み込み可能です。"
      redirect_to users_url
    else
      User.import(params[:file])
      flash[:success] = "CSVファイルをインポートしました。"
      redirect_to users_url
    end
  end
  
  def show
    # @selected = User.find_by(superior:true)
    if current_user.admin?
      flash[:danger] = '権限がありません'
      redirect_to root_url
    else
      @worked_sum = @attendances.where.not(started_at: nil).count
    end
  end

  def new
    @user = User.new # ユーザーオブジェクトを生成し、インスタンス変数に代入します。
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info #_user.html.erbからここへ飛ぶ　更新しフラッシュ表示　一覧に戻る
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しましたApplicationController。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  def users_at_work
    @users = User.all.includes(:attendances)
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end

    def basic_info_params
      params.require(:user).permit(:affiliation, :employee_number, :uid, :basic_time, :work_time,
                                   :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end
end
