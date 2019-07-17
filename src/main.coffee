import Vue from 'vue'
import App from './App.vue'
import router from './router'

import VueResource from 'vue-resource'
import VueLS from 'vue-localstorage'
import BootstrapVue from 'bootstrap-vue/dist/bootstrap-vue.esm';

Vue.use VueResource
Vue.use VueLS
Vue.use BootstrapVue

import 'bootstrap-vue/dist/bootstrap-vue.css'
import 'bootstrap/dist/css/bootstrap.css'
import 'vue-select/dist/vue-select.css'

Vue.config.productionTip = false

new Vue
  router: router
  render: (h) -> h(App)
.$mount('#app')
