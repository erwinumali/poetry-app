import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "timer", "words", "easyWord", "hardWord", "actions", "currentView", "otherView"
  ]

  static values = {
    timer: Number,

    playerId: String,
    judgeId: String,
    currentId: String,

    scoreUrl: String,
    unscoreUrl: String,
    skipUrl: String
  }

  connect() {
    console.log('turn controller connected!')

    this._countdown()

    this._renderView()
  }

  score({ params }) {
    fetch(this.scoreUrlValue, {
      method: 'POST',
      headers: this._getFetchHeaders(),
      body: JSON.stringify({ word: params['word'] })
    })
  }

  unscore({ params }) {
    fetch(this.unscoreUrlValue, {
      method: 'POST',
      headers: this._getFetchHeaders(),
      body: JSON.stringify({ word: params['word'] })
    })
  }

  skip() {
    fetch(this.skipUrlValue, {
      method: 'POST',
      headers: this._getFetchHeaders(),
      body: JSON.stringify({  })
    })
  }

  _currentId() {
    return document.querySelector('div[data-controller="game"]').dataset['gameCurrentIdValue']
  }

  _isJudge() {
    return this.judgeIdValue == this._currentId()
  }

  _isPlayer() {
    return this.playerIdValue == this._currentId()
  }

  _countdown() {
    if (this.timerValue == 0) {
      // this._endTurn()
    }
    else {
      this.timerValue -= 1

      this.timerTarget.innerHTML = "<h1>" + Number(this.timerValue) + "</h1>"

      setTimeout(() => this._countdown(), 1000)
    }
  }

  _renderView() {
    if (this._isPlayer() || this._isJudge()) {
      this.currentViewTarget.classList.remove('hidden')
    }
    else {
      this.otherViewTarget.classList.remove('hidden')
    }
  }

  _getFetchHeaders() {
    return {
      Accept: "text/vnd.turbo-stream.html",
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json'
    }
  }
}
