class PledgeController < ApplicationController
  before_action :find_pregnancy, only: [:create]
  before_action :find_pledge, only: [:update]

  def create
    @pledge = @pregnancy.pledges.new(pledge_params)
    @pledge.created_by = current_user
    @pledge.save
    if @pledge.save
      redirect_to edit_pregnancy_path(@pregnancy), flash: { notice: "Saved new pledge for #{@pregnancy.patient.name}!" }
    else
      flash[:alert] = 'pledge failed to save! Please submit the pledge again.'
      redirect_to edit_pregnancy_path(@pregnancy)
    end
  end

  def update
    if @pledge.update_attributes pledge_params
      respond_to { |format| format.js }
    else
      head :bad_request
    end
  end

  private

  def pledge_params
    params.require(:pledge).permit(:pledge_type, :amount, :other_pledge_identifier, 
                                    :sent, :sent_by, :paid, :paid_date)
  end

  def find_pregnancy
    @pregnancy = Pregnancy.find params[:pregnancy_id]
  end

  def find_pledge
    find_pregnancy
    @pledge = @pregnancy.pledges.find params[:id]
  end
end
