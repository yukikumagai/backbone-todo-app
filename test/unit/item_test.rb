require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def setup
    @list = List.create!
    @item = @list.items.build(shortdesc: 'Buy milk', isdone: false)
  end

  test 'is valid with a shortdesc and a list' do
    assert @item.valid?
  end

  test 'is invalid without a shortdesc' do
    @item.shortdesc = nil
    assert_not @item.valid?
    assert @item.errors[:shortdesc].any?
  end

  test 'is invalid without a list' do
    @item.list = nil
    assert_not @item.valid?
    assert @item.errors[:list].any?
  end

  test 'as_json excludes longdesc and list_id' do
    @item.save!
    json = @item.as_json
    assert_not json.key?('longdesc'),  'longdesc should be excluded'
    assert_not json.key?('list_id'),   'list_id should be excluded'
    assert json.key?('shortdesc'),     'shortdesc should be present'
  end
end
