require File.join(File.dirname(__FILE__), 'test_helper')

class User < ActiveRecord::Base
  acts_as_favorite_user
end

class Favorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :favorable, :polymorphic => true
end

class Book < ActiveRecord::Base
  acts_as_favorite
end

class Drink < ActiveRecord::Base
  acts_as_favorite
end

class Animal < ActiveRecord::Base
end

class Duck < Animal
  acts_as_favorite
end

class ActsAsFavoriteTest < Test::Unit::TestCase
  fixtures :users, :books, :drinks, :animals, :favorites

  def test_should_create_favorite
    assert_difference users(:james).favorites, :count do
      users(:james).has_favorite books(:agile)
    end
  end

  def test_dynamic_counter_should_return_true
    assert users(:josh).has_favorite_books?
  end

  def test_should_return_false_with_no_favorite_books
    assert_equal users(:george).has_favorite_books?, false
  end

  def test_should_add_items_to_favorites
    assert_difference Favorite, :count do
      users(:james).has_favorite drinks(:wine)
      assert users(:james).has_favorite?(drinks(:wine))
    end
  end

  def test_should_remove_from_favorites
    assert_difference users(:josh).favorites, :count, -1 do
      users(:josh).has_no_favorite drinks(:beer)
    end
  end

  def test_should_return_users_with_specified_favorite
    assert books(:ruby).favoriting_users.include?(users(:josh))
  end

  def test_should_add_and_remove_favorites
    assert users(:george).favorites.empty?

    assert_difference users(:george).favorites(true), :count, 3 do
      users(:george).has_favorite books(:agile)
      users(:george).has_favorite books(:ruby)
      users(:george).has_favorite books(:rails)
    end

    assert_equal users(:george).favorites(true).size, 3
    assert users(:george).favorite_books.size, 3

    assert_difference users(:george).favorites(true), :count, -2 do
      users(:george).has_no_favorite books(:agile)
      users(:george).has_no_favorite books(:ruby)
    end
    assert_equal users(:george).favorites(true).size, 1
    assert users(:george).favorite_books.size, 1

  end

  def test_add_should_work_with_subclasses
    duckie = Duck.create!
    assert users(:tobias).favorites.empty?

    users(:tobias).has_favorite duckie

    assert_equal users(:tobias).favorites(true).size, 1
    assert users(:tobias).has_favorite?(duckie)
    assert_equal users(:tobias).favorite_ducks.size, 1
  end

  def test_remove_should_work_with_subclasses
    duckie = Duck.create!
    assert users(:michael).favorites.empty?

    users(:michael).has_favorite duckie

    assert_equal users(:michael).favorites(true).size, 1
    assert users(:michael).has_favorite?(duckie)
    assert_equal users(:michael).favorite_ducks.size, 1

    users(:michael).has_no_favorite duckie
    assert_equal users(:michael).favorites(true).size, 0
    assert_equal users(:michael).favorite_ducks.size, 0
  end

end
