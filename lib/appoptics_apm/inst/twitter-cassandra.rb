# Copyright (c) 2016 SolarWinds, LLC.
# All rights reserved.

module AppOpticsAPM
  module Inst
    module Cassandra
      def extract_trace_details(op, column_family, keys, args, options = {})
        report_kvs = {}

        begin
          report_kvs[:Op] = op.to_s
          report_kvs[:Cf] = column_family.to_s if column_family
          report_kvs[:Key] = keys.inspect if keys

          # Open issue - how to handle multiple Cassandra servers
          report_kvs[:RemoteHost], report_kvs[:RemotePort] = @servers.first.split(':')

          report_kvs[:Backtrace] = AppOpticsAPM::API.backtrace if AppOpticsAPM::Config[:cassandra][:collect_backtraces]

          if options.empty? && args.is_a?(Array)
            options = args.last if args.last.is_a?(Hash)
          end

          unless options.empty?
            [:start_key, :finish_key, :key_count, :batch_size, :columns, :count, :start,
             :stop, :finish, :finished, :reversed, :consistency, :ttl].each do |k|
              report_kvs[k.to_s.capitalize] = options[k] if options.key?(k)
            end

            if op == :get_indexed_slices
              index_clause = columns_and_options[:index_clause] || {}
              unless index_clause.empty?
                [:column_name, :value, :comparison].each do |k|
                  report_kvs[k.to_s.capitalize] = index_clause[k] if index_clause.key?(k)
                end
              end
            end
          end
        rescue => e
          AppOpticsAPM.logger.debug "[appoptics_apm/debug] #{__method__}:#{File.basename(__FILE__)}:#{__LINE__}: #{e.message}" if AppOpticsAPM::Config[:verbose]
        end

        report_kvs
      end

      def insert_with_appoptics(column_family, key, hash, options = {})
        return insert_without_appoptics(column_family, key, hash, options = {}) unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:insert, column_family, key, hash, options)

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          insert_without_appoptics(column_family, key, hash, options = {})
        end
      end

      def remove_with_appoptics(column_family, key, *columns_and_options)
        args = [column_family, key] + columns_and_options

        return send :remove_without_appoptics, *args unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:remove, column_family, key, columns_and_options)

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          send :remove_without_appoptics, *args
        end
      end

      def count_columns_with_appoptics(column_family, key, *columns_and_options)
        args = [column_family, key] + columns_and_options

        return send :count_columns_without_appoptics, *args unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:count_columns, column_family, key, columns_and_options)

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          send :count_columns_without_appoptics, *args
        end
      end

      def get_columns_with_appoptics(column_family, key, *columns_and_options)
        args = [column_family, key] + columns_and_options

        if AppOpticsAPM.tracing? && !AppOpticsAPM.tracing_layer_op?(:multi_get_columns)
          report_kvs = extract_trace_details(:get_columns, column_family, key, columns_and_options)

          AppOpticsAPM::API.trace(:cassandra, report_kvs) do
            send :get_columns_without_appoptics, *args
          end
        else
          send :get_columns_without_appoptics, *args
        end
      end

      def multi_get_columns_with_appoptics(column_family, key, *columns_and_options)
        args = [column_family, key] + columns_and_options

        return send :multi_get_columns_without_appoptics, *args unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:multi_get_columns, column_family, key, columns_and_options)

        AppOpticsAPM::API.trace(:cassandra, report_kvs, :multi_get_columns) do
          send :multi_get_columns_without_appoptics, *args
        end
      end

      def get_with_appoptics(column_family, key, *columns_and_options)
        args = [column_family, key] + columns_and_options

        return send :get_without_appoptics, *args unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:get, column_family, key, columns_and_options)

        AppOpticsAPM::API.trace(:cassandra, report_kvs, :get) do
          send :get_without_appoptics, *args
        end
      end

      def multi_get_with_appoptics(column_family, key, *columns_and_options)
        args = [column_family, key] + columns_and_options

        if AppOpticsAPM.tracing? && !AppOpticsAPM.tracing_layer_op?(:get)
          report_kvs = extract_trace_details(:multi_get, column_family, key, columns_and_options)

          AppOpticsAPM::API.trace(:cassandra, report_kvs) do
            send :multi_get_without_appoptics, *args
          end
        else
          send :multi_get_without_appoptics, *args
        end
      end

      def exists_with_appoptics?(column_family, key, *columns_and_options)
        args = [column_family, key] + columns_and_options

        return send :exists_without_appoptics?, *args unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:exists?, column_family, key, columns_and_options)

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          send :exists_without_appoptics?, *args
        end
      end

      def get_range_single_with_appoptics(column_family, options = {})
        if AppOpticsAPM.tracing? && !AppOpticsAPM.tracing_layer_op?(:get_range_batch)
          report_kvs = extract_trace_details(:get_range_single, column_family, nil, nil)

          AppOpticsAPM::API.trace(:cassandra, report_kvs) do
            get_range_single_without_appoptics(column_family, options)
          end
        else
          get_range_single_without_appoptics(column_family, options)
        end
      end

      def get_range_batch_with_appoptics(column_family, options = {})
        return get_range_batch_without_appoptics(column_family, options) unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:get_range_batch, column_family, nil, nil)

        AppOpticsAPM::API.trace(:cassandra, report_kvs, :get_range_batch) do
          get_range_batch_without_appoptics(column_family, options)
        end
      end

      def get_indexed_slices_with_appoptics(column_family, index_clause, *columns_and_options)
        args = [column_family, index_clause] + columns_and_options

        return send :get_indexed_slices_without_appoptics, *args unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:get_indexed_slices, column_family, nil, columns_and_options)

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          send :get_indexed_slices_without_appoptics, *args
        end
      end

      def create_index_with_appoptics(keyspace, column_family, column_name, validation_class)
        unless AppOpticsAPM.tracing?
          return create_index_without_appoptics(keyspace, column_family, column_name, validation_class)
        end

        report_kvs = extract_trace_details(:create_index, column_family, nil, nil)
        begin
          report_kvs[:Keyspace] = keyspace.to_s
          report_kvs[:Column_name] = column_name.to_s
          report_kvs[:Validation_class] = validation_class.to_s
        rescue => e
          AppOpticsAPM.logger.debug "[appoptics_apm/debug] #{__method__}:#{File.basename(__FILE__)}:#{__LINE__}: #{e.message}" if AppOpticsAPM::Config[:verbose]
        end

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          create_index_without_appoptics(keyspace, column_family, column_name, validation_class)
        end
      end

      def drop_index_with_appoptics(keyspace, column_family, column_name)
        return drop_index_without_appoptics(keyspace, column_family, column_name) unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:drop_index, column_family, nil, nil)
        begin
          report_kvs[:Keyspace] = keyspace.to_s
          report_kvs[:Column_name] = column_name.to_s
        rescue => e
          AppOpticsAPM.logger.debug "[appoptics_apm/debug] #{__method__}:#{File.basename(__FILE__)}:#{__LINE__}: #{e.message}" if AppOpticsAPM::Config[:verbose]
        end

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          drop_index_without_appoptics(keyspace, column_family, column_name)
        end
      end

      def add_column_family_with_appoptics(cf_def)
        return add_column_family_without_appoptics(cf_def) unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:add_column_family, nil, nil, nil)
        begin
          report_kvs[:Cf] = cf_def[:name] if cf_def.is_a?(Hash) && cf_def.key?(:name)
        rescue => e
          AppOpticsAPM.logger.debug "[appoptics_apm/debug] #{__method__}:#{File.basename(__FILE__)}:#{__LINE__}: #{e.message}" if AppOpticsAPM::Config[:verbose]
        end

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          add_column_family_without_appoptics(cf_def)
        end
      end

      def drop_column_family_with_appoptics(column_family)
        return drop_column_family_without_appoptics(column_family) unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:drop_column_family, column_family, nil, nil)

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          drop_column_family_without_appoptics(column_family)
        end
      end

      def add_keyspace_with_appoptics(ks_def)
        return add_keyspace_without_appoptics(ks_def) unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:add_keyspace, nil, nil, nil)
        report_kvs[:Name] = ks_def.name rescue ''

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          add_keyspace_without_appoptics(ks_def)
        end
      end

      def drop_keyspace_with_appoptics(keyspace)
        return drop_keyspace_without_appoptics(keyspace) unless AppOpticsAPM.tracing?

        report_kvs = extract_trace_details(:drop_keyspace, nil, nil, nil)
        report_kvs[:Name] = keyspace.to_s rescue ''

        AppOpticsAPM::API.trace(:cassandra, report_kvs) do
          drop_keyspace_without_appoptics(keyspace)
        end
      end
    end
  end
