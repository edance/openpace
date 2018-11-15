import Vue from 'vue';

document.addEventListener("turbolinks:load", function() {
  new Vue({
    el: '.duration-select',
    data: {
      hours: '',
      minutes: '',
      seconds: '',
    }
  });
});
