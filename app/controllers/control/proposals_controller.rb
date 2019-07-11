require 'csv'

class Control::ProposalsController < ControlController
  def index
    @event  = Event.where(slug: params[:event_slug]).first
    @unsafe = @event.proposals.unsafe
    @safe   = @event.proposals.safe

    format_question = Question.where(label: "What format would work best for this talk?").first
    @talk_formats = format_question.values.split(",")
  end

  def export
    @event  = Event.where(slug: params[:event_slug]).first
    format_question = Question.where(label: "What format would work best for this talk?").first
    fmt = params[:fmt]
    proposal_ids = Response.where(question_id: format_question.id, value: fmt).pluck(:proposal_id)
    proposals = @event.proposals.safe.where(id: proposal_ids)

    title_q = Question.where(label: "Talk Title").first
    name_q = Question.where(label: "Name").first
    prev_speaking_q = Question.where(label: "What is your previous speaking experience? We'd like to have a good mix of new and experienced speakers.").first
    prev_given_q = Question.where(label: "Have you presented on this topic at other events? If so, where and when?").first
    rust_belt_q = Question.where(label: "Are you from the Rust Belt? We'd love to have some speakers from the region as well as people from outside it!").first

    data = CSV.generate(headers: true) do |csv|
      csv << ["Link", "Title", "Average Score", "Name", "Previous Speaking","Previously given this talk", "Rust Belt"]
      proposals.each do |p|
        link = review_url(proposal_id: p.id)
        title = p.responses.where(question_id: title_q.id).first.value

        scores = Note.where(proposal: p).where('score IS NOT NULL').pluck(:score)
        num_scores = scores.count
        total = scores.sum
        avg = num_scores == 0 ? "n/a" : "%0.2f" % (total / num_scores)

        name = p.responses.where(question_id: name_q.id).first.value

        prev_speaking = p.responses.where(question_id: prev_speaking_q.id).first.value
        prev_given = p.responses.where(question_id: prev_given_q.id).first.value
        rust_belt = p.responses.where(question_id: rust_belt_q.id).first.value
        csv << [link, title, avg, name, prev_speaking, prev_given, rust_belt]
      end
    end
    send_data data, type: 'text/csv; charset=utf-8; header=present', filename: "#{fmt}.csv"
  end

  def edit
    @proposal = Proposal.includes(responses: :scrub, event: :questions).find params[:id]
    @notes    = current_user.notes_for @proposal
    @proposal.event.blinds.each do |blind|
      blind.existing_responses_for @proposal
    end
  end

  def update
    @proposal = Proposal.find params[:id]
    @proposal.safe_for_review = params[:proposal][:safe_for_review]

    if @proposal.save
      flash[:notice] = "Proposal updated!"
      redirect_to action: :index
    else
      flash[:notice] = "Something went terribly wrong."
      redirect_to action: :edit
    end
  end

  def destroy
    Proposal.find(params[:id]).destroy
    redirect_to :back, notice: "Proposal destroyed!"
  end

  def scrub
    scrub = Scrub.find_or_create_by(response_id: scrub_ajax_params[:scrub][:response_id])
    scrub.update scrub_ajax_params[:scrub]
    render partial: 'review/response', locals: { response: scrub.response.decorate }
  end

  protected

  def scrub_ajax_params
    params.permit(scrub: [:response_id, :blind_level, :value])
  end

end
