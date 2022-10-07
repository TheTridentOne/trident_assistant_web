# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@rails/request.js', to: 'https://ga.jspm.io/npm:@rails/request.js@0.0.6/src/index.js', preload: true
pin '@rails/activestorage', to: 'https://ga.jspm.io/npm:@rails/activestorage@7.0.4/app/assets/javascripts/activestorage.esm.js', preload: true

pin 'stimulus-use', to: 'https://ga.jspm.io/npm:stimulus-use@0.50.0/dist/index.js', preload: true
pin 'hotkeys-js', to: 'https://ga.jspm.io/npm:hotkeys-js@3.10.0/dist/hotkeys.esm.js', preload: true

pin 'flatpickr', to: 'https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js', preload: true
pin 'stimulus-flatpickr', to: 'https://ga.jspm.io/npm:stimulus-flatpickr@3.0.0-0/dist/index.m.js', preload: true

pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'application', preload: true
