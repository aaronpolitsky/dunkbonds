class Admin::UsersController < ApplicationController

	before_action :authenticate_user!
	before_action :is_admin?

	def index
		@users = User.all
		@guests = User.where(:is_guest => true)
		@real_users = User.where(:is_guest => false)
		@accounts = Account.all
		@user_accounts = @accounts.group_by{|a| a.user }
	end

	def show
		@user = User.find(params[:id])
		@accounts = @user.accounts
	end
	
	private 

	def is_admin?
		unless current_user.is_admin?			
			flash[:error] = "nope."
		  redirect_to root_path 
		end
	end
end
