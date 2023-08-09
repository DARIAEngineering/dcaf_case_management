class FundsController < ApplicationController
  before_action :confirm_admin_user
  before_action :confirm_data_access, only: [:edit, :update]
  before_action :set_fund, only: %i[show edit update]
  rescue_from ActiveRecord::RecordNotFound, with: -> { head :bad_request }

  # GET /funds/id
  def show
    set_fund
  end

  # GET /funds/edit
  def edit; end

  # PATCH /funds/id
  def update
    set_fund

    if @fund.update(fund_params)
      flash[:notice] = t('flash.fund_details_updated')
      redirect_to @fund
    else
      flash[:alert] = t('flash.error_saving_fund_details', error: @fund.errors.full_messages.to_sentence)
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_fund
      @fund = current_tenant
    end

    def fund_params
      params.require(:fund)
        .permit(:full_name, :site_domain, :phone)
    end
end
