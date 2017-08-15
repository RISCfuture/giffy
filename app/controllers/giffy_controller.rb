# Controller for the `/giffy` command.

class GiffyController < SlackCommandController

  # Runs when `/giffy` is invoked. `params[:text]` contains the search query.
  # Spawns a {GIFSearchJob}.

  def search
    # if command.channel_id.start_with?('G')
    #   render plain: t('controllers.giffy.search.private_channel')
    #   return
    # end

    GIFSearchJob.perform_later command.to_h
    head :ok
  end
end
