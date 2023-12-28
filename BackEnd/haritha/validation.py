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

# Transform and store data for the target dataframe
data_by_primary_key_t = {}
for primary_key_t in primary_keys_t:
    selected_row_t = target_df.loc[target_df[primary_key_t].notnull()]
    if not selected_row_t.empty:
        data_by_primary_key_t[primary_key_t] = selected_row_t.to_dict(orient='records')

# Transform and store data for the source dataframe
data_by_primary_key_s = {}
for primary_key_s in primary_keys_s:
    selected_row_s = source_df.loc[source_df[primary_key_s].notnull()]
    if not selected_row_s.empty:
        # Apply transformations to the entire DataFrame and convert to a list of dictionaries
        transformed_data_s = selected_row_s.apply(apply_transformations, axis=1)
        data_by_primary_key_s[primary_key_s] = transformed_data_s.tolist()


# Compare transformed data
for primary_key in primary_keys_s:
    if primary_key in primary_keys_t:
        data_s = data_by_primary_key_s[primary_key]
        data_t = data_by_primary_key_t[primary_key]

        if data_s != data_t:
            for i, (row_s, row_t) in enumerate(zip(data_s, data_t)):
                for field, value_s, value_t in zip(row_s.keys(), row_s.values(), row_t.values()):
                    if value_s != value_t:
                        print(f"Row {i + 1}, Field: {field}, Source Value: {value_s}, Target Value: {value_t}")
    else:
        print(f"Error: Primary Key {primary_key} not found in target.")