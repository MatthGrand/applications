/// <reference types="cypress" />
import { random } from '../support/utils';

it('allows creating a new user', () => {
  cy.login();
  cy.get('[href*="/users"]').click();
  cy.get('[data-testid="add-user"]').click();
  cy.fixture('users').then((user) => {
    cy.get('#kc-username').type(`${user.newUser.username}.${random}`);
    cy.get('[data-testid="firstName-input"]').type(`${user.newUser.firstName}.${random}`);
    cy.get('[data-testid="lastName-input"]').type(`${user.newUser.lastName}.${random}`);
  });
  cy.get('[data-testid="create-user"]').click();
  cy.contains('The user has been created');
});

it('import and check user information', () => {
  cy.login();
  cy.get('[href*="/realm-settings"]').click();
  cy.get('[data-testid="action-dropdown"]').click();
  cy.get('[data-testid="openPartialImportModal"]').click();
  const importFile = 'cypress/fixtures/import-data.json';
  cy.fixture('users').then((user) => {
    cy.readFile(importFile).then((obj) => {
      obj.users[0].username = `${user.importedUser.username}.${random}`;
      obj.users[0].email = `${random}.${user.importedUser.email}`;
      obj.users[0].lastName = `${user.importedUser.lastName}-${random}`;
      cy.writeFile(importFile, JSON.stringify(obj));
    });
    cy.get('#partial-import-file-filename').selectFile(importFile, { action: 'drag-drop' });
    cy.get('[data-testid="users-checkbox"]').click();
    cy.get('[data-testid="import-button"]').click();
    cy.contains('record added');
    cy.get('[data-testid="close-button"]').click();
    cy.get('[href*="/users"]').click();
    cy.contains(`${user.importedUser.username}.${random}`);
  });
});
