import { u } from 'umbrellajs';

const formatValue = (value) => {
  const arr = value.replace(/^0+/, '').split('').reverse();

  if (arr.length < 4) {
    const remaining = 4 - arr.length;

    for (let i = 0; i < remaining; i++) {
      arr.push('0');
    }
  }

  if (arr.length > 4) {
    arr.splice(4, 0, ':');
  }

  arr.splice(2, 0, ':');

  return arr.reverse().join('');
}

const stripValue = (value) => {
  return value.replace(/[^0-9\.]+/g, '');
}

const handleKeyDown = (e) => {
  const keyCode = e.keyCode;
  const target = e.target;
  let value = stripValue(target.value);

  // Backspace
  if (keyCode === 8) {
    value = value.slice(0, value.length -1);
  }

  // 0-9 only
  if ((keyCode >= 48 && keyCode <= 57) || (keyCode >= 96 && keyCode <= 105)) {
    value = `${value}${String.fromCharCode(keyCode)}`;
  }

  target.value = formatValue(value);
};

document.addEventListener("turbolinks:load", function() {
  u('.time-input').handle('keydown', handleKeyDown);
});

