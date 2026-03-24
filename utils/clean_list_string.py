import ast
import pandas as pd

def clean_list_string(val):
    # Handle nulls
    if pd.isna(val) or val is None or str(val).lower() == 'nan':
        return None 
    
    val_str = str(val).strip()
    
    # If the CSV saved it as a Python list string like "['2018', '2019']"
    if val_str.startswith('[') and val_str.endswith(']'):
        try:
            # Safely evaluate the string into a python list
            parsed_list = ast.literal_eval(val_str)
            # Strip any lingering braces/quotes from the items
            return [str(item).strip("{}'\" ") for item in parsed_list]
        except (ValueError, SyntaxError):
            pass 
            
    # If the CSV saved it as a Postgres array string like "{2018, 2019}"
    # Strip the outside braces/brackets and split by comma
    cleaned_str = val_str.strip("{}[]'\"")
    if not cleaned_str:
        return None
        
    return [item.strip(" '\"") for item in cleaned_str.split(',')]