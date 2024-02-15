
# from readSouce import read_csv_file,find_majority_element
import csv
from collections import Counter
import csv
from io import StringIO
from comonPk import *

def read_csv_String_to_dic(csv_string):
    # Create an empty list to store dictionaries
    data_list = []

    # Create a StringIO object to treat the string as a file
    csv_file = StringIO(csv_string)

    # Read the CSV file
    csv_reader = csv.DictReader(csv_file)

    # Iterate over rows in the CSV file
    for row in csv_reader:
        data_list.append(row)

    return data_list

# Example usage:

def df_to_list_of_dicts(df):
    # Convert DataFrame to CSV string
    csv_string = df.to_csv(index=False)

    # Create an empty list to store dictionaries
    data_list = []

    # Create a StringIO object to treat the string as a file
    csv_file = StringIO(csv_string)

    # Read the CSV file
    csv_reader = csv.DictReader(csv_file)

    # Iterate over rows in the CSV file
    for row in csv_reader:
        data_list.append(row)

    return data_list


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


def find_repeated_element(lst, min_repetitions):
    counts = Counter(lst)

    for element, count in counts.items():
        if count >= min_repetitions:
            return element

    return None

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
def remove_duplicates(lst):
    unique_tuples = set(tuple(inner_list) for inner_list in lst)
    return [list(unique_tuple) for unique_tuple in unique_tuples]

def clean(my_list):
    result = []
    unique_tuples = set(tuple(inner_list) for inner_list in my_list)
    unique_list =[list(unique_tuple) for unique_tuple in unique_tuples]
    
    for thelist in unique_list:
        if( my_list.count(thelist)>5):
            result.append(thelist)
            
    return result

def replace_substrings_with_keys(target_column, input_str, substitution_dict):
    

    if input_str is None:
        return None
    i=0
    keys=[]
    for key, value in substitution_dict.items():
        if value is not None and value != '':
            input_str = input_str.replace(value, f'{{{i}}}')
            keys.append(key)
            i+=1   
             
    for j in range(i):
        input_str = input_str.replace(f'{{{j}}}', f'{{{keys[j]}}}')
                  
    return input_str
    
def mappColumn(src, trg, source_key_column, target_key_column):
    
    global hash_map 
    global connectionsList
    Sourcedata=df_to_list_of_dicts(src)
    TargetData=df_to_list_of_dicts(trg)
    threshold = TargetData.__len__() * 0.05
    
    connectionsList = []
    hash_map={}
    
    outputString = ""
    output_file_path = "mappingLog.txt"
    mappingDoc = {}  # Dictionary to store mapping results
    
    with open(output_file_path, 'w') as output_file:
        for key in TargetData[0].keys():
            
            outlist = []
            mappingResult = None

            for source_row in Sourcedata:
                # Fetch the corresponding row from the target data based on the primary key
                target_row = next((row for row in TargetData if row[target_key_column] == source_row[source_key_column]), None)

                if target_row is None or target_row[key] == "" :
                    continue

                output_string = replace_substrings_with_keys(key, target_row[key], source_row)

                if output_string is None:
                    continue

                outlist.append(output_string)
                mappingResult = find_repeated_element(outlist,threshold)

                if mappingResult is not None:
                    # Update the mapping dictionary
                    mappingDoc[key] = mappingResult
                    
                    output_file.write(
                        f"Original String: {target_row[key]}   Output String: {output_string}\n"
                        "-------------------------------------------------------------\n"
                        f"{key}: {mappingResult}\n"
                        "-------------------------------------------------------------\n"
                    )
                    
                    # Add to mappingDoc immediately after writing to outputString
                    outputString += f"{key}: {mappingResult}\n"
                    # print("Data in target: ", target_row[key])
                    # print(key, ": ", mappingResult)
                    
                    break

                # Write the line to the file
                output_line = f"Original String: {target_row[key]}   Output String: {output_string}\n"
                output_file.write(output_line)

            # print("-------------------------------------------------------------")
            
            
            
    connectionsList = remove_duplicates(connectionsList)
    # Return the output string and mapping dictionary
    if len(mappingDoc) == 0:
        return "No mapping found", mappingDoc
    
    return outputString, mappingDoc, connectionsList


# Example usage:

# src=get_file()
# trgt=get_file()

# SourcedataString = read_csv_file('A1.csv')
# TargetDataString = read_csv_file('A2.csv')


# Sourcedata=read_csv_String_to_dic(SourcedataString);
# Targetdata=read_csv_String_to_dic(TargetDataString);
# pks=get_two_keys(Sourcedata,Targetdata)
# printKeys(pks)

# if(len(pks)==2):
#     source_key_column = pks[0]  # Replace with the actual primary key column in source data
#     target_key_column = pks[1]  # Replace with the actual primary key column in target data
# elif(len(pks)>2):
#     source_key_column=input("Enter Pk for Source")
#     target_key_column=input("Enter Pk for target")
    
    

# mappColumn(SourcedataString, TargetDataString, source_key_column, target_key_column)




def mapColumnstring(SourcedataString, TargetDataString, source_key_column, target_key_column):
    Sourcedata=read_csv_String_to_dic(SourcedataString);
    Targetdata=read_csv_String_to_dic(TargetDataString);
    return mappColumn(Sourcedata,Targetdata, source_key_column, target_key_column)
    
        
