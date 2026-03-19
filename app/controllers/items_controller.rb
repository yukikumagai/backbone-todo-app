class ItemsController < ApplicationController
  before_filter :find_list

  # GET /:token/items.json
  def index
    render json: @list.items
  end

  # GET /:token/items/:id.json
  def show
    item = @list.items.find(params[:id])
    render json: item
  end

  # POST /:token/items.json
  def create
    item = @list.items.create!(item_params)
    trigger_pusher_event('created', item.attributes)
    render json: item, status: :created
  end

  # PUT /:token/items/:id.json
  def update
    item = @list.items.find(params[:id])
    item.update_attributes!(item_params)
    trigger_pusher_event('updated', item.attributes)
    render json: item
  end

  # DELETE /:token/items/:id.json
  def destroy
    item = @list.items.find(params[:id])
    item.destroy
    trigger_pusher_event('destroyed', { id: params[:id] })
    render json: {}, status: :ok
  end

  private

  def find_list
    @list = List.find_by_token(params[:token])
    render json: { error: 'List not found' }, status: :not_found if @list.nil?
  end

  # Strong-parameter-style whitelist (Rails 3 style using explicit hash slice)
  def item_params
    params.slice(:shortdesc, :isdone)
  end

  def trigger_pusher_event(event_name, payload)
    Pusher[@list.channel_name].trigger(
      event_name,
      payload,
      request.headers['X-Pusher-Socket-ID']
    )
  rescue Pusher::Error => e
    Rails.logger.warn "Pusher trigger failed (#{event_name}): #{e.message}"
  end
end
