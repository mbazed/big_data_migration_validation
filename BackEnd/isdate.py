from datetime import datetime

def is_valid_date(date_str):
    date_formats = [
        '%Y-%m-%d',
        '%Y/%m/%d',
        '%d-%m-%Y',
        '%d/%m/%Y',
        '%m-%d-%Y',
        '%m/%d/%Y',
        '%Y%m%d',
        '%m%d%Y',
        '%d%m%Y',
        '%m/%d/%y',  # Added format for month/day/year
        '%B %d, %Y',  # Month Day, Year
        '%d %B %Y',  # Day Month Year
        '%dth %B %Y',  # Day Month Year with Ordinal Indicator
        '%B %dth, %Y',  # Month Day Year with Ordinal Indicator
        '%b %d, %Y',  # Abbreviated Month Day, Year
        '%b %d %Y',  # Abbreviated Month Day Year
        '%d %b %y',  # Day Month Abbreviated Year
        '%b %dth %Y',  # Abbreviated Month Day Year with Ordinal Indicator
        '%d %b %Y',  # Day Abbreviated Month Year
        '%Y, %B %d',  # Year, Month Day
        '%Y %B %d',  # Year Month Day
        '%Y %B %dth',  # Year Month Day with Ordinal Indicator
        '%Y-%m-%d',  # Year-Month-Day (ISO 8601)
    ]
    
    for date_format in date_formats:
        try:
            parsed_date = datetime.strptime(date_str, date_format)
            return True, date_format
        except ValueError:
            pass
    return False, None

input_date = input("Enter a date: ")

valid, format_detected = is_valid_date(input_date)

if valid:
    print("Valid date")
    print("Detected format:", format_detected)
else:
    print("Invalid date")
