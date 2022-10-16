import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    json: String,
  };
  static targets = ["content"];

  connect() {
    if (!this.jsonValue) return;

    const json = JSON.stringify(JSON.parse(this.jsonValue), null, 4);
    if (this.contentTarget.tagName == "TEXTAREA") {
      this.contentTarget.value = json;
    } else {
      this.contentTarget.innerText = json;
    }
  }
}
