require 'slack'

# Local cache of Slack user information, to alleviate calls to the `user.info`
# Slack API. The {.load} command loads cached user info with an API fallthrough.
#
# A cached user is invalid after one day.
#
# Properties
# ----------
#
# |            |                                                                   |
# |:-----------|:------------------------------------------------------------------|
# | `slack_id` | The Slack-assigned user ID.                                       |
# | `info`     | JSON-formatted information returned by the `user.info` Slack API. |

class User < ActiveRecord::Base
  # The length of time before cached data is invalidated.
  TTL = 1.day

  validates :slack_id,
            presence: true,
            length: {maximum: 40}

  # @return [Hash] JSON-formatted information about this Slack user.

  def info
    i = read_attribute(:info)
    i ? JSON.parse(i) : nil
  end

  # @return [true, false] If this cache entry is older than one day.

  def stale?
    updated_at < TTL.ago
  end

  # Refreshes the `info` column using the {Slack} API.

  def refresh!
    self.info = Slack.instance.user_info(slack_id).to_json
    save!
  end

  # Loads cached user info, falling through to the API otherwise.
  #
  # @param [String] slack_id A Slack-assigned user ID (not username).
  # @return [Hash] User info (see Slack API for more information).

  def self.load(slack_id)
    user = User.find_by_slack_id(slack_id)

    if user
      user.refresh! if user.stale?
      user.info
    else
      user = where(slack_id: slack_id).create_or_update!(info: Slack.instance.user_info(slack_id).to_json)
      user.info
    end
  end
end
