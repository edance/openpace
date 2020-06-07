import algoliasearch from 'algoliasearch/lite';
import instantsearch from 'instantsearch.js';
import { searchBox, hits } from 'instantsearch.js/es/widgets';

document.addEventListener('turbolinks:load', function() {
  const searchClient = algoliasearch(window.ALGOLIA_APPLICATION_ID, window.ALGOLIA_API_KEY);

  const search = instantsearch({
    indexName: 'Race',
    searchClient,
  });

  search.addWidgets([
    searchBox({
      container: "#searchbox"
    }),

    hits({
      container: "#hits"
    })
  ]);

  search.start();
});
