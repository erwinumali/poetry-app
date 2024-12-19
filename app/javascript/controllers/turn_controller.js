import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "timer", "words", "easyWord", "hardWord", "actions" ]

  static values = {
    timer: Number,
    easyWords: Array,
    hardWords: Array
  }

  connect() {
    this._countdown()

    this._setWord()
  }

  _setWord() {
    let easyWord = this.easyWordsValue.shift()
    let hardWord = this.hardWordsValue.shift()
    console.log(this.hardWordsValue);


    this.easyWordTarget.innerHTML = easyWord['word'].toUpperCase()
    this.hardWordTarget.innerHTML = hardWord['word'].toUpperCase()
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
}
