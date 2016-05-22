class ReportFlag < ActiveRecord::Base
  # Associations
  belongs_to :reporter, class_name: "User"
  belongs_to :reportee, polymorphic: true
  belongs_to :responder, class_name: "User"

  # Validations
  validates :description, presence: true
  validate :reporter_reportee_unique

  # State
  include AASM
  aasm do
    state :raised, initial: true
    state :upheld
    state :rejected

    event :uphold do
      transitions from: :raised, to: :upheld do
        guard do
          !self.response.blank?
        end
      end
    end
    event :reject do
      transitions from: :raised, to: :rejected do
        guard do
          !self.response.blank?
        end
      end
    end
  end

  # Methods
  def reportee_type
    return "League" if self[:reportee_type] == "Liga"
    return self[:reportee_type]
  end

  def may_respond?
    return true unless self.response.blank?
    self.errors.add(:response,"is required")
    return false
  end

  def responded?
    self.upheld? || self.rejected?
  end

  private
  def reporter_reportee_unique
    self.errors.add(:base,"You have already reported this #{self.reportee_type.downcase}") if ReportFlag.raised.where(reporter_id: self.reporter_id, reportee_type: self.reportee_type, reportee_id: self.reportee_id).where.not(id: self.id).any?
  end
end
