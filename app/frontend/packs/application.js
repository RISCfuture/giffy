/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Vue from 'vue'

import i18next from 'i18next'
import i18nextXHRBackend from 'i18next-xhr-backend'
import VueI18Next from '@panter/vue-i18next'
Vue.use(VueI18Next)
i18next.use(i18nextXHRBackend).init({lng: document.getElementsByTagName('HTML')[0].getAttribute('lang')})
const i18n = new VueI18Next(i18next)

import VueRouter from 'vue-router'
Vue.use(VueRouter);
import routes from 'config/routes'
const router = new VueRouter({routes, mode: 'history'})

import 'stylesheets/application.css'

document.addEventListener('DOMContentLoaded', () => {
  new Vue({i18n, router}).$mount('#app')
})
