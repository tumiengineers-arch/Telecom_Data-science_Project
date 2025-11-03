
# Adding att the csv files 
from google.colab import files
uploaded = files.upload()

# Step 1: Load and merge telecom datasets
import pandas as pd

# Load datasets
customers = pd.read_csv('telecom_customers.csv')
usage = pd.read_csv('telecom_usage.csv')
billing = pd.read_csv('telecom_billing.csv')
tickets = pd.read_csv('telecom_tickets.csv')

# Merge datasets
df = customers.merge(usage, on='customer_id') \
              .merge(billing, on='customer_id') \
              .merge(tickets.groupby('customer_id').agg({
                  'ticket_id': 'count',
                  'resolved': 'mean',
                  'resolution_time_days': 'mean'
              }).reset_index(), on='customer_id', how='left')

# Preview
df.head()









