defmodule SqueezeWeb.CalendarView do
  use SqueezeWeb, :view

  def today do
    Timex.today()
  end

  def days_in_month do
    today()
    |> Date.days_in_month()
  end

  def weeks_in_month do
    days_in_month() / 7
  end

  def first_of_month do
    today = today()
    {:ok, date} = Date.new(today.year, today.month, 1)
    date
  end

  def last_day_of_month do
    today = today()
    {:ok, date} = Date.new(today.year, today.month, Date.days_in_month(today))
    date
  end

  def dates do
    Date.range(first_date(), last_date())
  end

  # 7 is Sunday in elxir
  def first_date() do
    date = first_of_month()
    day_of_week = Date.day_of_week(date)
    if day_of_week == 7 do
      date
    else
     Date.add(date, -day_of_week)
    end
  end

  # Last day is 6 Saturday
  def last_date() do
    date = last_day_of_month()
    day_of_week = Date.day_of_week(date)
    if day_of_week == 7 do
      Date.add(date, 6)
    else
      Date.add(date, 6 - day_of_week)
    end
  end
end
