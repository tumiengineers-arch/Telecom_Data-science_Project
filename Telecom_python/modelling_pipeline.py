#Data loading: Reads all relevant CSVs
#Merging: Combines customer, usage, and billing data
#Feature engineering: Creates binary features for late payment and high usage
#Modeling: Logistic Regression and Random Forest
#Evaluation: Confusion matrix and classification report


# modeling_pipeline.py

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix

# Step 1: Load datasets
customers = pd.read_csv('telecom_customers.csv')
usage = pd.read_csv('telecom_usage.csv')
billing = pd.read_csv('telecom_billing.csv')
tickets = pd.read_csv('telecom_tickets.csv')

# Step 2: Merge datasets
df = customers.merge(usage, on='customer_id') \
              .merge(billing, on='customer_id')

# Step 3: Feature engineering
df['late_payment'] = df['payment_status'].apply(lambda x: 1 if x in ['Late', 'Unpaid'] else 0)
df['high_usage'] = df['data_gb'].apply(lambda x: 1 if x > 5 else 0)

# Step 4: Prepare data for modeling
features = ['age', 'tenure_months', 'monthly_fee', 'call_minutes', 'data_gb', 'sms_count', 'late_payment', 'high_usage']
X = df[features]
y = df['churned']

# Step 5: Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Step 6: Scaling
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Step 7: Modeling
logreg = LogisticRegression()
rf = RandomForestClassifier()

logreg.fit(X_train_scaled, y_train)
rf.fit(X_train, y_train)

# Step 8: Evaluation
print("Logistic Regression Results:")
print(confusion_matrix(y_test, logreg.predict(X_test_scaled)))
print(classification_report(y_test, logreg.predict(X_test_scaled)))

print("Random Forest Results:")
print(confusion_matrix(y_test, rf.predict(X_test)))
print(classification_report(y_test, rf.predict(X_test)))

