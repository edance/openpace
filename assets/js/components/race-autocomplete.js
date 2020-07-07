import algoliasearch from 'algoliasearch/lite';
import autocomplete from 'autocomplete.js';
import Turbolinks from 'turbolinks';

function newHitsSource(index, params) {
  return function doSearch(query, cb) {
    index
      .search(query, params)
      .then(function(res) {
        cb(res.hits, res);
      })
      .catch(function(err) {
        console.error(err);
        cb([]);
      });
  };
}

document.addEventListener('turbolinks:load', function() {
  const client = algoliasearch(window.ALGOLIA_APPLICATION_ID, window.ALGOLIA_API_KEY);
  const index = client.initIndex('Race');

  autocomplete('#race-autocomplete', { hint: false }, [
    {
      source: newHitsSource(index, { hitsPerPage: 10 }),
      displayKey: 'my_attribute',
      templates: {
        suggestion: function(suggestion) {
          return suggestion._highlightResult.name.value;
        }
      }
    }
  ]).on('autocomplete:selected', function(_event, suggestion, _dataset, _context) {
    Turbolinks.visit(suggestion.full_slug);
  });
});
