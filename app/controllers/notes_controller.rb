require_relative '../../lib/has_access'

class NotesController < ApplicationController
  include HasAccess
  before_filter :authenticate!
  before_filter :has_access?

  def create
    note = current_user.notes.build note_ajax_params[:note]
    render json: { success: note.save, message: note.save_message }
  end

  def update
    note = current_user.notes.find params[:id]
    note.update note_ajax_params[:note]
    render json: { success: note.save, message: note.save_message }
  end

  protected

  def note_ajax_params
    params.permit(note: [:proposal_id, :content])
  end

end
