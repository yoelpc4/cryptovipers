import Vue from "vue";
import BootstrapVue from "bootstrap-vue";
import "bootstrap/dist/css/bootstrap.min.css";
import "bootstrap-vue/dist/bootstrap-vue.css";
import App from "./App.vue";

Vue.config.productionTip = false;

Vue.use(BootstrapVue);

new Vue({
  transformToRequire: {
    img: "src",
    image: "xlink:href",
  },
  render: (h) => h(App),
}).$mount("#app");
