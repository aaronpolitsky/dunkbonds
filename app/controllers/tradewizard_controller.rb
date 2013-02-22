class TradewizardController < ApplicationController

  before_filter :load_account_and_goal 

  def new
  	@trade_survey = TradeSurvey.new
  end

  def create
  	@trade_survey = TradeSurvey.new(params[:trade_survey])
    session[:liparams] = @trade_survey.line_item_params(@goal.bond_face_value)
    flash[:notice] = "Based on those questions, I've filled in the form on the left with what you want to add to your cart."
    redirect_to (new_account_line_item_path) 
 end

  private 

  def load_account_and_goal
    if current_or_guest_user.accounts.exists?(params[:account_id])
      @account = current_or_guest_user.accounts.find(params[:account_id])  
      @goal = @account.goal
    else
      flash[:warning] = "Cut it out."
      redirect_to accounts_path
    end
  end
end

class TradeSurvey
  extend ActiveModel::Naming
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :is_optimistic, :likelihood_pct, :donation

  validates :is_optimistic, :presence => true, :inclusion => [true, false]
  validates :likelihood_pct, :presence => true, :numericality => {:greater_than => 0, :less_than_or_equal_to => 100}
  validates :donation, :presence => true, :numericality => {:greater_than => 0, :less_than_or_equal_to => 100}

  def initialize(hsh = {})
    hsh.each do |key, value|
      self.send(:"#{key}=", value)
    end
  end

  def to_key
  end

  def persisted?
    false
  end

  def line_item_params(face)
    liparams = {}

    if self.is_optimistic == "true"
      liparams[:type_of] = "swap bid"
      #set qty to nearest donation/face, so that qty*face ~= donation, then 
      # set price to qty*face*likelihood, so that we have a range of QF*(1-%) to QF*(1+(1-%))      
      liparams[:qty] = (self.donation.to_d / face).round
      liparams[:max_bid_min_ask] = face * (self.likelihood_pct.to_d/100)
      # liparams[:qty] = (self.donation.to_i / (face * ((self.likelihood_pct.to_d/100.0) * (self.likelihood_pct.to_d/100.0)))).to_i
    else
      liparams[:type_of] = "bond bid"
      liparams[:max_bid_min_ask] = face * (self.likelihood_pct.to_d/100.0)
      liparams[:qty] = (self.donation.to_d / (1 - self.likelihood_pct.to_d/100.0)).round
    end
    

    liparams
  end

end
