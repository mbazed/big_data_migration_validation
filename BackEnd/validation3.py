import pandas as pd
import  numpy as np
import time
import json  # Import the json module

# Configure the logging settings with a specific format
# logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

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
    nullErrorString = ""
    errorCount = 0

    for column, sourceValue in sourceRow.items():
        if column != primaryKey:
            targetValue = targetRow[column] if column in targetRow.index else None

            # Check for null values
            if pd.isnull(targetValue) or targetValue == '' or str(targetValue).strip() == '':
                if pd.isnull(sourceValue) or sourceValue == '' or str(sourceValue).strip() == '':
                    # Both values are null
                    continue
                else:
                    errorCount += 1
                    nullErrorString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}\n"
                    nullErrorString += f"Expected: {sourceValue}\n"
                    nullErrorString += f"Found: {targetValue}\n"
            else:
                # Check for non-null values
                if str(sourceValue) != str(targetValue):
                    errorCount += 1
                    outputString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}\n"
                    outputString += f"Expected: {sourceValue}\n"
                    outputString += f"Found: {targetValue}\n"

    # logging.info(f"rowByRowCompare: primaryKey - {primaryKey}, sourceRow - {sourceRow}, targetRow - {targetRow}, outputString - {outputString}")
    
    return outputString, nullErrorString  # Return both outputString and nullErrorString

def dividedCompare(sourceData, targetData, mappingDoc_input, primary_key):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData
    
    outputString = []  
    missingRows = []
    duplicateRows = []
    nullErrorString = ""  # Initialize nullErrorString

    start_time = time.time()

    if source_df.shape[0] == target_df.shape[0]:
        # Compare data types of source and target DataFrames
        data_types_source = source_df.dtypes.replace('object', 'string').to_dict()
        data_types_target = target_df.dtypes.replace('object', 'string').to_dict()
        # print(data_types_source)
        # print(data_types_target)
        mismatched_data_types = []

        # Compare data types for each column
        for column in data_types_source:
            if column in data_types_target:
                if data_types_source[column] != data_types_target[column]:
                    mismatched_data_types.append(column)
            else:
                outputString.append(f">> Column '{column}' not found in target DataFrame")
        
        # Append mismatched data types to outputString
        if mismatched_data_types:
            outputString.append("Mismatched Data Types:")
            for column in mismatched_data_types:
                outputString.append(f"Column '{column}': Source type - {data_types_source[column]}, Target type - {data_types_target.get(column, 'Not found')}")

        for _, srcRow in source_df.iterrows():
            transformed_source_row = generate_target_data(srcRow, mappingDoc)
            primary_key_value = transformed_source_row[primary_key]

            # Convert primary_key_value to the data type of target_df[primary_key].values
            primary_key_value = target_df[primary_key].values.dtype.type(primary_key_value)

            if primary_key_value in target_df[primary_key].values:
                target_row = target_df[target_df[primary_key] == primary_key_value]
                result, nullErrors = rowByRowCompare(transformed_source_row, target_row.iloc[0], primary_key)
                if result:
                    outputString.append(result)
                if nullErrors:
                    nullErrorString += nullErrors
            else:
                outputString.append(f">> Primary key {primary_key_value} not found in target_df")
                outputString.append(str(srcRow))  # Convert srcRow to string
       
        errorCount = ''.join(outputString).count(">>")
        errornos=[f"Total errors found: {errorCount}\n"]
        errornos.extend(outputString)
        outputString=errornos
        # logging.info(f"dividedCompare: primary_key - {primary_key}, outputString - {outputString}, Total errors found: {errorCount}")

    elif source_df.shape[0] < target_df.shape[0]:
        outputString.append(f"\nTarget DataFrame contains duplicate values.\nNo.of rows of source: {source_df.shape[0]}\nNo.of rows of target: {target_df.shape[0]}")
        duplicateRows = target_df[target_df.duplicated(subset=primary_key, keep=False)]
        # print(duplicateRows)  # Collect duplicate rows
    else:
        outputString.append(f"\nValues are missing in the target DataFrame.\nNo.of rows of source: {source_df.shape[0]}\nNo.of rows of target: {target_df.shape[0]}")
        missingRows = source_df[~source_df[primary_key].isin(target_df[primary_key])]  # Find entire missing rows
        # print(missingRows)
        if not missingRows.empty:
            # Convert missingRows DataFrame to a dictionary
            missingRows_dict = missingRows.to_dict(orient='records')
            missingRows = missingRows_dict
            outputString.append("\nMissing Rows:\n" + json.dumps(missingRows))  # Serialize to JSON format
        else:
            outputString.append("\nNo Missing Rows Found")  # If missingRows is empty
    
    end_time = time.time()  # Measure end time
    processing_time = end_time - start_time
    print(processing_time)
    

    # Construct JSON object
    result_json = {
    "missingRows": missingRows,
    "mismatchedDataTypes": mismatched_data_types,
    "nullErrorString": nullErrorString.split(">>"),  # Split by '>>' symbol
    "outputString": ''.join(outputString)
   }

  
    return json.dumps(result_json)  # Return the JSON object