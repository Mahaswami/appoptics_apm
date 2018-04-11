# Copyright (c) 2016 SolarWinds, LLC.
# All rights reserved.

module AppOpticsAPM
  module Inst
    #
    # ActionController
    #
    # This modules contains the instrumentation code specific
    # to Rails v5.
    #
    module ActionControllerAPI
      include ::AppOpticsAPM::Inst::RailsBase

      def process_action(method_name, *args)
        kvs = {
            :Controller   => self.class.name,
            :Action       => self.action_name
        }
        request.env['appoptics_apm.controller'] = kvs[:Controller]
        request.env['appoptics_apm.action'] = kvs[:Controller]

        return super(method_name, *args) unless AppOpticsAPM.tracing?
        begin
          kvs[:Backtrace] = AppOpticsAPM::API.backtrace if AppOpticsAPM::Config[:action_controller_api][:collect_backtraces]

          AppOpticsAPM::API.log_entry('rails-api', kvs)
          super(method_name, *args)

        rescue Exception => e
          AppOpticsAPM::API.log_exception(nil, e) if log_rails_error?(e)
          raise
        ensure
          AppOpticsAPM::API.log_exit('rails-api')
        end
      end

      #
      # render
      #
      # Our render wrapper that calls 'add_logging', which will log if we are tracing
      #
      def render(*args, &blk)
        trace('actionview') do
          super(*args, &blk)
        end
      end
    end
  end
end
