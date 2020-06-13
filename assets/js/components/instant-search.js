import algoliasearch from 'algoliasearch/lite';
import instantsearch from 'instantsearch.js';
import { configure, currentRefinements, infiniteHits, refinementList } from 'instantsearch.js/es/widgets';

document.addEventListener('turbolinks:load', function() {
  const $cards = document.querySelector('.race-cards');

  if (!$cards) {
    return;
  }

  const region = $cards.dataset['region'];
  const distance = $cards.dataset['distance'];

  const searchClient = algoliasearch(window.ALGOLIA_APPLICATION_ID, window.ALGOLIA_API_KEY);

  const search = instantsearch({
    indexName: 'Race',
    searchClient,
  });

  const template = `
    <div class="card mb-3">
      <div class="row no-gutters">
        <div class="col">
          <div class="card-body">
            <h4 class="card-title">
              {{name}}
            </h4>
            <p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This content is a little bit longer.</p>
            <p class="card-text"><small class="text-muted">Last updated 3 mins ago</small></p>
          </div>
        </div>
      </div>
    </div>
  `;

  const refinements = {};

  if (region && region.trim()) {
    refinements.full_state = [region];
  }

  search.addWidgets([
    configure({
      disjunctiveFacetsRefinements: refinements,
    }),

    currentRefinements({
      container: '#current-refinements',
    }),

    refinementList({
      container: '#refinement-list',
      attribute: 'month',
    }),

    infiniteHits({
      container: '#hits',
      templates: {
        item: template
      },
    })
  ]);

  search.start();
});
