require 'models/semester_period'

Fabricator(:semester_period) do
  faculty_semester
  type :teaching
  first_week_parity :odd
  starts_at '2014-09-22'
  ends_at '2015-02-14'
end

Fabricator(:teaching_semester_period, from: :semester_period) do
  type :teaching
  first_week_parity :odd
  starts_at '2014-09-22'
  ends_at '2014-12-20'
end

Fabricator(:holiday_semester_period, from: :semester_period) do
  type :holiday
  first_week_parity nil
  starts_at '2014-12-21'
  ends_at '2015-01-04'
end

Fabricator(:exams_semester_period, from: :semester_period) do
  type :exams
  first_week_parity nil
  starts_at '2015-01-05'
  ends_at '2015-02-14'
end
