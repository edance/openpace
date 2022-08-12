export default {
  mounted() {
    this.input = this.el.querySelector('input');
    this.selects = this.el.querySelectorAll('select');
    this.setInitialValue();
    this.addEventListeners();
  },

  addEventListeners() {
    this.selects.forEach(select => {
      select.addEventListener('change', e => {
        let total = 0;

        this.selects.forEach(select => {
          const value = parseInt(select.value, 10);

          if (isNaN(value)) {
            return;
          }

          if (select.name.indexOf('seconds') !== -1) {
            total += value;
          }
          if (select.name.indexOf('minutes') !== -1) {
            total += value * 60;
          }
          if (select.name.indexOf('hours') !== -1) {
            total += value * 60 * 60;
          }
        });

        this.input.value = total;
      });
    });
  },

  setInitialValue() {
    const value = parseInt(this.input.value, 10);
    if (isNaN(value)) {
      return;
    }

    this.selects.forEach(select => {
      if (select.name.indexOf('seconds') !== -1) {
        select.value = value % 60;
      }
      if (select.name.indexOf('minutes') !== -1) {
        select.value = Math.floor(value / 60 % 60);
      }
      if (select.name.indexOf('hours') !== -1) {
        select.value = Math.floor(value / 60 / 60 % 60);
      }
    });
  }
}
