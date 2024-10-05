import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];
  static values = {
    decrementCallback: String,
    incrementCallback: String,
  };

  connect() {
    this.inputTarget.addEventListener("change", this.handleChange.bind(this));
  }

  increment() {
    const max = this.inputTarget.max
      ? parseInt(this.inputTarget.max)
      : Infinity;
    const newValue = parseInt(this.inputTarget.value) + 1;
    if (newValue <= max) {
      this.inputTarget.value = newValue;
      this.callIncrementCallback();
    }
  }

  decrement() {
    const min = this.inputTarget.min
      ? parseInt(this.inputTarget.min)
      : -Infinity;
    const newValue = parseInt(this.inputTarget.value) - 1;
    if (newValue >= min) {
      this.inputTarget.value = newValue;
      this.callDecrementCallback();
    }
  }

  callIncrementCallback() {
    const callback = this.incrementCallbackValue;
    if (typeof window[callback] === "function") {
      window[callback](this.inputTarget.value);
    }
  }

  callDecrementCallback() {
    const callback = this.decrementCallbackValue;
    if (typeof window[callback] === "function") {
      window[callback](this.inputTarget.value);
    }
  }

  handleChange(event) {
    const newValue = parseInt(event.target.value);
    this.inputTarget.value = newValue;

    if (newValue > parseInt(this.inputTarget.dataset.oldValue || 0)) {
      this.callIncrementCallback();
    } else if (newValue < parseInt(this.inputTarget.dataset.oldValue || 0)) {
      this.callDecrementCallback();
    }

    this.inputTarget.dataset.oldValue = newValue;
  }
}
