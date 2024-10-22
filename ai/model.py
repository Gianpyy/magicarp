import tensorflow as tf
from sklearn.ensemble import IsolationForest
from sklearn.neighbors import LocalOutlierFactor

# Keras setup
Input = tf.keras.layers.Input
Dense = tf.keras.layers.Dense
Dropout = tf.keras.layers.Dropout
LSTM = tf.keras.layers.LSTM
Model = tf.keras.models.Model
Sequential = tf.keras.models.Sequential
Bidirectional = tf.keras.layers.Bidirectional
BatchNormalization = tf.keras.layers.BatchNormalization
GRU = tf.keras.layers.GRU
RepeatVector = tf.keras.layers.RepeatVector
TimeDistributed = tf.keras.layers.TimeDistributed


# Isolation Forest
def isolation_forest_model(X_data, contamination=0.05):
    model = IsolationForest(contamination=contamination)
    pseudo_labels = model.fit_predict(X_data)
    pseudo_labels = (pseudo_labels == -1).astype(int)  # Convert -1 (anomalia) e 1 (normale) in 0 e 1
    return pseudo_labels


# Local Outlier Factor (LOF)
def lof_model(X_data, contamination=0.05):
    model = LocalOutlierFactor(n_neighbors=20, contamination=contamination)
    pseudo_labels = model.fit_predict(X_data)
    pseudo_labels = (pseudo_labels == -1).astype(int)  # Convert -1 (anomalia) e 1 (normale) in 0 e 1
    return pseudo_labels


# Autoencoder con lunghezza di sequenza variabile
def build_autoencoder(input_feature_dim, window_size):
    # Definisci l'input per accettare sequenze di lunghezza variabile
    input_layer = Input(shape=(window_size, input_feature_dim))  # Fissa la dimensione della finestra

    # Encoder
    encoded = LSTM(64, activation='relu', return_sequences=False)(input_layer)

    # Decoder
    decoded = RepeatVector(window_size)(encoded)  # Usa window_size qui
    decoded = LSTM(input_feature_dim, activation='relu', return_sequences=True)(decoded)

    # Output
    decoded = TimeDistributed(Dense(input_feature_dim, activation='sigmoid'))(decoded)

    # Autoencoder Model
    autoencoder = Model(inputs=input_layer, outputs=decoded)
    autoencoder.compile(optimizer='adam', loss='mean_squared_error')
    return autoencoder


# Autoencoder per dati giornalieri (vettori statici)
def build_daily_autoencoder(input_dim):
    # Encoder
    input_layer = Input(shape=(input_dim,))
    encoded = Dense(128, activation='relu')(input_layer)
    encoded = Dense(64, activation='relu')(encoded)
    encoded = Dense(32, activation='relu')(encoded)

    # Decoder
    decoded = Dense(64, activation='relu')(encoded)
    decoded = Dense(128, activation='relu')(decoded)
    decoded = Dense(input_dim, activation='sigmoid')(decoded)

    # Autoencoder Model
    autoencoder = Model(inputs=input_layer, outputs=decoded)
    autoencoder.compile(optimizer='adam', loss='mean_squared_error')
    return autoencoder


# RelapsePredNet LSTM model
def build_relapse_prednet(input_shape):
    model = Sequential()
    model.add(Bidirectional(LSTM(128, return_sequences=False), input_shape=input_shape))
    model.add(BatchNormalization())
    model.add(Dropout(0.2))
    model.add(Dense(128, activation='relu'))
    model.add(BatchNormalization())
    model.add(Dense(64, activation='relu'))
    model.add(Dense(1, activation='sigmoid'))
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
    return model


# GRU Sequence-to-Sequence model
def build_seq2seq(input_shape):
    encoder_inputs = Input(shape=input_shape)
    encoded = GRU(128, activation='relu', return_sequences=False)(encoder_inputs)
    repeat_vector = RepeatVector(input_shape[0])(encoded)
    decoded = GRU(128, activation='relu', return_sequences=True)(repeat_vector)
    decoded = TimeDistributed(Dense(input_shape[1], activation='sigmoid'))(decoded)
    seq2seq_autoencoder = Model(encoder_inputs, decoded)
    seq2seq_autoencoder.compile(optimizer='adam', loss='mean_squared_error')
    return seq2seq_autoencoder
