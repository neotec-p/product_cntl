class WasherProductionSeq < ActiveRecord::Base
  belongs_to :washer
  belongs_to :production
end
