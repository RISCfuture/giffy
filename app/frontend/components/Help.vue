<template>
  <div>
    <h2>{{ $t('components.help.commands') }}</h2>
    <dl>
      <dt><samp>{{ $t('components.help.giffy') }}</samp></dt>
      <dd v-html="giffyDescription"></dd>

      <dt><samp>{{ $t('components.help.latex') }}</samp></dt>
      <dd v-html="latexDescription"></dd>

      <dt><samp>{{ $t('components.help.comic_sans') }}</samp></dt>
      <dd v-html="comicSansDescription"></dd>
    </dl>
  </div>
</template>

<script>
  export default {
    computed: {
      giffyDescription() { return this.$t('components.help.giffy_description') },
      latexDescription() { return this.$t('components.help.latex_description') },
      comicSansDescription() { return this.$t('components.help.comic_sans_description') }
    }
  };
</script>

<style lang="sass" scoped>
  dl
    margin-top: 2em

  dt
    font-size: 120%

  dd
    font-size: 120%
    margin-top: 0.5em
    margin-bottom: 2em
    margin-left: 1em
</style>
