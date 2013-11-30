/* global module, require */
module.exports = function(grunt) {
  'use strict';
  var pkg = grunt.file.readJSON('package.json');
  require('load-grunt-tasks')(grunt, { scope: 'devDependencies' });
  grunt.initConfig({
    conf: {
      mojo_app: 'script/chiba_pm4',
      carton: 'carton'
    },
    dir: {
      cwd: require('path').resolve('.'),
      perllib: 'lib',
      perltest: 't',
      jssrc: 'public/js',
      jslib: 'public/vendor',
      jstest: 'test',
      css: 'public/css',
      redis: 'redis',
      template: 'templates'
    },
    pkg: pkg,
    jshint: {
      files: [
        'GruntFile.js',
        'bower.json',
        'package.json',
        'karma.conf.js',
        '<%= dir.jssrc %>/**/*.js',
        '<%= dir.template %>/**/*.js.ep',
        '<%= dir.jstest %>/**/*.js'
      ],
      options: {
        strict: true,
        indent: 2,
        maxlen: 80,
        unused: true,
        undef: true,
        browser: true,
        devel: true,
        debug: true
      }
    },
    karma: {
      unit: {
        configFile: 'karma.conf.js',
        background: true
      }
    },
    bower: {
      install: {
        options: {
          targetDir: '<%= dir.jslib %>',
          layout: 'byComponent',
          cleanTargetDir: true
        }
      }
    },
    external_daemon: {
      redis: {
        options: {
          verbose: true
        },
        cmd: 'redis-server',
        args: [
          '--logfile', '<%= dir.cwd %>/<%= dir.redis %>/redis.log',
          '--dir', '<%= dir.cwd %>/<%= dir.redis %>/',
          '--appendonly', 'yes',
          '--maxmemory', '256mb',
          '--loglevel', 'verbose'
        ]
      },
      morbo: {
        options: {
          verbose: true
        },
        cmd: '<%= conf.carton %>',
        args: ['exec', '--',
          'morbo', '<%= conf.mojo_app %>']
      }
    },
    exec: {
      mojo_test: {
        command: function (verbose) {
          var option = '';
          if (verbose) {
            option = ' -v';
          }
          return grunt.template.process('<%= conf.carton %> exec -- ' +
            '<%= conf.mojo_app %> test' + option);
        }
      }
    },
    watch: {
      jshint: {
        files: [ '<%= jshint.files %>' ],
        tasks: [ 'jshint' ]
      },
      karma: {
        files: [
          'karma.conf.js',
          '<%= dir.jssrc %>/**/*.js',
          '<%= dir.template %>/**/*.js.ep',
          '<%= dir.jstest %>/**/*.js'
        ],
        tasks: [ 'karma:unit:run' ]
      },
      mojo_test: {
        files: [
          '<%= dir.perllib %>/**/*.pm',
          '<%= dir.template %>/**/*.ep',
          '<%= dir.perltest %>/**/*.t'
        ],
        tasks: [ 'mojo:test' ]
      }
    }
  });


  grunt.registerTask('mojo:test', ['exec:mojo_test']);
  grunt.registerTask('test', ['jshint', 'mojo:test']);
  grunt.registerTask('server',
    ['external_daemon:redis', 'external_daemon:morbo', 'watch']);

  grunt.registerTask('default', ['server']);
};
/* vi:set sts=2 sw=2 et: */
