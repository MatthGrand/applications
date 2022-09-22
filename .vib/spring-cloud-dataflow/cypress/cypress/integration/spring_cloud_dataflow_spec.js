/// <reference types="cypress" />
import { random, importAppStarters } from '../support/utils.js';

before(() => {
  importAppStarters();
});

it('allows creating a stream and deploying it', () => {
  cy.visit('/dashboard/#/streams/list/create');
  cy.fixture('streams').then((stream) => {
    cy.get('.CodeMirror-line').type(
      `${stream.newStream.app1} | ${stream.newStream.app2}`
    );
    cy.contains('#v-2', stream.newStream.app1).and(
      'contain',
      stream.newStream.app2
    );
    cy.contains('button', 'Create stream(s)').click();
    cy.get('.modal-content').should('contain', 'Create Stream');
    cy.get('input[placeholder="Stream Name"]').type(
      `${stream.newStream.name}-${random}`
    );
    cy.contains('Create the stream').click();
    cy.contains('Stream(s) have been created successfully');

    cy.visit(
      `/dashboard/#/streams/list/${stream.newStream.name}-${random}/deploy`
    );
    cy.contains('button', 'Deploy stream').click();
    cy.contains('Deploy success');
  });
});

it('allows importing a task from a file and destroying it ', () => {
  cy.visit('/dashboard/#/manage/tools');
  cy.contains('Import tasks').click();
  const newTask = 'cypress/fixtures/task-to-import.json';
  cy.readFile(newTask).then((obj) => {
    obj.tasks.[0].name = `imported-task-${random}`;
    cy.writeFile(newTask, obj);
  });
  cy.get('[type="file"]').selectFile(newTask, { force: true });
  cy.contains('button', 'Import').click();
  cy.contains('task(s) created');

  cy.visit('dashboard/#/tasks-jobs/tasks');
  cy.contains('Group Actions').click();
  cy.get('[aria-label="Select All"]').click({ force: true });
  cy.contains('Destroy task').click();
  cy.contains('Destroy the task').click();
  cy.contains('task definition(s) destroyed');
});
