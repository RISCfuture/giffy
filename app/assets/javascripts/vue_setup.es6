Vue.use(VueParams);
Vue.use(VueI18Next);
Vue.params.i18nextLanguage = document.getElementsByTagName('HTML')[0].getAttribute('lang');

window.Vues = new Set();

i18next.use(i18nextXHRBackend).init({
                                      lng: Vue.params.i18nextLanguage
                                    }, function () {
  for (let vue of window.Vues) {
    vue.refresh();
  }
});
