import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "timer", "words", "word", "skip",
    "currentView",
    "bonk", "empty"
  ]

  static values = {
    playerType: String,

    timer: Number,

    scoreUrl: String,
    unscoreUrl: String,
    skipUrl: String,
    endTurnUrl: String,
  }

  connect() {
    console.log('turn controller connected!')

    this._countdown()

    this._renderView()
  }

  // Actions
  //
  score(e) {
    if (e.target.classList.contains('disabled') || this._isJudge()) {
      return
    }

    this._disableButtons()

    fetch(this.scoreUrlValue, {
      method: 'POST',
      headers: this._getFetchHeaders(),
      body: JSON.stringify({ word: e.params['word'] })
    }).then(() => this._enableButtons())
  }

  unscore(e) {
    if (e.target.classList.contains('disabled') || this._isJudge()) {
      return
    }

    this._disableButtons()

    fetch(this.unscoreUrlValue, {
      method: 'POST',
      headers: this._getFetchHeaders(),
      body: JSON.stringify({ word: e.params['word'] })
    }).then(() => this._enableButtons())
  }

  skip(e) {
    if (e.target.classList.contains('disabled')) { return }

    this._disableButtons()

    fetch(this.skipUrlValue, {
      method: 'POST',
      headers: this._getFetchHeaders(),
      body: JSON.stringify({ type: e.params['skip'] })
    }).then(() => this._enableButtons())
  }

  endTurn() {
    if (!this._isJudge()) { return }

    fetch(this.endTurnUrlValue, {
      method: 'POST',
      headers: this._getFetchHeaders()
    })
  }

  // Callbacks
  //
  wordTargetConnected(target) {
    if (this._isCurrent()) {
      this._renderPass()

      // Autoskip
      // if (this._scoredCount() == 2) {
      //   setTimeout(() => this.skip({ params: { }, target: target }), 200)
      // }
    }
  }

  skipTargetConnected(target) {
    this._renderSkip()
  }

  bonkTargetConnected(target) {
    if (this._isCurrent()) {
      this.bonkTarget.classList.remove('invisible')

      setTimeout(() => {
        if (this.hasBonkTarget) { this.bonkTarget.classList.add('invisible') }
      }, 100)

      setTimeout(() => {
        if (this.hasBonkTarget) { this.bonkTarget.remove() }
      }, 300)
    }
    else {
      target.remove()
    }
  }

  emptyTargetConnected(target) {
    if (this.timerValue > 5) { this.timerValue = 5 }
  }

  // Private
  //
  _currentId() {
    return document.querySelector('div[data-controller="game"]').dataset['gameCurrentIdValue']
  }

  _isCurrent() {
    return this.playerTypeValue == 'current';
  }

  _isJudge() {
    return this.playerTypeValue == 'judge';
  }

  _countdown() {
    if (this.timerValue == 0) {
      if (this._isJudge()) {
        this.endTurn()
      }
      else {
        this.currentViewTarget.classList.add('hidden')
      }
    }
    else {
      let interval = 1000

      const remainder = this.timerValue % 1000
      if (remainder != 0) { interval = remainder }

      this.timerValue -= interval

      setTimeout(() => this._countdown(), interval)

      this.timerTarget.innerHTML = "<h1>" + Math.floor( Number(this.timerValue) / 1000 ) + "</h1>"
    }
  }

  _renderView() {
    this._renderSkip()
  }

  _renderSkip() {
    if (this.hasEmptyTarget) { return }

    if (this._isCurrent()) {
      this.skipTarget.querySelector('[data-skip-type="skip"]').classList.remove('hidden')

      this._renderPass()
    }
  }

  _renderPass() {
    if (this._scoredCount() == 0) {
      this.skipTarget.querySelector('[data-skip-type="pass"]').classList.add('hidden')
      this.skipTarget.querySelector('[data-skip-type="skip"]').classList.remove('hidden')
    }
    else {
      this.skipTarget.querySelector('[data-skip-type="pass"]').classList.remove('hidden')
      this.skipTarget.querySelector('[data-skip-type="skip"]').classList.add('hidden')
    }
  }

  _disableButtons() {
    this.wordTargets.forEach((word) => {
      word.classList.add('disabled')
    })

    this.skipTarget.querySelectorAll('button').forEach((skip) => {
      skip.classList.add('disabled')
    })
  }

  _enableButtons() {
    this.wordTargets.forEach((word) => {
      word.classList.remove('disabled')
    })

    this.skipTarget.querySelectorAll('button').forEach((skip) => {
      skip.classList.remove('disabled')
    })
  }

  _scoredCount() {
    return document.querySelectorAll('.scored[data-turn-target="word"]').length
  }

  _getFetchHeaders() {
    return {
      //Accept: "text/vnd.turbo-stream.html",
      Accept: 'application/json',
      'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
      'Content-Type': 'application/json'
    }
  }
}
