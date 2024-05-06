import pandas as pd
import  numpy as np
import time
import json  # Import the json module

# Configure the logging settings with a specific format
# logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# Global variables

mappingDoc = {}  # Initialize mappingDoc as an empty dictionary
import math

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

def dividedCompare(sourceData, targetData, mappingDoc_input, primary_key):
    mappingDoc = mappingDoc_input
    source_df = sourceData
    target_df = targetData
    
    mismatched_data_types = []
    corrupedData = []  
    missingRows = []
    duplicateRows = []
    nullErrorString = []  # Initialize nullErrorString

    CerrorCount = 0

    start_time = time.time()

    if source_df.shape[0] < target_df.shape[0]:
        duplicateRows.append(f">> Target DataFrame contains duplicate values.No.of rows of source: {source_df.shape[0]}No.of rows of target: {target_df.shape[0]}")
        duplicateRows = target_df[target_df.duplicated(subset=primary_key, keep=False)]
    if source_df.shape[0] > target_df.shape[0]:
        missingRows.append(f">> Values are missing in the target DataFrame.No.of rows of source: {source_df.shape[0]}No.of rows of target: {target_df.shape[0]}")
        missingRows = source_df[~source_df[primary_key].isin(target_df[primary_key])]  # Find entire missing rows
        # print(missingRows)
        if not missingRows.empty:
            # Convert missingRows DataFrame to a dictionary
            missingRows_dict = missingRows.to_dict(orient='records')
            missingRows = missingRows_dict
            
    # if source_df.shape[0] == target_df.shape[0]:
    # Compare data types of source and target DataFrames
    data_types_source = source_df.dtypes.replace('object', 'string').to_dict()
    data_types_target = target_df.dtypes.replace('object', 'string').to_dict()
    # print(data_types_source)
    # print(data_types_target)

    # Compare data types for each column
    for column in data_types_source:
        if column in data_types_target:
            if data_types_source[column] != data_types_target[column]:
                mismatched_data_types.append(column)
        else:
            # corrupedData.append(f">> Column '{column}' not found in target DataFrame")
            pass


    for _, srcRow in source_df.iterrows():
        transformed_source_row = generate_target_data(srcRow, mappingDoc)
        primary_key_value = transformed_source_row[primary_key]

        # Convert primary_key_value to the data type of target_df[primary_key].values
        primary_key_value = target_df[primary_key].values.dtype.type(primary_key_value)

        if primary_key_value in target_df[primary_key].values:
            target_row = target_df[target_df[primary_key] == primary_key_value]
            result, nullErrors = rowByRowCompare(transformed_source_row, target_row.iloc[0], primary_key)
            if result:
                corrupedData.extend(result)
            if nullErrors:
                nullErrorString.extend(nullErrors)
        else:
            corrupedData.append(f">> Primary key {primary_key_value} not found in target_df")
            corrupedData.append(str(srcRow))  # Convert srcRow to string
       
    CerrorCount = ''.join(corrupedData).count(">>")
    errornos=[f"Total errors found: {CerrorCount} "]
    errornos.extend(corrupedData)
    corrupedData=errornos
    # logging.info(f"dividedCompare: primary_key - {primary_key}, corrupedData - {corrupedData}, Total errors found: {errorCount}")
    #corrupedData.append("Missing Rows:" + json.dumps(missingRows))  # Serialize to JSON format
    # else:
    #corrupedData.append("No Missing Rows Found")  # If missingRows is empty
    

    NerrorCount = ''.join(nullErrorString).count(">>")
    errornos=[f"Total errors found: {NerrorCount} "]
    errornos.extend(nullErrorString)
    nullErrorString=''.join(errornos)

    end_time = time.time()  # Measure end time
    processing_time = end_time - start_time
    print(f"Processing Time: {processing_time}")

    

    # Construct JSON object
    result_json = {
    "missingRowsCount": len(missingRows),
    "mismatchedCount": len(mismatched_data_types),
    "nullErrorCount": NerrorCount,
    "corruptedCount": CerrorCount,
    "missingRows": missingRows,
    "mismatchedDataTypes": mismatched_data_types,
    "nullErrorString": nullErrorString,
    "corruptedData": ''.join(corrupedData),
    "rowsChecked": source_df.shape[0],
   }

    # print(result_json)
    return json.dumps(result_json)  # Return the JSON object
