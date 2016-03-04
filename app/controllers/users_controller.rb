class UsersController < ApplicationController

  def add_pregnancy
    c = Pregnancy.find(params[:id])
    user = User.find(params[:user_id])
    user.pregnancies << pc
    redirect_to root_path
  end

  def remove_pregnancy
    c = Pregnancy.find(params[:id])
    user = User.find(params[:user_id])
    user.pregnancies.delete(pc)
    redirect_to root_path
  end

end
