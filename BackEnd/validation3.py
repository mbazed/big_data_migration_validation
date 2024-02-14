import math
import pandas as pd
# from primary_key import find_primary_key
from comonPk import get_two_keys
import logging
from collections import Counter
import time
import threading
from threading import local

thread_local = local()
# Configure the logging settings with a specific format
logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# Global variables
threadout = [""] * 4
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
    errorString = ""

    for column, sourceValue in sourceRow.items():
        if column != primaryKey:
            targetValue = targetRow[column] if column in targetRow.index else None
            if str(sourceValue) != str(targetValue):
                errorString += f">>For {primaryKey}: {sourceRow[primaryKey]}, Column {column} values differ:\n"
                errorString += f"Source: {sourceValue}\n"
                errorString += f"Target: {targetValue}\n"
    
    # logging.info(f"rowByRowCompare: primaryKey - {primaryKey}, sourceRow - {sourceRow}, targetRow - {targetRow}, errorString - {errorString}")
    return errorString

def process_rows_dynamic(rows, target_df, mappingDoc, primary_key, thread_index):
    global threadout
    local_output_string = []

    for _, srcRow in rows.iterrows():
        transformed_source_row = generate_target_data(srcRow, mappingDoc)
        primary_key_value = transformed_source_row[primary_key]
            
        primary_key_value = target_df[primary_key].values.dtype.type(primary_key_value)

        if primary_key_value in target_df[primary_key].values:
            target_row = target_df[target_df[primary_key] == primary_key_value]
            result = rowByRowCompare(transformed_source_row, target_row.iloc[0], primary_key)
            if result:
                local_output_string.append(result)
        else:
            local_output_string.append(f">> Primary key {primary_key_value} not found in target_df")
    
    logging.info(f"dividedCompare: primary_key - {primary_key}, outputString - {local_output_string}")
    # print(f"dividedCompare: primary_key - {primary_key}, outputString - {local_output_string}")
    # setattr(thread_local, f'outputString_{thread_index}', local_output_string)
    threadout[thread_index]=local_output_string
    

def dividedCompare(sourceData, targetData, mappingDoc_input, primary_key):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData
    errorCount=0
    logging.info(f"dividedCompare: mappingDoc - {mappingDoc}")
    start_time = time.time()  # Measure start time

    num_threads = 4
    chunk_size = math.floor(source_df.shape[0]/num_threads)  # Adjust this based on your requirements
    

    threads = []
    for i in range(num_threads):
        start_idx = i * chunk_size
        end_idx = min((i + 1) * chunk_size, len(source_df))
        thread = threading.Thread(target=process_rows_dynamic, args=(source_df.iloc[start_idx:end_idx], target_df, mappingDoc, primary_key, i))
        threads.append(thread)
        thread.start()

    # Wait for all threads to finish
    for thread in threads:
        thread.join()

    # Flatten the list of lists
    flattened_list = [item for sublist in threadout for item in sublist]

    # Convert the characters to a string
    outputString = ''.join(map(str, flattened_list))

    # Count the occurrences of ">>"
    errorCount = outputString.count(">>")
    
    errornos=f"Total errors found: {errorCount}\n"
    errornos+= outputString
    outputString=errornos

# Update outputString with the corrected errornos
    
    end_time = time.time()  # Measure end time
    processing_time = end_time - start_time
    print(f"Processing time with parallel processing: {processing_time} seconds")
    print(f"Output string :{outputString} ")
    logging.info(f"dividedCompare_parallel_dynamic: primary_key - {primary_key}, outputString - {outputString}")
    return outputString