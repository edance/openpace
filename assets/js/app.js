// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.scss';

// Import dependencies
import 'phoenix_html';

// Import bootstrap and required libraries
import './bootstrap';

// Import base components
import './components/base';

// Fonts
import './fonts';

// Live View
import './live_view';
