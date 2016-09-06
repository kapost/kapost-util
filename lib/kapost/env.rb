# frozen_string_literal: true

module Kapost
  # Kapost::Env is a simple wrapper around Ruby's `ENV` hash. It only
  # supports the `.fetch` method, which looks for a key in ENV, falling back to
  # a default if one is provided. See http://ruby-doc.org/core-2.2.0/Hash.html#method-i-fetch
  # Additionally, it provides a `.fetch!` which will do the same, however it
  # will not fall back to the defailt if Rails.env is "production". This is
  # useful to provide a safe default for use in dev and testing, without
  # needing to specifiy it in a .env file, however it will still blow up in
  # production.
  class Env

    # Exception raised when key is missing from ENV, and no default is given
    class KeyError < ::KeyError
      def initialize(key)
        @key = key
      end

      def message
        "Enviroment Variable #{@key} was missing, and no default was provided."
      end
    end

    # Exception raised in production if key is not present in ENV
    class ProductionKeyError < KeyError
      def message
        "Environment Variable #{@key} is required."
      end
    end

    def initialize(env = ENV, app_env: nil)
      @env = env
      @app_env = app_env
    end

    def fetch(*args, &block)
      @env.fetch(*args, &block)
    rescue ::KeyError
      raise KeyError, args.first
    end

    def fetch!(*args, &block)
      if production?
        begin
          @env.fetch(args.first)
        rescue ::KeyError
          raise ProductionKeyError, args.first
        end
      else
        fetch(*args, &block)
      end
    end

    private

    def production?
      app_env == "production"
    end

    def app_env
      @app_env ||= if defined?(Rails)
                     Rails.env
                   else
                     @env["RAILS_ENV"] || @env["RACK_ENV"] || "development"
                   end
    end
  end

  # Make a default-configured Env available as the Kapost::ENV constant
  ENV = Env.new
end
