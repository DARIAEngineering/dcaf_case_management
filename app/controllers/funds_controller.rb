class FundsController < ApplicationController
  before_action :set_fund, only: %i[ show edit update destroy ]

  # GET /funds
  def index
    @funds = Fund.all
  end

  # GET /funds/1
  def show
  end

  # GET /funds/new
  def new
    @fund = Fund.new
  end

  # GET /funds/1/edit
  def edit
  end

  # POST /funds
  def create
    @fund = Fund.new(fund_params)

    if @fund.save
      redirect_to @fund, notice: "Fund was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /funds/1
  def update
    if @fund.update(fund_params)
      redirect_to @fund, notice: "Fund was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /funds/1
  def destroy
    @fund.destroy
    redirect_to funds_url, notice: "Fund was successfully destroyed."
  end

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
