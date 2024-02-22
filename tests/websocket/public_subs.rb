# frozen_string_literal: true

require 'concurrent'
require 'test/unit'
require_relative '../../lib/cryptomarket/websocket/market_data_client'
require_relative '../key_loader'
require_relative '../checks'
require_relative 'time_flow'

class TestWSPublicSubs < Test::Unit::TestCase # rubocop:disable Metrics/ClassLength
  @@SECOND = 1
  @@MINUTE = 60
  @@HOUR = 3600
  def setup
    @wsclient = Cryptomarket::Websocket::MarketDataClient.new
    @wsclient.connect
  end

  def teardown
    @wsclient.close
    sleep(2)
  end

  def gen_result_callback(veredict_checker)
    ->(err, _result) { veredict_checker.append(err.nil?) }
  end

  def gen_check_result_hash_list_callback(check_fn, veredict_checker)
    proc { |notification, _notification_type|
      notification.each_value do |val_list|
        val_list.each do |val|
          good_val = check_fn.call(val)
          veredict_checker.append(good_val)
        end
      end
    }
  end

  def gen_check_result_hash_callback(check_fn, veredict_checker)
    proc { |notification, _notification_type|
      notification.each_value do |val|
        good_val = check_fn.call(val)
        veredict_checker.append(good_val)
      end
    }
  end

  def test_trades_subscription
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_trades(
      callback: gen_check_result_hash_list_callback(WSChecks.good_ws_public_trade, veredict_checker),
      symbols: %w[eoseth ethbtc],
      limit: 2,
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_candles_subscriptions
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_candles(
      period: 'M1',
      callback: gen_check_result_hash_list_callback(WSChecks.good_ws_public_candle, veredict_checker),
      symbols: %w[eoseth ethbtc],
      limit: 2,
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_mini_ticker
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_mini_ticker(
      speed: '1s',
      callback: gen_check_result_hash_callback(WSChecks.good_ws_mini_ticker, veredict_checker),
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_mini_ticker_in_batches
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_mini_ticker_in_batches(
      speed: '1s',
      callback: gen_check_result_hash_callback(WSChecks.good_ws_mini_ticker, veredict_checker),
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_ticker
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_ticker(
      speed: '1s',
      callback: gen_check_result_hash_callback(WSChecks.good_ticker, veredict_checker),
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_ticker_in_batches
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_ticker_in_batches(
      speed: '1s',
      callback: gen_check_result_hash_callback(WSChecks.good_ticker, veredict_checker),
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_full_order_book
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_full_order_book(
      callback: gen_check_result_hash_callback(WSChecks.good_orderbook, veredict_checker),
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_partial_order_book
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_partial_order_book(
      speed: '100ms',
      depth: 'D5',
      callback: gen_check_result_hash_callback(WSChecks.good_orderbook, veredict_checker),
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_partial_order_book_in_batches
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_partial_order_book_in_batches(
      speed: '100ms',
      depth: 'D5',
      callback: gen_check_result_hash_callback(WSChecks.good_orderbook, veredict_checker),
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_top_of_book
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_top_of_book(
      speed: '100ms',
      callback: gen_check_result_hash_callback(WSChecks.good_orderbook_top, veredict_checker),
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_top_of_book_in_batches
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_top_of_book_in_batches(
      speed: '100ms',
      callback: gen_check_result_hash_callback(WSChecks.good_orderbook_top, veredict_checker),
      symbols: %w[eoseth ethbtc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_price_rates
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_price_rates(
      speed: '1s',
      callback: gen_check_result_hash_callback(WSChecks.good_price_rate, veredict_checker),
      target_currency: 'ETH',
      currencies: %w[eos btc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end

  def test_subscribe_to_price_rates_in_batches
    veredict_checker = VeredictChecker.new
    @wsclient.subscribe_to_price_rates_in_batches(
      speed: '1s',
      callback: gen_check_result_hash_callback(WSChecks.good_price_rate, veredict_checker),
      target_currency: 'ETH',
      currencies: %w[eos btc],
      result_callback: gen_result_callback(veredict_checker)
    )
    sleep(10 * @@SECOND)
    assert(veredict_checker.good_veredict?)
  end
end
