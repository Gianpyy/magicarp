import numpy as np


def evaluate_model(eureka_id, pseudo_labels, anomalous_days, x_test, reconstructed_data, reconstruction_error, avg_loss):
    num_anomalous_days = len(anomalous_days)
    mse = np.mean(np.square(x_test - reconstructed_data))
    anomaly_percentage = (num_anomalous_days / len(x_test)) * 100
    cumulative_reconstruction_error = np.cumsum(reconstruction_error)
    reconstruction_error_mean = np.mean(reconstruction_error)
    reconstruction_error_std = np.std(reconstruction_error)

    results_ae = {
        #"Model": f"Autoencoder - Paziente {eureka_id}",
        "EurekaID": int(eureka_id),
        "Support": len(pseudo_labels),
        "Anomalous Days": num_anomalous_days,
        "MSE": mse,
        "Anomaly Percentage": anomaly_percentage,
        "Cumulative Error": cumulative_reconstruction_error[-1],
        "Mean Reconstruction Error": reconstruction_error_mean,
        "Std Reconstruction Error": reconstruction_error_std,
        "Average Training Loss": avg_loss
    }

    return results_ae
