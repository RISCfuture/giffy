# @abstract
#
# Abstract superclass for all controllers in Giffy.

class ApplicationController < ActionController::Base
  include CurrentTemplate

  skip_forgery_protection
end
