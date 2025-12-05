import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "createForm", "code", "cancel", "joinForm", "help", "logout", "newBtn", "putCode" ]

  join(e) {
    this.joinFormTarget.classList.remove('hidden')
    this.codeTarget.focus()

    this.cancelTarget.classList.remove('hidden')

    this.newBtnTarget.classList.add('hidden')
    this.helpTarget.classList.add('hidden')
    this.logoutTarget.classList.add('hidden')
    this.putCodeTarget.classList.add('hidden')
  }

  joinGame() {
    window.location.href = `/games/${this.codeTarget.value}`
  }

  cancel() {
    this.joinFormTarget.classList.add('hidden')
    this.createFormTarget.classList.add('hidden');

    this.newBtnTarget.classList.remove('hidden')
    this.helpTarget.classList.remove('hidden')
    this.logoutTarget.classList.remove('hidden')
    this.putCodeTarget.classList.remove('hidden')
  }

  newGame() {
    this.newBtnTarget.classList.add('hidden')
    this.helpTarget.classList.add('hidden')
    this.logoutTarget.classList.add('hidden')
    this.putCodeTarget.classList.add('hidden')

    this.createFormTarget.classList.remove('hidden');
  }

  upcase() {
    this.codeTarget.value = this.codeTarget.value.toUpperCase()
  }
}
