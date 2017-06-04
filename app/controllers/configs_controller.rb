class ConfigsController < ApplicationController
  before_action :confirm_admin_user

  def index
    @configs = Config.all
  end

  # def create
  #   new_config = Config.new config_params
  #   new_config.created_by = current_user
  #   if new_config.save
  #     flash[:success] = 'Config created successfully'
  #     redirect_to config_path
  #   else
  #     flash[:danger] = 'Config failed to create'
  #     render 'index'
  #   end
  # end

  def update
    @config = Config.find params[:id]
    @config.config_value = format_config_params(config_params) # this is not going to work
    if @config.save
      flash[:success] = 'Config updated successfully'
      redirect_to configs_path
    else
      flash[:danger] = 'Config failed to update'
      render 'index'
    end
  end

  private

  def config_params
    params.require(:config).permit(:options)
  end

  def format_config_params(params)
    # should probably be a model method?
    formatted_options = params[:options].split(',').map(&:strip)
    { options: formatted_options }
  end
end
