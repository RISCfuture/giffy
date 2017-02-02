# @abstract
#
# Abstract superclass for all Giffy models.

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
