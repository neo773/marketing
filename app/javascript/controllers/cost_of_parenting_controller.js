import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["childrenTabs"]

  connect() {
    this.updateChildrenTabs(this.childrenTabsTarget.children.length)
  }

  incrementChildren(event) {
    const newValue = parseInt(event.detail.value)
    console.log(newValue);
    if (newValue >= 2) {
      this.childrenTabsTarget.classList.remove('hidden');
      this.childrenTabsTarget.querySelectorAll('.tab-item').forEach((tab, index) => {
        if (index < newValue) {
          tab.classList.remove('hidden');
        }
      });
    }
    this.updateChildrenTabs(newValue);
  }
  
  decrementChildren(event) {
    const newValue = parseInt(event.detail.value)
    console.log(newValue);
    if (newValue < 2) {
      this.childrenTabsTarget.classList.add('hidden');
    } else {
      this.childrenTabsTarget.querySelectorAll('.tab-item').forEach((tab, index) => {
        if (index >= newValue) {
          tab.classList.add('hidden');
        }
      });
    }
    this.updateChildrenTabs(newValue);
  }

}