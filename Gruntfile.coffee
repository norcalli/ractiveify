module.exports = (grunt) ->
  require("load-grunt-tasks") grunt

  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    livescript:
      default:
        files:
          'index.js': 'src/index.ls'
          'compilers/coffeescript.js': 'src/compilers/coffeescript.ls'
          'compilers/livescript.js': 'src/compilers/livescript.ls'

  grunt.registerTask 'default', ['livescript']

