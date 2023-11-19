
# from readSouce import read_csv_file,find_majority_element
import csv
from collections import Counter
import csv
from io import StringIO

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

def replace_substrings_with_keys(input_str, substitution_dict):
    if input_str == None:
        return None
    for key, value in substitution_dict.items():
        if value != None:
            input_str = input_str.replace(value, f'{{{key}}}')
    return input_str
    
def mappColumn(Sourcedata, TargetData):
    outputString="Maping Doc\n-------------------\n"
    output_file_path="mappingLog.txt"
    with open(output_file_path, 'w') as output_file:
        for key in TargetData[0].keys():
            outlist = []
            mappingResult = None

            for i in range(len(Sourcedata)):
                if TargetData[i][key] == "":
                    continue
                output_string = replace_substrings_with_keys(TargetData[i][key], Sourcedata[i])
                if output_string == None:
                    continue
                outlist.append(output_string)
                mappingResult = find_repeated_element(outlist, 5)
                if(mappingResult != None):
                    output_file.write(
                        f"Original String: {TargetData[i][key]}   Output String: {output_string}\n"
                        "-------------------------------------------------------------\n"
                        f"{key}: {mappingResult}\n"
                        "-------------------------------------------------------------\n"
                    )
                    break

                # Write the line to the file
                output_line = f"Original String: {TargetData[i][key]}   Output String: {output_string}\n"
                output_file.write(output_line)

            print("-------------------------------------------------------------")
        
            outputString += f"{key}: {mappingResult}\n"
            print("Data in target: ", TargetData[i][key])
            print(key, ": ", mappingResult)
    return outputString

# Sourcedata=read_csv_file('studentsData.csv')
# TargetData=read_csv_file('targetStudent.csv')
def mapColumnstring(SourcedataString, TargetDataString):
    Sourcedata=read_csv_String_to_dic(SourcedataString);
    Targetdata=read_csv_String_to_dic(TargetDataString);
    return mappColumn(Sourcedata,Targetdata)
    
        
