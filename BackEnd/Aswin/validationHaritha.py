import pandas as pd
from primary_key import find_primary_key
from collections import Counter
from myapp import *

global target_df
global source_df
global transformed_source_df
global primary_keys_s
global primary_key_values_s
mappingDoc = {}  # Initialize mappingDoc as an empty dictionary

def apply_transformations(row):
    global transformed_source_df
    global primary_keys_s
    global mappingDoc
    
    result_dict = {}

    for target_column, pattern in mappingDoc.items():
        # Use the pattern to construct the value for the target column
        result_dict[target_column] = pattern.format(**row)

    return pd.Series(result_dict)

def comparison(key):
    global target_df
    global transformed_source_df
    global primary_keys_s
    global primary_key_values_s
    primary_keys_t = key
    primary_key_values_t = target_df[primary_keys_t].tolist()

    # Loop through each primary key value
    for primary_key_value in primary_key_values_s:
        # Check for duplicate primary key values
        if primary_key_values_t.count(primary_key_value) > 1:
            print(f"Duplicate primary key value found: {primary_key_value}")

        if primary_key_value in primary_key_values_t:
            # Fetch corresponding row using primary_key_value
            row_s_transformed = transformed_source_df[transformed_source_df[primary_keys_s] == primary_key_value]
            row_t = target_df[target_df[primary_keys_t] == primary_key_value]

            # Check if the primary key exists in both DataFrames
            if not row_s_transformed.empty and not row_t.empty:
                # Compare values for each column in the transformed source DataFrame
                for column in transformed_source_df.columns:
                    value_s = row_s_transformed[column].iloc[0] if column in row_s_transformed.columns else None
                    value_t = row_t[column].iloc[0] if column in row_t.columns else None

                    # Compare values and print if they are not equal
                    if value_s != value_t:
                        print(f"For {primary_keys_s}: {primary_key_value}, Column {column} values differ:")
                        print(f"Source: {value_s}")
                        print(f"Target: {value_t}")
            else:
                print(f"For {primary_keys_s}: {primary_key_value}, Data is Missing")
        else:
            print(f"For {primary_keys_s}: {primary_key_value}, Data is Missing")

def findAll(sourcedata, targetdata, mappingDoc_input):
    global target_df
    global source_df
    global transformed_source_df
    global primary_keys_s
    global primary_key_values_s
    global mappingDoc
    
    # Assign the input mappingDoc to the global variable
    mappingDoc = mappingDoc_input
    source_df = sourcedata
    target_df = targetdata
    # Apply transformations to source_df
    transformed_source_df = source_df.apply(apply_transformations, axis=1)

    # Find primary key columns for source_df
    primary_keys_s = find_primary_key(transformed_source_df)

    # Ensure primary_keys_s is a string or a tuple
    primary_keys_s = primary_keys_s[0] if isinstance(primary_keys_s, tuple) else primary_keys_s

    # Assuming primary_keys_s contains the primary key column name
    primary_key_values_s = transformed_source_df[primary_keys_s].tolist()

    # Find primary key columns for target_df
    primary_keys_t = find_primary_key(target_df)

    # Ensure primary_keys_t is a string or a tuple
    if primary_keys_t is not None:
        primary_keys_t = primary_keys_t[0] if isinstance(primary_keys_t, tuple) else primary_keys_t
        comparison(primary_keys_t)
    else:
        print("Column names in target_df:")
        for col in target_df.columns:
            print(col)
        # Accept a column name as input from the user
        user_input_column = input("Enter a column name from the above list: ")
        # Check if the entered column name is valid
        if user_input_column in target_df.columns:
            comparison(user_input_column)
        else:
            print("Invalid column name. Please enter a valid column name.")
