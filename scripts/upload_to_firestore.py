import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore

# Step 1: Initialize Firebase Admin SDK (use your service account key file)
cred = credentials.Certificate("scripts/talipapa-ef93a-firebase-adminsdk-fbsvc-392a5caca8.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

# Step 2: Load your dummy Excel file
df = pd.read_excel("scripts/SampleData.xlsx")  # Make sure this file exists in the same folder

# Step 3: Upload each row to Firestore
for _, row in df.iterrows():
    data = {
        "date": row["Date"],
        "commodity": row["Commodity"],  
        "commodity_type": row["Commodity Type"],  
        "specification": row["Specification"],  
        "unit": row["Unit"],  
        "weekly_average_price": float(row["Weekly Average Price"]),  
    }
    db.collection("commodities").add(data)

print("✅ Dummy data uploaded to Firestore.")
