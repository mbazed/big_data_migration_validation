from itertools import combinations
import logging
from tkinter import filedialog

from tabulate import tabulate
import numpy as np

# Configure logging to write to a file
logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
def get_file():
        try:
            root = tk.Tk()
            root.withdraw()
            file_path = filedialog.askopenfilename(title="Select a file")
        except Exception:
            file_path = input("Enter the path of the file: ")

        if not file_path:
            print("No file selected")
    

        print(f"Selected file: {file_path}")
        data = read_data(file_path)
        
        if data is None:
            print("No data found")
        return data
# ... (other imports and configurations)
def find_candidtae_keys(data):
    columns = data.columns
    min_key = None
    min_key_size = float('inf')
    key = []
    is_unique = False
    foundKey=0
    
    # print("All Columns: ", columns)
    for subset_size in range(1, len(columns)//2 + 1):
        
        for column_combination in combinations(columns, subset_size):
            if len(column_combination) >2 and foundKey==1:
                return  key
            if len(column_combination) > min_key_size:
                return key
                
           
            # print(" " *150, end='\r')
            # print(f"Current Combination: {column_combination}", end='\r')
            
            is_unique = data.groupby(list(column_combination)).size().max() == 1
            if is_unique and len(column_combination) < min_key_size:
                key = []
                min_key = column_combination
                min_key_size = len(column_combination)
                foundKey=1
            if is_unique and len(column_combination) == min_key_size:
                key.append(column_combination)
                foundKey=1
                
    return key
def find_same_columns_by_name(list1, list2):
    # Convert tuples and single-element lists to sets of tuples for efficient comparison
    set1 = {tuple(lst) if isinstance(lst, list) else tuple([lst]) for lst in list1}
    set2 = {tuple(lst) if isinstance(lst) else tuple([lst]) for lst in list2}
    
    # Find the common sets
    common_sets = set1.intersection(set2)
    
    # Convert sets back to lists
    common_lists_result = [list(common_set) for common_set in common_sets]
    if common_lists_result == []:
        return None
    return list(common_lists_result[0])

def find_same_columns_by_value(df_src, df_tgt, ck_set1, ck_set2):
    duplicate_columns = []

    for col1 in ck_set1:
        for col2 in ck_set2:
            try:
                # Find common values using set intersection
                common_values = set(tuple(row) for row in df_src[col1].values) & set(tuple(row) for row in df_tgt[col2].values)
                
                # Compare with half of the total number of unique values
                if len(common_values) >= len(set(tuple(row) for row in df_src[col1].values)) / 2:
                    duplicate_columns.append((col1, col2))
            except KeyError as e:
                logging.warning(f"KeyError: {e}. Skipping comparison for {col1} and {col2}")

    if duplicate_columns == []:
        return None, None
    return duplicate_columns

def get_two_keys(data1, data2):
    try:
        logging.info("Getting candidate keys for Data 1")
        ck_set_1 = find_candidtae_keys(data1)
        logging.info(f"Candidate keys for Data 1: {ck_set_1}")

        logging.info("Getting candidate keys for Data 2")
        ck_set_2 = find_candidtae_keys(data2)
        logging.info(f"Candidate keys for Data 2: {ck_set_2}")

        ck_name_set1 = [col[0] for col in ck_set_1]
        ck_name_set2 = [col[0] for col in ck_set_2]

        logging.info("Finding common columns by name")
        result_names = find_same_columns_by_value(data1,data2,ck_name_set1, ck_name_set2)

        if result_names is not None:
            logging.info(f"Common columns found by name: {result_names}")

            # Extract original tuples from the result names
            result = [next((col for col in ck_set_1 if col[0] == name), None) for name in result_names]

            if result is not None:
                if len(result) == 1:
                    logging.info(f"Single common column found by value: {result}")
                    return result[0]  # Return the single common column as a tuple
                elif len(result) > 1:
                    logging.info(f"Common columns found by value: {result}")
                    return result
                else:
                    logging.warning("Unexpected number of common columns found.")
                    return None
            else:
                logging.warning("Failed to map result names to original tuples.")
                return None
        else:
            logging.warning("No common columns found by name.")
            return None
    except Exception as ex:
        logging.exception(f"An exception occurred: {ex}")
        return None

# Example usage:
data1 = get_file()  # Replace with your actual data loading logic
data2 = get_file()  # Replace with your actual data loading logic

logging.info("Getting two keys")
result = get_two_keys(data1, data2)

try:
    if result is not None:
        if len(result) == 2:
            pk1, pk2 = result
            print(f"Primary key for Data 1: {pk1}")
            print(f"Primary key for Data 2: {pk2}")
        elif len(result) > 2:
            print("Multiple options for primary keys. Displaying options:")
            headers = ["Option", "Primary Key for Data 1", "Primary Key for Data 2"]
            options = [(i + 1, item[0], item[1]) for i, item in enumerate(result)]
            print(tabulate(options, headers=headers, tablefmt="pretty"))
        else:
            logging.warning("Unexpected result structure. Unable to unpack.")
    else:
        logging.warning("No common columns found.")
except Exception as ex:
    logging.exception(f"An exception occurred during result processing: {ex}")
