- [Introduction](#org5409ea7)
- [Version](#orga0e91c5)
- [Installation](#org5f1dd2c)
- [Usage](#org5370e37)
    - [Constants](#orga3509b5)
    - [Ensure](#org6982753)
    - [Formatting](#orgf1df8b2)
    - [Chunks](#orgbd46647)
    - [Parsing American Dates](#org699b533)
    - [Holidays and Workdays](#org156cfb2)
    - [Ordinal Weekdays in Month](#orgb99874d)
    - [Easter](#org16ce332)
    - [Date Specs](#org90aeba3)
- [Contributing](#org4b44d01)

[![CI](https://github.com/ddoherty03/fat_date/actions/workflows/ruby.yml/badge.svg?branch=master)](https://github.com/ddoherty03/fat_date/actions/workflows/ruby.yml)


<a id="org5409ea7"></a>

# Introduction

`fat_date` collects core extensions for the Date class to make it more useful in financial applications, including:

-   determining when a `Date` is a federal or NYSE holiday with Presidential decrees included,
-   determining when a `Date` is part of a larger calendar-related "chunk," such as a year, half, quarter, bimonth, month, semimonth, or week,
-   calculating Easter for a `Date's` year, a date on which some "movable feasts" depend, and
-   parsing so-called "specs" that allow the beginning or ending `Date` of a larger period of time to be returned, a facility put to good use in the [FatPeriod](https://github.com/ddoherty03/fat_period) gem.


<a id="orga0e91c5"></a>

# Version

```ruby
"#{FatDate::VERSION}"
```

```
0.1.4
```


<a id="org5f1dd2c"></a>

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'fat_date', :git => 'https://github.com/ddoherty03/fat_date.git'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install fat_date
```


<a id="org5370e37"></a>

# Usage

Many of these have little that is of general interest, but there are a few goodies.


<a id="orga3509b5"></a>

### Constants

`FatDate` adds two date constants to the `Date` class, Date::BOT and Date::EOT. These represent the earliest and latest dates of practical commercial interest. The exact values are rather arbitrary, but they prove useful in date ranges, for example. They are defined as:

-   **`Date::BOT`:** January 1, 1900
-   **`Date::EOT`:** December 31, 3000
-   **`Date::FEDERAL_DECREED_HOLIDAYS`:** an Array of dates declared as non-work days for federal employees by presidential proclamation
-   **`Date::PRESIDENTIAL_FUNERALS`:** an Array of dates of presidential funerals, which are observed with a closing of most federal agencies


<a id="org6982753"></a>

### Ensure

The `Date.ensure` class method tries to convert its argument to a `Date` object by (1) applying the `#to_date` method or (2) applying the `Date.parse` method to a String. This is handy when you want to define a method that takes a date argument but want the caller to be able to supply anything that can reasonably be converted to a `Date`:

```ruby
def tomorow_tomorrow(arg)
  from = Date.ensure(arg)  # => ArgumentError: cannot convert class 'Array' to a Date or DateTime
  from + 2.days            # => Mon, 03 Jun 2024, Wed, 16 Oct 2024 05:47:30 -0500, Sun, 03 Mar 2024
end                        # => :tomorow_tomorrow

tomorow_tomorrow('June 1').to_s
```

```
2025-06-03
```

If you give it a Time, it will return a `DateTime`

```ruby
[Time.now, tomorow_tomorrow(Time.now)]
```

```
[2025-12-24 05:12:00.897539094 -0600, Fri, 26 Dec 2025 05:12:00 -0600]
```

But it's only as good as Date.parse! If all it sees is 'March', it returns March 1 of the current year.

```ruby
tomorow_tomorrow('Ides of March').to_s
```

```
2025-03-03
```


<a id="orgf1df8b2"></a>

### Formatting

`FatDate` provides some concise methods for printing string versions of dates that are often useful:

```ruby
d = Date.parse('1957-09-22')
methods = ['iso', 'num', 'tex_quote', 'eng', 'american', 'org']
tab = []
tab << ['Description', 'Result']
tab << nil
methods.each do |m|
  tab << [m, d.send(m.to_sym)]
end
tab <<  ["org(active: true)", d.org(active: true)]
```

```
| Description       | Result             |
|-------------------+--------------------|
| iso               | 1957-09-22         |
| num               | 19570922           |
| tex_quote         | 1957--09--22       |
| eng               | September 22, 1957 |
| american          | 9/22/1957          |
| org               | [1957-09-22 Sun]   |
| org(active: true) | <1957-09-22 Sun>   |
```

Most of these are self-explanatory, but a couple are not. The `Date.org(active: false)` method formats a date as an Emacs org-mode timestamp, by default an inactive timestamp that does not show up in the org agenda, but can be made active with the optional parameter `active:` set to a truthy value. See <https://orgmode.org/manual/Timestamps.html#Timestamps>.

The `#tex_quote` method formats the date in iso form but using TeX's convention of using en-dashes to separate the components.


<a id="orgbd46647"></a>

### Chunks

Many of the methods provided by `FatDate` deal with various calendar periods that are less common than those provided by the Ruby Standard Library or gems such as `active_support`. This documentation refers to these calendar periods as "chunks", and they are the following:

-   year,
-   half,
-   quarter,
-   bimonth,
-   month,
-   semimonth,
-   biweek,
-   week, and
-   day

`FatDate` provides methods that query whether the date falls on the beginning or end of each of these chunks:

```ruby
tab = []
tab << ['Subject Date', 'Method', 'Result']
tab << nil
d = Date.parse('2017-06-30')
%i[beginning end].each do |side|
  %i(year half quarter bimonth month semimonth biweek week).each do |chunk|
    meth = "#{side}_of_#{chunk}?".to_sym
    tab << [d.iso, meth.to_s, "#{d.send(meth)}"]
  end
end
tab
```

```
| Subject Date | Method                  | Result |
|--------------+-------------------------+--------|
| 2017-06-30   | beginning_of_year?      | false  |
| 2017-06-30   | beginning_of_half?      | false  |
| 2017-06-30   | beginning_of_quarter?   | false  |
| 2017-06-30   | beginning_of_bimonth?   | false  |
| 2017-06-30   | beginning_of_month?     | false  |
| 2017-06-30   | beginning_of_semimonth? | false  |
| 2017-06-30   | beginning_of_biweek?    | false  |
| 2017-06-30   | beginning_of_week?      | false  |
| 2017-06-30   | end_of_year?            | false  |
| 2017-06-30   | end_of_half?            | true   |
| 2017-06-30   | end_of_quarter?         | true   |
| 2017-06-30   | end_of_bimonth?         | true   |
| 2017-06-30   | end_of_month?           | true   |
| 2017-06-30   | end_of_semimonth?       | true   |
| 2017-06-30   | end_of_biweek?          | false  |
| 2017-06-30   | end_of_week?            | false  |
```

It also provides corresponding methods that return the date at the beginning or end of the calendar chunk, starting at the given date:

```ruby
tab = []
tab << ['Subject Date', 'Method', 'Result']
tab << nil
d = Date.parse('2017-04-21')
%i[beginning end].each do |side|
  %i(year half quarter bimonth month semimonth biweek week ).each do |chunk|
    meth = "#{side}_of_#{chunk}".to_sym
    tab << [d.iso, "d.#{meth}", "#{d.send(meth)}"]
  end
end
tab
```

```
| Subject Date | Method                   | Result     |
|--------------+--------------------------+------------|
| 2017-04-21   | d.beginning_of_year      | 2017-01-01 |
| 2017-04-21   | d.beginning_of_half      | 2017-01-01 |
| 2017-04-21   | d.beginning_of_quarter   | 2017-04-01 |
| 2017-04-21   | d.beginning_of_bimonth   | 2017-03-01 |
| 2017-04-21   | d.beginning_of_month     | 2017-04-01 |
| 2017-04-21   | d.beginning_of_semimonth | 2017-04-16 |
| 2017-04-21   | d.beginning_of_biweek    | 2017-04-10 |
| 2017-04-21   | d.beginning_of_week      | 2017-04-17 |
| 2017-04-21   | d.end_of_year            | 2017-12-31 |
| 2017-04-21   | d.end_of_half            | 2017-06-30 |
| 2017-04-21   | d.end_of_quarter         | 2017-06-30 |
| 2017-04-21   | d.end_of_bimonth         | 2017-04-30 |
| 2017-04-21   | d.end_of_month           | 2017-04-30 |
| 2017-04-21   | d.end_of_semimonth       | 2017-04-30 |
| 2017-04-21   | d.end_of_biweek          | 2017-04-23 |
| 2017-04-21   | d.end_of_week            | 2017-04-23 |
```

You can query which numerical half, quarter, etc. that a given date falls in:

```ruby
tab = []
tab << ['Subject Date', 'Method', 'Result']
tab << nil
%i(year half quarter bimonth month semimonth biweek week ).each do |chunk|
  d = Date.parse('2017-04-21') + rand(100)
  meth = "#{chunk}".to_sym
  tab << [d.iso, "d.#{meth}", "in #{chunk} number #{d.send(meth)}"]
end
tab
```

```
| Subject Date | Method      | Result                |
|--------------+-------------+-----------------------|
| 2017-06-04   | d.year      | in year number 2017   |
| 2017-05-01   | d.half      | in half number 1      |
| 2017-05-03   | d.quarter   | in quarter number 2   |
| 2017-04-29   | d.bimonth   | in bimonth number 2   |
| 2017-06-14   | d.month     | in month number 6     |
| 2017-04-29   | d.semimonth | in semimonth number 8 |
| 2017-05-20   | d.biweek    | in biweek number 10   |
| 2017-06-12   | d.week      | in week number 24     |
```


<a id="org699b533"></a>

### Parsing American Dates

Americans often write dates in the form M/d/Y, and the normal parse method will parse such a string as d/M/Y, often resulting in invalid date errors. `FatDate` adds the specialty parsing method, `Date.parse_american` to handle such strings.

```ruby
begin
  ss = '9/22/1957'
  Date.parse(ss)
rescue Date::Error => ex
  puts "Date.parse('#{ss}') raises #{ex.class} (#{ex}), but"
  puts "Date.parse_american('#{ss}') => #{Date.parse_american(ss)}"
end
```

```
=> false
Date.parse('9/22/1957') raises Date::Error (invalid date), but
Date.parse_american('9/22/1957') => 1957-09-22
=> nil
:org_babel_ruby_eoe
```


<a id="org156cfb2"></a>

### Holidays and Workdays

1.  Federal

    One of the original motivations for this library was to provide an easy way to determine whether a given date is a federal holiday in the United States or, nearly but not quite the same, a non-trading day on the New York Stock Exchange. To that end, `FatDate` provides the following methods:
    
    -   Date#weekend? &#x2013; is this date on a weekend?
    -   Date#weekday? &#x2013; is this date on a week day?
    -   Date#easter\_this\_year &#x2013; the date of Easter in the Date's year
    
    Methods concerning Federal holidays:
    
    -   Date#fed\_holiday? &#x2013; is this date a Federal holiday? It knows about obscurities such as holidays decreed by past Presidents, dates of Presidential funerals, and the Federal rule for when holidays fall on a weekend, whether it is moved to the prior Friday or the following Monday.
    -   Date#fed\_workday? &#x2013; is it a date when Federal government offices are open?, inverse of Date#fed\_holiday?
    -   Date#add\_fed\_workdays(n) &#x2013; n Federal workdays following (or preceding if n negative) this date,
    -   Date#next\_fed\_workday &#x2013; the next Federal workday following this date,
    -   Date#prior\_fed\_workday &#x2013; the previous Federal workday before this date,
    -   Date#next\_until\_fed\_workday &#x2013; starting with this date, move forward until we hit a Federal workday
    -   Date#prior\_until\_fed\_workday &#x2013; starting with this date, move back until we hit a Federal workday
        
        Whether a particular date is a federal holiday is complicated. Certain holidays are statutory as set forth in [5 U.S.C. §6103](https://www.govinfo.gov/content/pkg/USCODE-2024-title5/pdf/USCODE-2024-title5-partIII-subpartE-chap61-subchapI-sec6103.pdf). But if the holiday falls on a Saturday, the prior Friday is observed; if on a Sunday, the following Monday is observed. Inauguration Day after 1965 is observed by employees in Washington, D.C., and surrounding areas, effectively shutting down most federal agencies.
        
        On top of that the days of Presidential funeral are federal holidays. On top of that, each President can decree temporary holidays by Executive Order, often to give employees Christmas Eve and the day after Christmas the day off if they would not otherwise be off. The `fat_date` library attempts to capture all of this, but the days of Presidential decrees are only good for the last decade or so.
        
        Here is a sampling:
    
    ```ruby
    result = []
    result << ['Date', 'Federal Holiday?', 'Comment']
    result << nil
    result << ['2014-05-16', Date.parse('2014-05-16').fed_holiday?, 'Nuttin special']
    result << ['2014-05-18', Date.parse('2014-05-18').fed_holiday?, 'A weekend']
    result << ['2014-01-01', Date.parse('2014-01-01').fed_holiday?, 'New Year']
    result << ['1963-11-25', Date.parse('1963-11-25').fed_holiday?, 'JFK Funeral']
    result << ['1973-01-25', Date.parse('1973-01-25').fed_holiday?, 'LBJ Funeral']
    result << ['2003-12-25', Date.parse('2003-12-25').fed_holiday?, 'Christmas']
    result << ['1961-01-20', Date.parse('1961-01-20').fed_holiday?, 'JFK Inauguration (before 1965)']
    result << ['1969-01-20', Date.parse('1969-01-20').fed_holiday?, 'RMN Inauguration (after 1965)']
    result << ['2012-12-24', Date.parse('2012-12-24').fed_holiday?, 'Christmas Eve Decreed by Obama']
    result << ['2003-12-26', Date.parse('2003-12-26').fed_holiday?, 'Friday after Christmas']
    ```
    
    ```
    | Date       | Federal Holiday? | Comment                        |
    |------------+------------------+--------------------------------|
    | 2014-05-16 | false            | Nuttin special                 |
    | 2014-05-18 | true             | A weekend                      |
    | 2014-01-01 | true             | New Year                       |
    | 1963-11-25 | true             | JFK Funeral                    |
    | 1973-01-25 | true             | LBJ Funeral                    |
    | 2003-12-25 | true             | Christmas                      |
    | 1961-01-20 | false            | JFK Inauguration (before 1965) |
    | 1969-01-20 | true             | RMN Inauguration (after 1965)  |
    | 2012-12-24 | true             | Christmas Eve Decreed by Obama |
    | 2003-12-26 | true             | Friday after Christmas         |
    ```

2.  NYSE

    And we have similar methods for "holidays" or non-trading days on the NYSE:
    
    -   Date#nyse\_holiday? &#x2013; is this date a NYSE holiday?
    -   Date#nyse\_workday? &#x2013; is it a date when the NYSE is open for trading?, inverse of Date#nyse\_holiday?
    -   Date#add\_nyse\_workdays(n) &#x2013; n NYSE workdays following (or preceding if n negative) this date,
    -   Date#next\_nyse\_workday &#x2013; the next NYSE workday following this date,
    -   Date#prior\_nyse\_workday &#x2013; the previous NYSE workday before this date,
    -   Date#next\_until\_nyse\_~~workday &#x2013; starting with this date, move forward until we hit a NYSE workday
    -   Date#prior\_until\_nyse\_workday &#x2013; starting with this date, move back until we hit a Federal workday
    
    Likewise, days on which the NYSE is closed can be gotten with:
    
    ```ruby
    Date.parse('2014-04-18').nyse_holiday?
    ```
    
    ```
    true
    ```
    
    ```ruby
    date_comments = [
      ['2014-04-18', 'Good Friday'],
      ['2014-05-18', 'Weekend'],
      ['2014-05-21', 'Any old day'],
      ['2014-01-01', 'New Year']
    ]
    result = []
    result << ['Date', 'Federal Holiday?', 'NYSE Holiday?', 'Comment']
    result << nil
    date_comments.each do |str, comment|
      d = Date.parse(str)
      result << [d.org, d.fed_holiday?, d.nyse_holiday?, comment]
    end
    result
    ```
    
    ```
    | Date             | Federal Holiday? | NYSE Holiday? | Comment     |
    |------------------+------------------+---------------+-------------|
    | [2014-04-18 Fri] | false            | true          | Good Friday |
    | [2014-05-18 Sun] | true             | true          | Weekend     |
    | [2014-05-21 Wed] | false            | false         | Any old day |
    | [2014-01-01 Wed] | true             | true          | New Year    |
    ```


<a id="orgb99874d"></a>

### Ordinal Weekdays in Month

It is often useful to find the 1st, 2nd, etc, Sunday, Monday, etc. in a given month. `FatDate` provides the class method `Date.nth_wday_in_year_month(nth, wday, year, month)` to return such dates. The first parameter can be negative, which will count from the end of the month.

```ruby
results = []
results << ['n', 'Year', 'Month', 'nth Thursday']
results << nil
(1..4).each do |n|
  d = Date.nth_wday_in_year_month(n, 4, 2024, 6)
  results << [n, d.year, 'June', d.org]
end
(-4..-1).to_a.reverse.each do |n|
  d = Date.nth_wday_in_year_month(n, 4, 2024, 6)
  results << [n, d.year, 'June', d.org]
end
results
```

```
| n  | Year | Month | nth Thursday     |
|----+------+-------+------------------|
| 1  | 2024 | June  | [2024-06-06 Thu] |
| 2  | 2024 | June  | [2024-06-13 Thu] |
| 3  | 2024 | June  | [2024-06-20 Thu] |
| 4  | 2024 | June  | [2024-06-27 Thu] |
| -1 | 2024 | June  | [2024-06-27 Thu] |
| -2 | 2024 | June  | [2024-06-20 Thu] |
| -3 | 2024 | June  | [2024-06-13 Thu] |
| -4 | 2024 | June  | [2024-06-06 Thu] |
```


<a id="org16ce332"></a>

### Easter

Many holidays in the West are determined by the date of Easter, so FatDate provides the class method `Date.easter(year)` to return the date of Easter for the given year, using the Julian calendar date before the year of reform, and using the Gregorian calendar beginning in the year of reform. By default, it uses 1582 for the date of reform, but it can take a named parameter, `reform_year:` to specify a different date. For England, the year of reform was September, 1752. So, to get a historically accurate date of Easter for Anglicans between 1582 and 1752, you should use a reform\_year of 1753, since the reform happened after Easter in 1752.

-   **`Date.easter(year, reform_year: 1582)`:** return the date of Easter for the given `year`, assuming the given year of calendar reform; return nil for any year before 30AD.
-   **Date#easter\_this\_year:** return the date of Easter for the year in which the subject Date falls.
-   **Date#easter?:** return whether the subject Date is Easter.

```ruby
yrs = [800, 1000, 1200, 1400, 1500, 1600, 1800, 2000]
result = []
result << ['Year', 'Easter Date']
result << nil
yrs.each do |y|
  result << [y, Date.easter(y).org ]
end
result
```

```
| Year | Easter Date      |
|------+------------------|
|  800 | [0800-04-19 Wed] |
| 1000 | [1000-03-31 Mon] |
| 1200 | [1200-04-09 Sun] |
| 1400 | [1400-04-18 Fri] |
| 1500 | [1500-04-19 Thu] |
| 1600 | [1600-04-02 Sun] |
| 1800 | [1800-04-13 Sun] |
| 2000 | [2000-04-23 Sun] |
```


<a id="org90aeba3"></a>

### Date Specs

It is often desirable to get the first or last date of a specified time period. For this `FatDate` provides the `spec` method that takes a string and an optional `spec_type` parameter of either `:from`, indicating that the first date of the period should be returned or `:to`, indicating that the last date of the period should be returned. It assumes the `spec_type` to be `:from` by default.

Though many specs, other than those specifying a single day, represent a period of time longer than one date, the `Date.spec` method returns a single date, either the first or last day of the period described by the spec. See the library `FatPeriod` where the `Date.spec` method is put to good use in defining a `Period` type to represent ranges of time.

The `spec` method supports a rich set of ways to specify periods of time. The following sections catalog them all.

1.  Given Day

    -   **YYYY-MM-DD:** returns a single day given.
    -   **MM-DD:** returns the specified day of the specified month in the current year.

2.  Day-of-Year

    -   **YYYY-ddd:** returns the ddd'th day of the specified year. Note that exactly three digits are needed: with only two digits it would be interpreted as a month.
    -   **ddd:** returns the ddd'th day of the current year. Again, note that exactly three digits are needed: two digits would be interpreted as a month, and four digits as a year.

3.  Month

    The following return the first or last day of the given month.
    
    -   **YYYY-MM:** returns the first or last day of the specified month in the specified year.
    -   **MM:** returns first or last day of the specified month of the current year.

4.  Year

    -   **YYYY:** returns the first or last day of the specified year.

5.  Commercial Weeks-of-Year

    -   **YYYY-Wnn or YYYY-nnW:** returns the first or last day of the nn'th commercial week of the given year according to the ISO 8601 standard, in which the week containing the first Thursday of the year counts as the first commercial week, even if that week started in the prior calendar year,
    -   **Wnn or nnW:** returns the first or last day of the nn'th commercial week of the current year,

6.  Halves

    -   **YYYY-1H or YYYY-2H:** returns the first or last day of the specified half year for the given year,
    -   **1H or 2H:** returns the first or last day of the specified half year for the current year,

7.  Quarters

    -   **YYYY-1Q, YYYY-2Q, etc :** returns the first or last day of the calendar quarter for the given year,
    -   **1Q, 2Q, etc :** returns the first or last day of the calendar quarter for the current year,

8.  Semi-Months

    -   **YYYY-MM-A or YYYY-MM-B:** returns the first or last day of the semi-month for the given month and year, where the first semi-month always runs from the 1st to the 15th and the second semi-month always runs from the 16th to the last day of the given month, regardless of the number of days in the month.
    -   **MM-A or MM-B:** returns the first or last day of the semi-month of the current year.
    -   **A or B:** returns the first or last day of the semi-month of the current year and month.

9.  Week-of-Month

    -   **YYYY-MM-i or YYYY-MM-ii up to YYYY-MM-vi:** returns the first or last day of the given week within the month, including any partial weeks,
    -   **MM-i or MM-ii up to MM-vi:** returns the first or last day of the given week within the month of the current year, including any partial weeks,
    -   **i or ii up to vi:** returns the first or last day of the given week within the current month of the current year, including any partial weeks,

10. Day-of-Week

    -   **YYYY-MM-nSu up to YYYY-MM-nSa :** returns the single day that is the n'th Sunday, Monday, etc., in the given month using the first two letters of the English names for the days of the week,
    -   **MM-nSu up to MM-nSa or MM-nSun up to MM-nSat:** returns the single date that is the n'th Sunday, Monday, etc., in the given month of the current year using the first two letters of the English names for the days of the week,
    -   **nSu up to nSa or nSun up to nSat:** returns the single date that is the n'th Sunday, Monday, etc., in the current month of the current year using the first two letters of the English names for the days of the week,

11. Easter Based

    -   **YYYY-E:** returns the single date of Easter in the Western church for the given year,
    -   **E:** returns the single date of Easter in the Western church for the current year,
    -   **YYYY-E-n or YYYY-E+n:** returns the single date that falls n days before (-) or after (+) Easter in the Western church for the given year,
    -   **E-n or E+n:** returns the single date that falls n days before (-) or after (+) Easter in the Western church for the current year,

12. Relative Dates

    -   **yesterday or yesteryear or lastday or last\_year, etc:** the relative prefixes, 'last' or 'yester' prepended to any chunk name returns the period named by the chunk that precedes today's date.
    -   **today or toyear or this-year or thissemimonth, etc:** the relative prefixes, 'to' or 'this' prepended to any chunk name returns the period named by the chunk that contains today's date.
    -   **nextday or nextyear or next-year or nextsemimonth, etc:** the relative prefixes, 'next' prepended to any chunk name returns the period named by the chunk that follows today's date. As a special case, 'tomorrow' is treated as equivalent to 'nextday'.

13. Extremes

    -   **forever:** returns Date::BOT for :from, and Date::EOT for :to, which, for financial applications is meant to stand in for eternity.
    -   **never:** returns nil, representing no date.

14. Skip Modifiers

    Appended to any of the above specs (other than 'never'), you may add a 'skip modifier' to change the date to the first day-of-week adjacent to the date that the spec resolves to. This is done by appending one of the following to the spec:
    
    -   **'<Su', '<Mo', &#x2026; '<Sa':** skip to the first Sunday, Monday, etc., *before* the date the spec resolves to.
    -   **'<=Su', '<=Mo', &#x2026; '<=Sa':** skip to the first Sunday, Monday, etc., *on or before* the date the spec resolves to.
    -   **'>Su', '>Mo', &#x2026; '>Sa':** skip to the first Sunday, Monday, etc., *after* the date the spec resolves to.
    -   **'>=Su', '>=Mo', &#x2026; '>=Sa':** skip to the first Sunday, Monday, etc., *on or after* the date the spec resolves to.
    
    For example, `Date.spec('2024<=Tu', :to)` resolves to the last Tuesday of 2024, which happens to be December 31, 2024; `Date.spec('2024<Tu', :to)`, on the other hand would resolve to December 24, 2024, since it looks for the first Tuesday strictly *before* December 31, 2024.

15. Conventions

    Some things to note with respect to `Date.spec`:
    
    1.  The second argument can be either `:from` or `:to`, but it defaults to `:from`. If it is `:from`, `spec` returns the first date of the specified period; if it is `:to`, it returns the last date of the specified period. When the "period" resolves to a single day, both arguments return the same date, so `spec('2024-E', :from)` and `spec('2024-E', :to)` both result in March 31, 2024.
    2.  Where relevant, `spec` accepts letters of either upper or lower case: so 2024-1Q can be written 2024-1q and 'yesteryear' can be written 'YeSterYeaR', and likewise for all components of the spec using letters.
    3.  Date components can be separated with either a hyphen, as in the examples above, or with a '/' as is common. Thus, 2024-11-09 can also be 2024/11/09, or indeed, 2024/11-09 or 2024-11/09.
    4.  The prefixes for relative periods can be separated from the period name by a hyphen, and underscore, or by nothing at all. Thus, yester-day, yester\_day, and yesterday are all acceptable. Neologisms such as 'yestermonth' are quaint, but not harmful.
    5.  Where the names of days of the week are appropriate, any word that starts with 'su' counts as Sunday, regardless of case, any word that starts with 'mo' counts as Monday, and so on.
    6.  'fortnight' is a synonym for a biweek.

16. Examples

    The following examples demonstrate all of the date specs available.
    
    ```ruby
    strs = ['today', '2024-07-04', '2024-05', '2024', '2024-333',
           '08', '08-12', '2024-W36', '2024-36W', 'W36', '36W',
           '2024-1H', '2024-2H', '1H', '2H',
           '1957-1Q', '1957-2Q', '1957-3Q', '1957-4Q',
           '1Q', '2Q', '3Q', '4Q',
           '2015-06-A', '2015-06-B', '06-A', '06-B', 'A', 'B',
           '2021-09-I', '2021-09-II',
           '2021-09-i', '2021-09-ii', '2021-09-iii', '2021-09-iv', '2021-09-v',
           '10-i', '10-iii',
           '2016-04-3Tu', '2016-11-4Th', '2016-11-2Th',
           '05-3We', '06-3Wed', '3Su', '4Sa',
           '1830-E', 'E', '2012-E+10', '2024-E+40', '2026-E<Fri',
           'yestermonth', 'lastmonth', 'yesterfortnight', 'thisfortnight', 'nextfortnight',
           '2025-E+50>=Su'
           ]
    tab = []
    tab << ['Spec', 'From', 'To']
    tab << nil
    strs.each do |s|
      tab << ["'#{s}'", Date.spec(s, :from).org, Date.spec(s, :to).org]
    end
    tab
    ```
    
    ```
    | Spec              | From             | To               |
    |-------------------+------------------+------------------|
    | 'today'           | [2025-12-24 Wed] | [2025-12-24 Wed] |
    | '2024-07-04'      | [2024-07-04 Thu] | [2024-07-04 Thu] |
    | '2024-05'         | [2024-05-01 Wed] | [2024-05-31 Fri] |
    | '2024'            | [2024-01-01 Mon] | [2024-12-31 Tue] |
    | '2024-333'        | [2024-11-28 Thu] | [2024-11-28 Thu] |
    | '08'              | [2025-08-01 Fri] | [2025-08-31 Sun] |
    | '08-12'           | [2025-08-12 Tue] | [2025-08-12 Tue] |
    | '2024-W36'        | [2024-09-02 Mon] | [2024-09-08 Sun] |
    | '2024-36W'        | [2024-09-02 Mon] | [2024-09-08 Sun] |
    | 'W36'             | [2025-09-01 Mon] | [2025-09-07 Sun] |
    | '36W'             | [2025-09-01 Mon] | [2025-09-07 Sun] |
    | '2024-1H'         | [2024-01-01 Mon] | [2024-06-30 Sun] |
    | '2024-2H'         | [2024-07-01 Mon] | [2024-12-31 Tue] |
    | '1H'              | [2025-01-01 Wed] | [2025-06-30 Mon] |
    | '2H'              | [2025-07-01 Tue] | [2025-12-31 Wed] |
    | '1957-1Q'         | [1957-01-01 Tue] | [1957-03-31 Sun] |
    | '1957-2Q'         | [1957-04-01 Mon] | [1957-06-30 Sun] |
    | '1957-3Q'         | [1957-07-01 Mon] | [1957-09-30 Mon] |
    | '1957-4Q'         | [1957-10-01 Tue] | [1957-12-31 Tue] |
    | '1Q'              | [2025-01-01 Wed] | [2025-03-31 Mon] |
    | '2Q'              | [2025-04-01 Tue] | [2025-06-30 Mon] |
    | '3Q'              | [2025-07-01 Tue] | [2025-09-30 Tue] |
    | '4Q'              | [2025-10-01 Wed] | [2025-12-31 Wed] |
    | '2015-06-A'       | [2015-06-01 Mon] | [2015-06-15 Mon] |
    | '2015-06-B'       | [2015-06-16 Tue] | [2015-06-30 Tue] |
    | '06-A'            | [2025-06-01 Sun] | [2025-06-15 Sun] |
    | '06-B'            | [2025-06-16 Mon] | [2025-06-30 Mon] |
    | 'A'               | [2025-12-01 Mon] | [2025-12-15 Mon] |
    | 'B'               | [2025-12-16 Tue] | [2025-12-31 Wed] |
    | '2021-09-I'       | [2021-09-01 Wed] | [2021-09-05 Sun] |
    | '2021-09-II'      | [2021-09-06 Mon] | [2021-09-12 Sun] |
    | '2021-09-i'       | [2021-09-01 Wed] | [2021-09-05 Sun] |
    | '2021-09-ii'      | [2021-09-06 Mon] | [2021-09-12 Sun] |
    | '2021-09-iii'     | [2021-09-13 Mon] | [2021-09-19 Sun] |
    | '2021-09-iv'      | [2021-09-20 Mon] | [2021-09-26 Sun] |
    | '2021-09-v'       | [2021-09-27 Mon] | [2021-09-30 Thu] |
    | '10-i'            | [2025-10-01 Wed] | [2025-10-05 Sun] |
    | '10-iii'          | [2025-10-13 Mon] | [2025-10-19 Sun] |
    | '2016-04-3Tu'     | [2016-04-19 Tue] | [2016-04-19 Tue] |
    | '2016-11-4Th'     | [2016-11-24 Thu] | [2016-11-24 Thu] |
    | '2016-11-2Th'     | [2016-11-10 Thu] | [2016-11-10 Thu] |
    | '05-3We'          | [2025-05-21 Wed] | [2025-05-21 Wed] |
    | '06-3Wed'         | [2025-06-18 Wed] | [2025-06-18 Wed] |
    | '3Su'             | [2025-12-21 Sun] | [2025-12-21 Sun] |
    | '4Sa'             | [2025-12-27 Sat] | [2025-12-27 Sat] |
    | '1830-E'          | [1830-04-11 Sun] | [1830-04-11 Sun] |
    | 'E'               | [2025-04-20 Sun] | [2025-04-20 Sun] |
    | '2012-E+10'       | [2012-04-18 Wed] | [2012-04-18 Wed] |
    | '2024-E+40'       | [2024-05-10 Fri] | [2024-05-10 Fri] |
    | '2026-E<Fri'      | [2026-04-03 Fri] | [2026-04-03 Fri] |
    | 'yestermonth'     | [2025-11-01 Sat] | [2025-11-30 Sun] |
    | 'lastmonth'       | [2025-11-01 Sat] | [2025-11-30 Sun] |
    | 'yesterfortnight' | [2025-12-08 Mon] | [2025-12-21 Sun] |
    | 'thisfortnight'   | [2025-12-22 Mon] | [2026-01-04 Sun] |
    | 'nextfortnight'   | [2026-01-05 Mon] | [2026-01-18 Sun] |
    | '2025-E+50>=Su'   | [2025-06-15 Sun] | [2025-06-15 Sun] |
    ```


<a id="org4b44d01"></a>

# Contributing

1.  Fork it (<http://github.com/ddoherty03/fat_date/fork> )
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Commit your changes (`git commit -am 'Add some feature'`)
4.  Push to the branch (`git push origin my-new-feature`)
5.  Create new Pull Request
