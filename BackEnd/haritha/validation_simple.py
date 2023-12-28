import pandas as pd
from primary_key import find_primary_key

# Assuming you've already read the CSV files into source_df and target_df
source_df = pd.read_csv('studentsData.csv')
target_df = pd.read_csv('studentsdatatarget.csv')

# Find primary key columns
primary_keys_s = find_primary_key(source_df)
primary_keys_t = find_primary_key(target_df)

# Ensure primary_keys_s and primary_keys_t are strings, not tuples
primary_keys_s = primary_keys_s[0] if isinstance(primary_keys_s, tuple) else primary_keys_s
primary_keys_t = primary_keys_t[0] if isinstance(primary_keys_t, tuple) else primary_keys_t

# Assuming primary_keys_s contains the primary key column name
primary_key_values_s = source_df[primary_keys_s].tolist()
primary_key_values_t = target_df[primary_keys_t].tolist()

# Loop through each primary key value
for primary_key_value in primary_key_values_s:
    if primary_key_value in primary_key_values_t:
        # Fetch corresponding row using primary_key_value
        row_s = source_df[source_df[primary_keys_s] == primary_key_value]
        row_t = target_df[target_df[primary_keys_t] == primary_key_value]

        # Compare values for each column
        for column in source_df.columns:
            value_s = row_s[column].iloc[0]
            value_t = row_t[column].iloc[0]

            # Compare values and print if they are not equal
            if value_s != value_t:
                print(f"Column {column} values for {primary_keys_s} = {primary_key_value} differ:")
                print(f"Source: {value_s}")
                print(f"Target: {value_t}")
