const { environment } = require('@rails/webpacker');

const webpack = require('webpack'); // eslint-disable-line
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
}));

module.exports = environment;
