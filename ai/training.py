def train_model(model, x_train, y_train, epochs, batch_size, validation_split):
    history = model.fit(x_train, y_train, epochs, batch_size, validation_split)
    return history


def make_prediction(model, x_test):
    reconstructed_data = model.predict(x_test)
    return reconstructed_data
