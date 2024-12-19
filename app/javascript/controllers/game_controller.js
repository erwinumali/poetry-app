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

  ready(e) {
    if (this.playerTargets.length % 2 != 0) {
      alert('This game requires an even number of players!')
      e.preventDefault();
    }
  }

  // Callbacks
  //
  startButtonTargetConnected(target) {
    if (this.hostValue == 'true') {
      target.classList.remove('hidden')
    }
  }

  playerTargetConnected(target) {
    if (this.hostValue != 'true') {
      // Remove link is only present in the lobby
      if (target.querySelector('.remove-link') != null) {
        target.querySelector('.remove-link').remove()
      }
    }

    if (this.currentIdValue == target.dataset.playerId) {
      target.classList.add('current-player')

      // Remove link if host
      if (target.querySelector('.remove-link') != null) {
        target.querySelector('.remove-link').remove()
      }
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
