module CollectHelper
  def input_for(response)
    id      = "#{response.question.id}_value"
    name    = "responses[][value]"
    values  = response.question.values.blank? ? nil : response.question.values.split(',')

    case response.question.kind
      when "text"     then text_field_tag(name, response.value, id: id)
      when "tel"      then telephone_field_tag(name, response.value, id: id)
      when "email"    then email_field_tag(name, response.value, id: id)
      when "textarea" then text_area_tag(name, response.value, id: id)
      when "radio"    then radio_group(name, response.question.group, id, values, response.value)
      else ""
    end
  end

  def size_class_for(response)
    "large"
  end

  def classes_for(question)
    question.required? ? "required" : ""
  end

  def form_title_for(proposal)
    if proposal.new_record?
      "Submit a New Proposal"
    else
      "Edit Your Proposal."
    end
  end

  protected

  def radio_group(name, group, id, values, selected)
    values.each_with_index.map { |value, index|
      indexed_id = "#{id}_#{index}"
      button = radio_button_tag "#{name}_#{group}", value, selected == value, id: indexed_id
      label_tag indexed_id, class: 'radio' do
        button + value
      end
    }.reduce &:+
  end
end