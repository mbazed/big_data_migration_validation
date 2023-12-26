import pandas as pd
from pandas.errors import ParserError
from io import StringIO
from primary_key import find_primary_key

# Assuming you've already read the Excel file into target_df
source_df = pd.read_csv('studentsData.csv')

    # Try to read the CSV file
target_df = pd.read_csv('studentsdatatarget.csv')

primary_keys_s = find_primary_key(source_df)
primary_keys_t = find_primary_key(target_df)
data_by_primary_key_s = {}
data_by_primary_key_t = {}

for primary_key in primary_keys_s:
    # Using loc to select rows with the specific primary key
    selected_rows = source_df.loc[source_df[primary_key].notnull()]

    # Check if there are rows for the given primary key
    if not selected_rows.empty:
        # Convert the selected rows to a dictionary and store in the data_by_primary_key variable
        data_by_primary_key_s[primary_key] = selected_rows.to_dict(orient='records')

for primary_key in primary_keys_t:
    # Using loc to select rows with the specific primary key
    selected_rows = target_df.loc[target_df[primary_key].notnull()]

    # Check if there are rows for the given primary key
    if not selected_rows.empty:
        # Convert the selected rows to a dictionary and store in the data_by_primary_key variable
        data_by_primary_key_t[primary_key] = selected_rows.to_dict(orient='records')

# Access data using primary key
# Access data using primary key
for primary_key in primary_keys_s:
    if primary_key in primary_keys_t:
        # Compare the data for the corresponding primary key in source and target
        data_s = data_by_primary_key_s[primary_key]
        data_t = data_by_primary_key_t[primary_key]

        if data_s != data_t:
            # print(f"Error: Data for Primary Key {primary_key} is different in source and target.")

            # Iterate over all rows and columns to identify differences
            for i in range(len(data_s)):
                for field, value_s, value_t in zip(data_s[i].keys(), data_s[i].values(), data_t[i].values()):
                    if value_s != value_t:
                        print(f"Row {i + 1}, Field: {field}, Source Value: {value_s}, Target Value: {value_t}")
    else:
        print(f"Error: Primary Key {primary_key} not found in target.")
