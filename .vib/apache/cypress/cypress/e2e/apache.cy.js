/*
 * Copyright Broadcom, Inc. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0
 */

/// <reference types="cypress" />

it('visits the apache start page', () => {
  cy.visit('/');
  cy.contains('It works');
});

