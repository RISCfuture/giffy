# @abstract
#
# Abstract superclass for all Giffy mailers.

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@giffy.pro'
  layout 'mailer'
end
