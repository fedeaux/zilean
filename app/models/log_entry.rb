class LogEntry < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  def trim(log_entry)
    affected_log_entries = []

    if started_at < log_entry.started_at and finished_at > log_entry.finished_at
      new_log_entry = LogEntry.new attributes.except('id')
      new_log_entry.started_at = log_entry.finished_at

      new_log_entry.save if persisted?
      affected_log_entries << new_log_entry

      self.finished_at = log_entry.started_at
      affected_log_entries << self

    elsif started_at < log_entry.started_at and finished_at > log_entry.started_at
      self.finished_at = log_entry.started_at
      affected_log_entries << self

    elsif started_at > log_entry.started_at and log_entry.started_at < finished_at
      self.started_at = log_entry.finished_at
      affected_log_entries << self
    end

    if started_at >= finished_at
      destroy
    elsif persisted?
      save
    end

    affected_log_entries
  end

  def colliding_log_entries
    {
      left: user.log_entries.where("started_at < :started_at AND
                                    finished_at >= :started_at AND
                                    finished_at <= :finished_at",
                                    finished_at: finished_at, started_at: started_at),

      right: user.log_entries.where("finished_at > :finished_at AND
                                     started_at >= :started_at AND
                                     started_at <= :finished_at",
                                     finished_at: finished_at, started_at: started_at),

      wrapper: user.log_entries.where("started_at < :started_at AND finished_at > :finished_at",
                                       finished_at: finished_at, started_at: started_at),

      wrapped: user.log_entries.where("started_at >= :started_at AND finished_at <= :finished_at",
                                       finished_at: finished_at, started_at: started_at),
    }
  end
end
