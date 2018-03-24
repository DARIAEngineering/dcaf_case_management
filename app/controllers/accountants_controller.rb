# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  before_action :confirm_admin_user
  before_action :find_patient, only: [:edit]

  def index
    fulfilled_pts = Patient.where(pledge_sent: true,
                                  :initial_call_date.gte => 6.months.ago)
                           .order('pledge_sent_at desc')
    @patients = Kaminari.paginate_array(fulfilled_pts)
                        .page(params[:page]).per(25)
  end

  def search
    @results = if params[:search].blank?
                 Patient.where(pledge_sent: true)
                        .search(params[:search])
                        .order('pledge_sent_at desc')
               else
                 Patient.where(pledge_sent: true)
                        .order('pledge_sent_at desc')
               end
    respond_to { |format| format.js }
  end

  def edit
    # This is a cheater method that populates the fulfillment partial into a
    # modal
    respond_to { |format| format.js }
  end

  private

  def find_patient
    @patient = Patient.find params[:id]
  end
end
