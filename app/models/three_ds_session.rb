class ThreeDsSession < ApplicationRecord
  include AASM

  attribute :uuid, default: -> { SecureRandom.uuid }
  
  aasm :state do
    state :created, initial: true
    state :otp_required
    state :completed
    state :failed

    event :otp do
      transitions from: :created, to: :otp_required
    end

    event :complete do
      transitions from: :otp_required, to: :completed
    end

    event :fail do
      transitions from: :otp_required, to: :failed
    end
  end
end
