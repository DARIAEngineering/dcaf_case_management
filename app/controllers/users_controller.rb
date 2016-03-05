class UsersController < ApplicationController
  before_action :get_user_and_pregnancy

  def add_pregnancy
    @user.pregnancies << @pregnancy
    # @all_pregnancies = @user.pregnancies
    # redirect_to root_path
    respond_to { |format| format.js }
  end

  def remove_pregnancy
    @user.pregnancies.delete(@pregnancy)
    redirect_to root_path
  end

  private 

  def get_user_and_pregnancy
    @pregnancy = Pregnancy.find(params[:id])
    @user = User.find(params[:user_id])
  end
end
