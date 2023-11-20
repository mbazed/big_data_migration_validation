import pandas as pd




def migrate_data(row):
    A = row['ID']
    B = row['Date']
    C = row['Region']
    D = row['City']
    E = row['Category']
    F= row['Product']
    Q= row['Qty']
    U= row['UnitPrice']
    T= row['TotalPrice']

    X = f'{C},{D}'
    Y = f'F{A}' 
    Z = f'{B}-2023'
    

    return pd.Series({'FID': Y, 'Location': X, 'Type': E ,'Item': F,'Quantity': Q,'UnitPrice': U,'TotalPrice': T,'Date':Z})

# Read source ,'
source_df = pd.read_csv('BackEnd\Data\sampledatafoodsales.csv')

# Drop rows with null values in specified columns


source_df = source_df.dropna(subset=['ID', 'Date', 'Region', 'City','Category','Product','Qty','UnitPrice','TotalPrice'])

# Apply migration logic
target_df = source_df.apply(migrate_data, axis=1)

# Concatenate the new columns with the original DataFrame


# Save the result to target CSV
try:
    target_df.to_csv('targetFoodData.csv', index=False)
    targetReRead_df = pd.read_csv('targetFoodData.csv')
    print(targetReRead_df)
    print("Migrated Successfully")


except Exception as e:
    print("Error in Migration:", e)

