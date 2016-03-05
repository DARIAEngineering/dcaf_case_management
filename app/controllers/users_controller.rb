class UsersController < ApplicationController
  def add_pregnancy
    p = Pregnancy.find(params[:id])
    user = User.find(params[:user_id])
    user.pregnancies << p
    redirect_to root_path
  end

  def remove_pregnancy
    p = Pregnancy.find(params[:id])
    user = User.find(params[:user_id])
    user.pregnancies.delete(p)
    redirect_to root_path
  end
end
