import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "player" ]

  static values = {
    readyUrl: String
  }

  initialize() {
  }

  ready() {
    if (this.playerTargets.length % 2 != 0) {
      alert("Need an even number of players!")
      return
    }
    else {
      fetch(this.readyUrlValue, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ hide_layout: true })
      }).
        then(response => response.text()).
        then(html => this.element.innerHTML = html)
    }
  }
}
