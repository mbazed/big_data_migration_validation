import pandas as pd
from primary_key import find_primary_key
import logging
from collections import Counter
from myapp import *

# Configure the logging settings with a specific format
logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# Global variables
global target_df
global source_df
global transformed_source_df
global primary_keys_s
global primary_key_values_s
mappingDoc = {}  # Initialize mappingDoc as an empty dictionary

def substitute_pattern(pattern, row):
    for key, value in row.items():
        pattern = pattern.replace(f"{{{key}}}", str(value))
    return pattern

def generate_target_data(row, patterns):
    target_data = {}
    for key, pattern in patterns.items():
        target_data[key] = substitute_pattern(pattern, row)
    return pd.Series(target_data)

def comparison(key):
    global target_df
    global transformed_source_df
    global primary_keys_s
    global primary_key_values_s
    primary_keys_t = key
    primary_key_values_t = target_df[primary_keys_t].tolist()
    errors=[]

    # Loop through each primary key value
    for primary_key_value in primary_key_values_s:
        # Check for duplicate primary key values
        if primary_key_values_t.count(primary_key_value) > 1:
            logging.warning(f"Duplicate primary key value found: {primary_key_value}")
            errors.append(f"Duplicate primary key value found: {primary_key_value}")

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

                    # Compare values and log if they are not equal
                    if value_s != value_t:
                        logging.error(f"For {primary_keys_s}: {primary_key_value}, Column {column} values differ:")
                        logging.error(f"Source: {value_s}")
                        logging.error(f"Target: {value_t}")
                        error_msg = (
                            f"For {primary_keys_s}: {primary_key_value}, Column {column} values differ:\n"
                            f"Source: {value_s}\n"
                            f"Target: {value_t}"
                        )
                        errors.append(error_msg)
          
            else:
                logging.error(f"For {primary_keys_s}: {primary_key_value}, Data is Missing")
                errors.append(f"For {primary_keys_s}: {primary_key_value}, Data is Missing")
        else:
            logging.error(f"For {primary_keys_s}: {primary_key_value},  primary")
            errors.append(f"For {primary_keys_s}: {primary_key_value}, Data is Missing")
    return "\n".join(errors)

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
    logging.info(f"findAll: mappingDoc - {mappingDoc}")
    
    # Apply transformations to source_df
    transformed_source_df = source_df.apply(generate_target_data, axis=1, args=(mappingDoc,))
    logging.info(f"findAll: transformed_source_df - {transformed_source_df}")

    # Find primary key columns for source_df
    primary_keys_s = find_primary_key(target_df)

    # Ensure primary_keys_s is a string or a tuple
    primary_keys_s = primary_keys_s[0] if isinstance(primary_keys_s, tuple) else primary_keys_s
    logging.info(f"findAll: primary_keys_s - {primary_keys_s}")

    # Assuming primary_keys_s contains the primary key column name
    primary_key_values_s = transformed_source_df[primary_keys_s].tolist()
    logging.info(f"findAll: primary_key_values_s - {primary_key_values_s}")

    # Find primary key columns for target_df
    primary_keys_t = find_primary_key(target_df)

    # Ensure primary_keys_t is a string or a tuple
    if primary_keys_t is not None:
        primary_keys_t = primary_keys_t[0] if isinstance(primary_keys_t, tuple) else primary_keys_t
        logging.info(f"findAll: primary_keys_t - {primary_keys_t}")
        return comparison(primary_keys_t)
    else:
        logging.info("findAll: Column names in target_df:")
        for col in target_df.columns:
            logging.info(col)
        # Accept a column name as input from the user
        user_input_column = input("Enter a column name from the above list: ")
        logging.info(f"findAll: user_input_column - {user_input_column}")
        # Check if the entered column name is valid
        if user_input_column in target_df.columns:
            return comparison(user_input_column)
        else:
            logging.error("findAll: Invalid column name. Please enter a valid column name.")

# Example usage
# findAll(sourcedata_example, targetdata_example, mappingDoc_input_example)
