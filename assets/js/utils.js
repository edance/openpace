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
