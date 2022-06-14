/// <reference types="cypress" />
import body from '../fixtures/logs-body.json';

it('shows build info endpoint', () => {
  cy.request({
    method: 'GET',
    url: '/loki/api/v1/status/buildinfo',
    form: true,
  }).then((response) => {
    expect(response.status).to.eq(200);

    expect(response.body).to.include.all.keys(
      'version',
      'revision',
      'branch',
      'buildUser',
      'goVersion'
    );
  });
});

it('allows Loki to get Grafana logs', () => {
  cy.request({
    method: 'GET',
    url: 'loki/api/v1/query?query={app="grafana-loki"}',
    form: true,
  }).then((response) => {
    expect(response.status).to.eq(200);
    expect(response.headers['content-type']).to.eq(
      'application/json; charset=UTF-8'
    );
  });
});

it('checks Loki range endpoint', () => {
  cy.request({
    method: 'GET',
    url: 'loki/api/v1/query?query={job="varlogs"}',
    form: true,
  }).then((response) => {
    expect(response.status).to.eq(200);
    expect(response.headers['content-type']).to.eq(
      'application/json; charset=UTF-8'
    );
    expect(response.body.data.stats.summary).not.to.be.empty;
    expect(response.body.data.stats).to.include.all.keys(
      'summary',
      'querier',
      'ingester'
    );
  });
});

it('can publish logs to the endpoint', () => {
  cy.request({
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    url: 'loki/api/v1/push',
    body: body,
  }).then((response) => {
    expect(response.status).to.eq(204);
    expect(response.headers['content-type']).to.eq(
      'application/json; charset=UTF-8'
    );
  });
});

it('can get a list of series', () => {
  cy.request({
    method: 'GET',
    url: 'loki/api/v1/series',
    form: true,
  }).then((response) => {
    expect(response.status).to.eq(200);
  });
});
