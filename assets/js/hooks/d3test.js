import * as d3 from "d3";

export default {
  mounted() {
    // set the dimensions and margins of the graph
    const margin = { top: 30, right: 30, left: 120, bottom: 30 };
    const width = 1000;
    const height = 500;
    const innerWidth = width - margin.left - margin.right;
    const innerHeight = height - margin.top - margin.bottom;

    const container = d3.select(this.el);
    const tooltipDiv = container.select(".tooltipz");

    const svg = container.append("svg").attr("viewBox", [0, 0, width, height]);

    const wrapper = svg
      .append("g")
      .attr("transform", `translate(${margin.left}, ${margin.top})`);

    this.handleEvent("summaries", ({ summaries }) => {
      const data = summaries
        .filter((d) => d.type === "Run")
        .map((d) => {
          const speed = d.distance / d.duration; // meters per second

          return {
            ...d,
            distance: d.distance / 1609,
            start_at_local: new Date(d.start_at_local),
            year: new Date(d.start_at_local).getFullYear(),
            speed,
            pace: 1609 / 60 / speed,
          };
        });

      const x = d3
        .scaleLinear()
        .domain(d3.extent(data, (d) => d.speed))
        .range([0, innerWidth]);

      const xAxis = (g) => g.call(d3.axisTop(x).tickFormat((d) => `${d} mps`));
      wrapper.append("g").call(xAxis);

      const r = d3
        .scaleSqrt()
        .domain(d3.extent(data, (d) => d.distance))
        .range([1, 10]);

      const color = d3.scaleSequential(
        d3.extent(data, (d) => d.speed),
        d3.interpolateMagma
      );

      const circles = wrapper
        .append("g")
        .attr("className", "circles")
        .selectAll("circle")
        .data(data)
        .join("circle")
        .attr("r", (d) => r(d.distance))
        .attr("fill", (d) => color(d.speed))
        .attr("s", (d) => d.slug)
        .attr("x", (d) => x(d.speed))
        .attr("y", (d) => innerHeight / 2)
        .call(this.tooltip, tooltipDiv);

      const force = d3
        .forceSimulation(data)
        .force("charge", d3.forceManyBody().strength(0))
        .force(
          "x",
          d3.forceX().x((d) => x(d.speed))
        )
        .force(
          "y",
          d3.forceY((d) => innerHeight / 2)
        )
        .force(
          "collision",
          d3.forceCollide().radius((d) => r(d.distance) + 1)
        );

      force.on("tick", () => {
        circles
          // .transition()
          // .ease(d3.easeLinear)
          .attr("cx", (d) => d.x)
          .attr("cy", (d) => d.y);
      });

      // Disable the animation
      while (force.alpha() > force.alphaMin()) {
        force.tick();
      }
    });
  },
  tooltip(selectionGroup, tooltipDiv) {
    selectionGroup.each(function () {
      d3.select(this)
        .on("mouseover.tooltip", handleMouseover)
        .on("mousemove.tooltip", handleMousemove)
        .on("mouseleave.tooltip", handleMouseleave);
    });

    const MOUSE_POS_OFFSET = 5;

    function setContents(datum, tooltipDiv) {
      // customize this function to set the tooltip's contents however you see fit
      tooltipDiv
        .selectAll("p")
        .data(Object.entries(datum))
        .join("p")
        .filter(([key, value]) => value !== null && value !== undefined)
        .html(
          ([key, value]) =>
            `<strong>${key}</strong>: ${
              typeof value === "object" ? value.toLocaleString("en-US") : value
            }`
        );
    }

    function handleMouseover() {
      // show/reveal the tooltip, set its contents,
      // style the element being hovered on
      showTooltip();
      setContents(d3.select(this).datum(), tooltipDiv);
      // setStyle(d3.select(this));
      d3.select(this)
        .transition()
        .duration(100)
        .attr("r", 20)
        .attr("fill", "#ff0000");
    }

    function handleMousemove(event) {
      // update the tooltip's position
      const [mouseX, mouseY] = d3.pointer(event, this);
      // add the left & top margin values to account for the SVG g element transform
      setPosition(mouseX, mouseY);
    }

    function handleMouseleave() {
      // do things like hide the tooltip
      // reset the style of the element being hovered on
      hideTooltip();
      // resetStyle(d3.select(this));
    }

    function showTooltip() {
      tooltipDiv.style("display", "block");
    }

    function hideTooltip() {
      tooltipDiv.style("display", "none");
    }

    function setPosition(mouseX, mouseY) {
      tooltipDiv
        .style(
          "top",
          // mouseY < height / 2 ? `${mouseY + MOUSE_POS_OFFSET}px` : "initial"
          `${mouseY + MOUSE_POS_OFFSET}px`
        )
        .style(
          "right",
          `${mouseX + MOUSE_POS_OFFSET}px`
          // mouseX > width / 2
          //   ? `${width - mouseX + MOUSE_POS_OFFSET}px`
          //   : "initial"
        );
      // .style(
      //   "bottom",
      //   mouseY > height / 2
      //     ? `${height - mouseY + MOUSE_POS_OFFSET}px`
      //     : "initial"
      // )
      // .style(
      //   "left",
      //   mouseX < width / 2 ? `${mouseX + MOUSE_POS_OFFSET}px` : "initial"
      // );
    }
  },
};
