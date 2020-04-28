# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

my_date_formats = { :default => '%m/%d/%Y' } 
Time::DATE_FORMATS.merge!(my_date_formats) 
Date::DATE_FORMATS.merge!(my_date_formats)