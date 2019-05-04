// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.scss';

// Import dependencies
import 'react-phoenix';
import 'phoenix_html';
import 'bootstrap';

// Import base components
import './components/base';
import './components/route-map';
import './components/route-chart';

// Turbolinks
import './turbolinks';

// Fonts
import './fonts';
