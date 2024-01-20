import os
import pandas as pd
import logging
from primary_key import find_primary_key

log_directory = "logs"
log_file_path = os.path.join(log_directory, "validationlog.txt")

if not os.path.exists(log_directory):
    os.makedirs(log_directory)

# Configure logging settings
logging.basicConfig(filename=log_file_path, level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def transform_row(row, rules_dict):
    transformed_data = {}

    for key, rule in rules_dict.items():
        # Replace {key} with row['key'] to handle column names with spaces
        formatted_rule = rule.replace('{', "row['").replace('}', "']")
        transformed_value = eval(f'f"{formatted_rule}"', {'row': row})
        transformed_data[key] = transformed_value

    return transformed_data


    
# def apply_transformations(row, transformation_rules):
    
    
    
#     logging.info(f"Applying transformations to row: {row}, using rules: {transformation_rules}    as this : {convert_rules(transformation_rules)}")
#     college_id = f"TVE-{row['Class']}-{row['Roll No.']}"
#     student_name = row['Name']
#     contact_no = f"+91 {row['Phone Number']}"
#     # ... more transformations ...

#     return pd.Series(
#         convert_rules(transformation_rules)
#     )
def compare(primary_keys_s, primary_keys_t, transformed_source_df, target_df):
    resultString = ""
    
    logging.info(f"Comparing Data with primary keys: {primary_keys_s}, {primary_keys_t}")
    
    primary_key_values_t = target_df[primary_keys_t].tolist()
    primary_key_values_s = transformed_source_df[primary_keys_s].tolist()

    for primary_key_value in primary_key_values_s:
        logging.info(f"Checking primary key value: {primary_key_value}")
        
        if primary_key_values_t.count(primary_key_value) > 1:
            resultString += f"Duplicate primary key value found: {primary_key_value}\n"
            logging.warning(f"Duplicate primary key value found: {primary_key_value}")

        if primary_key_value in primary_key_values_t:
            row_s_transformed = transformed_source_df[transformed_source_df[primary_keys_s] == primary_key_value]
            row_t = target_df[target_df[primary_keys_t] == primary_key_value]

            if not row_s_transformed.empty and not row_t.empty:
                for column in transformed_source_df.columns:
                    value_s = row_s_transformed[column].iloc[0] if column in row_s_transformed.columns else None
                    value_t = row_t[column].iloc[0] if column in row_t.columns else None

                    if value_s != value_t:
                        resultString += f"For {primary_keys_s}: {primary_key_value}, Column {column} values differ:\n"
                        resultString += f"Source: {value_s}\n"
                        resultString += f"Target: {value_t}\n"
                        logging.warning(f"For {primary_keys_s}: {primary_key_value}, Column {column} values differ")
            else:
                resultString += f"For {primary_keys_s}: {primary_key_value}, Data is Missing\n"
                logging.warning(f"For {primary_keys_s}: {primary_key_value}, Data is Missing")
        else:
            resultString += f"For {primary_keys_s}: {primary_key_value}, Data is Missing\n"
            logging.warning(f"For {primary_keys_s}: {primary_key_value}, Data is Missing")

    logging.info(f"Result String: {resultString}")
    return resultString

def compareData(pks, pkt, source_df, target_df, mapingDoc):
    logging.info(f"Comparing Data with primary keys: {pks}, {pkt}")
    logging.info(f"Mapping Document: {mapingDoc}")
    
    # source_df = pd.read_csv('A1.csv')
    # target_df = pd.read_csv('A2.csv')

    logging.info("Read CSV files into DataFrames")
    
    transformed_source_df = source_df.apply(transform_row, axis=1, args=(mapingDoc,))
    logging.info("Applied transformations to source DataFrame")

    primary_keys_s = find_primary_key(transformed_source_df)
    primary_keys_s = primary_keys_s[0] if isinstance(primary_keys_s, tuple) else primary_keys_s
    
    if primary_keys_s:
        primary_key_values_s = transformed_source_df[primary_keys_s].tolist()
        logging.info(f"Primary Key values for source DataFrame: {primary_key_values_s}")
    else:
        logging.warning("No primary keys found for source DataFrame")
        
    primary_keys_t = find_primary_key(target_df)

    if primary_keys_t:
        primary_keys_t = primary_keys_t[0] if isinstance(primary_keys_t, tuple) else primary_keys_t
        logging.info(f"Primary Key values for target DataFrame: {target_df[primary_keys_t].tolist()}")
    else:
        logging.warning("No primary keys found for target DataFrame")

    result = compare(primary_keys_s, primary_keys_t, transformed_source_df, target_df)
    logging.info(f"Comparison Result: {result}")

    return result
