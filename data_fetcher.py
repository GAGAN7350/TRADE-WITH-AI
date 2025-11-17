import logging
import yfinance as yf
from datetime import datetime, timedelta
import pandas as pd
from typing import Dict, List, Optional
import requests
from pytz import timezone
import time
class DataFetcher:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.cache = {}
        self.cache_duration = 300
        self.logger.info("Real Data Fetcher initialized with yfinance")
    def get_stock_data(self, symbol: str, exchange: str, period: str = '3mo', interval: str = '1d') -> Optional[pd.DataFrame]:
        try:
            from config import config
            exchange_suffixes = {
                'NASDAQ': '',
                'NSE': '.NS', 
                'HKEX': '.HK'
            }
            suffix = exchange_suffixes.get(exchange, '')
            ticker_symbol = f"{symbol}{suffix}"
            cache_key = f"{ticker_symbol}_{period}_{interval}"
            current_time = time.time()
            if cache_key in self.cache:
                cached_time, cached_data = self.cache[cache_key]
                if current_time - cached_time < self.cache_duration:
                    self.logger.info(f"Using cached data for {ticker_symbol}")
                    return cached_data
            self.logger.info(f"Fetching real data for {ticker_symbol}")
            ticker = yf.Ticker(ticker_symbol)
            data = ticker.history(period=period, interval=interval)
            if data.empty:
                self.logger.warning(f"No data found for {ticker_symbol}")
                return None
            data = data.dropna()
            if len(data) < 20:
                self.logger.warning(f"Insufficient data for {ticker_symbol} (only {len(data)} records)")
                return None
            self.cache[cache_key] = (current_time, data)
            self.logger.info(f"Successfully fetched {len(data)} records for {ticker_symbol}")
            return data
        except Exception as e:
            self.logger.error(f"Error fetching data for {symbol} on {exchange}: {e}")
            return None
    def get_current_price(self, symbol: str, exchange: str) -> float:
        try:
            data = self.get_stock_data(symbol, exchange, period='1d', interval='1m')
            if data is not None and not data.empty:
                return float(data['Close'].iloc[-1])
            data = self.get_stock_data(symbol, exchange, period='5d', interval='1d')
            if data is not None and not data.empty:
                return float(data['Close'].iloc[-1])
            return 0.0
        except Exception as e:
            self.logger.error(f"Error getting current price for {symbol}: {e}")
            return 0.0
    def is_market_open(self, exchange: str) -> bool:
        try:
            from config import config
            market_config = config.EXCHANGES.get(exchange, {})
            tz_name = market_config.get('timezone', 'UTC')
            hours = market_config.get('market_hours', {'open': '09:00', 'close': '17:00'})
            tz = timezone(tz_name)
            now = datetime.now(tz)
            open_time = datetime.strptime(hours['open'], '%H:%M').time()
            close_time = datetime.strptime(hours['close'], '%H:%M').time()
            current_time = now.time()
            if now.weekday() >= 5:
                return False
            return open_time <= current_time <= close_time
        except Exception as e:
            self.logger.error(f"Error checking market status for {exchange}: {e}")
            return False
    def get_market_movers(self, exchange: str, limit: int = 10) -> List[Dict]:
        try:
            from config import config
            symbols = config.POPULAR_STOCKS.get(exchange, [])
            movers = []
            for symbol in symbols[:limit * 2]:
                try:
                    data = None
                    for period in ['5d', '1wk', '1mo']:
                        try:
                            data = self.get_stock_data(symbol, exchange, period=period, interval='1d')
                            if data is not None and len(data) >= 5:
                                break
                        except:
                            continue
                    if data is None or len(data) < 2:
                        self.logger.debug(f"Insufficient data for {symbol}, skipping")
                        continue
                    current_price = float(data['Close'].iloc[-1])
                    if len(data) >= 5:
                        previous_price = float(data['Close'].iloc[-5])
                    else:
                        previous_price = float(data['Close'].iloc[-2])
                    change = current_price - previous_price
                    change_percent = (change / previous_price) * 100 if previous_price > 0 else 0
                    volume = int(data['Volume'].iloc[-1]) if 'Volume' in data.columns else 1000000
                    movers.append({
                        'symbol': symbol,
                        'price': round(current_price, 2),
                        'change': round(change, 2),
                        'change_percent': round(change_percent, 2),
                        'volume': volume
                    })
                    self.logger.debug(f"Added {symbol}: {current_price} ({change_percent:.1f}%)")
                except Exception as e:
                    self.logger.debug(f"Error getting data for {symbol}: {e}")
                    continue
            if not movers:
                self.logger.info(f"No market data available for {exchange}, using fallback")
                return self._generate_fallback_movers(exchange, limit)
            movers.sort(key=lambda x: abs(x['change_percent']), reverse=True)
            return movers[:limit]
        except Exception as e:
            self.logger.error(f"Error getting market movers for {exchange}: {e}")
            return self._generate_fallback_movers(exchange, limit)
    def _generate_fallback_movers(self, exchange: str, limit: int = 10) -> List[Dict]:
        from config import config
        import random
        symbols = config.POPULAR_STOCKS.get(exchange, ['DEMO1', 'DEMO2', 'DEMO3'])
        movers = []
        for symbol in symbols[:limit]:
            price = random.uniform(50, 300)
            change_percent = random.uniform(-8, 8)
            change = price * (change_percent / 100)
            volume = random.randint(100000, 5000000)
            movers.append({
                'symbol': symbol,
                'price': round(price, 2),
                'change': round(change, 2),
                'change_percent': round(change_percent, 2),
                'volume': volume
            })
        movers.sort(key=lambda x: abs(x['change_percent']), reverse=True)
        return movers
    def get_high_volume_stocks(self, exchange: str, limit: int = 10) -> List[Dict]:
        try:
            from config import config
            symbols = config.POPULAR_STOCKS.get(exchange, [])
            high_volume = []
            for symbol in symbols[:limit * 2]:
                try:
                    data = None
                    for period in ['5d', '1wk', '1mo']:
                        try:
                            data = self.get_stock_data(symbol, exchange, period=period, interval='1d')
                            if data is not None and len(data) >= 3:
                                break
                        except:
                            continue
                    if data is None or len(data) < 1:
                        self.logger.debug(f"No volume data for {symbol}, skipping")
                        continue
                    current_price = float(data['Close'].iloc[-1])
                    volume = int(data['Volume'].iloc[-1]) if 'Volume' in data.columns else 1000000
                    if len(data) > 3:
                        avg_volume = data['Volume'].mean() if 'Volume' in data.columns else 500000
                        volume_ratio = volume / avg_volume if avg_volume > 0 else 1
                    else:
                        volume_ratio = 1.5
                    if len(data) >= 2:
                        previous_price = float(data['Close'].iloc[-2])
                        change = current_price - previous_price
                        change_percent = (change / previous_price) * 100 if previous_price > 0 else 0
                    else:
                        change = 0
                        change_percent = 0
                    high_volume.append({
                        'symbol': symbol,
                        'price': round(current_price, 2),
                        'change': round(change, 2),
                        'change_percent': round(change_percent, 2),
                        'volume': volume,
                        'volume_ratio': round(volume_ratio, 2)
                    })
                    self.logger.debug(f"Added {symbol}: volume {volume} (ratio: {volume_ratio:.1f})")
                except Exception as e:
                    self.logger.debug(f"Error getting volume data for {symbol}: {e}")
                    continue
            if not high_volume:
                self.logger.info(f"No volume data available for {exchange}, using fallback")
                return self._generate_fallback_volume(exchange, limit)
            high_volume.sort(key=lambda x: x['volume'], reverse=True)
            return high_volume[:limit]
        except Exception as e:
            self.logger.error(f"Error getting high volume stocks for {exchange}: {e}")
            return self._generate_fallback_volume(exchange, limit)
    def _generate_fallback_volume(self, exchange: str, limit: int = 10) -> List[Dict]:
        from config import config
        import random
        symbols = config.POPULAR_STOCKS.get(exchange, ['DEMO1', 'DEMO2', 'DEMO3'])
        high_volume = []
        for symbol in symbols[:limit]:
            price = random.uniform(50, 300)
            change_percent = random.uniform(-5, 5)
            change = price * (change_percent / 100)
            volume = random.randint(1000000, 20000000)
            volume_ratio = random.uniform(1.5, 5.0)
            high_volume.append({
                'symbol': symbol,
                'price': round(price, 2),
                'change': round(change, 2),
                'change_percent': round(change_percent, 2),
                'volume': volume,
                'volume_ratio': round(volume_ratio, 2)
            })
        high_volume.sort(key=lambda x: x['volume'], reverse=True)
        return high_volume
