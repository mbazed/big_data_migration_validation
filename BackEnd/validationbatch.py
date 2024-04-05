import pandas as pd
from validation3 import *
import time
from multiprocessing import Pool, Manager
import json

# Global variables
num_processes = 6

def substitute_pattern(pattern, row):
    for key, value in row.items():
        if value is None or (isinstance(value, float) and math.isnan(value)):
            pattern = pattern.replace(f"{{{key}}}", "")
        else:
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
                    nullErrorString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}"
                    nullErrorString += f"Expected: {sourceValue}"
                    nullErrorString += f"Found: {targetValue}"
            else:
                # Check for non-null values
                if str(sourceValue) != str(targetValue):
                    errorCount += 1
                    outputString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}"
                    outputString += f"Expected: {sourceValue}"
                    outputString += f"Found: {targetValue}"

    # logging.info(f"rowByRowCompare: primaryKey - {primaryKey}, sourceRow - {sourceRow}, targetRow - {targetRow}, outputString - {outputString}")
    
    return outputString, nullErrorString  # Return both outputString and nullErrorString


def process_batch(args):
    batch, target_df, mapping_doc, primary_key = args
    local_output_string = []  # Local list to store errors
    local_null_error_string = []  # Local list to store null errors
    
    transformed_batch = batch.apply(lambda row: generate_target_data(row, mapping_doc), axis=1)
    
    for index, transformed_source_row in transformed_batch.iterrows():
        primary_key_value = transformed_source_row[primary_key]
        
        # Convert primary_key_value to the data type of target_df[primary_key].values
        primary_key_value = target_df[primary_key].values.dtype.type(primary_key_value)

        if primary_key_value in target_df[primary_key].values:
            target_row = target_df[target_df[primary_key] == primary_key_value]
            result, null_error = rowByRowCompare(transformed_source_row, target_row.iloc[0], primary_key)
            if result:
                local_output_string.append(result)  # Append errors to local list
            if null_error:
                local_null_error_string.append(null_error)  # Append null errors to local list
        else:
            local_output_string.append(f">> Primary key {primary_key_value} not found in target_df")
            local_output_string.append(str(batch.loc[index]))

    return local_output_string, local_null_error_string

def dividedCompareParallelbatch(source_data, target_data, mapping_doc, primary_key):
    source_df = source_data
    target_df = target_data

    mismatched_data_types = []
    main_null_error_string = []
    missingRows = []
    corrupted_data = []
    duplicateRows = []

    start_time = time.time()

    if source_df.shape[0] == target_df.shape[0]:
        data_types_source = source_df.dtypes.replace('object', 'string').to_dict()
        data_types_target = target_df.dtypes.replace('object', 'string').to_dict()

        # Compare data types for each column
        for column in data_types_source:
            if column in data_types_target:
                if data_types_source[column] != data_types_target[column]:
                    mismatched_data_types.append(column)
            else:
                corrupted_data.append(f"Column '{column}' not found in target DataFrame")

        batch_size = source_df.shape[0] // num_processes
        batches = [source_df[i*batch_size:(i+1)*batch_size] for i in range(num_processes)]

        with Pool(processes=num_processes) as pool:
            results = pool.map(process_batch, [(batch, target_df, mapping_doc, primary_key) for batch in batches])

        for local_output_string, local_null_error_string in results:
            corrupted_data.extend(local_output_string)
            main_null_error_string.extend(local_null_error_string)

    # Rest of the code remains the same

    elif source_df.shape[0] < target_df.shape[0]:
        duplicateRows.append(f">> Target DataFrame contains duplicate values.No.of rows of source: {source_df.shape[0]}No.of rows of target: {target_df.shape[0]}")
        duplicateRows = target_df[target_df.duplicated(subset=primary_key, keep=False)]

    else:
        missingRows.append(f">> Values are missing in the target DataFrame.No.of rows of source: {source_df.shape[0]}No.of rows of target: {target_df.shape[0]}")
        missingRows = source_df[~source_df[primary_key].isin(target_df[primary_key])]
        if not missingRows.empty:
            missingRows_dict = missingRows.to_dict(orient='records')
            missingRows = missingRows_dict
        #     corrupted_data.append("Missing Rows:" + json.dumps(missingRows))
        # else:
        #     corrupted_data.append("No Missing Rows Found")

    end_time = time.time()
    processing_time = end_time - start_time
    print(processing_time)

    result_json = {
        "mismatchedDataTypes": mismatched_data_types,
        "nullErrorString": main_null_error_string,
        "missingRows": missingRows,
        "corrupted_data": ''.join(corrupted_data),
    }

    return json.dumps(result_json)
