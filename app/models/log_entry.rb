class LogEntry < ApplicationRecord
  belongs_to :user
  belongs_to :activity

  scope :today, -> {
    on_day
  }

  scope :on_day, -> (day = Time.current) {
    start = day.beginning_of_day - Time.zone.utc_offset
    finish = day.end_of_day - Time.zone.utc_offset

    on_period start, finish
  }

  scope :on_period, -> (start, finish) {
    where("(started_at >= :start AND started_at < :finish) OR
           (finished_at > :start AND finished_at < :finish)", start: start, finish: finish)
  }

  def self.create(attributes)
    new_log_entry = LogEntry.new attributes
    affected_log_entries = []

    new_log_entry.colliding_log_entries.each do |collided_log_entry|
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

    unless new_log_entry.persisted?
      new_log_entry.save
      affected_log_entries << new_log_entry
    end

    affected_log_entries
  end

  def self.crop(start, finish, user)
    cropping_log_entry = LogEntry.new started_at: start, finished_at: finish, user: user
    affected_log_entries = []

    cropping_log_entry.colliding_log_entries.each do |collided_log_entry|
      if collided_log_entry
        # always reload because log entries can change between iterations
        collided_log_entry.reload
        affected_log_entries += collided_log_entry.trim(cropping_log_entry)
      end
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

  def collision_with(log_entry)
    if log_entry.started_at < started_at
      if log_entry.finished_at < started_at
        false

      elsif log_entry.finished_at == started_at
        :left

      elsif log_entry.finished_at > started_at
        if log_entry.finished_at < finished_at
          :left

        elsif log_entry.finished_at >= finished_at
          :wrapping
        end
      end

    elsif log_entry.started_at == started_at
      if finished_at <= log_entry.finished_at
        :wrapping

      else
        :left
      end

    elsif log_entry.started_at > started_at and log_entry.started_at < finished_at
      if log_entry.finished_at < finished_at
        :wrapped

      elsif log_entry.finished_at >= finished_at
        :right
      end

    elsif log_entry.started_at == finished_at
      :right

    elsif log_entry.started_at > finished_at
      false
    end
  end

  def trim(log_entry)
    affected_log_entries = []

    collision_type = collision_with log_entry

    if collision_type == :wrapping
      destroy
      affected_log_entries << self

    elsif collision_type == :left
      self.started_at = log_entry.finished_at
      affected_log_entries << self

    elsif collision_type == :right
      self.finished_at = log_entry.started_at
      affected_log_entries << self

    elsif collision_type == :wrapped
      new_log_entry = LogEntry.new attributes.except('id')
      new_log_entry.started_at = log_entry.finished_at

      new_log_entry.save if persisted?
      affected_log_entries << new_log_entry

      self.finished_at = log_entry.started_at
      affected_log_entries << self
    end

    if persisted?
      save
    end

    affected_log_entries
  end

  def colliding_log_entries
    user.log_entries.where("(started_at >= :started_at AND
                             started_at <= :finished_at)

                            OR

                            (finished_at >= :started_at AND
                             finished_at <= :finished_at)

                            OR

                            (started_at < :started_at AND
                             finished_at > :finished_at)
      ",

      finished_at: finished_at, started_at: started_at).to_a
  end
end
