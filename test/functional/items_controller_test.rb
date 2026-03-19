require 'test_helper'

# Stub Pusher so tests do not make real HTTP calls.
module Pusher
  def self.[](channel); PusherChannelStub.new; end

  class PusherChannelStub
    def trigger(*); true; end
  end
end

class ItemsControllerTest < ActionController::TestCase
  setup do
    @list = List.create!
    @item = @list.items.create!(shortdesc: 'Initial item', isdone: false)
  end

  # ------------------------------------------------------------------
  # index
  # ------------------------------------------------------------------
  test 'GET index returns json list of items' do
    get :index, token: @list.token
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert_equal @list.items.count, json.length
  end

  test 'GET index returns 404 for unknown token' do
    get :index, token: 'nonexistent'
    assert_response :not_found
  end

  # ------------------------------------------------------------------
  # show
  # ------------------------------------------------------------------
  test 'GET show returns the requested item' do
    get :show, token: @list.token, id: @item.id
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @item.shortdesc, json['shortdesc']
  end

  # ------------------------------------------------------------------
  # create
  # ------------------------------------------------------------------
  test 'POST create adds a new item and returns 201' do
    assert_difference '@list.items.count', 1 do
      post :create, token: @list.token, shortdesc: 'New task', isdone: false
    end
    assert_response :created
  end

  # ------------------------------------------------------------------
  # update
  # ------------------------------------------------------------------
  test 'PUT update modifies an existing item' do
    put :update, token: @list.token, id: @item.id, shortdesc: 'Updated', isdone: true
    assert_response :success
    @item.reload
    assert_equal 'Updated', @item.shortdesc
    assert @item.isdone
  end

  # ------------------------------------------------------------------
  # destroy
  # ------------------------------------------------------------------
  test 'DELETE destroy removes the item' do
    assert_difference '@list.items.count', -1 do
      delete :destroy, token: @list.token, id: @item.id
    end
    assert_response :success
  end
end
