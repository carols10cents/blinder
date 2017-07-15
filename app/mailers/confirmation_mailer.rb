class ConfirmationMailer < ActionMailer::Base
  default from: ENV['CFP_FROM']

  def confirmation_email(proposal)
    @proposal = proposal
    mail to:        proposal.get_email_address,
         subject:   "Thank you for submitting to #{ proposal.event.title }!",
         tag:       'cfp-thanks',
         html_body: render_to_string(layout: false, template: "collect/thanks"),
         layout:    false
  end

end