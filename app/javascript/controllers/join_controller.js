import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "create", "code" ]

  initialize() {
    this.codeTarget.hidden = true
  }

  join() {
    if (this.codeTarget.hidden) {
      this.codeTarget.hidden = false
      this.codeTarget.focus()
      this.createTarget.hidden = true
    }
    else {
      window.location.href = `/games/${this.codeTarget.value}`
    }
  }

  upcase() {
    this.codeTarget.value = this.codeTarget.value.toUpperCase()
  }
}
