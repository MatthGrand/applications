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
  (username = Cypress.env('email'), password = Cypress.env('password')) => {
    cy.visit('/');
    cy.get('#login').type(username);
    cy.get('#password').type(password);
    cy.contains('button', 'Log in').click();
  }
);
