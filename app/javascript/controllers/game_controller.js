import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "player", "startButton" ]

  static values = {
    code: String,
    host: String,
    currentId: String,
    readyUrl: String,
    startUrl: String
  }

  initialize() {
  }

  start() {
    fetch(this.startUrlValue, {
      method: 'POST',
      headers: this._getFetchHeaders(),
    }).
      then(response => response.text()).
      then(html => this.element.innerHTML = html)
  }

  // Callbacks
  //
  startButtonTargetConnected(target) {
    console.log('button connected!')

    if (this.hostValue == 'true') {
      target.classList.remove('hidden')
    }
  }

  playerTargetConnected(target) {
    if (this.hostValue != 'true') {
      target.querySelector('.remove-link').remove()
    }

    if (this.currentIdValue == target.dataset.playerId) {
      target.classList.add('current-player')
    }
  }

  // Private
  //
  _getFetchHeaders() {
    return {
      Accept: "text/vnd.turbo-stream.html",
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json'
    }
  }
}
