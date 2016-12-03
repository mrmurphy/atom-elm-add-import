'use babel';

import ElmAddImportView from './elm-add-import-view';
import { CompositeDisposable } from 'atom';

export default {

  elmAddImportView: null,
  modalPanel: null,
  subscriptions: null,

  activate() {
    this.elmAddImportView = new ElmAddImportView();
    this.modalPanel = atom.workspace.addModalPanel({
      item: this.elmAddImportView.getElement(),
      visible: false
    });

    // Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    this.subscriptions = new CompositeDisposable();

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'elm-add-import:activate': () => this.show(),
      'elm-add-import:deactivate': () => this.close()
    }));

    this.elmAddImportView.elm.ports.importAdded.subscribe(newContents => {
      this.close()
      atom.workspace.getActiveTextEditor().setText(newContents)
    })
  },

  deactivate() {
    this.close();
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.elmAddImportView.destroy();
  },

  close() {
    document.querySelector('atom-workspace').classList.remove('elm-add-import')
    this.modalPanel.hide()
    document.querySelector('.editor').focus()
  },

  show() {
    const workspaceClasses = document.querySelector('atom-workspace').classList
    workspaceClasses.add('elm-add-import')

    this.modalPanel.show()
    const text = atom.workspace.getActiveTextEditor().getText()
    this.elmAddImportView.show(text)
  }
};
