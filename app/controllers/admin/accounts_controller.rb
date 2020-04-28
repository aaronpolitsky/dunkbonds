class Admin::AccountsController < ApplicationController

	before_action :authenticate_user!
	before_action :is_admin?

  def index
  	@goal_accounts = Account.all.group_by{|a| a.goal}
  end

  def show
  	@account = Account.find(params[:id])
  end

  private

	def is_admin?
		unless current_user.is_admin?			
			flash[:error] = "nope."
		  redirect_to root_path 
		end
	end
end
