class ProfilesTags < ActiveRecord::Base
  belongs_to :profile
  belongs_to :tag
end
