import pandas as pd
from itertools import combinations
import time
import tkinter as tk
from tkinter import filedialog

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




def find_minimal_primary_key(data):
    columns = data.columns
    min_key = None
    min_key_size = float('inf')
    key = []
    is_unique = False
    foundKey=0
    prevLen=10
    
    print("All Columns: ", columns)
    for subset_size in range(1, len(columns)//2 + 1):
        
        for column_combination in combinations(columns, subset_size):
            
            if len(column_combination) > min_key_size:
                return 1,min_key, key
                
           
            print(" " *prevLen, end='\r')
            print(f"Current Combination: {column_combination}", end='\r')
            prevLen=len(f"Current Combination: {column_combination}")
            
            is_unique = data.groupby(list(column_combination)).size().max() == 1
            if is_unique and len(column_combination) < min_key_size:
                key = []
                min_key = column_combination
                min_key_size = len(column_combination)
                foundKey=1
            if is_unique and len(column_combination) == min_key_size:
                key.append(column_combination)
                foundKey=1
                
    return foundKey,min_key, key



# try:
#     root = tk.Tk()
#     root.withdraw()
#     file_path = filedialog.askopenfilename(title="Select a file")
# except Exception:
#     file_path = input("Enter the path of the file: ")

# if not file_path:
#     print("No file selected")

# print(f"Selected file: {file_path}")
# data = read_data(file_path)

def getPrimaryKey(data):
    
    if data is None:
        print("No data found")
    
    foundKey, minimal_primary_key, all_Pk = find_minimal_primary_key(data)

    if foundKey:
        print("\nMinimal Primary Key:", ', '.join(minimal_primary_key))
        print("======================\nAll Primary Keys:", all_Pk)
        # return str(', '.join(minimal_primary_key))
        return minimal_primary_key
        
    else:
        print("No minimal primary key found")
        return None, None




        
    


    
    
