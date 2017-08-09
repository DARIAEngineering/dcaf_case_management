class ConfigsController < ApplicationController
  before_action :confirm_admin_user

  def index
    Config.autosetup
    @configs = Config.all.sort
  end

  def update
    @config = Config.find params[:id]
    @config.config_value = format_config_params(config_params)
    if @config.save
      flash[:notice] = 'Config updated successfully'
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
    formatted_options = params[:options].split(',').map(&:strip)
    { options: formatted_options }
  end
end
