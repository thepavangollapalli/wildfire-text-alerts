class WildfireTextAlert < ApplicationRecord
    belongs_to :user, dependent: :destroy

    validates :msg_digest, uniqueness: { scope: [:user, :zip], message: "no repeated messages to user" }
end
