class LogEntry < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  scope :today, -> {
    on_day Time.current
  }

  scope :on_day, -> (day = Time.current) {
    start = day.in_time_zone(Time.zone).beginning_of_day
    finish = day.in_time_zone(Time.zone).end_of_day

    on_period start, finish
  }

  scope :on_period, -> (start, finish) {
    where("(started_at >= :start AND started_at < :finish) OR
           (finished_at > :start AND finished_at < :finish)", start: start, finish: finish)
  }

  def self.create(attributes)
    new_log_entry = LogEntry.new attributes
    collisions = new_log_entry.colliding_log_entries
    affected_log_entries = []

    collisions.each do |collision_type, collided_log_entries|
      collided_log_entries.each do |collided_log_entry|
        if collided_log_entry
          # always reload because log entries can change between iterations
          collided_log_entry.reload

          # first it tries to merge both entries, if it is not possible, just trims the previous entry
          # anytime a merge succeeds, creating the task is unnecessary
          if collided_log_entry.merge(new_log_entry)
            new_log_entry = collided_log_entry
            affected_log_entries << collided_log_entry

          else
            affected_log_entries += collided_log_entry.trim(new_log_entry)
          end
        end
      end
    end

    unless new_log_entry.persisted?
      new_log_entry.save
      affected_log_entries << new_log_entry
    end

    affected_log_entries
  end

  def duration
    finished_at - started_at
  end

  def mergeable?(log_entry)
    activity.id == log_entry.activity.id and
      user.id == log_entry.user.id and
      (observations.blank? or log_entry.observations.blank? or observations == log_entry.observations)
  end

  def merge(log_entry)
    if mergeable? log_entry
      attributes = { started_at: [started_at, log_entry.started_at].min, finished_at: [finished_at, log_entry.finished_at].max }
      attributes[:observations] = log_entry.observations if observations.blank?

      if persisted?
        update attributes
      else
        assign_attributes attributes
      end

      if log_entry.persisted?
        log_entry.destroy
      end

      self
    else
      false
    end
  end

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
                                    finished_at: finished_at, started_at: started_at).to_a,

      right: user.log_entries.where("finished_at > :finished_at AND
                                     started_at >= :started_at AND
                                     started_at <= :finished_at",
                                     finished_at: finished_at, started_at: started_at).to_a,

      wrapper: user.log_entries.where("started_at < :started_at AND finished_at > :finished_at",
                                       finished_at: finished_at, started_at: started_at).to_a,

      wrapped: user.log_entries.where("started_at >= :started_at AND finished_at <= :finished_at",
                                       finished_at: finished_at, started_at: started_at).to_a,
    }
  end
end
