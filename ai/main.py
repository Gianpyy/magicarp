import numpy as np
import pandas as pd
from data_processing import preprocess_and_clean_data, create_sliding_window, split_data, \
    calculate_reconstruction_error, binarize_autoencoder_predictions, scale_data
from evaluation import evaluate_model
from model import build_autoencoder
from training import train_model, make_prediction
from utils import save_anomalies_to_markdown, set_relapse_label, save_results_to_db


def run_lopo_cross_validation_with_sliding_window(daily_data, features, window_size=7):
    print("Avvio Leave-One-Patient-Out Cross-Validation con Sliding Window")

    all_results = []
    eureka_ids = daily_data['eureka_id'].unique()
    global_anomalous_days = []

    for test_eureka_id in eureka_ids:
        # Split data into train and test
        x_train, x_test = split_data(daily_data, test_eureka_id)
        x_train_scaled, x_test_scaled = scale_data(x_train, x_test, features)

        if len(x_train) >= window_size:
            x_train_sliding = create_sliding_window(x_train_scaled, window_size)

            # Build autoencoder model
            print(f"Addestramento Autoencoder per paziente {test_eureka_id}")
            input_shape = (x_train_sliding.shape[1], x_train_sliding.shape[2])
            autoencoder = build_autoencoder(input_shape[1], window_size)

            # Train model
            history = autoencoder.fit(x_train_sliding, x_train_sliding, epochs=50, batch_size=32, validation_split=0.2)

            # Get mean loss on model train
            average_loss = np.mean(history.history['loss'])

            if len(x_test) >= window_size:
                x_test_sliding = create_sliding_window(x_test_scaled, window_size)

                # Make prediction on test data
                reconstructed_data = autoencoder.predict(x_test_sliding)

                # Calculate reconstruction error
                reconstruction_error = np.mean(np.abs(x_test_sliding - reconstructed_data), axis=1)

                # Binarize predictions
                pseudo_labels = binarize_autoencoder_predictions(x_test_sliding, reconstructed_data)

                # Filter dates in the sliding window
                x_test['date'] = pd.to_datetime(daily_data['day'])
                window_dates = x_test['date'].values[window_size - 1:]

                # Reduce array, considering a day as anomalous if there's at least one anomaly
                pseudo_labels_reduced = np.any(pseudo_labels == 1, axis=1)

                # Filter anomalous dates
                anomalous_days = np.unique(window_dates[pseudo_labels_reduced])

                # Evaluate model
                results = evaluate_model(
                    eureka_id=test_eureka_id,
                    pseudo_labels=pseudo_labels,
                    anomalous_days=anomalous_days,
                    x_test=x_test_sliding,
                    reconstructed_data=reconstructed_data,
                    reconstruction_error=reconstruction_error,
                    avg_loss=average_loss
                )

                # Save global anomalous days
                global_anomalous_days.append(results['Anomalous Days'])

                # Append results into all results
                all_results.append(results)

    # Set relapse label in results
    set_relapse_label(
        threshold=75,
        results=all_results,
        global_anomalous_days=global_anomalous_days
    )

    # Print results
    output_file = "output/evaluation_metrics_sliding.md"
    save_anomalies_to_markdown(all_results, output_file)
    save_results_to_db(all_results)


# Load data
raw_data = pd.read_csv('data/CrossCheck_Daily_Data.csv')

# Run data pre-processing procedures

data = preprocess_and_clean_data(raw_data)
features = [
    'eureka_id',  # ID
    'year',
    'month',
    'day_of_month',
    'weekday',
    'days_since_start',
    'month_sin',
    'month_cos',
    'weekday_sin',
    'weekday_cos',
    'audio_convo_duration_ep_0',  # Duration of detected conversations
    'audio_convo_num_ep_0',  # Number of detected conversations
    'loc_dist_ep_0',  # Distance travelled
    'loc_visit_num_ep_0',  # Number of visited locations
    'unlock_num_ep_0',  # Number of lock/unlocks
    'unlock_duration_ep_0',  # Duration in unlocked status
    'audio_amp_mean_ep_0',
    'light_mean_ep_0',
]

# Define parameters for algorithm
window_size = 7

# Run Leave-One-Patient-Out cross-validation
run_lopo_cross_validation_with_sliding_window(data, features, window_size)
