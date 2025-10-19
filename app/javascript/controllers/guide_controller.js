import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "timer", "word", "pass", "skip" ]

  static values = {
    timer: Number
  }

  connect() {
    console.log('Guide controller connected!')

    this._countdown()
  }

  // Actions
  //
  score(e) {
    let target = e.currentTarget;
    let state = target.getAttribute('data-state');

    if (state == 'unscored') {
      target.setAttribute('data-state', 'scored');
      target.classList.remove('unscored');
      target.classList.add('scored');
    }
    else {
      target.setAttribute('data-state', 'unscored');
      target.classList.add('unscored');
      target.classList.remove('scored');
    }

    let oneScored = false;
    this.wordTargets.forEach((word) => {
      if (word.getAttribute('data-state') == 'scored') { oneScored = true; }
    });

    if (oneScored) {
      this.passTarget.classList.remove('hidden');
      this.skipTarget.classList.add('hidden');
    }
    else {
      this.passTarget.classList.add('hidden');
      this.skipTarget.classList.remove('hidden');
    }
  }

  // Callbacks
  //

  _countdown() {
    if (this.timerValue == 0) {
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
}
