import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["checkboxAll", "checkbox", "valueInput", "submitButton"];

  connect() {
    if (!this.hasCheckboxAllTarget) return;

    this.checkboxAllTarget.addEventListener("change", (event) =>
      this.toggle(event)
    );
    this.checkboxTargets.forEach((checkbox) =>
      checkbox.addEventListener("change", (event) => this.refresh(event))
    );
    this.refresh();
  }

  disconnect() {
    if (!this.hasCheckboxAllTarget) return;

    this.checkboxAllTarget.removeEventListener("change", (event) =>
      this.toggle(event)
    );
    this.checkboxTargets.forEach((checkbox) =>
      checkbox.removeEventListener("change", this.refresh)
    );
  }

  toggle(event) {
    event.preventDefault();

    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = event.target.checked;
      this.triggerInputEvent(checkbox);
    });
    this.refreshForm();
  }

  refresh() {
    const checkboxesCount = this.checkboxTargets.length;
    const checkboxesCheckedCount = this.checked.length;

    this.checkboxAllTarget.checked = checkboxesCheckedCount > 0;
    this.checkboxAllTarget.indeterminate =
      checkboxesCheckedCount > 0 && checkboxesCheckedCount < checkboxesCount;

    this.refreshForm();
  }

  refreshForm() {
    const checkboxesCheckedCount = this.checked.length;

    if (checkboxesCheckedCount > 0) {
      this.submitButtonTargets.forEach((button) => {
        button.classList.remove("hidden");
      });
    } else {
      this.submitButtonTargets.forEach((button) => {
        button.classList.add("hidden");
      });
    }

    this.valueInputTargets.forEach((input) => {
      input.innerHTML = "";

      this.checkedValues.forEach((value) => {
        input.innerHTML += `
        <input name=${input.dataset["name"]} value=${value} />
        `;
      });
    });
  }

  triggerInputEvent(checkbox) {
    const event = new Event("input", { bubbles: false, cancelable: true });

    checkbox.dispatchEvent(event);
  }

  get checkedValues() {
    return this.checked.map((el) => el.value);
  }

  get checked() {
    return this.checkboxTargets.filter((checkbox) => checkbox.checked);
  }

  get unchecked() {
    return this.checkboxTargets.filter((checkbox) => !checkbox.checked);
  }
}
