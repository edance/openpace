import { loadScript } from '../utils';
import { colors, fonts } from '../variables';

const FONT_SIZE = 16;

document.addEventListener("turbolinks:load", function() {
  loadScript('//js.stripe.com/v3/').then(() => {
    // Create a Stripe client.
    const stripe = window.Stripe(window.STRIPE_PUBLISHABLE_KEY);

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
    };

    // Create an instance of the card Element.
    const card = elements.create('card', {classes, style});

    // Add an instance of the card Element into the `card-element` <div>.
    card.mount('#credit-card-input');
  });
});
