require 'securerandom'

require_relative './product'
require_relative './claim'

class Contract
  attr_reader   :id # unique id
  attr_reader   :purchase_price
  attr_reader   :covered_product

  attr_accessor :status
  attr_accessor :effective_date
  attr_accessor :expiration_date
  attr_accessor :purchase_date
  attr_accessor :in_store_guarantee_days

  attr_accessor :claims

  def initialize(purchase_price, covered_product)
    @id                 = SecureRandom.uuid
    @purchase_price     = purchase_price
    @status             = "PENDING"
    @covered_product    = covered_product
    @claims             = Array.new
  end

  # We should move this to the contract class
  # Should the limit of liability be calculated pre-claim
  # Magic number = 0.8 - 80%? of the contract purchase price? covered product purchase price?
  # contract lifecycle - dates and status
  def limit_of_liability
    claim_total = claims.sum(&:amount)
    (purchase_price - claim_total) * 0.8
  end

  def active?(date)
    date  >= effective_date &&
    date  <= expiration_date &&
    status == "ACTIVE"
  end

  # Equality for entities is based on unique id
  def ==(other)
    self.id == other.id
  end
end
