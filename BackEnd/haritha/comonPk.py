import logging
from getCks import *
from tabulate import tabulate
import numpy as np

# Configure logging to write to a file
logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

def find_same_columns_by_name(list1, list2):
    # Convert tuples and single-element lists to sets of tuples for efficient comparison
    set1 = {tuple(lst) if isinstance(lst, list) else (lst,) for lst in list1}
    set2 = {tuple(lst) if isinstance(lst) else (lst,) for lst in list2}
    
    # Find the common sets
    common_sets = set1.intersection(set2)
    
    # Convert sets back to lists
    common_lists_result = [list(common_set) for common_set in common_sets]
    if common_lists_result == []:
        return None
    return list(common_lists_result[0][0])

def find_same_columns_by_value(df_src, df_tgt, ck_set1, ck_set2):
    duplicate_columns = []

    for col1 in ck_set1:
        for col2 in ck_set2:
            try:
                # Find common values using set intersection
                common_values = set(df_src[col1].values) & set(df_tgt[col2].values)
                
                # Compare with half of the total number of unique values
                if len(common_values) >= len(set(df_src[col1].values)) / 2:
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

        logging.info("Finding common columns by value")
        result = find_same_columns_by_value(data1, data2, ck_name_set1, ck_name_set2)

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
            logging.warning("No common columns found.")
            return None
    except Exception as ex:
        logging.exception(f"An exception occurred: {ex}")
        return None




def printKeys(result):
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
        
        
# Example usage:
# data1 = get_file()
# data2 = get_file()
# result = get_two_keys(data1, data2)
# printKeys(result)

def comonPkDriverFunction(data1,data2):
    logging.info("Getting two keys")
    result = get_two_keys(data1, data2)
    printKeys(result)
    return result