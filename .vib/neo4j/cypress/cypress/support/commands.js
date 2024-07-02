/*
 * Copyright Broadcom, Inc. All Rights Reserved.
 * SPDX-License-Identifier: APACHE-2.0
 */

const COMMAND_DELAY = 2000;

for (const command of ['click']) {
  Cypress.Commands.overwrite(command, (originalFn, ...args) => {
    const origVal = originalFn(...args);

    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(origVal);
      }, COMMAND_DELAY);
    });
  });
}

Cypress.Commands.add(
  'login',
  (username = Cypress.env('username'), password = Cypress.env('password')) => {
    cy.visit('/');
    cy.get('form').should('exist').and('be.visible'); // Needed to ensure stability of the test
    cy.get('input[data-testid="username"]').type(username);
    cy.get('input[type="password"]').type(password);
    cy.contains('button', 'Connect').click();
    cy.contains('You are connected as user');
  }
);
