/// <reference types="cypress" />
import {
  random,
} from './utils'

it('allows user to log in and log out', () => {
  cy.login();
  cy.get('[data-testid="ErrorOutlineIcon"]').should('not.exist');
  cy.get("#logout").scrollIntoView().should('be.visible').click();
})

it('allows creating a bucket and file upload', () => {  
  cy.login();
  cy.visit('add-bucket');
  cy.fixture('testdata').then((td) => {
    cy.get('#bucket-name').should('be.visible').type(`${td.bucketTitle}.${random}`);
  })
  cy.contains('button[type="submit"]','Create Bucket').click();
  cy.contains('#upload-main','Upload').should('be.visible').click();
  cy.contains('span','Upload File').should('be.visible').click();
  cy.get('div#object-list-wrapper > input[type="file"]').selectFile('cypress/fixtures/example.json',
  {force:true});
})

it('allows creating a user', () => {
  cy.login();
  cy.visit('identity/users');
  cy.contains('Create User');
  cy.get('[aria-label="Create User"]').should('be.visible').click();
  cy.fixture('testdata').then((td) => {
    cy.get('#accesskey-input').should('be.visible').type(`${td.testAccessKey}.${random}`);
    cy.get('#standard-multiline-static').should('be.visible').type(`${td.testSecretKey}.${random}`);
  })
  cy.contains('button[type="submit"]','Save').should('be.visible').click();
  cy.fixture('testdata').then((td) => {
    cy.contains(td.testAccessKey).should('be.visible');
    cy.get('#accesskey-input').should('not.exist');
  })
})

it('allows creating a group', () => {
  cy.login();
  cy.visit('identity/groups');
  cy.get('[aria-label="Create Group"]').should('be.visible').click();
  cy.fixture('testdata').then((td) => {
    cy.get('#group-name').should('be.visible').type(`${td.testGroupName}.${random}`);
    cy.contains('button[type="submit"]','Save').click();
    cy.contains(td.testGroupName);
  })
})

it('allows creating a service account and downloading credentials', () => {
  cy.login();
  cy.visit('identity/account');
  cy.get('[aria-label="Create service account"]').should('be.visible').click();
  cy.contains('button[type="submit"]','Create').click();
  cy.get('#download-button').should('be.visible').click(); 
  cy.readFile('cypress/downloads/credentials.json').should('exist');
})
