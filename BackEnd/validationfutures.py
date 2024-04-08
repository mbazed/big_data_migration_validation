from mpi4py.futures import MPIPoolExecutor
import pandas as pd
import numpy as np
import time
import json

# Global variables
mappingDoc = {}
num_processes = 4

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
            if(pd.isnull(targetValue) or targetValue == '' or str(targetValue).strip() == ''):
                if (pd.isnull(sourceValue) or sourceValue == '' or str(sourceValue).strip() == ''):
                    # Both values are null
                    continue
                else:
                    errorCount += 1
                    nullErrorString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}\n"
                    nullErrorString += f"Expected: {sourceValue}\n"
                    nullErrorString += f"Found: {targetValue}\n"

            # Check for non-null values
            elif str(sourceValue) != str(targetValue):
                errorCount += 1
                outputString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}\n"
                outputString += f"Expected: {sourceValue}\n"
                outputString += f"Found: {targetValue}\n"
    return outputString, nullErrorString

def process_rows_dynamic(chunk, target_df, mappingDoc, primary_key):
    local_output_string = []  # Local list to store errors
    local_null_error_string = []  # Local list to store null errors
    for _, srcRow in chunk.iterrows():
        transformed_source_row = generate_target_data(srcRow, mappingDoc)
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
            local_output_string.append(srcRow)

    return local_output_string, local_null_error_string

def dividedCompareParallelFutures(sourceData, targetData, mappingDoc_input, primary_key):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData 

    outputString = []
    mainNullErrorString = []
    missingRows = []
    duplicateRows = []

    start_time = time.time()

    if source_df.shape[0] == target_df.shape[0]:

        data_types_source = source_df.dtypes.replace('object', 'string').to_dict()
        data_types_target = target_df.dtypes.replace('object', 'string').to_dict()
        mismatched_data_types = []

        # Compare data types for each column
        for column in data_types_source:
            if column in data_types_target:
                if data_types_source[column] != data_types_target[column]:
                    mismatched_data_types.append(column)
            else:
                outputString.append(f">> Column '{column}' not found in target DataFrame")

        with MPIPoolExecutor() as executor:
            chunks = np.array_split(source_df, num_processes)
            results = executor.map(process_rows_dynamic, chunks, [target_df]*num_processes, [mappingDoc]*num_processes, [primary_key]*num_processes)
            for result in results:
                local_output_string, local_null_error_string = result
                outputString.extend(local_output_string)
                mainNullErrorString.extend(local_null_error_string)

        errorCount = ''.join(outputString).count(">>")
        errornos = [f"Total errors found: {errorCount}\n"]
        errornos.extend(outputString)
        outputString = errornos

    elif source_df.shape[0] < target_df.shape[0]:
        outputString.append(f"\nTarget DataFrame contains duplicate values.\nNo.of rows of source: {source_df.shape[0]}\nNo.of rows of target: {target_df.shape[0]}")
        duplicateRows = target_df[target_df.duplicated(subset=primary_key, keep=False)]

    else:
        outputString.append(f"\nValues are missing in the target DataFrame.\nNo.of rows of source: {source_df.shape[0]}\nNo.of rows of target: {target_df.shape[0]}")
        missingRows = source_df[~source_df[primary_key].isin(target_df[primary_key])]
        if not missingRows.empty:
            missingRows_dict = missingRows.to_dict(orient='records')
            missingRows = missingRows_dict
            outputString.append("\nMissing Rows:\n" + json.dumps(missingRows))
        else:
            outputString.append("\nNo Missing Rows Found")
    
    end_time = time.time()
    processing_time = end_time - start_time
    print(processing_time)

    result_json = {
        "mismatchedDataTypes": mismatched_data_types,
        "missingRows": missingRows,
        "nullErrorString": mainNullErrorString,
        "outputString": ''.join(outputString),
    }

    return json.dumps(result_json)
