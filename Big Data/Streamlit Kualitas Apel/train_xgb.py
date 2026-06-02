import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from xgboost import XGBClassifier

# 1. Load Dataset Bersih
data = pd.read_csv("apple_clean.csv")
print("Dataset loaded. Shape:", data.shape)

X = data.drop("Quality", axis=1)
y = data["Quality"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2,random_state=42)

# 2. Definisi Preprocessing
scaler = StandardScaler()

# 3. Model Terbaik
xgb_model = XGBClassifier(eval_metric="logloss",random_state=42)

# 4. Pipeline Model
pipeline = Pipeline(steps=[
    ('scaler', scaler),
    ('classifier', xgb_model)
])

# 5. Latih Pipeline
print("Melatih pipeline...")
pipeline.fit(X_train, y_train)

# 6. Simpan Pipeline untuk Deployment
joblib.dump(pipeline, "apple_quality_pipeline.joblib")
print("\nPipeline saved as: apple_quality_pipeline.joblib")