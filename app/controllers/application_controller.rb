# @abstract
#
# Abstract superclass for all controllers in Giffy.

class ApplicationController < ActionController::Base
  include CurrentTemplate
end
