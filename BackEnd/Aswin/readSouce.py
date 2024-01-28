import csv
import json
import pandas as pd
from io import StringIO
from io import StringIO


# Use StringIO to simulate a file-like object from the string
def read_csv_string(csv_string):
    


    data_df = pd.read_csv(StringIO(csv_string))
    
    

# Print the result
    return data_df

def json_to_df(json_string):
    data_dict = json.loads(json_string)
    dfdata = pd.DataFrame(data_dict)
    return dfdata
def read_file_content_df(file):
    """
    Reads the content of a CSV or Excel file and returns a Pandas DataFrame.

    Parameters:
        file (werkzeug.datastructures.FileStorage): The uploaded file.

    Returns:
        pd.DataFrame: The DataFrame containing the file data.
    """
    # Check the file extension
    file_extension = file.filename.split('.')[-1].lower()

    if file_extension == 'csv':
        # Read CSV file
        df = pd.read_csv(file)
    elif file_extension in ['xls', 'xlsx']:
        # Read Excel file
        df = pd.read_excel(file)
    else:
        raise ValueError(f"Unsupported file format: {file_extension}. Supported formats are CSV and Excel.")

    return df

def read_csv_file(csv_file_path):
    # Create an empty list to store dictionaries
    data_list = []

    # Read the CSV file
    with open(csv_file_path, mode='r', encoding='utf-8-sig') as csv_file:
        csv_reader = csv.DictReader(csv_file)

        # Iterate over rows in the CSV file
        for row in csv_reader:
            data_list.append(row)
    
    # data_list.pop()    
    return data_list



def find_majority_element(nums):
    candidate = None
    count = 0

    # Step 1: Find a candidate
    for num in nums:
        if count == 0:
            candidate = num
        count += (1 if num == candidate else -1)

    # Step 2: Check if the candidate is a majority element
    count = 0
    for num in nums:
        if num == candidate:
            count += 1

    if count > len(nums) // 2:
        return candidate
    else:
        return None



# Print the list of dictionaries
