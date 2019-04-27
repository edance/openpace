// import 'datalist-polyfill';

// const setInitialValue = (input) => {
//   const options = $(input.list.options).filter((idx, x) => {
//     return x.dataset.value === input.value;
//   });

//   if (options.length === 0) {
//     return;
//   }

//   input.value = options[0].value;
// };

// const updateHiddenValue = (e) => {
//   const input = e.target,
//         list = input.getAttribute('list'),
//         options = document.querySelectorAll('#' + list + ' option'),
//         hiddenInput = document.getElementById(list + '-hidden'),
//         inputValue = input.value;

//   hiddenInput.value = inputValue;

//   for (let i = 0; i < options.length; i++) {
//     const option = options[i];

//     if (option.innerText === inputValue) {
//       hiddenInput.value = option.getAttribute('data-value');
//       break;
//     }
//   }
// };

// document.addEventListener("turbolinks:load", function() {
//   $('input[list]').each((_, el) => setInitialValue(el));
//   $('input[list]').on('input', updateHiddenValue);
// });
