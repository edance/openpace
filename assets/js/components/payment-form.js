import { u } from 'umbrellajs';
import { loadScript } from '../utils';
import { colors, fonts } from '../variables';

const FONT_SIZE = 16;

function createCardElement(element, stripe) {
  // Create an instance of Elements.
  const elements = stripe.elements();

  const style = {
    base: {
      color: colors.gray[800],
      lineHeight: `${FONT_SIZE * 1.5}px`,
      fontFamily: fonts.base,
      fontSmoothing: 'antialiased',
      fontSize: `${FONT_SIZE - 2}px`,
      '::placeholder': {
        color: colors.gray[500],
      },
    },
    invalid: {
      color: colors.theme['danger'],
      iconColor: colors.theme['danger'],
    }
  };

  const classes = {
    base: 'form-control form-control-alternative',
    invalid: 'is-invalid',
  };

  // Create an instance of the card Element.
  const card = elements.create('card', {classes, style});

  card.mount(element);

  return card;
}

// Handle real-time validation errors from the card Element.
function addListenersToCard(card, errorContainer) {
  card.addEventListener('change', function(event) {
    if (event.error) {
      errorContainer.textContent = event.error.message;
    } else {
      errorContainer.textContent = '';
    }
  });
}

// Submit the form with the token ID.
function stripeTokenHandler(form, token) {
  const input = u(form).find('.stripe-token-input');
  input.attr('value', token.id);

  // Submit the form
  form.submit();
}

function addListenersToForm(form, card, errorContainer, stripe) {
  form.addEventListener('submit', function(event) {
    event.preventDefault();

    stripe.createToken(card).then(function(result) {
      if (result.error) {
        // Inform the user if there was an error.
        errorContainer.textContent = result.error.message;
      } else {
        // Send the token to your server.
        stripeTokenHandler(form, result.token);
      }
    });
  });
}

function init() {
  const $form = u('.payment-form');

  if ($form.length === 0) {
    return;
  }

  loadScript('//js.stripe.com/v3/').then(() => {
    $form.each(element => {
      const cardContainer = u(element).find('.card-input-group');
      const cardElement = cardContainer.find('.credit-card-input').first();
      const errorContainer = cardContainer.find('.invalid-feedback').first();
      const stripe = window.Stripe(window.STRIPE_PUBLISHABLE_KEY);
      const card = createCardElement(cardElement, stripe);
      addListenersToCard(card, errorContainer);
      addListenersToForm(element, card, errorContainer, stripe);
    });
  });
};

window.addEventListener("phx:page-loading-stop", init);
window.addEventListener("load", init);
