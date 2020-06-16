import algoliasearch from 'algoliasearch/lite';
import instantsearch from 'instantsearch.js';
import { configure, currentRefinements, infiniteHits, toggleRefinement, refinementList } from 'instantsearch.js/es/widgets';
import { getFullMonths } from '../utils';

function removeUnderscores(items) {
  return items.map(item => ({
    ...item,
    highlighted: item.highlighted.replace(/\_/g, ' '),
  }));
}

function renderBadges(item) {
  const badges = [];

  if (item["boston_qualifier"]) {
    badges.push(`<span class="badge badge-success">Boston Qualifier</span>`);
  }

  if (item["course_profile"] == "downhill") {
    badges.push(`<span class="badge badge-success">Downhill Course</span>`);
  }

  if (item["course_profile"] == "flat") {
    badges.push(`<span class="badge badge-info">Flat Course</span>`);
  }

  if (item["course_profile"] == "rolling_hills") {
    badges.push(`<span class="badge badge-warning">Rolling Hills</span>`);
  }

  if (item["course_profile"] == "hilly") {
    badges.push(`<span class="badge badge-danger">Hilly Course</span>`);
  }

  if (item["course_terrain"] == "road") {
    badges.push(`<span class="badge badge-dark">Road</span>`);
  }

  if (item["course_terrain"] == "trail") {
    badges.push(`<span class="badge badge-dark">Trail</span>`);
  }

  if (item["course_type"] == "loop") {
    badges.push(`<span class="badge badge-primary">Loop Course</span>`);
  }

  if (item["course_type"] == "out_and_back") {
    badges.push(`<span class="badge badge-info">Out & Back Course</span>`);
  }

  if (item["course_type"] == "point_to_point") {
    badges.push(`<span class="badge badge-success">Point-to-Point Course</span>`);
  }

  return badges.join(' ');
}

function renderRaceCard(item) {
  const { name, state, formatted_start_date, city, url } = item;

  return `
    <div class="card mb-3">
      <div class="card-body">
        <a href="${url}">
          <h3 class="card-title">
            ${name}
          </h3>
        </a>

        <p class="card-text">
          <span class="text-muted">
            ${formatted_start_date} | ${city}, ${state}
          </span>
        </p>

        <p class="card-text">
          ${renderBadges(item)}
        </p>
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
      cssClasses: {
        loadMore: 'btn btn-outline-primary w-100',
      },
    })
  ]);

  search.start();
});
