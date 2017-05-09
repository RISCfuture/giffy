module.exports = {
  test: /.vue$/,
  loader: 'vue-loader',
  options: {
    loaders: {
      js: 'babel-loader?presets[]=es2015&presets[]=stage-2',
      file: 'file-loader',
      scss: 'vue-style-loader!css-loader!postcss-loader!sass-loader',
      sass: 'vue-style-loader!css-loader!postcss-loader!sass-loader?indentedSyntax'
    }
  }
}
