require "test/unit"
require "date"
require_relative './contract'

class ContractTest < Test::Unit::TestCase

  def test_contract_is_setup_correctly
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    contract = Contract.new(100.0, product)
    assert_equal 100, contract.purchase_price
    assert_equal "PENDING", contract.status
    assert_equal Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0"), contract.covered_product
  end

  # entities compare by unique IDs, not properties
  def test_contract_equality
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    contract = Contract.new(100.0, product)

    contract_same_id         = contract.clone
    contract_same_id.status  = "ACTIVE"

    assert_equal     contract, contract_same_id

    contract_different_id = Contract.new(100.0, product)
    assert_not_equal contract, contract_different_id
  end

  def test_contract_limit_of_liability_default
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    contract = Contract.new(100.0, product)
    contract2 = Contract.new(200.0, product)

    assert_equal 80.0, contract.limit_of_liability
    assert_equal 160.0, contract2.limit_of_liability
  end

  def test_contract_limit_of_liability_with_existing_claim
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    contract = Contract.new(1000.0, product)
    claim = Claim.new(500.0, Date.new(2010, 5, 8))
    contract.claims << claim

    assert_equal 400.0, contract.limit_of_liability
  end

  def test_active?
    product  = Product.new("dishwasher", "OEUOEU23", "Whirlpool", "7DP840CWDB0")
    contract = Contract.new(100.0, product)

    contract.status          = "ACTIVE"
    contract.effective_date  = Date.new(2010, 5, 8)
    contract.expiration_date = Date.new(2012, 5, 8)

    assert contract.active?(Date.new(2011, 5, 8))
    refute contract.active?(Date.new(2013, 5, 8))
    refute contract.active?(Date.new(2009, 5, 8))

    contract.status = "PENDING"
    refute contract.active?(Date.new(2011, 5, 8))
  end
end
