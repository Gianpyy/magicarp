import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler


def preprocess_and_clean_data(raw_data):
    # Extract features from raw data
    data = raw_data

    # Fill raws containing NaN
    data['loc_dist_ep_0'].fillna(value=0, inplace=True)
    data['loc_visit_num_ep_0'].fillna(value=0, inplace=True)
    data['audio_amp_mean_ep_0'].fillna(value=0, inplace=True)
    data['light_mean_ep_0'].fillna(value=0, inplace=True)


    # Remove 'u' from eureka_id
    data['eureka_id'] = data['eureka_id'].apply(lambda x: int(x[1:]))

    # Extract features from date
    data['day'] = pd.to_datetime(raw_data['day'], format="%Y%m%d")
    min_date = pd.to_datetime('2012-01-01')
    data = data[data['day'] >= min_date]
    data['year'] = data['day'].dt.year
    data['month'] = data['day'].dt.month
    data['day_of_month'] = data['day'].dt.day
    data['weekday'] = data['day'].dt.weekday  # 0 = Lunedì, 6 = Domenica

    # Calculate first day feature
    data['first_day'] = data.groupby('eureka_id')['day'].transform('min')
    data['days_since_start'] = (data['day'] - data['first_day']).dt.days

    # Drop unnecessary columns
    data = data.drop(columns=['first_day'])

    # Cyclic feature for month and weekday
    data['month_sin'] = np.sin(2 * np.pi * data['month'] / 12)
    data['month_cos'] = np.cos(2 * np.pi * data['month'] / 12)
    data['weekday_sin'] = np.sin(2 * np.pi * data['weekday'] / 7)
    data['weekday_cos'] = np.cos(2 * np.pi * data['weekday'] / 7)

    # Remove patients with less than 30 days of data
    patient_counts = data.groupby('eureka_id').size().reset_index(name='count')
    patients_to_keep = patient_counts[patient_counts['count'] >= 30]['eureka_id']
    filtered_data = data[data['eureka_id'].isin(patients_to_keep)]

    return filtered_data


def create_sliding_window(data, window_size):
    sequences = []
    for i in range(len(data) - window_size + 1):
        sequences.append(data[i:i + window_size])
    return np.array(sequences)


def split_data(data, eureka_id):
    # Escludi le colonne non numeriche
    # columns_to_scale = data.columns.difference(['eureka_id', 'day'])

    # Dividi i dati in train e test set
    train_data = data[data['eureka_id'] != eureka_id]
    test_data = data[data['eureka_id'] == eureka_id]

    return train_data, test_data


def scale_data(train_data, test_data, features):
    scaler = MinMaxScaler()
    x_train_scaled = scaler.fit_transform(train_data[features])
    x_test_scaled = scaler.transform(test_data[features])

    return x_train_scaled, x_test_scaled


def binarize_autoencoder_predictions(original_data, reconstructed_data, threshold_percentile=95):
    # Calcola l'errore di ricostruzione (differenza assoluta media)
    reconstruction_error = np.mean(np.abs(original_data - reconstructed_data), axis=1)

    # Imposta una soglia basata sul percentile scelto
    threshold = np.percentile(reconstruction_error, threshold_percentile)

    # Binarizza le predizioni: 1 = anomalia, 0 = normale
    binary_predictions = (reconstruction_error > threshold).astype(int)

    return binary_predictions


def calculate_reconstruction_error(x_test, reconstructed_data):
    reconstruction_error = np.mean(np.abs(x_test - reconstructed_data), axis=1)
    return reconstruction_error
