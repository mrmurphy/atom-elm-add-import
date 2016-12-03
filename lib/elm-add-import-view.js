'use babel';

import elmApp from './app'

export default class ElmAddImportView {

  constructor() {
    this.element = document.createElement('div');
    this.element.classList.add('elm-add-import');
    this.element.classList.add('native-key-bindings');
    this.elm = elmApp.Main.embed(this.element)
  }

  // Returns an object that can be retrieved when package is activated
  serialize() {}

  // Tear down any state and detach
  destroy() {
    this.element.remove();
  }

  show(editorContents) {
    this.elm.ports.open.send(editorContents)
  }

  getElement() {
    return this.element;
  }

}
