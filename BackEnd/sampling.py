import pandas as pd

def perform_sampling(source_data,  sample_percent=10):
    # Read the CSV file into a DataFrame
    df = source_data

    # Apply condition if provided
    # if condition:
    #     filtered_df = df.query(condition)
    # else:
    #     filtered_df = df

    sample_size = int(len(df)* sample_percent/100)
    # Perform sampling
    sampled_df = df.sample(n=sample_size )

    return sampled_df

def collect_sample_data_with_primary_key(data_file,  sample_percent=10, primary_key='ID'):
    # Perform sampling on the source data
    sampled_data = perform_sampling(data_file, sample_percent)
    
    # Get the primary key values corresponding to the sampled data
    sampled_primary_keys = sampled_data[primary_key].tolist()

    return sampled_data, sampled_primary_keys

def collect_corresponding_data_from_target(target_file, sampled_primary_keys, primary_key='ID'):
    # Read the target CSV file into a DataFrame
    target_df = target_file
    
    # Filter the target data based on primary key values from sampled source data
    sample_target_data = target_df[target_df[primary_key].isin(sampled_primary_keys)]

    return sample_target_data