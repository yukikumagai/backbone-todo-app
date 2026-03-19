require 'test_helper'

class ListTest < ActiveSupport::TestCase
  test 'creates a token automatically before saving' do
    list = List.create!
    assert_not_nil list.token, 'token should be set'
    assert list.token.length > 0
  end

  test 'token contains only channel-safe characters' do
    list = List.create!
    assert_match(/\A[A-Za-z0-9\-_]+\z/, list.token)
  end

  test 'find_by_token returns the correct list' do
    list = List.create!
    found = List.find_by_token(list.token)
    assert_equal list.id, found.id
  end

  test 'find_by_token returns nil for unknown token' do
    assert_nil List.find_by_token('does_not_exist')
  end

  test 'total_count reflects the number of items' do
    list = List.create!
    assert_equal 0, list.total_count
    list.items.create!(shortdesc: 'Task A')
    list.reload
    assert_equal 1, list.total_count
  end

  test 'remaining_count excludes completed items' do
    list = List.create!
    list.items.create!(shortdesc: 'Task A', isdone: false)
    list.items.create!(shortdesc: 'Task B', isdone: true)
    list.reload
    assert_equal 1, list.remaining_count
  end

  test 'channel_name contains the Rails environment' do
    list = List.create!
    assert list.channel_name.include?(Rails.env)
  end

  test 'dependent items are destroyed when the list is destroyed' do
    list = List.create!
    list.items.create!(shortdesc: 'Task to clean up')
    item_ids = list.items.map(&:id)
    list.destroy
    item_ids.each do |id|
      assert_nil Item.find_by_id(id), "Item #{id} should have been destroyed"
    end
  end
end
