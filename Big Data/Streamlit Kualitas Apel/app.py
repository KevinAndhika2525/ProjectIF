import streamlit as st
import pandas as pd
import joblib

# ============================================================
# LOAD PIPELINE MODEL (SCALER + XGBOOST)
# ============================================================
try:
    pipeline = joblib.load("apple_quality_pipeline.joblib")
except FileNotFoundError:
    st.error("❌ File 'apple_quality_pipeline.joblib' tidak ditemukan. Pastikan Anda sudah menyimpan pipeline sebelumnya.")
    st.stop()

# ============================================================
# STREAMLIT PAGE CONFIG
# ============================================================
st.set_page_config(
    page_title="Apple Quality Prediction",
    layout="wide"
)

st.title("🍎 Prediksi Kualitas Apel")
st.write("Masukkan nilai atribut apel untuk memprediksi apakah apel tersebut **berkualitas baik atau buruk** menggunakan model **XGBoost Pipeline**.")

# ============================================================
# INPUT FORM (7 Fitur Numerik)
# ============================================================
col1, col2 = st.columns(2)

with col1:
    size = st.number_input("Ukuran (size)", min_value=0.0, max_value=30.0, step=0.1, value=8.0)
    weight = st.number_input("Berat (weight)", min_value=0.0, max_value=500.0, step=1.0, value=150.0)
    sweetness = st.number_input("Sweetness", min_value=0.0, max_value=10.0, step=0.1, value=7.0)
    crunchiness = st.number_input("Crunchiness", min_value=0.0, max_value=10.0, step=0.1, value=6.0)

with col2:
    juiciness = st.number_input("Juiciness", min_value=0.0, max_value=10.0, step=0.1, value=7.0)
    ripeness = st.number_input("Ripeness", min_value=0.0, max_value=10.0, step=0.1, value=8.0)
    acidity = st.number_input("Acidity", min_value=0.0, max_value=10.0, step=0.1, value=4.0)

# ============================================================
# SUSUN INPUT SESUAI URUTAN FITUR DATASET
# ============================================================
input_df = pd.DataFrame([{
    "Size": size,
    "Weight": weight,
    "Sweetness": sweetness,
    "Crunchiness": crunchiness,
    "Juiciness": juiciness,
    "Ripeness": ripeness,
    "Acidity": acidity
}])

# ============================================================
# PREDIKSI
# ============================================================
st.markdown("---")

if st.button("🔍 Prediksi Kualitas Apel"):

    pred = pipeline.predict(input_df)[0]
    prob = pipeline.predict_proba(input_df)[0][1]  # Probabilitas kelas 1

    st.subheader("📌 Hasil Prediksi")

    if pred == 1:
        st.success(f"✔ Apel ini **BERKUALITAS BAIK** (Probabilitas: {prob*100:.2f}%)")
    else:
        st.error(f"⚠ Apel ini **BERKUALITAS BURUK** (Probabilitas: {(1-prob)*100:.2f}%)")

    st.write("Probabilitas lengkap:", pipeline.predict_proba(input_df))