end

# There are two main Cassandra clients for Ruby.  This one from Twitter
# and the other from datastax.  This one defined ::Cassandra as a class
# and datastax defines it as a module.  We use this to detect
# and differentiate between the client in use.

if defined?(::Cassandra) && ::Cassandra.is_a?(Class) && AppOpticsAPM::Config[:cassandra][:enabled]
  AppOpticsAPM.logger.info '[appoptics_apm/loading] Instrumenting cassandra' if AppOpticsAPM::Config[:verbose]

  class ::Cassandra
    include AppOpticsAPM::Inst::Cassandra

    [:insert, :remove, :count_columns, :get_columns, :multi_get_columns, :get,
     :multi_get, :get_range_single, :get_range_batch, :get_indexed_slices,
     :create_index, :drop_index, :add_column_family, :drop_column_family,
     :add_keyspace, :drop_keyspace].each do |m|
      if method_defined?(m)
        class_eval "alias #{m}_without_appoptics #{m}"
        class_eval "alias #{m} #{m}_with_appoptics"
      else AppOpticsAPM.logger.warn "[appoptics_apm/loading] Couldn't properly instrument Cassandra (#{m}).  Partial traces may occur."
      end
    end

    # Special case handler for question mark methods
    if method_defined?(:exists?)
      alias exists_without_appoptics? exists?
      alias exists? exists_with_appoptics?
    else AppOpticsAPM.logger.warn '[appoptics_apm/loading] Couldn\'t properly instrument Cassandra (exists?).  Partial traces may occur.'
    end
  end # class Cassandra
end


