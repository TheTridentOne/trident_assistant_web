// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();


addEventListener('turbo:submit-start', ({ target }) => {
  for (const field of target.elements) {
    field.disabled = true;
  }
});
