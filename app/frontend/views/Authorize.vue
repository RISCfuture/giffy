<template>
  <div>
    <div class="jumbotron">
      <div v-if="!request && !error">
        <h1>{{ $t('views.authorize.jumbotron.giffy') }}</h1>
        <p>{{ $t('views.authorize.jumbotron.giffy_description') }}</p>

        <a :href="oauthURL">
          <img src="https://platform.slack-edge.com/img/add_to_slack.png"
               :alt="addToSlackAlt"
               width="139"
               height="40"
               srcset="https://platform.slack-edge.com/img/add_to_slack.png 1x, https://platform.slack-edge.com/img/add_to_slack@2x.png 2x" />
        </a>
      </div>

      <div v-else id="auth-status">
        <img v-if="request && loading" :src="loadingImageURL" width="33" height="33" classs="spinner" />
        <p :class="messageClass" v-if="message">{{ message }}</p>
      </div>

    </div>
    <help></help>
  </div>
</template>

<script>
  import axios from 'axios'
  import constants from 'config/constants.js.erb'
  import Help from 'components/Help.vue'
  import loadingImageURL from 'images/loading.svg'

  export default {
    data() {
      return {
        request: null,
        refreshInterval: null,

        oauthURL: constants.oauthURL,
        loadingImageURL
      }
    },

    components: {Help},

    computed: {
      authorizationRequestID() {
        let matches = window.location.search.match(/authorization_request_id=(\d+)/)
        return matches ? matches[1] : null
      },

      error() {
        let matches = window.location.search.match(/error=(\w+)/)
        return matches ? matches[1] : null
      },

      addToSlackAlt() { this.$t('views.authorize.add_to_slack') },

      loading() { return this.request === null || (this.request.status !== 'success' && this.request.status !== 'error')},

      message() {
        if (this.error !== null)
          return this.$t(`views.authorize.error_message.${this.error}`,
           {defaultValue: this.$t('views.authorize.error_message.default', {error: this.error})});

        if (this.request === null)
          return this.$t('views.authorize.auth_status.message.pending');

        switch (this.request.status) {
          case 'success':
            return this.$t('views.authorize.auth_status.message.success',
                             {team: this.request.authorization.team_name});
          case 'error':
            return this.$t(`views.authorize.auth_status.message.error.${this.request.error}`,
                             {defaultValue: this.request.error});
          default:
            return this.$t('views.authorize.auth_status.message.pending');
        }
      },

      messageClass() {
        if (this.error !== null) return 'bg-danger';
        if (this.request === null) return null;

        switch (this.request.status) {
          case 'error':
            return 'bg-danger';
          case 'success':
            return 'bg-success';
          default:
            return null;
        }
      }
    },

    methods: {
      refresh() {
        if (this.authorizationRequestID) {
          axios.get(`/authorization_requests/${this.authorizationRequestID}.json`)
               .then((response) => {
                 this.request = response.data;
                 if (this.request.status === 'success' || this.request.status === 'error') {
                   if (this.refreshInterval !== null)
                     window.clearInterval(this.refreshInterval);
                 }
               }).catch((error) => {
            this.request.status = 'error';
            this.request.error = (error !== null ? error : this.$t('views.authorize.auth_status.message.xhr_error')); });
        }
      }
    },

    mounted() {
      this.refresh();
      this.refreshInterval = window.setInterval((() => this.refresh()), 2000);
    }
  }
</script>

<style lang="sass" scoped>
  .jumbotron
    margin-bottom: 4em

    p img
      vertical-align: middle

    p.bg-danger, p.bg-success
      padding: 0.5em
      font-size: 120%

  #auth-status
    display: flex
    flex-flow: row nowrap
    align-items: center

    img.spinner
      flex: 0 0 auto
      margin-right: 0.5em

    p
      flex: 1 0 auto
      margin-bottom: 0
</style>
