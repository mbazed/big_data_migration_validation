import threading
import pandas as pd
import numpy as np
import logging
import concurrent.futures
# from myapp import *
from readSouce import *
import time

# Configure the logging settings with a specific format
# logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# Global variables
mappingDoc = {}
num_threads = 4

global_ErrorString = [[] for _ in range(num_threads)]

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

            # Check for null values
            if pd.isnull(sourceValue) or sourceValue == '' or str(sourceValue).strip() == '':
                if (pd.isnull(sourceValue) or sourceValue == '' or str(sourceValue).strip() == '') and \
                   (pd.isnull(targetValue) or targetValue == '' or str(targetValue).strip() == ''):
                    # Both values are null
                    continue
                else:
                    errorCount += 1
                    outputString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}\n"
                    outputString += f"Expected: {sourceValue}\n"
                    outputString += f"Found: {targetValue}\n"

            # Check for non-null values
            elif str(sourceValue) != str(targetValue):
                errorCount += 1
                outputString += f">> For {primaryKey}: {sourceRow[primaryKey]}, Column {column}\n"
                outputString += f"Expected: {sourceValue}\n"
                outputString += f"Found: {targetValue}\n"

    return outputString

def process_rows_dynamic(chunk, target_df, mappingDoc, primary_key,thread_id):
    local_output_string = []
    for _, srcRow in chunk.iterrows():
        transformed_source_row = generate_target_data(srcRow, mappingDoc)
        primary_key_value = transformed_source_row[primary_key]

        # Convert primary_key_value to the data type of target_df[primary_key].values
        primary_key_value = target_df[primary_key].values.dtype.type(primary_key_value)

        if primary_key_value in target_df[primary_key].values:
            target_row = target_df[target_df[primary_key] == primary_key_value]
            result = rowByRowCompare(transformed_source_row, target_row.iloc[0], primary_key)
            if result:
                local_output_string.append(result)
        else:
            local_output_string.append(f">> Primary key {primary_key_value} not found in target_df")
            local_output_string.append(srcRow)
    # print(thread_id)
    global_ErrorString[thread_id]= local_output_string

def dividedCompareParallel(sourceData, targetData, mappingDoc_input, primary_key):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData
    # logging.info(f"dividedCompare: mappingDoc - {mappingDoc}")
    # logging.info(f"dividedCompare: primary_key used - {primary_key}")

    outputString = []
    missingRows = []
    duplicateRows = []

    # Create and start multiple threads
    threads = []

    start_time = time.time()

    if source_df.shape[0] == target_df.shape[0]:
        
        for i in range(num_threads):
            chunk_size = source_df.shape[0] // num_threads
            source_df_chunk = source_df[i * chunk_size:(i + 1) * chunk_size]
            thread = threading.Thread(target=process_rows_dynamic, args=(source_df_chunk, target_df, mappingDoc, primary_key,i))
            thread.start()
            threads.append(thread)

# Wait for all threads to complete
        # for thread in threads:
        #     thread.join()
        
        for i in range(num_threads):
            outputString.extend(global_ErrorString[i])
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
