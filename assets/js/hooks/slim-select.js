import SlimSelect from "slim-select";

export default {
  mounted() {
    this.slimSelect = new SlimSelect({ select: this.el });
  },
};
