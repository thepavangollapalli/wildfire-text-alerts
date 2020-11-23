class WildfireTextAlert < ApplicationRecord
    belongs_to :user, dependent: :destroy

    validates :msg_hash, uniqueness: { scope: [:user, :zip], message: "no repeated messages to user" }
end
