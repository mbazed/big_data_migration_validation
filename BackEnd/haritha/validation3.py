import pandas as pd
from primary_key import find_primary_key
from comonPk import get_two_keys
import logging
from collections import Counter
import time

# Configure the logging settings with a specific format
logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# Global variables

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

def rowByRowCompare(sourceRow, targetRow, primaryKey):
    outputString = ""
    
    for column, sourceValue in sourceRow.items():
        if column != primaryKey:
            targetValue = targetRow[column] if column in targetRow.index else None
            if sourceValue != targetValue:
                outputString += f"For {primaryKey}: {sourceRow[primaryKey]}, Column {column} values differ:\n"
                outputString += f"Source: {sourceValue}\n"
                outputString += f"Target: {targetValue}\n"
    
    # logging.info(f"rowByRowCompare: primaryKey - {primaryKey}, sourceRow - {sourceRow}, targetRow - {targetRow}, outputString - {outputString}")
    return outputString

def dividedCompare(sourceData, targetData, mappingDoc_input):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData
    logging.info(f"dividedCompare: mappingDoc - {mappingDoc}")
    
    # Choose the primary key
    primary_key = get_two_keys(target_df, target_df)[0][0]
    # logging.info(f"dividedCompare: primary_key found1 - {primary_key}")

    start_time = time.time()  # Measure start time

    


    # Alternatively, you can use find_primary_key function
    primary_key = find_primary_key(target_df)[0]
    logging.info(f"dividedCompare: primary_key found - {primary_key}")

    outputString = []  

    for _, srcRow in source_df.iterrows():
        transformed_source_row = generate_target_data(srcRow, mappingDoc)
        primary_key_value = transformed_source_row[primary_key]
    
        if primary_key_value in target_df[primary_key].values:
            target_row = target_df[target_df[primary_key] == primary_key_value]
            result = rowByRowCompare(transformed_source_row, target_row.iloc[0], primary_key)
            if result:
                outputString.append(result)
        else:
            outputString.append(f"Primary key {primary_key_value} not found in target_df")
    end_time = time.time()  # Measure end time
    processing_time = end_time - start_time
    print(f"Processing time without parallel processing: {processing_time} seconds")
    logging.info(f"dividedCompare: primary_key - {primary_key}, outputString - {outputString}")
    return ', '.join(outputString)
