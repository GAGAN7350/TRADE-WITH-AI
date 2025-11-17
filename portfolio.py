import json
import os
from datetime import datetime, timedelta
from typing import Dict, List, Optional
import logging
class FastPortfolioManager:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.data_file = 'data/fast_portfolios.json'
        self.cache_file = 'data/portfolio_cache.json'
        self.portfolios = {}
        self.cache = {}
        self.cache_duration = 300
        os.makedirs('data', exist_ok=True)
        self.load_portfolios()
        self.load_cache()
    def load_portfolios(self):
        try:
            if os.path.exists(self.data_file):
                with open(self.data_file, 'r') as f:
                    self.portfolios = json.load(f)
                self.logger.info(f"Loaded {len(self.portfolios)} portfolios")
            else:
                self.portfolios = {}
        except Exception as e:
            self.logger.error(f"Error loading portfolios: {e}")
            self.portfolios = {}
    def save_portfolios(self):
        try:
            with open(self.data_file, 'w') as f:
                json.dump(self.portfolios, f, indent=2, default=str)
        except Exception as e:
            self.logger.error(f"Error saving portfolios: {e}")
    def load_cache(self):
        try:
            if os.path.exists(self.cache_file):
                with open(self.cache_file, 'r') as f:
                    cache_data = json.load(f)
                    cache_time = datetime.fromisoformat(cache_data.get('timestamp', '2020-01-01'))
                    if datetime.now() - cache_time < timedelta(seconds=self.cache_duration):
                        self.cache = cache_data.get('data', {})
                    else:
                        self.cache = {}
        except Exception as e:
            self.logger.error(f"Error loading cache: {e}")
            self.cache = {}
    def save_cache(self):
        try:
            cache_data = {
                'timestamp': datetime.now().isoformat(),
                'data': self.cache
            }
            with open(self.cache_file, 'w') as f:
                json.dump(cache_data, f, indent=2, default=str)
        except Exception as e:
            self.logger.error(f"Error saving cache: {e}")
    def add_position(self, user_id: str, symbol: str, exchange: str, 
                    quantity: int, avg_cost: float) -> bool:
        try:
            if user_id not in self.portfolios:
                self.portfolios[user_id] = {
                    'positions': [],
                    'created_at': datetime.now().isoformat(),
                    'updated_at': datetime.now().isoformat()
                }
            for position in self.portfolios[user_id]['positions']:
                if position['symbol'] == symbol.upper() and position['exchange'] == exchange.upper():
                    old_quantity = position['quantity']
                    old_cost = position['avg_cost']
                    total_cost = (old_quantity * old_cost) + (quantity * avg_cost)
                    new_quantity = old_quantity + quantity
                    position['avg_cost'] = total_cost / new_quantity
                    position['quantity'] = new_quantity
                    position['updated_at'] = datetime.now().isoformat()
                    self.portfolios[user_id]['updated_at'] = datetime.now().isoformat()
                    self.save_portfolios()
                    return True
            new_position = {
                'symbol': symbol.upper(),
                'exchange': exchange.upper(),
                'quantity': quantity,
                'avg_cost': avg_cost,
                'added_at': datetime.now().isoformat(),
                'updated_at': datetime.now().isoformat()
            }
            self.portfolios[user_id]['positions'].append(new_position)
            self.portfolios[user_id]['updated_at'] = datetime.now().isoformat()
            self.save_portfolios()
            return True
        except Exception as e:
            self.logger.error(f"Error adding position: {e}")
            return False
    def remove_position(self, user_id: str, symbol: str, exchange: str, 
                       quantity: Optional[int] = None) -> bool:
        try:
            if user_id not in self.portfolios:
                return False
            positions = self.portfolios[user_id]['positions']
            for i, position in enumerate(positions):
                if position['symbol'] == symbol.upper() and position['exchange'] == exchange.upper():
                    if quantity is None:
                        positions.pop(i)
                    else:
                        if quantity >= position['quantity']:
                            positions.pop(i)
                        else:
                            position['quantity'] -= quantity
                            position['updated_at'] = datetime.now().isoformat()
                    self.portfolios[user_id]['updated_at'] = datetime.now().isoformat()
                    self.save_portfolios()
                    return True
            return False
        except Exception as e:
            self.logger.error(f"Error removing position: {e}")
            return False
    def get_portfolio_summary(self, user_id: str) -> Optional[Dict]:
        try:
            if user_id not in self.portfolios:
                return None
            portfolio = self.portfolios[user_id]
            positions = portfolio['positions']
            if not positions:
                return {
                    'user_id': user_id,
                    'positions': [],
                    'total_value': 0,
                    'total_cost': 0,
                    'total_pnl': 0,
                    'total_pnl_percent': 0,
                    'position_count': 0,
                    'last_updated': portfolio.get('updated_at', ''),
                    'performance': 'No positions'
                }
            total_value = 0
            total_cost = 0
            processed_positions = []
            for position in positions:
                mock_current_price = position['avg_cost'] * (0.95 + (hash(position['symbol']) % 100) / 1000)
                market_value = mock_current_price * position['quantity']
                cost_basis = position['avg_cost'] * position['quantity']
                unrealized_pnl = market_value - cost_basis
                processed_position = {
                    'symbol': position['symbol'],
                    'exchange': position['exchange'],
                    'quantity': position['quantity'],
                    'avg_cost': position['avg_cost'],
                    'current_price': mock_current_price,
                    'market_value': market_value,
                    'cost_basis': cost_basis,
                    'unrealized_pnl': unrealized_pnl,
                    'unrealized_pnl_percent': (unrealized_pnl / cost_basis) * 100 if cost_basis > 0 else 0,
                    'day_change': mock_current_price * 0.02,
                    'day_change_percent': 2.0,
                    'prediction': 'HOLD',
                    'confidence': 0.65,
                    'last_updated': datetime.now().isoformat()
                }
                processed_positions.append(processed_position)
                total_value += market_value
                total_cost += cost_basis
            total_pnl = total_value - total_cost
            total_pnl_percent = (total_pnl / total_cost) * 100 if total_cost > 0 else 0
            return {
                'user_id': user_id,
                'positions': processed_positions,
                'total_value': total_value,
                'total_cost': total_cost,
                'total_pnl': total_pnl,
                'total_pnl_percent': total_pnl_percent,
                'position_count': len(positions),
                'last_updated': datetime.now().isoformat(),
                'performance': 'Good' if total_pnl_percent > 0 else 'Poor' if total_pnl_percent < -5 else 'Neutral'
            }
        except Exception as e:
            self.logger.error(f"Error getting portfolio summary: {e}")
            return None
    def get_all_portfolios(self) -> List[str]:
        return list(self.portfolios.keys())
    def create_sample_portfolio(self, user_id: str = "demo") -> bool:
        try:
            sample_positions = [
                {"symbol": "AAPL", "exchange": "NASDAQ", "quantity": 100, "avg_cost": 150.00},
                {"symbol": "MSFT", "exchange": "NASDAQ", "quantity": 50, "avg_cost": 280.00},
                {"symbol": "GOOGL", "exchange": "NASDAQ", "quantity": 25, "avg_cost": 2500.00},
                {"symbol": "TSLA", "exchange": "NASDAQ", "quantity": 30, "avg_cost": 200.00},
                {"symbol": "RELIANCE", "exchange": "NSE", "quantity": 200, "avg_cost": 2400.00}
            ]
            for pos in sample_positions:
                self.add_position(user_id, pos["symbol"], pos["exchange"], 
                                pos["quantity"], pos["avg_cost"])
            return True
        except Exception as e:
            self.logger.error(f"Error creating sample portfolio: {e}")
            return False
    def get_portfolio_stats(self) -> Dict:
        return {
            'total_portfolios': len(self.portfolios),
            'total_positions': sum(len(p['positions']) for p in self.portfolios.values()),
            'last_updated': datetime.now().isoformat()
        }
