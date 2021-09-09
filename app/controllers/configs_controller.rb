class ConfigsController < ApplicationController
  before_action :confirm_admin_user

  def index
    @configs = Config.config_keys.keys.map do |field|
      Config.find_or_create_by(config_key: field)
    end
  end

  def update
    @config = Config.find params[:id]
    @config.config_value = format_config_params(config_params)

    if @config.save
      flash[:notice] = t('flash.config_update_success')
      redirect_to configs_path
    else
      error_content = @config.errors.full_messages.to_sentence
      flash[:alert] ||= t('flash.config_failed_update', error: error_content)
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
