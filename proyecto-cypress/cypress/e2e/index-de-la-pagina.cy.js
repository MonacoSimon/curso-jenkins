describe('template spec', () => {
  it('passes', () => {
    cy.visit('https://mail.google.com/mail/u/0/#inbox')
    cy.get('#headingText > span').should('be.visible')
  })
})