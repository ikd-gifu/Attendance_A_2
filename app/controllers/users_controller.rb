class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :csv_output]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :index, :users_at_work, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: [:show, :csv_output]

  require 'csv'

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
  
  #csv出力
  def csv_output
    # @attendances = @user.attendances.where()
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    
    respond_to do |format|
      format.html
      format.csv do |csv|
        send_users_csv(@attendances)
      end
    end
  end
  
  def send_users_csv(attendances)
    bom = %w(EF BB BF).map { |e| e.hex.chr }.join # bomを作成
    
    csv_data = CSV.generate(bom) do |csv|# generateで引数にbomを渡してあげる
      header = ["日付", "出社時間", "退社時間"]
      csv << header
      @attendances.each do |attendance|
        if attendance.started_at.present? && attendance.finished_at.present?
          values = [
            l(attendance.worked_on, format: :short),
            l(attendance.started_at, format: :time),
            l(attendance.finished_at, format: :time)
          ]
        elsif attendance.started_at.present? && attendance.finished_at.blank?
          values = [
            l(attendance.worked_on, format: :short),
            l(attendance.started_at, format: :time),
            attendance.finished_at
          ]
        else
          values = [
            l(attendance.worked_on, format: :short),
            attendance.started_at,
            attendance.finished_at
          ]
        end
        csv << values
      end
    end
    send_data(csv_data, filename: "#{@user.name}の#{@first_day.month}月の承認済み勤怠情報.csv")
  end
  
  def show
    if current_user.admin?
      flash[:danger] = '権限がありません'
      redirect_to root_url
    else
      @worked_sum = @attendances.where.not(started_at: nil).count
      
      # respond_to do |format|
      #   format.html
      #   format.csv do |csv|
      #     send_posts_csv(@attendances)
      #   end
      # end
      
      if current_user.superior?
        @target_superior_user_attendances = Attendance.all.where(overtime_application_target_superior_id: params[:id])
        @overtime_application_count = @target_superior_user_attendances.where(overtime_application_status: "申請中").count
        @target_superior_user_for_change_attendances = Attendance.all.where(attendance_change_application_target_superior_id: params[:id])
        @attendance_change_application_count = @target_superior_user_for_change_attendances.where(attendance_change_application_status: "申請中").count
        
        @target_superior_user_for_affiliation_manager_approval_application_attendances = Attendance.all.where(affiliation_manager_approval_application_target_superior_id: params[:id])
        @affiliation_manager_approval_application_count = @target_superior_user_for_affiliation_manager_approval_application_attendances.where(affiliation_manager_approval_application_status: "申請中").count
        @selected_superior_users = User.where(superior: true).where.not(id: @user.id)
        @approval_attendance = @user.attendances.find_by(worked_on: params[:date])
      else
        @target_superior_user_for_affiliation_manager_approval_application_attendances = Attendance.all.where.not(affiliation_manager_approval_application_target_superior_id: nil)
        @affiliation_manager_approval_application_count = @target_superior_user_for_affiliation_manager_approval_application_attendances.where(affiliation_manager_approval_application_status: "申請中").count
        @selected_superior_users = User.where(superior: true)
        @approval_attendance = @user.attendances.find_by(worked_on: params[:date])
      end
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
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
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
      params.require(:user).permit(:affiliation, :employee_number, :uid, :basic_work_time,
                                    :designated_work_start_time, :designated_work_end_time)
    end
    
    # def send_posts_csv(attendances)
    #   csv_data = CSV.generate do |csv|
    #     column_names = %w(日付　出社時間　退社時間)
    #     csv << column_names
    #     attendances.each do |day|
    #       column_values = [
    #         day.worked_on,
    #         day.started_at,
    #         day.finished_at,
    #       ]
    #       csv << column_values
    #     end
    #   end
    #   send_data(csv_data, filename: "承認済み勤怠情報.csv")
    # end

end
