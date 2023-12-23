
from getCks import *
def common_lists(list1, list2):
    # Convert tuples and single-element lists to sets of tuples for efficient comparison
    set1 = {tuple(lst) if isinstance(lst, list) else (lst,) for lst in list1}
    set2 = {tuple(lst) if isinstance(lst, list) else (lst,) for lst in list2}
    
    # Find the common sets
    common_sets = set1.intersection(set2)
    
    # Convert sets back to lists
    common_lists_result = [list(common_set) for common_set in common_sets]
    
    return common_lists_result


# Example usage:
list1 =  [('Roll No.',), ('Name',), ('Phone Number',)]
list2 =  [('Roll No.',), ('Name',), ('Phone Number',)]


data1 = get_file()
data2 = get_file()

print("Data 1:", data1)
print("Data 2:", data2)

ck_set_1 = find_candidtae_keys(data1)
ck_set_2 = find_candidtae_keys(data2)

print("Candidate Keys 1:", ck_set_1)
print("Candidate Keys 2:", ck_set_2)

result = common_lists(ck_set_1, ck_set_2)
print("Common Lists Result:", result)
