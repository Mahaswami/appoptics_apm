# Copyright (c) 2016 SolarWinds, LLC.
# All rights reserved.

module AppOpticsAPM
  module Inst
    module Memcached
      include AppOpticsAPM::API::Memcache

      def self.included(cls)
        AppOpticsAPM.logger.info '[appoptics_apm/loading] Instrumenting memcached' if AppOpticsAPM::Config[:verbose]

        cls.class_eval do
          MEMCACHE_OPS.reject { |m| !method_defined?(m) }.each do |m|
            define_method("#{m}_with_appoptics") do |*args|
              opts = { :KVOp => m }

              if args.length && !args[0].is_a?(Array)
                opts[:KVKey] = args[0].to_s
                rhost = remote_host(args[0].to_s)
                opts[:RemoteHost] = rhost if rhost
              end

              AppOpticsAPM::API.trace(:memcache, opts) do
                result = send("#{m}_without_appoptics", *args)

                info_kvs = {}
                info_kvs[:KVHit] = memcache_hit?(result) if m == :get && args.length && args[0].class == String
                info_kvs[:Backtrace] = AppOpticsAPM::API.backtrace if AppOpticsAPM::Config[:memcached][:collect_backtraces]

                AppOpticsAPM::API.log(:memcache, :info, info_kvs) unless info_kvs.empty?
                result
              end
            end

            class_eval "alias #{m}_without_appoptics #{m}"
            class_eval "alias #{m} #{m}_with_appoptics"
          end
        end
      end

    end # module Memcached

    module MemcachedRails
      def self.included(cls)
        cls.class_eval do
          if ::Memcached::Rails.method_defined? :get_multi
            alias get_multi_without_appoptics get_multi
            alias get_multi get_multi_with_appoptics
          elsif AppOpticsAPM::Config[:verbose]
            AppOpticsAPM.logger.warn '[appoptics_apm/loading] Couldn\'t properly instrument Memcached.  Partial traces may occur.'
          end
        end
      end

      def get_multi_with_appoptics(keys, raw = false)
        if AppOpticsAPM.tracing?
          layer_kvs = {}
          layer_kvs[:KVOp] = :get_multi

          AppOpticsAPM::API.trace(:memcache, layer_kvs || {}, :get_multi) do
            begin
              info_kvs = {}
              info_kvs[:KVKeyCount] = keys.flatten.length

              values = get_multi_without_appoptics(keys, raw)

              info_kvs[:KVHitCount] = values.length
              info_kvs[:Backtrace] = AppOpticsAPM::API.backtrace if AppOpticsAPM::Config[:memcached][:collect_backtraces]

              AppOpticsAPM::API.log(:memcache, :info, info_kvs)
            rescue
              values = get_multi_without_appoptics(keys, raw)
            end
            values
          end
        else
          get_multi_without_appoptics(keys, raw)
        end
      end
    end # module MemcachedRails
  end # module Inst
end # module AppOpticsAPM

if defined?(::Memcached) && AppOpticsAPM::Config[:memcached][:enabled]
  ::Memcached.class_eval do
    include AppOpticsAPM::Inst::Memcached
  end

  if defined?(::Memcached::Rails)
    ::Memcached::Rails.class_eval do
      include AppOpticsAPM::Inst::MemcachedRails
    end
  end
end
