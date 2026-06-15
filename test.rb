# test.rb
class User < ApplicationRecord
  belongs_to :organization
  has_many :projects
end
