import logging
from typing import Dict, List, Any, Tuple
from datetime import datetime
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
import joblib
import os
import warnings
warnings.filterwarnings('ignore')
class TradingNeuralNetwork:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.model = None
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()
        self.is_trained = False
        self.feature_names = []
        self.models_dir = 'models'
        os.makedirs(self.models_dir, exist_ok=True)
        self.model_path = os.path.join(self.models_dir, 'trading_model.keras')
        self.scaler_path = os.path.join(self.models_dir, 'scaler.pkl')
        self.encoder_path = os.path.join(self.models_dir, 'label_encoder.pkl')
        self.load_model()
        self.logger.info(f"Real Neural Network initialized. Trained: {self.is_trained}")
    def _create_model(self, input_dim: int) -> keras.Model:
        model = keras.Sequential([
            layers.Input(shape=(input_dim,)),
            layers.Dense(128, activation='relu'),
            layers.BatchNormalization(),
            layers.Dropout(0.3),
            layers.Dense(64, activation='relu'),
            layers.BatchNormalization(), 
            layers.Dropout(0.3),
            layers.Dense(32, activation='relu'),
            layers.BatchNormalization(),
            layers.Dropout(0.2),
            layers.Dense(16, activation='relu'),
            layers.Dropout(0.1),
            layers.Dense(3, activation='softmax')
        ])
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='categorical_crossentropy',
            metrics=['accuracy', 'precision', 'recall']
        )
        return model
    def prepare_training_data(self, data_fetcher, technical_analyzer, max_stocks: int = 20) -> Tuple[np.ndarray, np.ndarray]:
        self.logger.info("Preparing training data from real stock market data...")
        all_features = []
        all_labels = []
        from config import config
        stocks_processed = 0
        for exchange, symbols in config.POPULAR_STOCKS.items():
            if stocks_processed >= max_stocks:
                break
            self.logger.info(f"Processing stocks from {exchange}")
            symbols_to_process = symbols[:max(1, (max_stocks - stocks_processed) // len(config.POPULAR_STOCKS))]
            for symbol in symbols_to_process:
                if stocks_processed >= max_stocks:
                    break
                try:
                    self.logger.info(f"Processing {symbol} ({exchange})...")
                    data = data_fetcher.get_stock_data(symbol, exchange, period='6mo', interval='1d')
                    if data is None or len(data) < 60:
                        self.logger.warning(f"Insufficient data for {symbol}, skipping")
                        continue
                    samples_generated = 0
                    for i in range(50, len(data) - 5):
                        try:
                            current_data = data.iloc[:i+1]
                            features = technical_analyzer.get_feature_vector(current_data)
                            if len(features) != 12:
                                continue
                            current_price = float(data['Close'].iloc[i])
                            future_price = float(data['Close'].iloc[i+5])
                            return_pct = (future_price - current_price) / current_price * 100
                            if return_pct > 3:
                                label = 'BUY'
                            elif return_pct < -3:
                                label = 'SELL'
                            else:
                                label = 'HOLD'
                            all_features.append(features)
                            all_labels.append(label)
                            samples_generated += 1
                        except Exception as e:
                            continue
                    self.logger.info(f"Generated {samples_generated} samples from {symbol}")
                    stocks_processed += 1
                except Exception as e:
                    self.logger.error(f"Error processing {symbol}: {e}")
                    continue
        if not all_features:
            raise ValueError("No training data could be generated")
        X = np.array(all_features)
        y = np.array(all_labels)
        self.logger.info(f"Prepared {len(X)} training samples from {stocks_processed} stocks")
        return X, y
    def get_model_info(self) -> Dict[str, Any]:
        info = {
            'is_trained': self.is_trained,
            'model_exists': self.model is not None,
            'model_path': self.model_path,
            'classes': list(self.label_encoder.classes_) if self.is_trained else ['BUY', 'SELL', 'HOLD'],
        }
        if self.model and self.is_trained:
            try:
                info.update({
                    'input_shape': self.model.input_shape,
                    'total_params': self.model.count_params(),
                    'layers': len(self.model.layers)
                })
            except:
                pass
        return info
    def train_model(self, data_fetcher, technical_analyzer, max_stocks: int = 15, epochs: int = 50) -> Dict[str, Any]:
        try:
            self.logger.info("Starting real neural network training...")
            X, y = self.prepare_training_data(data_fetcher, technical_analyzer, max_stocks)
            if len(X) < 100:
                raise ValueError(f"Insufficient training data: {len(X)} samples (need at least 100)")
            y_encoded = self.label_encoder.fit_transform(y)
            y_categorical = keras.utils.to_categorical(y_encoded, num_classes=3)
            X_scaled = self.scaler.fit_transform(X)
            X_train, X_test, y_train, y_test = train_test_split(
                X_scaled, y_categorical, test_size=0.2, random_state=42, stratify=y_encoded
            )
            self.logger.info(f"Training samples: {len(X_train)}, Test samples: {len(X_test)}")
            self.model = self._create_model(X_train.shape[1])
            callbacks = [
                keras.callbacks.EarlyStopping(
                    monitor='val_loss', patience=10, restore_best_weights=True, verbose=0
                ),
                keras.callbacks.ReduceLROnPlateau(
                    monitor='val_loss', factor=0.2, patience=5, verbose=0
                )
            ]
            self.logger.info(f"Training for up to {epochs} epochs...")
            history = self.model.fit(
                X_train, y_train,
                epochs=epochs,
                batch_size=32,
                validation_data=(X_test, y_test),
                callbacks=callbacks,
                verbose=0
            )
            test_loss, test_accuracy, test_precision, test_recall = self.model.evaluate(
                X_test, y_test, verbose=0
            )
            y_pred = self.model.predict(X_test, verbose=0)
            y_pred_classes = np.argmax(y_pred, axis=1)
            y_test_classes = np.argmax(y_test, axis=1)
            class_names = self.label_encoder.classes_
            report = classification_report(y_test_classes, y_pred_classes, 
                                         target_names=class_names, output_dict=True, zero_division=0)
            self.save_model()
            self.is_trained = True
            training_results = {
                'test_accuracy': float(test_accuracy),
                'test_precision': float(test_precision),
                'test_recall': float(test_recall),
                'test_loss': float(test_loss),
                'classification_report': report,
                'training_samples': len(X_train),
                'test_samples': len(X_test),
                'epochs_trained': len(history.history['loss']),
                'final_train_accuracy': float(history.history['accuracy'][-1]),
                'final_val_accuracy': float(history.history['val_accuracy'][-1]),
                'message': 'Real training completed successfully'
            }
            self.logger.info(f"Training completed! Test accuracy: {test_accuracy:.4f}")
            return training_results
        except Exception as e:
            self.logger.error(f"Error training model: {str(e)}")
            raise
    def predict(self, features: List[float]) -> Dict[str, Any]:
        try:
            if not self.is_trained or self.model is None:
                return {
                    'prediction': 'HOLD',
                    'confidence': 0.33,
                    'probabilities': {'BUY': 0.33, 'SELL': 0.33, 'HOLD': 0.34},
                    'error': 'Model is not trained',
                    'timestamp': datetime.now().isoformat()
                }
            features_array = np.array([features])
            features_scaled = self.scaler.transform(features_array)
            prediction_probs = self.model.predict(features_scaled, verbose=0)[0]
            predicted_class_idx = np.argmax(prediction_probs)
            predicted_class = self.label_encoder.classes_[predicted_class_idx]
            confidence = float(prediction_probs[predicted_class_idx])
            return {
                'prediction': predicted_class,
                'confidence': confidence,
                'probabilities': {
                    class_name: float(prob) 
                    for class_name, prob in zip(self.label_encoder.classes_, prediction_probs)
                },
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            self.logger.error(f"Error making prediction: {str(e)}")
            return {
                'prediction': 'HOLD',
                'confidence': 0.33,
                'probabilities': {'BUY': 0.33, 'SELL': 0.33, 'HOLD': 0.34},
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    def predict_portfolio_positions(self, positions_data: List[Dict], 
                                  technical_analyzer, data_fetcher) -> List[Dict]:
        predictions = []
        for position in positions_data:
            try:
                symbol = position.get('symbol', '')
                exchange = position.get('exchange', '')
                if not symbol or not exchange:
                    continue
                data = data_fetcher.get_stock_data(symbol, exchange, period='3mo', interval='1d')
                if data is None or len(data) < 50:
                    predictions.append({
                        'symbol': symbol,
                        'exchange': exchange,
                        'prediction': 'HOLD',
                        'confidence': 0.33,
                        'error': 'Insufficient data',
                        'current_price': position.get('current_price', 0),
                        'unrealized_pnl_percent': position.get('unrealized_pnl_percent', 0)
                    })
                    continue
                features = technical_analyzer.get_feature_vector(data)
                if len(features) != 12:
                    predictions.append({
                        'symbol': symbol,
                        'exchange': exchange,
                        'prediction': 'HOLD',
                        'confidence': 0.33,
                        'error': 'Feature calculation error',
                        'current_price': position.get('current_price', 0),
                        'unrealized_pnl_percent': position.get('unrealized_pnl_percent', 0)
                    })
                    continue
                result = self.predict(features)
                result.update({
                    'symbol': symbol,
                    'exchange': exchange,
                    'current_price': position.get('current_price', 0),
                    'unrealized_pnl_percent': position.get('unrealized_pnl_percent', 0)
                })
                predictions.append(result)
            except Exception as e:
                self.logger.error(f"Error predicting for {position.get('symbol', 'unknown')}: {str(e)}")
                predictions.append({
                    'symbol': position.get('symbol', ''),
                    'exchange': position.get('exchange', ''),
                    'prediction': 'HOLD',
                    'confidence': 0.33,
                    'error': str(e),
                    'current_price': position.get('current_price', 0),
                    'unrealized_pnl_percent': position.get('unrealized_pnl_percent', 0)
                })
        return predictions
    def save_model(self):
        try:
            if self.model:
                self.model.save(self.model_path)
                self.logger.info(f"Model saved to {self.model_path}")
            joblib.dump(self.scaler, self.scaler_path)
            joblib.dump(self.label_encoder, self.encoder_path)
            self.logger.info("Model components saved successfully")
            return True
        except Exception as e:
            self.logger.error(f"Error saving model: {str(e)}")
            return False
    def load_model(self) -> bool:
        try:
            if (os.path.exists(self.model_path) and 
                os.path.exists(self.scaler_path) and 
                os.path.exists(self.encoder_path)):
                self.model = keras.models.load_model(self.model_path)
                self.scaler = joblib.load(self.scaler_path)
                self.label_encoder = joblib.load(self.encoder_path)
                self.is_trained = True
                self.logger.info("Model loaded successfully")
                return True
        except Exception as e:
            self.logger.warning(f"Could not load existing model: {str(e)}")
        return False
    def retrain_with_new_data(self, data_fetcher, technical_analyzer, max_stocks: int = 15):
        try:
            self.logger.info("Retraining model with new data...")
            return self.train_model(data_fetcher, technical_analyzer, max_stocks)
        except Exception as e:
            self.logger.error(f"Error retraining model: {str(e)}")
            raise
FastNeuralNetwork = TradingNeuralNetwork
