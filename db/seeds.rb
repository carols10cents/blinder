# Core Event & associated Blinds
event = Event.create! title: 'Rust Belt Rust 2019',
  blind_level: 0,
  human_key: "rbr2019",
  slug: "rbr2019",
  active: true,
  info: File.read('db/texts/event_info.md')

personal_info = Blind.create! event: event,
  level: 5,
  title: "Personal &amp; Contact Information",
  info: "Your identifying information is not available to the selection committee until the last round of evaluation. We will never share or publish any of your information without your explicit permission.",
  position: 0

talk_info = Blind.create! event: event,
  level: 1,
  title: "Talk Information",
  info: "The information in this section is the primary data used during proposal evaluation and selection. Please do not include identifying information in this section.",
  position: 1

balancing_info = Blind.create! event: event,
  level: 2,
  title: "Balancing Information",
  info: "This information is not given to the selection committee until a late round in the selection process. It is used to provide contextual information about proposals and provides additional differentiation between similarly strong proposals. There are no wrong answers!",
  position: 2

make_life_easier = Blind.create! event: event,
  level: 10,
  title: "Making Life Easier",
  info: "If your proposal is selected, there are a few pieces of information we need to properly celebrate/publicize/set up for your talk. These items are not shared with the selection committee, but they really do make our lives easier. :)",
  position: 4

position = -1
def position(reset = false)
  position = -1 if reset
  position = position + 1
end

consent_label = <<-CONSENT
Do you consent to this conference recording your talk/presentation and then distributing the video on the internet with a CC-BY license?
CONSENT

conduct_label = <<-CONDUCT
Do you agree to abide by the <a href="https://rust-belt-rust.com/conduct/">code of conduct</a>?
CONDUCT

# Questions for the Blinds!
Question.create! blind: personal_info, required: true, label: "Name", kind: "text", position: position(true)
Question.create! blind: personal_info, required: true, label: "Email Address", kind: "email", position: position
Question.create! blind: personal_info, required: true, label: "Phone Number (ex 1 412 555 5555)", kind: "tel", position: position
Question.create! blind: personal_info, required: false, label: "Twitter", kind: "text", position: position
Question.create! blind: personal_info, required: false, label: "Main Website", kind: "text", position: position
Question.create! blind: personal_info, required: true, label: consent_label, kind: "radio", values: "Yes,No", position: position, group: "recording_consent"
Question.create! blind: personal_info, required: true, label: conduct_label, kind: "radio", values: "Yes,No", position: position, group: "conduct"
Question.create! blind: personal_info, required: false, label: "Anything else you'd like us to know?", kind: "textarea", position: position


Question.create! blind: talk_info, required: true, label: "Talk Title", kind: "text", position: position(true)
Question.create! blind: talk_info, required: true, label: "Talk Abstract (what will go on the website to promote your talk)", kind: "textarea", position: position
Question.create! blind: talk_info, required: false, label: "Notes for reviewers (additional info about what you might cover, any logistical needs you might have)", kind: "textarea", position: position
Question.create! blind: talk_info, required: true, label: "What format would work best for this talk?", kind: "radio", values: "30 minute talk,3 hour workshop,6 hour workshop,Any/other (please explain in the next field)", position: position, group: "format"
Question.create! blind: talk_info, required: false, label: "If you answered 'Any/other' for the format question, please explain here:", kind: "textarea", position: position
Question.create! blind: talk_info, required: true, label: "Who's your ideal audience?", kind: "textarea", position: position
Question.create! blind: talk_info, required: true, label: "Why are you excited to talk about this?", kind: "textarea", position: position

Question.create! blind: balancing_info, required: false, label: "What is your previous speaking experience? We'd like to have a good mix of new and experienced speakers.", kind: "textarea", position: position(true)
Question.create! blind: balancing_info, required: false, label: "Have you presented on this topic at other events? If so, where and when?", kind: "textarea", position: position
Question.create! blind: balancing_info, required: false, label: "Are you from the Rust Belt? We'd love to have some speakers from the region as well as people from outside it!", kind: "textarea", position: position

Question.create! blind: make_life_easier, required: true, label: "Bio for the website, about a paragraph", kind: "textarea", position: position
Question.create! blind: make_life_easier, required: true, label: "URL to a headshot or avatar", kind: "text", position: position(true)
Question.create! blind: make_life_easier, required: true, label: "Will you need childcare?", kind: "radio", values: "Yes,No", position: position, group: "childcare"

# Admin users
admins = [
  { uid: 193874,  name: 'carols10cents' },
]

admins.each do |admin|
  User.create! uid: admin[:uid], name: admin[:name], role: 'admin', provider: 'github'
end
#
# # Review users
# reviewers = [
#   { uid: 22222,  name: 'Someone Else' }
# ]
#
# reviewers.each do |reviewer|
#   User.create! uid: reviewer[:uid], name: reviewer[:name], role: 'reviewer', provider: 'github'
# end
