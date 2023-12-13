import pandas as pd
import uniqueKeyIdentifier as u

data, minimal_primary_key = u.getPrimaryKey('studentsData.csv')

if data and minimal_primary_key:
    print(f"\nMinimal Primary Key from uniqueKeyIdentifier.py: {minimal_primary_key}\n")
    print(f"Source Data: {data}")
else:
    print("No minimal primary key found")

# Assuming you've already read the Excel file into source_df
source_df = pd.DataFrame(data)
# Extract unique values from the first column as primary keys
primary_keys_s = minimal_primary_key
#primary_keys_t = target_df.iloc[:, 0].unique()

data_by_primary_key_s = {}
data_by_primary_key_t = {}

for primary_key in primary_keys_s:
    # Using loc to select rows with the specific primary key
    selected_rows = source_df.loc[source_df.iloc[:, 0] == primary_key]

    # Check if there are rows for the given primary key
    if not selected_rows.empty:
        # Convert the selected rows to a dictionary and store in the data_by_primary_key variable
        data_by_primary_key_s[primary_key] = selected_rows.to_dict(orient='records')

for primary_key in primary_keys_t:
    # Using loc to select rows with the specific primary key
    selected_rows = target_df.loc[target_df.iloc[:, 0] == primary_key]

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

        if data_s == data_t:
            print(f"Data for Primary Key {primary_key} is the same in source and target.")
        else:
            print(f"Error: Data for Primary Key {primary_key} is different in source and target.")
            print(f"Source Data: {data_s}")
            print(f"Target Data: {data_t}")
    else:
        print(f"Error: Primary Key {primary_key} not found in target.")
