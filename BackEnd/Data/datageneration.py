import pandas as pd

# Read the CSV file into a DataFrame
df = pd.read_csv('100000 Sales Records.csv')

# Duplicate the rows to make it 10 lakh (1 million) rows
df_duplicate = pd.concat([df] * 10)

# Reset the index to start from 0
df_duplicate.reset_index(drop=True, inplace=True)

# Add a new column for the primary key index
df_duplicate['index-key'] = range(1, len(df_duplicate) + 1)

# Write the DataFrame to a new CSV file
df_duplicate.to_csv('duplicated_file.csv', index=False)
