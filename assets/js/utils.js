export function formatDate(date) {
  let month = date.getMonth() + 1,
      day = date.getDate(),
      year = date.getFullYear();

  return [year, pad(month), pad(day)].join('-');
}

function pad(num) {
  return num < 10 ? `0${num}` : num;
}

export function guessTimezone() {
  try {
    return Intl.DateTimeFormat().resolvedOptions().timeZone;
  } catch(err) {
    return 'America/New_York';
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
  var test =(Math.round(n) / multiplicator);
  return +(test.toFixed(digits));
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

export function loadScript(url) {
  const script = document.createElement('script');
  script.src = url;
  script.async = true;
  const promise = new Promise((resolve, reject) => {
    script.onload = resolve;
    script.onerror = reject;
  });
  document.body && document.body.appendChild(script);
  return promise;
}

export function getFullMonths() {
  return [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
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
