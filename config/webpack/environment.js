const { environment } = require('@rails/webpacker')

const webpack = require("webpack")
environment.plugins.append('Provide',
    new webpack.ProvidePlugin({
        $: 'jquery',
        jquery: 'jquery'
    })
)

module.exports = environment
