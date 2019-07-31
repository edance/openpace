import { u } from 'umbrellajs';
import { formatDate } from '../utils';

const highlightCurrentDate = () => {
  const today = new Date();
  const label = u(`*[data-date="${formatDate(today)}"]`);
  label.addClass('active');
};

document.addEventListener("turbolinks:load", highlightCurrentDate);
