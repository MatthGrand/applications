/// <reference types="cypress" />
import { random } from '../support/utils';

it('allows a user to add an item and register', () => {
  cy.visit('/en-gb/product/macbook');
  cy.contains('Add to Cart').click();
  cy.contains('You have added');
  cy.visit('/index.php?route=checkout/checkout');
  cy.fixture('customers').then((customer) => {
    cy.get('#input-firstname').type(
      `${customer.newCustomer.firstName}.${random}`
    );
    cy.get('#input-lastname').type(
      `${customer.newCustomer.lastName}.${random}`
    );
    cy.get('#input-email').type(`${customer.newCustomer.email}`);
    cy.get('#input-password').type(`${customer.newCustomer.password}`);
    cy.get('#input-shipping-address-1').type(`${customer.newCustomer.address}`);
    cy.get('#input-shipping-city').type(customer.newCustomer.city);
    cy.get('#input-shipping-postcode').type(customer.newCustomer.postCode);
    cy.get('#input-shipping-zone').select(customer.newCustomer.zone);
  });
  cy.get('#agree').click();
  cy.get('#button-register').click();
  cy.contains('Your account has been created');
  cy.login();
  cy.contains('Customers').click();
  cy.contains(`ul li ul li a`, 'Customers').click();
  cy.fixture('customers').then((customer) => {
  cy.contains(`${customer.newCustomer.email}`);
  });
});

it('allows an admin to add a product to the catalog', () => {
  cy.login();
  cy.contains('Catalog').click();
  cy.contains('Product').click();
  cy.get('a.btn.btn-primary i.fa-solid.fa-plus').click();
  cy.fixture('products').then((product) => {
    cy.get('#input-name-1').type(`${product.newProduct.name}.${random}`);
    cy.get('#input-meta-title-1').type(product.newProduct.metatagTitle);
    cy.contains('Data').click();
    cy.get('#input-model').type(product.newProduct.model);
    cy.get('#input-keyword-0-1').type(product.newProduct.model, { force: true });
    cy.get('button.btn.btn-primary i.fa-solid.fa-floppy-disk').click();
    cy.contains('Success');
    cy.visit('/');
    cy.get('[name="search"]').type(
      `${product.newProduct.name}.${random} {enter}`
    );
    cy.get('#content').contains(`${product.newProduct.name}.${random}`);
  });
});
