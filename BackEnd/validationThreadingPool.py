import pandas as pd
from validation3 import *
import time
from multiprocessing import Pool, Manager
import json

# Global variables
num_processes = 6

def process_rows_dynamic(args):
    chunk, target_df, mappingDoc, primary_key = args
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
            local_output_string.append(str(srcRow))

    return local_output_string, local_null_error_string

def dividedCompareParallelPool(sourceData, targetData, mappingDoc_input, primary_key):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData

    mismatched_data_types = []
    mainNullErrorString = []
    missingRows = []
    corruptedData = []
    duplicateRows = []
    CerrorCount = 0

    start_time = time.time()

    if source_df.shape[0] < target_df.shape[0]:
        corruptedData.append(f">> Target DataFrame contains duplicate values.No.of rows of source: {source_df.shape[0]}No.of rows of target: {target_df.shape[0]}")
        duplicateRows = target_df[target_df.duplicated(subset=primary_key, keep=False)]

    elif source_df.shape[0] > target_df.shape[0]:
        corruptedData.append(f">> Values are missing in the target DataFrame.No.of rows of source: {source_df.shape[0]}No.of rows of target: {target_df.shape[0]}")
        missingRows = source_df[~source_df[primary_key].isin(target_df[primary_key])]
        if not missingRows.empty:
            missingRows_dict = missingRows.to_dict(orient='records')
            missingRows = missingRows_dict
            print('before:' + ''.join(corruptedData))
            corruptedData.append("Missing Rows:" + json.dumps(missingRows))
            print('after:' + ''.join(corruptedData))
        else:
            corruptedData.append("No Missing Rows Found")

    # else:

    data_types_source = source_df.dtypes.replace('object', 'string').to_dict()
    data_types_target = target_df.dtypes.replace('object', 'string').to_dict()

    # Compare data types for each column
    for column in data_types_source:
        if column in data_types_target:
            if data_types_source[column] != data_types_target[column]:
                mismatched_data_types.append(column)
        else:
            corruptedData.append(f"Column '{column}' not found in target DataFrame")

    # Split the source data into chunks for multiprocessing
    chunks = []
    chunk_size = source_df.shape[0] // num_processes
    for i in range(num_processes):
        chunk = source_df[i * chunk_size:(i + 1) * chunk_size]
        chunks.append((chunk, target_df, mappingDoc, primary_key))

    # Create a multiprocessing Manager to manage the results
    # manager = Manager()
    # output_queue = manager.Queue()
    # null_error_queue = manager.Queue()

    # Create a Pool of processes and map the function
    with Pool(processes=num_processes) as pool:
        results = pool.map(process_rows_dynamic, chunks)

    # Collect results
    for local_output_string, local_null_error_string in results:
        corruptedData.extend(local_output_string)
        mainNullErrorString.extend(local_null_error_string)

    CerrorCount = ''.join(corruptedData).count(">>")
    errornos=[f"Total errors found: {CerrorCount} "]
    errornos.extend(corruptedData)
    corrupedData=errornos


    NerrorCount = ''.join(mainNullErrorString).count(">>")
    errornos=[f"Total errors found: {NerrorCount} "]
    errornos.extend(mainNullErrorString)
    mainNullErrorString=''.join(errornos)
    
    end_time = time.time()
    processing_time = end_time - start_time
    print(f"Processing Time: {processing_time}")


    result_json = {
        "missingRowsCount": len(missingRows),
        "mismatchedCount": len(mismatched_data_types),
        "nullErrorCount": NerrorCount,
        "corruptedCount": CerrorCount,
        "mismatchedDataTypes": mismatched_data_types,
        "nullErrorString": mainNullErrorString,
        "missingRows": missingRows,
        "corruptedData": ''.join(corruptedData),
        "rowsChecked": source_df.shape[0],

    }

    return json.dumps(result_json)
