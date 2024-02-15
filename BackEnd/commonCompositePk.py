from itertools import combinations
import logging 
import tkinter as tk
from tkinter import filedialog
from readSouce import * 
from tabulate import tabulate
import numpy as np


def read_data(file_path):
    
    if file_path.endswith('.xlsx'):
        
        try:
            data = pd.read_excel(file_path, engine='openpyxl')
        except Exception:
            data = pd.read_excel(file_path, engine='xlrd')
    elif file_path.endswith('.csv'):
        data = pd.read_csv(file_path)
    else:
        print("Unsupported file format. Please provide an Excel (XLSX) or CSV file.")
        return None
        

  
    data.columns = [str(col) for col in data.columns]
    return data
# Configure logging to write to a file
# logging.basicConfig(filename='log_file.txt', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
# def get_file():
#         try:
#             root = tk.Tk()
#             root.withdraw()
#             file_path = filedialog.askopenfilename(title="Select a file")
#         except Exception as e:
#             print(e)
#             file_path = input("Enter the path of the file: ")

#         if not file_path:
#             print("No file selected")
    

#         print(f"Selected file: {file_path}")
#         data = read_data(file_path)
        
#         if data is None:
#             print("No data found")
#         return data
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

def find_same_columns_by_value(df_src, df_tgt, ck_set1, ck_set2):
    duplicate_columns = []

    for col1 in ck_set1:
        for col2 in ck_set2:
            try:
                # Ensure columns exist in DataFrames
                if col1 not in df_src.columns or col2 not in df_tgt.columns:
                    logging.warning(f"Column {col1} or {col2} not found in DataFrame. Skipping comparison.")
                    continue
                
                # Convert columns to tuples of values
                src_values = df_src[col1].values.tolist()
                tgt_values = df_tgt[col2].values.tolist()
                
                # Find common values using set intersection
                common_values = set(src_values) & set(tgt_values)
                
                # Compare with half of the total number of unique values
                if len(common_values) >= len(set(src_values)) / 2:
                    duplicate_columns.append([col1, col2])
            except KeyError as e:
                logging.warning(f"KeyError: {e}. Skipping comparison for {col1} and {col2}")

    if duplicate_columns == []:
        return None, None
    return duplicate_columns
def is_composite_key(data):
    if data:
        pk_data2 = data[0]  # Considering the first primary key from the list

        if len(pk_data2) > 1:
            
            return True
        else:
            
            return False
    else:
        print("No primary key found for Data .")
        return False
def get_two_keys(data1, data2):
    try:
        logging.info("Getting candidate keys for Data 1")
        ck_set_1 = find_candidtae_keys(data1)
        
        
        logging.info(f"Candidate keys for Data 1: {ck_set_1}")

        logging.info("Getting candidate keys for Data 2")
        ck_set_2 = find_candidtae_keys(data2)
        logging.info(f"Candidate keys for Data 2: {ck_set_2}")
        
        
        if (is_composite_key(ck_set_2) != True and is_composite_key(ck_set_1) != True):
            

            ck_name_set1 = [col[0] for col in ck_set_1]
            ck_name_set2 = [col[0] for col in ck_set_2]

            logging.info("Finding common columns by value")
            result = find_same_columns_by_value(data1, data2, ck_name_set1, ck_name_set2)
       
            if result is not None:
                if len(result) > 0:
                    if result[0]==None:
                        return ck_name_set1,ck_name_set2
                    logging.info(f"Common columns found by value: {result}")
                    list_1 = []
                    list_2 = []
                    for item in result:
                        list_1.append([item[0]])
                        list_2.append([item[1]])
                
                    return list_1,list_2
                else:
                    logging.warning("Unexpected number of common columns found.")
                    return None
            else:
                logging.warning("No common columns found.")
                return ck_name_set1,ck_name_set2
        else:
            print("Primary key for Data 1 and 2  is composite.")
            return ck_set_1, ck_set_2    
    except Exception as ex:
        logging.exception(f"An exception occurred: {ex}")
        return None


# # Example usage:
# data1 = get_file()  # Replace with your actual data loading logic
# data2 = get_file()  # Replace with your actual data loading logic

# logging.info("Getting two keys")
# result = get_two_keys(data1, data2)
# print(result)

# try:
#     if result is not None:
#         if len(result) == 2:
#             pk1, pk2 = result
#             print(f"Primary key for Data 1: {pk1}")
#             print(f"Primary key for Data 2: {pk2}")
#         elif len(result) > 2:
#             print("Multiple options for primary keys. Displaying options:")
#             headers = ["Option", "Primary Key for Data 1", "Primary Key for Data 2"]
#             options = [(i + 1, item[0], item[1]) for i, item in enumerate(result)]
#             print(tabulate(options, headers=headers, tablefmt="pretty"))
#         else:
#             logging.warning("Unexpected result structure. Unable to unpack.")
#     else:
#         logging.warning("No common columns found.")
# except Exception as ex:
#     logging.exception(f"An exception occurred during result processing: {ex}")
