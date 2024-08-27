const { sassPlugin } = require('esbuild-sass-plugin');
const fs = require('fs');

const esbuild = require('esbuild');

const args = process.argv.slice(2);
const watch = args.includes('--watch');
const deploy = args.includes('--deploy');
const metafile = args.includes('--metafile');

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
}

const plugins = [
  sassPlugin({
    // cssImports: true,
  }),
]

let opts = {
  entryPoints: ['js/app.js', 'js/dashboard.js'],
  bundle: true,
  target: 'es2017',
  outdir: '../priv/static/assets',
  logLevel: 'info',
  loader,
  plugins
}

if (watch) {
  opts = {
    ...opts,
    watch,
    sourcemap: 'inline'
  };
}

if (deploy) {
  opts = {
    ...opts,
    minify: true
  };
}

if (metafile) {
  opts = {
    ...opts,
    metafile: true,
  };
}

const promise = esbuild.build(opts);

if (metafile) {
  promise.then(result => {
    fs.writeFileSync('metafile.json', JSON.stringify(result.metafile));
  });
}

if (watch) {
  promise.then(_result => {
    process.stdin.on('close', () => {
      process.exit(0);
    });

    process.stdin.resume();
  });
}
