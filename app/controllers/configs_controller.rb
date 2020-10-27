class ConfigsController < ApplicationController
  before_action :confirm_admin_user
  #rescue_from Mongoid::Errors::DocumentNotFound,
              #with: -> { redirect_to root_path }

  def index
    Config.autosetup
    @configs = Config.all.sort_by(&:config_key)
  end

  def update
    @config = Config.find params[:id]
    @config.config_value = format_config_params(config_params)
    if @config.save
      flash[:notice] = t('flash.config_update_success')
      redirect_to configs_path
    else
      error_content = @config.errors.full_messages.to_sentence
      flash[:alert] = t('flash.config_failed_update', error: error_content) unless flash[:alert]
      redirect_to configs_path
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
