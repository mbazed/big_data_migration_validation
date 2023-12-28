import pandas as pd
from pandas.errors import ParserError
from io import StringIO
from primary_key import find_primary_key

# Assuming you've already read the CSV files into source_df and target_df
source_df = pd.read_csv('studentsData.csv')
target_df = pd.read_csv('targetStudent.csv')

def apply_transformations(row):
    return {
        "College id": f"TVE-{row['Class']}-{row['Roll No.']}",
        "Student Name": row['Name'],
        "Contact no": f"+91 {row['Phone Number']}",
        # ... more transformations ...
    }

# Find primary keys for both source and target dataframes
primary_keys_s = find_primary_key(source_df)
primary_keys_t = find_primary_key(target_df)

# Transform and store data for the source dataframe
data_by_primary_key_s = {}
for primary_key_s in primary_keys_s:
    selected_row_s = source_df.loc[source_df[primary_key_s].notnull()]
    if not selected_row_s.empty:
        transformed_data_s = selected_row_s.apply(apply_transformations, axis=1)
        data_by_primary_key_s[primary_key_s] = transformed_data_s.tolist()

# Transform and store data for the target dataframe
data_by_primary_key_t = {}
for primary_key_t in primary_keys_t:
    selected_row_t = target_df.loc[target_df[primary_key_t].notnull()]
    if not selected_row_t.empty:
        data_by_primary_key_t[primary_key_t] = selected_row_t.to_dict(orient='records')

# Compare transformed data
for primary_key_value_s, transformed_data_s in data_by_primary_key_s.items():
    if primary_key_value_s in data_by_primary_key_t:
        # Compare the data for the corresponding primary key in source and target
        data_t = data_by_primary_key_t[primary_key_value_s]

        if transformed_data_s != data_t:
            print(f"Primary Key: {primary_key_value_s}, Source Value: {transformed_data_s}, Target Value: {data_t}")
