auth_status = new Vue(
  el: '#auth-status'

  data:
    request: null

  computed:
    loading: ->
      !@request? || (@request.status != 'success' && @request.status != 'error')

    message: ->
      return i18next.t('auth_status.message.pending') unless @request?
      switch @request.status
        when 'success'
          i18next.t 'auth_status.message.success', team: @request.authorization.team_name
        when 'error'
          i18next.t "auth_status.message.error.#{@request.error}", defaultValue: @request.error
        else
          i18next.t 'auth_status.message.pending'

    messageClass: ->
      switch @request?.status
        when 'error'
          'bg-danger'
        when 'success'
          'bg-success'
        else
          null

  methods:
    refresh: ->
      if @request?.id
        axios.get("/authorization_requests/#{@request.id}.json").then((response) =>
          @request = response.data
          if @request.status == 'success' || @request.status == 'error'
            window.clearInterval @refreshInterval
        ).catch (error) =>
          @request.status = 'error'
          @request.error = error ? i18next.t('auth_status.message.xhr_error')
      else
        @request = JSON.parse(@$el.getAttribute('data-request'))

  mounted: ->
    @refresh()
    @refreshInterval = window.setInterval((=> @refresh()), 2000)
)

window.Vues.add auth_status
