class FundsController < ApplicationController
  before_action :confirm_admin_user
  before_action :confirm_data_access, only: [:edit, :update]
  before_action :set_fund, only: %i[show edit update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: -> { head :bad_request }

  # GET /funds/id
  def show
    set_fund
  end

  # GET /funds/edit
  def edit; end

  def update
    set_fund
    if @fund.update(fund_params)
      redirect_to @fund, notice: 'Fund was successfully updated.'
    else
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
