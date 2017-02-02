# Controller for the `/giffy` command.

class GiffyController < SlackCommandController

  # Runs when `/giffy` is invoked. `params[:text]` contains the search query.
  # Spawns a {GIFSearchJob}.

  def search
    GIFSearchJob.perform_later command.to_h
    head :ok
  end
end
