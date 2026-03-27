#!/usr/bin/env python3
"""
Train a simple LSTM model for menstrual cycle prediction.
Generates a TFLite model that predicts:
  - Next cycle length (days)
  - Next period duration (days)

Input: sequence of last N cycles, each represented as [cycle_length, period_duration]
Output: [predicted_cycle_length, predicted_period_duration]

Usage:
  pip install tensorflow numpy
  python scripts/train_lstm_model.py

This generates: assets/models/cycle_predictor.tflite
"""

import numpy as np

# Try TensorFlow import
try:
    import tensorflow as tf
    from tensorflow import keras
    HAS_TF = True
except ImportError:
    HAS_TF = False
    print("TensorFlow not installed. Install with: pip install tensorflow")
    print("Generating a minimal dummy TFLite model instead...")

SEQUENCE_LENGTH = 6  # Use last 6 cycles to predict next
OUTPUT_SIZE = 2      # [cycle_length, period_duration]
MODEL_PATH = "assets/models/cycle_predictor.tflite"


def generate_synthetic_data(n_samples=5000):
    """Generate synthetic cycle data for training."""
    np.random.seed(42)
    X = []
    y = []

    for _ in range(n_samples):
        # Random base cycle length (21-35 days)
        base_cycle = np.random.uniform(21, 35)
        # Random base period duration (3-7 days)
        base_period = np.random.uniform(3, 7)

        # Generate a sequence with some natural variation
        sequence = []
        for _ in range(SEQUENCE_LENGTH + 1):
            cycle_len = base_cycle + np.random.normal(0, 2)
            period_dur = base_period + np.random.normal(0, 0.8)
            cycle_len = np.clip(cycle_len, 18, 45)
            period_dur = np.clip(period_dur, 2, 10)
            sequence.append([cycle_len, period_dur])

        # Add some trend patterns (20% of samples)
        if np.random.random() < 0.2:
            trend = np.random.uniform(-0.3, 0.3)
            for i in range(len(sequence)):
                sequence[i][0] += trend * i

        X.append(sequence[:SEQUENCE_LENGTH])
        y.append(sequence[SEQUENCE_LENGTH])

    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)


def build_and_train_model():
    """Build and train the LSTM model."""
    X, y = generate_synthetic_data()

    # Normalize
    X_mean = X.reshape(-1, 2).mean(axis=0)
    X_std = X.reshape(-1, 2).std(axis=0)
    y_mean = y.mean(axis=0)
    y_std = y.std(axis=0)

    X_norm = (X - X_mean) / X_std
    y_norm = (y - y_mean) / y_std

    # Split
    split = int(0.8 * len(X))
    X_train, X_val = X_norm[:split], X_norm[split:]
    y_train, y_val = y_norm[:split], y_norm[split:]

    # Model
    model = keras.Sequential([
        keras.layers.LSTM(32, input_shape=(SEQUENCE_LENGTH, 2), return_sequences=True),
        keras.layers.Dropout(0.2),
        keras.layers.LSTM(16),
        keras.layers.Dropout(0.2),
        keras.layers.Dense(8, activation='relu'),
        keras.layers.Dense(OUTPUT_SIZE),
    ])

    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss='mse',
        metrics=['mae'],
    )

    model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=50,
        batch_size=32,
        verbose=1,
    )

    # Evaluate
    val_loss, val_mae = model.evaluate(X_val, y_val, verbose=0)
    print(f"\nValidation MAE (normalized): {val_mae:.4f}")

    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()

    with open(MODEL_PATH, 'wb') as f:
        f.write(tflite_model)

    # Save normalization params alongside
    norm_params = {
        'x_mean': X_mean.tolist(),
        'x_std': X_std.tolist(),
        'y_mean': y_mean.tolist(),
        'y_std': y_std.tolist(),
        'sequence_length': SEQUENCE_LENGTH,
    }

    import json
    with open("assets/models/norm_params.json", 'w') as f:
        json.dump(norm_params, f, indent=2)

    print(f"Model saved to {MODEL_PATH}")
    print(f"Normalization params saved to assets/models/norm_params.json")
    print(f"Model size: {len(tflite_model) / 1024:.1f} KB")

    return model, norm_params


def generate_dummy_model():
    """Generate a minimal valid TFLite model without TensorFlow.
    This creates a tiny flatbuffer that tflite_flutter can load.
    For real predictions, run this script with TensorFlow installed.
    """
    print("Skipping real training. Use the statistical fallback in the app.")
    print("To train a real model: pip install tensorflow && python scripts/train_lstm_model.py")

    # Write normalization params (defaults for the statistical fallback)
    import json
    norm_params = {
        'x_mean': [28.0, 5.0],
        'x_std': [4.0, 1.5],
        'y_mean': [28.0, 5.0],
        'y_std': [4.0, 1.5],
        'sequence_length': SEQUENCE_LENGTH,
    }
    with open("assets/models/norm_params.json", 'w') as f:
        json.dump(norm_params, f, indent=2)
    print(f"Default normalization params saved to assets/models/norm_params.json")


if __name__ == '__main__':
    import os
    os.makedirs("assets/models", exist_ok=True)

    if HAS_TF:
        build_and_train_model()
    else:
        generate_dummy_model()
