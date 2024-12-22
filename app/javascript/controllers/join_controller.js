import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "create", "code", "cancel", "help" ]

  join(e) {
    if (this.codeTarget.classList.contains('hidden')) {
      this.codeTarget.classList.remove('hidden')
      this.codeTarget.focus()

      this.cancelTarget.classList.remove('hidden')

      this.createTarget.classList.add('hidden')
      this.helpTarget.classList.add('hidden')
    }
    else {
      window.location.href = `/games/${this.codeTarget.value}`
    }
  }

  cancel() {
    this.codeTarget.classList.add('hidden')
    this.cancelTarget.classList.add('hidden')

    this.createTarget.classList.remove('hidden')
    this.helpTarget.classList.remove('hidden')
  }

  upcase() {
    this.codeTarget.value = this.codeTarget.value.toUpperCase()
  }
}
