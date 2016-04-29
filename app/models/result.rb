class Result < ActiveRecord::Base
  # Associations

  # Scopes
  scope :runner_win, ->() { where(winning_side: "runner") }
  scope :corp_win, ->() { where(winning_side: "corp") }
  scope :draw, ->() { where(winning_side: "draw") }

  # Methods
end
