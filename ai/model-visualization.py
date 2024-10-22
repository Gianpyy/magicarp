from keras.src.utils import plot_model
from model import build_autoencoder

# Costruisci il modello
model = build_autoencoder(input_feature_dim=365, window_size=7)

# Visualizza il modello
plot_model(model, to_file='autoencoder_model4.png', show_shapes=True, show_layer_names=True, show_layer_activations=True)
