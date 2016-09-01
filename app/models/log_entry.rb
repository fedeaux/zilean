class LogEntry < ApplicationRecord
  belongs_to :user
  belongs_to :activity

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
