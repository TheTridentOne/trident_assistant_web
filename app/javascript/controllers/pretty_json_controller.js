import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    json: String,
  };
  static targets = ["content"];

  connect() {
    if (this.jsonValue) {
      this.contentTarget.innerText = JSON.stringify(
        JSON.parse(this.jsonValue),
        null,
        4
      );
    }
  }
}
