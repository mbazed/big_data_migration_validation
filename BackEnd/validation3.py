import pandas as pd


import logging
from collections import Counter
from myapp import *
from readSouce import *

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
    errorCount = 0
    
    for column, sourceValue in sourceRow.items():
        if column != primaryKey:
            targetValue = targetRow[column] if column in targetRow.index else None
            if str(sourceValue) != str(targetValue):
                errorCount += 1
                outputString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}\n"
                outputString += f"Expected: {sourceValue}\n"
                outputString += f"Found: {targetValue}\n"
    
    # logging.info(f"rowByRowCompare: primaryKey - {primaryKey}, sourceRow - {sourceRow}, targetRow - {targetRow}, outputString - {outputString}")
    return outputString

def dividedCompare(sourceData, targetData, mappingDoc_input, primary_key):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData
    logging.info(f"dividedCompare: mappingDoc - {mappingDoc}")
    logging.info(f"dividedCompare: primary_key used - {primary_key}")

    outputString = []  

    for _, srcRow in source_df.iterrows():
        transformed_source_row = generate_target_data(srcRow, mappingDoc)
        primary_key_value = transformed_source_row[primary_key]

        # Convert primary_key_value to the data type of target_df[primary_key].values
        primary_key_value = target_df[primary_key].values.dtype.type(primary_key_value)

        if primary_key_value in target_df[primary_key].values:
            target_row = target_df[target_df[primary_key] == primary_key_value]
            result = rowByRowCompare(transformed_source_row, target_row.iloc[0], primary_key)
            if result:
                outputString.append(result)
        else:
            outputString.append(f">> Primary key {primary_key_value} not found in target_df")
            
    errorCount = ''.join(outputString).count(">>")
    outputString.append(f"\nTotal errors found: {errorCount}")
    logging.info(f"dividedCompare: primary_key - {primary_key}, outputString - {outputString}, Total errors found: {errorCount}")
    return ''.join(outputString)

