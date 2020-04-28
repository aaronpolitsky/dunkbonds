class TradewizardController < ApplicationController

  before_action :load_account_and_goal 

  def new
  	@trade_survey = TradeSurvey.new
  end

  def create
  	@trade_survey = TradeSurvey.new(params[:trade_survey])

    unless @trade_survey.valid?
      flash[:error] = "Please answer each question.  <br>Yes/No<br>0-99%<br> donation >= 0 $<p>".html_safe
      if @trade_survey.errors[:likelihood_pct]
        flash[:error] = flash[:error] + "Also, that combo of % and donation would require a very large quantity.  Things get weird at the extremes.  Try lowering the % or the donation."
      end
      redirect_to new_goal_account_tradewizard_path(@goal, @account)
    else  
      liparams = @trade_survey.line_item_params(@goal.bond_face_value)

      @cart = current_or_guest_user.cart
      @line_item = @account.line_items.new(liparams)
      @line_item.max_bid_min_ask = @goal.bond_face_value  if liparams[:type_of] == "swap bid"

      respond_to do |format|
        if @line_item.save
          @cart.line_items << @line_item

          if @line_item.type_of == "swap bid"
            @bond_ask = @line_item.child
            @bond_ask.qty = liparams[:qty]
            @bond_ask.max_bid_min_ask = liparams[:max_bid_min_ask]
            
            if @bond_ask.save
              @cart.line_items << @bond_ask
              format.html {redirect_to @cart, :notice => "Based on your answers, you want to buy a swap and sell a bond.  I've added these to your cart." }
            else
              format.html { render :action => "new" }
              format.xml  { render :xml => @line_item.errors, :status => :unprocessable_entity }
            end
          else         
            format.html { redirect_to(@cart, :notice => 'Based on your answers, I added a bond bid to your cart.') }
            format.xml  { render :xml => @line_item.cart, :location => @line_item.cart }
          end
        else  
          format.html { render :action => "new" }
          format.xml  { render :xml => @line_item.errors, :status => :unprocessable_entity }
        end
      end
    end
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

  validates :is_optimistic, :presence => true, :inclusion => ["true", "false"]
  validates :likelihood_pct, :presence => true, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 99}
  validates :donation, :presence => true, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 100}
  validate :qty_would_be_too_high

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
      liparams[:max_bid_min_ask] = face * (1 - self.likelihood_pct.to_d/100)
      # liparams[:qty] = (self.donation.to_i / (face * ((self.likelihood_pct.to_d/100.0) * (self.likelihood_pct.to_d/100.0)))).to_i
    else
      liparams[:type_of] = "bond bid"
      liparams[:max_bid_min_ask] = face * (self.likelihood_pct.to_d/100.0)
      liparams[:qty] = (self.donation.to_d / (1 - self.likelihood_pct.to_d/100.0)).round
    end

    liparams
  end

  def qty_would_be_too_high
    if self.is_optimistic == "false"
      if (self.donation.to_d / (1 - self.likelihood_pct.to_d/100.0)).round > 100
        self.errors.add(:likelihood_pct, "That would require a very large quantity.  Things get weird at the extremes.  Try lowering the %")
        return false
      end
    end
    return true
  end

end
