require 'period'
require 'sirius/enums/exception_type'

class ScheduleException < Sequel::Model

  def period
    Period.new(starts_at, ends_at)
  end

  def period=(new_period)
    self.starts_at = new_period.starts_at
    self.ends_at = new_period.ends_at
  end

  def exception_type
    Sirius::ExceptionType.from_numeric(super)
  end

  def exception_type=(new_type)
    super Sirius::ExceptionType.to_numeric(new_type)
  end

end
