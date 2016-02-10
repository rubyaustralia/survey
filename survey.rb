# TODO:
# - [ ] put in a real git repo for ruby australia
# - [ ] get some review by survey people on validity of interpretation of some things
# - [ ] figure out if i can safely/anonymously share raw csv, or how to filter it
# - [ ] make mad professional pdf of report to launch at rubyconf
#
require 'csv'
require 'pp'

def column_values_by_count(rows, header_key)
  rows.each_with_object(Hash.new(0)) { |r, h| v=r[header_key].to_s; h[v] += 1 if v != "" }
end

def normalise_values_and_combine_counts(values_by_count, &normalise_function)
  values_by_count.each_with_object(Hash.new(0)) { |r, h| k,v=*r; nk=normalise_function.call(k, v); h[nk] += v if nk!=nil }
end

rows = File.open('survey.csv', 'r') { |f| CSV.new(f.read, :headers => true, :header_converters => :symbol, :converters => :all) }.to_a.map(&:to_hash)

# DEMOGRAPHICS
demographics = [
  :how_old_are_you,
  :whats_your_highest_level_of_education_completed,
  :what_is_your_australian_residency_status,
  :which_state_or_territory_do_you_live_in,
  :what_is_your_current_state_of_employment,
  :what_industry_is_your_employer_in,
  :have_you_attended_a_rubyconf_or_railscamp_in_australia_in_the_last_2_years
]
demographics.map { |k| puts k; pp column_values_by_count(rows, k); puts }

# Need Normalisation and/or care of interpretation
puts "gender"
gender_counts = normalise_values_and_combine_counts(column_values_by_count(rows, :whats_your_gender_identity)) do |k, _|
  case k
  when /female|woman|^f/i
    "female"
  when /male|mail|^m|bloke/i
    "male"
  else
    "other"
  end
end
pp gender_counts

# :how_many_years_have_you_been_programming_with_ruby,
puts "programming years"
programming_years_count = normalise_values_and_combine_counts(column_values_by_count(rows, :how_many_years_have_you_been_programming_with_ruby)) do |k, v|
  k
end

pp programming_years_count
# :how_many_years_have_you_been_working_professionally_with_ruby,
puts "working years"
working_years_count = normalise_values_and_combine_counts(column_values_by_count(rows, :how_many_years_have_you_been_working_professionally_with_ruby)) do |k, v|
  k
end
pp working_years_count

# :what_country_are_you_from,
# TODO originating in aus vs everywhere else
# then a table of where everyone else is from as percentage
puts "country"
country_counts = normalise_values_and_combine_counts(column_values_by_count(rows, :what_country_are_you_from)) do |k, v|
  case k
  when /australia/i
    "Australia"
  else
    "Everywhere else"
  end
end
pp country_counts

# EMPLOYER
employer_metrics = [
  :approximately_how_many_people_work_for_your_employer,
  :approximately_how_many_people_write_ruby_for_your_employer,
  :is_your_employer_actively_hiring_ruby_developers_right_now,
  :approximately_how_many_ruby_developers_has_your_employer_hired_in_the_past_12_months,
  :what_is_your_pretax_income,
]
employer_metrics.map { |k| puts k; pp column_values_by_count(rows, k); puts }

fib = [0, 1, 2, 3, 5, 8, 13, 21, 34, 55]
puts "years operating (bucketed)"
company_year_counts = normalise_values_and_combine_counts(column_values_by_count(rows, :how_many_years_has_your_employer_been_in_business)) do |k, v|
  nk = case k
  when /^\d+$/
    Integer(k)
  else
    nil
  end

  bucket = nil
  (0..fib.size).each do |i|
    begin
      if nk >= fib[i] && nk < fib[i + 1]
        bucket = "#{fib[i]} - #{fib[i + 1] - 1}"
        break
      end
    rescue
      bucket = "55+"
    end
  end

  bucket
end
pp company_year_counts

# RUBY AU
ruby_au_success_metrics = [
  :before_this_survey_were_you_previously_aware_of_ruby_australia_as_an_organisation,
  :what_work_location_policy_do_you_work_under,
]
ruby_au_success_metrics.map { |k| puts k; pp column_values_by_count(rows, k); puts }
