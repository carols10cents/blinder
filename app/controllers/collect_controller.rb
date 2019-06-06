class CollectController < ApplicationController

  ROBOT_ERROR = "There was a problem validating your <span>human key</span>. Please try again.".html_safe

  def home
    if params[:event_slug]
      @event = Event.where(slug: params[:event_slug]).first!.decorate
    else
      @event = Event.active.any? ? Event.active.first.decorate : Event.last.decorate
    end
  end

  def new
    if params[:event_slug]
      @event = Event.where(slug: params[:event_slug]).includes(blinds: :questions).first
    else
      @event = Event.active.any? ? Event.active.includes(blinds: :questions).first : Event.includes(blinds: :questions).last
    end
    @event = @event.decorate

    redirect_to root_path unless @event.can_propose?

    @proposal = Proposal.new

    @event.blinds.each do |blind|
      blind.new_responses_for @proposal
    end
  end

  def create
    @proposal   = Proposal.new(proposal_create_params)
    @event      = Event.where(slug: params[:event_slug]).first
    @proposal.event = @event

    @is_a_human = @event.is_a_human?(params[:human_key])

    params.permit! # this is a terrible idea; someone please do this right.
    params[:responses].map { |hash|
      if hash[:value].is_a? Hash
        hash[:value] = hash[:value].values.first
      end
      hash
    }
    @proposal.responses.build(params[:responses])

    if @is_a_human && @proposal.save
      send_confirmation_email
      redirect_to thanks_path @proposal.slug
    else
      add_errors
      @event.blinds.each do |blind|
        blind.posted_responses_for @proposal
      end

      render action: :new
    end
  end

  def edit
    redirect_to root_path unless params[:slug]

    @proposal = Proposal.includes(responses: { question: :blind }).find_by_slug(params[:slug])
    @event = @proposal.event.decorate

    @event.blinds.each do |blind|
      blind.existing_responses_for @proposal
    end

    render action: @event.can_propose? ? :new : :home #lolhacky
  end

  def update
    @proposal   = Proposal.includes(:event, :responses).find(params[:id])
    @event      = @proposal.event
    @is_a_human = @event.is_a_human?(params[:human_key])

    @proposal.responses.each do |response|
      selected = response_update_params.find { |param| param[:id] == response.id.to_s }
      if selected[:value].is_a? Hash
        selected[:value] = selected[:value].values.first
      end
      response.update(selected) if selected
    end

    if @is_a_human && @proposal.save
      send_confirmation_email
      redirect_to thanks_path @proposal.slug
    else
      add_errors
      @event.blinds.each do |blind|
        blind.posted_responses_for @proposal
      end

      render action: :new
    end
  end

  def thanks
    @proposal = Proposal.includes(event: { blinds: :questions }).find_by_slug params[:slug]
  end

  protected

  def add_errors
    @errors = @proposal.valid? ? { :"responses.base" => [] } : @proposal.errors.messages
    @errors[:"responses.base"].push(ROBOT_ERROR) unless @is_a_human
  end

  def proposal_create_params
    params.permit(:event_id, :slug, :responses)
  end

  def response_update_params
    params.permit!
    params[:responses]
  end

  def send_confirmation_email
    ConfirmationMailer.confirmation_email(@proposal).deliver_later
  end
end
