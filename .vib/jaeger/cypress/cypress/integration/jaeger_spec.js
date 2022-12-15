/// <reference types="cypress" />

it('lists and retrieves jaeger traces', () => {

  const testService = 'redis';
  const currentDate = new Date();
  const timestampMillis = currentDate.getTime() * 1000;

  cy.visit(`/search?end=${timestampMillis}&limit=20&lookback=1h&maxDuration&minDuration&service=${testService}&start=0`)

  // Ensure page contains Traces in an H2 tag
  cy.contains('h2', 'Traces');

  cy.get('a.ResultItemTitle--item.ub-flex-auto').invoke('attr', 'href').then((href) => {
    const traceID = href.substring(href.lastIndexOf('/') + 1, href.length);

    cy.request({
      method: 'GET',
      url: '/api/traces/' + traceID
    }).then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body.data[0].traceID).to.eq(traceID);
    });
  })

});
