class StoryController < ApplicationController
  before_filter :display_notice, :except => :story5

  def story1
  end

  def story2
  end

  def story3
  end

  def story4
  end

  def story5
  end

  def story6
  end

  def story7
  end

  def storyend
  end

  def kill_story_notice
    session[:kill_story_notice] = true
    redirect_to :back
  end

  private

  def display_notice
    unless session[:kill_story_notice]
      flash[:warning] = "Note:  I wrote this before my DUNKdeadline of March 1, 2013.  #{view_context.link_to("     I get it.  don't show this again.", story_kill_story_notice_path)}".html_safe
    end 
  end

end
