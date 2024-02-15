require "securerandom"
require_relative "wsClientBase"

module Cryptomarket
    module Websocket
        class AuthClient < ClientBase
            # Creates a new client
            def initialize(url:, api_key:, api_secret:, subscription_keys:, window:nil)
                @api_key = api_key
                @api_secret = api_secret
                @window = window
                super url:url, subscription_keys:subscription_keys
                @authed = false
            end

            def connected?
                return (super.connected? and @authed)
            end

            # connects via websocket to the exchange and authenticates it.
            def connect
                super
                authenticate(Proc.new {|err, result|
                    if not err.nil?
                        raise err
                    end
                    @authed = true
                })
                # try one minute
                current_try = 0
                max_tries = 60
                while not @authed and current_try < max_tries
                  current_try += 1
                  sleep(1)
                end
            end

            # Authenticates the websocket
            #
            # https://api.exchange.cryptomkt.com/#socket-session-authentication
            #
            # +Proc+ +callback+:: Optional. A +Proc+ to call with the result data. It takes two arguments, err and result. err is None for successful calls, result is None for calls with error: Proc.new {|err, result| ...}

            def authenticate(callback=nil)
                timestamp = Time.now.to_i * 1000
                digest = OpenSSL::Digest.new 'sha256'
                message = timestamp.to_s
                if not @window.nil?
                  message += @window.to_s
                end
                signature = OpenSSL::HMAC.hexdigest digest, @api_secret, timestamp.to_s
                params = {
                    'type'=> 'HS256',
                    'api_key'=> @api_key,
                    'timestamp'=> timestamp,
                    'signature'=> signature
                }
                if not @window.nil?
                  params['window'] = @window
                end
                return send_by_id('login', callback, params)
            end
        end
    end
end