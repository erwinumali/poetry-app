import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "timer", "words", "word", "skip", "currentView", "otherView", "playerHeader", "judgeHeader"
  ]

  static values = {
    timer: Number,

    playerId: String,
    judgeId: String,
    currentId: String,

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
    if (e.target.classList.contains('disabled') || this._isPlayer()) {
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
    if (e.target.classList.contains('disabled') || this._isPlayer()) {
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
    })
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
    if (this._isPlayer()) {
      this._renderPass()
      this._setWordsUnclickable()

      if (this._scoredCount() == 2) {
        setTimeout(() => this.skip({ params: { }, target: target }), 300)
      }
    }
  }

  skipTargetConnected(target) {
    this._renderSkip()
  }

  // Private
  //
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
      this.endTurn()
    }
    else {
      this.timerValue -= 1

      this.timerTarget.innerHTML = "<h1>" + Number(this.timerValue) + "</h1>"

      setTimeout(() => this._countdown(), 1000)
    }
  }

  _renderView() {
    if (this._isPlayer()) {
      this.currentViewTarget.classList.remove('hidden')
      this.playerHeaderTarget.classList.remove('hidden')

      this._setWordsUnclickable()
    }
    else if (this._isJudge()) {
      this.currentViewTarget.classList.remove('hidden')
      this.judgeHeaderTarget.classList.remove('hidden')
    }
    else {
      this.otherViewTarget.classList.remove('hidden')
    }

    this._renderSkip()
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

  _setWordsUnclickable() {
    this.wordTargets.forEach((word) => { word.classList.add('unclickable') })
  }

  _renderSkip() {
    if (this._isPlayer()) {
      this.skipTarget.querySelector('[data-skip-type="skip"]').classList.remove('hidden')

      this._renderPass()
    }
    else if (this._isJudge()) {
      this.skipTarget.querySelector('[data-skip-type="bonk"]').classList.remove('hidden')
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
