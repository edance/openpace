import Vue from 'vue';
import Hello from './Hello.vue';

document.addEventListener("turbolinks:load", function() {
  new Vue({
    el: '#components-demo',
    components: Hello
  });
});
