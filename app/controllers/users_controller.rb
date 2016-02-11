class UsersController < ApplicationController

  def add_case
    c = Case.find(params[:id])
    user = User.find(params[:user_id])
    user.cases << c
    redirect_to root_path
  end

  def remove_case
    c = Case.find(params[:id])
    user = User.find(params[:user_id])
    user.cases.delete(c)
    redirect_to root_path
  end

end
