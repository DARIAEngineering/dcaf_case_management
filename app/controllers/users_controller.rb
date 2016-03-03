class UsersController < ApplicationController

  def add_pregnancy_case
    c = PregnancyCase.find(params[:id])
    user = User.find(params[:user_id])
    user.pregnancy_cases << pc
    redirect_to root_path
  end

  def remove_pregnancy_case
    c = PregnancyCase.find(params[:id])
    user = User.find(params[:user_id])
    user.pregnancy_cases.delete(pc)
    redirect_to root_path
  end

end
