import multiprocessing
from multiprocessing import Manager
import pandas as pd
import numpy as np
import time

# Global variables
mappingDoc = {}


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
    # print(outputString)  # Printing here
    return outputString, nullErrorString

def process_rows_dynamic(chunk, target_df, mappingDoc, primary_key, queue):
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

    queue.put((local_output_string, local_null_error_string))  # Put local lists in the queue

def dividedCompareParallel(sourceData, targetData, mappingDoc_input, primary_key, num_processes):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData
    num_process = num_processes  

    outputString = []
    missingRows = []
    duplicateRows = []

    # Create a multiprocessing Manager to manage the queue
    manager = Manager()
    queue = manager.Queue()

    # Create and start multiple processes
    processes = []

    start_time = time.time()

    if source_df.shape[0] == target_df.shape[0]:
        for i in range(num_processes):
            chunk_size = source_df.shape[0] // num_processes
            source_df_chunk = source_df[i * chunk_size:(i + 1) * chunk_size]
            process = multiprocessing.Process(target=process_rows_dynamic, args=(source_df_chunk, target_df, mappingDoc, primary_key, queue))
            process.start()
            processes.append(process)

        for process in processes:
            process.join()

        # Collect errors from the queue
        while not queue.empty():
            local_output_string, local_null_error_string = queue.get()
            outputString.extend(local_output_string) 
            outputString.extend(local_null_error_string)

        errorCount = ''.join(outputString).count(">>")
        errornos = [f"Total errors found: {errorCount}\n"]
        errornos.extend(outputString)
        outputString = errornos

    elif source_df.shape[0] < target_df.shape[0]:
        outputString.append(f"\nTarget DataFrame contains duplicate values.\nNo.of rows of source: {source_df.shape[0]}\nNo.of rows of target: {target_df.shape[0]}")
        duplicateRows = target_df[target_df.duplicated(subset=primary_key, keep=False)]
        # print(duplicateRows)  # Collect duplicate rows
    else:
        outputString.append(f"\nValues are missing in the target DataFrame.\nNo.of rows of source: {source_df.shape[0]}\nNo.of rows of target: {target_df.shape[0]}")
        missingRows = source_df[~source_df[primary_key].isin(target_df[primary_key])]  # Find entire missing rows
        # print(missingRows)
        outputString.append("\nMissing Rows:\n" + missingRows.to_string(index=False))  

    end_time = time.time()  # Measure end time
    processing_time = end_time - start_time

    print(processing_time)
    return ''.join(outputString)
