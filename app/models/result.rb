class Result < ActiveRecord::Base
  # Associations

  # Scopes
  scope :runner_win, ->() { where(winning_side: "runner") }
  scope :corp_win, ->() { where(winning_side: "corp") }
  scope :draw, ->() { where(winning_side: "draw") }

  # Methods
  def runner_win?
    self.winning_side == "runner"
  end

  def corp_win?
    self.winning_side == "corp"
  end

  def draw?
    self.winning_side == "draw"
  end
end
