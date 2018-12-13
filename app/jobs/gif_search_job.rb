require 'google'
require 'slack'

# Asynchronous job for `/giffy`.
#
# @see GiffyController#search

class GIFSearchJob < SlackCommandJob
  queue_as :default

  protected

  # Searches for a GIF using Google Image Search and posts it to the channel.
  #
  # @param [Slack::Command] command The originating Slack command. This object
  #   is used to determine the channel to post to and GIF to search for.

  def perform_command(command)
    unless check_command(command)
      command.reply text:          I18n.t('controllers.giffy.search.private_channel'),
                    response_type: 'ephemeral'
      return
    end

    image = find_gif(command)
    unless image
      command.reply text:          I18n.t('controllers.giffy.search.no_results').sample,
                    response_type: 'in_channel'
      return
    end

    result_record = GIFResult.create(command: command, image_url: image)
    send_reply command, image, result_record
  end

  private

  def find_gif(command)
    images = Google.instance.image_search(command.text)
    return nil if images.empty?

    num = [1.0/rand, images.size - 1].min
    return images[num.to_i]
  end

  def send_reply(command, image, result_record)
    command.reply response_type: 'in_channel',
                  text:          I18n.t('jobs.gif_search.text', user: command.user_name, query: command.text),
                  attachments:   [{
                      image_url:       image,
                      attachment_type: 'default',
                      fallback:        I18n.t('jobs.gif_search.fallback'),
                      callback_id:     result_record.id&.to_s || 'nil',
                      actions:         [{
                          name:    'audit_gif',
                          text:    I18n.t('jobs.gif_search.actions.delete.title'),
                          type:    'button',
                          value:   'delete',
                          style:   'danger',
                          confirm: {
                              title:        I18n.t('jobs.gif_search.actions.delete.confirm.title'),
                              text:         I18n.t('jobs.gif_search.actions.delete.confirm.text'),
                              ok_text:      I18n.t('jobs.gif_search.actions.delete.confirm.ok'),
                              dismiss_text: I18n.t('jobs.gif_search.actions.delete.confirm.dismiss')
                          }
                      }]
                  }]
  end

  def check_command(command)
    return true unless command.channel_id.start_with?('G')

    info = command.authorization.api_command('groups.list', exclude_members: true)
    return info['groups'].any? { |g| g['id'] == command.channel_id }
  end
end
