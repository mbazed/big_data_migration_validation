import pandas as pd
from pandas.errors import ParserError
from io import StringIO
from uniqueKeyIdentifier import getPrimaryKey

# Assuming you've already read the Excel file into target_df
source_df = pd.read_csv('validationtestsource.csv')

    # Try to read the CSV file
target_df = pd.read_csv('validationtesttargetmodified.csv')

primary_keys_s = getPrimaryKey(source_df)
primary_keys_t = getPrimaryKey(target_df)

data_by_primary_key_s = {}
data_by_primary_key_t = {}

for primary_key in primary_keys_s:
    # Using loc to select rows with the specific primary key
    selected_rows = source_df.loc[getPrimaryKey(source_df) == primary_key]

    # Check if there are rows for the given primary key
    if not selected_rows.empty:
        # Convert the selected rows to a dictionary and store in the data_by_primary_key variable
        data_by_primary_key_s[primary_key] = selected_rows.to_dict(orient='records')

for primary_key in primary_keys_t:
    # Using loc to select rows with the specific primary key
    selected_rows = target_df.loc[getPrimaryKey(target_df) == primary_key]

    # Check if there are rows for the given primary key
    if not selected_rows.empty:
        # Convert the selected rows to a dictionary and store in the data_by_primary_key variable
        data_by_primary_key_t[primary_key] = selected_rows.to_dict(orient='records')

# Access data using primary key

for primary_key in primary_keys_s:
    if primary_key in data_by_primary_key_t:
        # Compare the data for the corresponding primary key in source and target
        data_s = data_by_primary_key_s[primary_key]
        data_t = data_by_primary_key_t[primary_key]

        differing_columns = []
        for column in data_s[0].keys():  # Assuming all items in data_s have the same columns
            values_s = [row.get(column) for row in data_s]
            values_t = [row.get(column) for row in data_t]

            if values_s != values_t:
                differing_columns.append(column)

        if not differing_columns:
            print(f"Data for Primary Key {primary_key} is the same in source and target.")
        else:
            print(f"Error: Data for Primary Key {primary_key} is different in source and target.")
            for column in differing_columns:
                values_s = [row.get(column) for row in data_s]
                values_t = [row.get(column) for row in data_t]
                print(f"{column}: Source({values_s}), Target({values_t})")
        print()
    else:
        print(f"Error: Primary Key {primary_key} not found in target.")



