# CryptoMarket-Ruby
[main page](https://www.cryptomkt.com/)


[sign up in CryptoMarket](https://www.cryptomkt.com/account/register).

# Installation
To install Cryptomarket use gem
```
gem install cryptomarket-sdk
```
# Documentation
This sdk makes use of the [api version 2](https://api.exchange.cryptomkt.com/v2) of cryptomarket

# Quick Start

## rest client
```ruby
require "cryptomarket"

# instance a client
api_key='AB32B3201'
api_secret='21b12401'
client = Cryptomarket::Client.new apiKey:apiKey, apiSecret:apiSecret

# get currencies
currencies = client.get_currencies

# get order books
order_book = client.get_orderbooks symbols:['EOSETH']

# get your account balances
account_balance = client.get_wallet_balances

# get your trading balances
trading_balance = client.get_spot_trading_balances

# move balance from account bank to account trading
result = @client.transfer_between_wallet_and_exchange(
  currency: "CRO",
  amount: "0.1",
  source:"wallet",
  destination:"spot",
)

# get your active orders
orders = client.get_all_active_spot_orders('EOSETH')

# create a new order
order = client.create_spot_order(
  symbol:'EOSETH',
  side:'buy',
  quantity:'10',
  order_type:args.ORDER_TYPE.MARKET
)
```

## websocket client
*work in progress*

## exception handling
```ruby
require "cryptomarket-sdk"

client = Cryptomarket::Client.new apiKey:apiKey, apiSecret:apiSecret

# catch a wrong argument
begin
    order = client.create_spot_order(
        symbol='EOSETH',
        side='selllll', # wrong
        quantity='3'
    )
rescue Cryptomarket::SDKException => e:
    puts e
end

# catch a failed transaction
begin
    order = client.create_spot_order(
        symbol='eosehtt',  # non existant symbol
        side='sell',
        quantity='10',
    )
rescue Cryptomarket::SDKException => e:
    puts e
end

wsclient = Cryptomarket::Websocket::TradingClient.new apiKey:apiKey, apiSecret:apiSecret

# websocket errors are passed as the first argument to the callback
my_callback = Proc.new {|err, data|
    if not err.nil?
        puts err # deal with error
        return
    end
    puts data
}

wsclient.get_spot_trading_balances(my_callback)

# catch authorization error
# to catch an authorization error on client connection, a on_error function must be defined on the client
wsclient = TradingClient(apiKey, apiSecret)
wsclient.onerror = Proc.new {|error| puts "error", error}
wsclient.connect


```
# Checkout our other SDKs

[node sdk](https://github.com/cryptomkt/cryptomkt-node)

[java sdk](https://github.com/cryptomkt/cryptomkt-java)

[go sdk](https://github.com/cryptomkt/cryptomkt-go)
yptomkt/cryptomkt-python)

[python sdk](https://github.com/cr