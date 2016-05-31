require 'date'

class Date
  def self.zero
    Date.parse('0000-01-01')
  end

  def days_since_zero
    (self - self.class.zero).to_i
  end

  def weeks_since_zero
    cweek + 52 * year
  end

  def months_since_zero
    month + 12 * year
  end

  def weekend?
    saturday? || sunday?
  end

  def weekday?
    !weekend?
  end
end
