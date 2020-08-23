class AttendancesController < ApplicationController
  protect_from_forgery with: :null_session
  
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_one_day_overtime_application, :update_one_day_overtime_application]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_one_day_overtime_application, :update_one_day_overtime_application]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month, :edit_one_day_overtime_application]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])

    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month #before_actionのadmin_or_correct_userに追加
    if current_user.admin?
      flash[:danger] = '権限がありません'
      redirect_to root_url
    end
  end

  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def edit_one_day_overtime_application#1日分の残業申請
    @user = User.find(params[:id])
    @selected_superior_users = User.where(superior: true).where.not(id: @user.id)
    # @day = Date.parse(params[:day])
    # @attendance = @user.attendances.find_by(params[:date])
    # @attendance = Attendance.find(params[:id])
    @attendance = Attendance.find_by(worked_on: params[:date]) #日付データ取得
    # @day = @attendance
  end

  def update_one_day_overtime_application#1日分の残業申請
    @user = User.find(params[:id])
    @attendance = Attendance.find_by(worked_on: params[:attendance][:date])
    
    if params[:attendance][:scheduled_end_time].blank?
      flash[:danger] = "終了予定時間を入力してください。"
    elsif params[:attendance][:overtime_application_target_superior_id].blank?
      flash[:danger] = "申請先上長を選択してください。"
    else
      @attendance.update_attributes(one_day_overtime_application_params)
      flash[:success] = "#{@user.name}の残業を申請しました。"
    end
    redirect_to user_url
  end

    # if @attendance.update_attributes(one_day_overtime_application_params)
    #   flash[:success] = "#{@user.name}の残業申請を更新しました。"
    # else
    #   flash[:danger] = "#{@user.name}の残業申請の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    # end
    # redirect_to user_url

  private
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :next_day])[:attendances]
    end

    #1日分の残業申請
    def one_day_overtime_application_params #モーダルのフィールドがattendanceの中にデータを入れる構造になっているためrequire(:attendance)
      params.require(:attendance).permit(:scheduled_end_time, :next_day, :business_process_content, :overtime_application_target_superior_id, :overtime_application_status)
    end

  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
     flash[:danger] = "編集権限がありません。"
     redirect_to(root_url)
    end
  end
end
