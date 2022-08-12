export default {
  mounted() {
    window.$(this.el).modal('show');
    this.el.addEventListener('hide-modal', () => {
      window.$(this.el).modal('hide');
    });
  }
}
