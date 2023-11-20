import pandas as pd

def migrate_data(row):
    A = int(row['Roll No.'])
    B = row['Name']
    C = int(row['Phone Number'])
    D = row['Class']

    E = f'TVE-{D}-{A}'
    F = f'{B}' 
    G = f'+91 {C}'

    return pd.Series({'College id': E, 'Student Name': F, 'Contact no': G})

# Read source CSV
source_df = pd.read_csv('studentsData.csv')

# Drop rows with null values in specified columns
source_df = source_df.dropna(subset=['Roll No.', 'Name', 'Phone Number', 'Class'])

# Apply migration logic
target_df = source_df.apply(migrate_data, axis=1)

# Concatenate the new columns with the original DataFrame


# Save the result to target CSV
try:
    target_df.to_csv('targetStudent.csv', index=False)
    targetReRead_df = pd.read_csv('targetStudent.csv')
    print(targetReRead_df)
    print("Migrated Successfully")


except Exception as e:
    print("Error in Migration:", e)

