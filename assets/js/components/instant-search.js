import algoliasearch from 'algoliasearch/lite';
import instantsearch from 'instantsearch.js';
import { configure, currentRefinements, infiniteHits, toggleRefinement, refinementList } from 'instantsearch.js/es/widgets';
import { getFullMonths } from '../utils';

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


function removeUnderscores(items) {
  return items.map(item => ({
    ...item,
    highlighted: item.highlighted.replace(/\_/g, ' '),
  }));
}

function renderRaceCard(item) {
  const { name, state, start_date, city } = item;

  return `
      <div class="card mb-3">
        <div class="row no-gutters">
          <div class="col">
            <div class="card-body">
              <a href="#">
                <h3 class="card-title">
                  ${name}
                </h3>
              </a>

              <p class="card-text">
                <span class="text-muted">
                  ${start_date} | ${city}, ${state}
                </span>
              </p>
            </div>
          </div>
        </div>
      </div>
  `;
}

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

  const refinementCss =  {
    label: 'custom-control custom-switch',
    checkbox: 'custom-control-input',
    labelText: 'custom-control-label',
    count: 'badge badge-primary',
  };

  const refinements = {};

  // Clear out the existing hits
  const hits = document.querySelector('#hits');
  hits.innerHTML = '';

  if (region && region.trim()) {
    refinements.full_state = [region];
  }

  search.addWidgets([
    configure({
      disjunctiveFacetsRefinements: refinements,
    }),

    toggleRefinement({
      container: '#bq-refinement',
      attribute: 'boston_qualifier',
      templates: {
        labelText: 'Boston Qualifiers',
      },
      cssClasses: {
        label: 'custom-control custom-switch',
        checkbox: 'custom-control-input',
        labelText: 'custom-control-label',
      },
    }),

    refinementList({
      container: '#month-refinement',
      attribute: 'month',
      cssClasses: refinementCss,
      sortBy: (x, y) => {
        const months = getFullMonths();
        return months.indexOf(x.name) - months.indexOf(y.name);
      }
    }),

    refinementList({
      container: '#weekday-refinement',
      attribute: 'weekday',
      cssClasses: refinementCss,
      sortBy: ['name:asc'],
    }),

    refinementList({
      container: '#course-profile-refinement',
      attribute: 'course_profile',
      cssClasses: refinementCss,
      sortBy: ['name:asc'],
      transformItems: removeUnderscores,
    }),

    refinementList({
      container: '#course-terrain-refinement',
      attribute: 'course_terrain',
      cssClasses: refinementCss,
      sortBy: ['name:asc'],
      transformItems: removeUnderscores,
    }),

    refinementList({
      container: '#course-type-refinement',
      attribute: 'course_type',
      cssClasses: refinementCss,
      sortBy: ['name:asc'],
      transformItems: removeUnderscores,
    }),

    infiniteHits({
      container: '#hits',
      templates: {
        item: renderRaceCard,
      },
    })
  ]);

  search.start();
});
