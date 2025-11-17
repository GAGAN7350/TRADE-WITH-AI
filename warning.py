import logging
import random
from typing import Dict, List, Optional, Callable
from dataclasses import dataclass
from datetime import datetime, timedelta
from enum import Enum
class AlertLevel(Enum):
    INFO = "INFO"
    WARNING = "WARNING"
    CRITICAL = "CRITICAL"
@dataclass
class Alert:
    symbol: str
    exchange: str
    level: AlertLevel
    message: str
    current_price: float
    price_change_percent: float
    volume_ratio: float
    timestamp: datetime
class WarningSystem:
    def __init__(self, data_fetcher=None):
        self.logger = logging.getLogger(__name__)
        self.data_fetcher = data_fetcher
        self.is_enabled = True
        self.is_running = False
        self.alert_callbacks = []
        self.recent_alerts = []
        self.logger.info("Mock Warning System initialized")
    def add_alert_callback(self, callback: Callable[[Alert], None]):
        self.alert_callbacks.append(callback)
        self.logger.info("Alert callback added")
    def enable(self):
        self.is_enabled = True
        self.logger.info("Warning system enabled")
    def disable(self):
        self.is_enabled = False
        self.logger.info("Warning system disabled")
    def start_monitoring(self):
        self.is_running = True
        self.logger.info("Mock monitoring started")
        self._generate_mock_alert()
    def stop_monitoring(self):
        self.is_running = False
        self.logger.info("Monitoring stopped")
    def _generate_mock_alert(self):
        try:
            stocks = [
                ('AAPL', 'NASDAQ'),
                ('TSLA', 'NASDAQ'),
                ('RELIANCE', 'NSE'),
                ('TCS', 'NSE'),
                ('0700', 'HKEX')
            ]
            symbol, exchange = random.choice(stocks)
            price = random.uniform(50, 300)
            price_change = random.uniform(-15, 15)
            volume_ratio = random.uniform(0.5, 5.0)
            if abs(price_change) > 10 or volume_ratio > 3:
                level = AlertLevel.CRITICAL
            elif abs(price_change) > 5 or volume_ratio > 2:
                level = AlertLevel.WARNING
            else:
                level = AlertLevel.INFO
            if price_change > 0:
                message = f"Strong upward movement detected (+{price_change:.1f}%)"
            elif price_change < -5:
                message = f"Significant price drop detected ({price_change:.1f}%)"
            else:
                message = "Price movement within normal range"
            if volume_ratio > 2:
                message += f" with high volume ({volume_ratio:.1f}x average)"
            alert = Alert(
                symbol=symbol,
                exchange=exchange,
                level=level,
                message=message,
                current_price=round(price, 2),
                price_change_percent=round(price_change, 2),
                volume_ratio=round(volume_ratio, 2),
                timestamp=datetime.now()
            )
            self.recent_alerts.append(alert)
            if len(self.recent_alerts) > 50:
                self.recent_alerts.pop(0)
            if self.is_enabled:
                for callback in self.alert_callbacks:
                    try:
                        callback(alert)
                    except Exception as e:
                        self.logger.error(f"Error in alert callback: {e}")
        except Exception as e:
            self.logger.error(f"Error generating mock alert: {e}")
    def get_recent_alerts(self, hours: int = 24) -> List[Alert]:
        cutoff_time = datetime.now() - timedelta(hours=hours)
        return [alert for alert in self.recent_alerts if alert.timestamp >= cutoff_time]
    def get_system_status(self) -> Dict:
        return {
            'enabled': self.is_enabled,
            'monitoring': self.is_running,
            'total_alerts_24h': len(self.get_recent_alerts(24)),
            'critical_alerts_24h': len([a for a in self.get_recent_alerts(24) if a.level == AlertLevel.CRITICAL]),
            'warning_alerts_24h': len([a for a in self.get_recent_alerts(24) if a.level == AlertLevel.WARNING]),
            'last_alert_time': self.recent_alerts[-1].timestamp.isoformat() if self.recent_alerts else None,
            'callback_count': len(self.alert_callbacks)
        }
    def check_portfolio_alerts(self, user_id: str) -> List[Alert]:
        alerts = []
        try:
            from fast_portfolio_manager import FastPortfolioManager
            portfolio_manager = FastPortfolioManager()
            positions = portfolio_manager.get_user_positions(user_id)
            for position in positions[:2]:
                if random.random() < 0.3:
                    price_change = random.uniform(-10, 10)
                    volume_ratio = random.uniform(0.5, 3.0)
                    level = AlertLevel.WARNING if abs(price_change) > 5 else AlertLevel.INFO
                    alert = Alert(
                        symbol=position['symbol'],
                        exchange=position['exchange'],
                        level=level,
                        message=f"Position alert: {price_change:+.1f}% change",
                        current_price=position.get('current_price', 100.0),
                        price_change_percent=price_change,
                        volume_ratio=volume_ratio,
                        timestamp=datetime.now()
                    )
                    alerts.append(alert)
        except Exception as e:
            self.logger.error(f"Error checking portfolio alerts for {user_id}: {e}")
        return alerts
    def set_price_alert(self, symbol: str, exchange: str, target_price: float, condition: str = 'above') -> bool:
        self.logger.info(f"Mock price alert set: {symbol} ({exchange}) {condition} ${target_price}")
        return True
    def remove_price_alert(self, symbol: str, exchange: str) -> bool:
        self.logger.info(f"Mock price alert removed: {symbol} ({exchange})")
        return True
    def get_active_alerts(self) -> List[Dict]:
        return [
            {
                'symbol': 'AAPL',
                'exchange': 'NASDAQ',
                'type': 'price_above',
                'target': 150.0,
                'created': datetime.now() - timedelta(days=1)
            },
            {
                'symbol': 'TSLA',
                'exchange': 'NASDAQ',
                'type': 'price_below',
                'target': 200.0,
                'created': datetime.now() - timedelta(hours=6)
            }
        ]
