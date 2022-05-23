import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.element.value = this.timeZone();
  }

  timeZone() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone;
  }
}
