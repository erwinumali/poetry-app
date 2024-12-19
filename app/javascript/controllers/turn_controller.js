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
    easyWords: Array,
    hardWords: Array
  }

  connect() {
    console.log('turn controller connected!')

    this._countdown()

    this._renderView()
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

  _setWord() {
    let easyWords = this.easyWordsValue,
        hardWords = this.hardWordsValue

    let easyWord = easyWords.pop()
    this.easyWordsValue = easyWords
    this.easyWordTarget.innerHTML = easyWord['word'].toUpperCase()

    let hardWord = hardWords.pop()
    this.hardWordsValue = hardWords
    this.hardWordTarget.innerHTML = hardWord['word'].toUpperCase()
  }

}
