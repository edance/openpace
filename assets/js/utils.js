import { colors } from "./variables.js";

export function formatDate(date) {
  let month = date.getMonth() + 1,
    day = date.getDate(),
    year = date.getFullYear();

  return [year, pad(month), pad(day)].join("-");
}

export function pad(num) {
  return num < 10 ? `0${num}` : num;
}

export function guessTimezone() {
  try {
    return Intl.DateTimeFormat().resolvedOptions().timeZone;
  } catch (err) {
    return "America/New_York";
  }
}

export function calcDistance(distance, imperial, digits = 0) {
  if (imperial) {
    return roundTo(distance / 1609, digits);
  }
  return roundTo(distance / 1000, digits);
}

export function calcFeet(distance, imperial, digits = 0) {
  if (imperial) {
    return roundTo(distance * 3.28, digits);
  }
  return roundTo(distance, digits);
}

export function roundTo(n, digits = 0) {
  var multiplicator = Math.pow(10, digits);
  n = parseFloat((n * multiplicator).toFixed(11));
  var test = Math.round(n) / multiplicator;
  return +test.toFixed(digits);
}

export function formatNumber(num, decimals = 0) {
  const str = num.toFixed(decimals);
  const parts = str.split(".");
  const firstPart = parts[0].replace(/(.)(?=(\d{3})+$)/g, "$1,");
  parts.shift();
  if (parts.length === 0) {
    return firstPart;
  }
  return `${firstPart}.${parts.join("")}`;
}

export function formatDistance(distance, imperial, digits = 1) {
  const label = imperial ? "mi" : "km";
  return `${calcDistance(distance, imperial, digits)} ${label}`;
}

export function loadScript(url) {
  const script = document.createElement("script");
  script.src = url;
  script.async = true;
  const promise = new Promise((resolve, reject) => {
    script.onload = resolve;
    script.onerror = reject;
  });
  document.body && document.body.appendChild(script);
  return promise;
}

export function capitalize(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

export function getFullMonths() {
  return [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
}

export function hexToRGB(hex, alpha) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);

  if (alpha) {
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
  } else {
    return `rgb(${r}, ${g}, ${b})`;
  }
}

export function parseDistance(distanceStr) {
  const parts = distanceStr.match(/([0-9\.,]*)\s*(km|k|m|mile|mi|miles)/);

  if (parts.length !== 3) {
    return null;
  }

  const distance = parseFloat(parts[1]);
  if (isNaN(distance)) {
    return null;
  }

  if (["mi", "mile", "miles"].indexOf(parts[2]) !== -1) {
    return 1609 * distance;
  }

  if (["km", "k"].indexOf(parts[2]) !== -1) {
    return distance * 1000;
  }

  return distance;
}

export function activityColor(type) {
  const map = {
    run: colors["red"],
    bike: colors["blue"],
    swim: colors["green"],
  };

  return map[type] || colors["yellow"];
}

export function range(start, end, step = 1) {
  const len = Math.floor((end - start) / step) + 1;
  return Array(len)
    .fill()
    .map((_, idx) => start + idx * step);
}
