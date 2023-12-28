import pandas as pd

# Sample data frame with duplicate columns
# data = {'A': [1, 2, 3], 'B': [1, 9, 3], 'C': [7, 8, 9]}
# df_src = pd.DataFrame(data)
# data = {'E': [1, 2, 3], 'F': [4, 5, 6], 'G': [7, 6, 9]}
# df_tgt = pd.DataFrame(data)




# Check for duplicate columns

def find_same_columns(df_src, df_tgt,ck_set1,ck_set2):
    duplicate_columns = []

    for col1 in ck_set1:
        for col2 in ck_set2:
            if (df_src[col1] == df_tgt[col2]).all():
                duplicate_columns.append((col1, col2))

    # print("Duplicate Columns:", duplicate_columns)
    if duplicate_columns == []:
        return None
    return duplicate_columns
    
    

