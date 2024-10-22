import numpy as np

from model import build_autoencoder


def train_autoencoder(X_train, X_val):
    input_dim = X_train.shape[1]
    autoencoder = build_autoencoder(input_dim)
    history = autoencoder.fit(X_train, X_train, epochs=50, batch_size=32, validation_data=(X_val, X_val))
    return autoencoder, history


def detect_anomalies(autoencoder, X_data):
    # Ricostruisci i dati e calcola l'errore di ricostruzione
    reconstructed = autoencoder.predict(X_data)
    reconstruction_error = ((X_data - reconstructed) ** 2).mean(axis=1)

    # Imposta una soglia per le anomalie
    threshold = np.percentile(reconstruction_error, 95)
    pseudo_labels = (reconstruction_error > threshold).astype(int)

    return pseudo_labels, reconstruction_error
