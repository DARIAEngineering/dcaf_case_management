class FundsController < ApplicationController
  before_action :confirm_admin_user
  before_action :set_fund, only: %i[show edit update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: -> { head :bad_request }

  # GET /funds
  def index
    @funds = Fund.all.sort_by { |f| [f.name] }
  end

  # GET /funds/1
  def show
    @fund
  end

  def edit; end

  # PATCH/PUT /funds/1
  def update
    if @fund.update(fund_params)
      redirect_to @fund, notice: 'Fund was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy; end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fund
      @fund = Fund.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fund_params
      params.fetch(:fund, {})
    end
end
