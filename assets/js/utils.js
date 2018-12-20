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
