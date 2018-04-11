# AppOpticsAPM Initializer (for the appoptics_apm gem)
# https://www.appoptics.com/
#
# More information on instrumenting Ruby applications can be found here:
# https://docs.appoptics.com/kb/apm_tracing/ruby/

if defined?(AppOpticsAPM::Config)

  #
  # Turn tracing on or off
  #
  # By default tracing is set to 'always', the other option is 'never'.
  # 'always' means that sampling will be done according to the current
  # sampling rate. 'never' means that there is no sampling.
  #
  AppOpticsAPM::Config[:tracing_mode] = :always

  #
  # Verbose output of instrumentation initialization
  #
  # AppOpticsAPM::Config[:verbose] = <%= @verbose %>
  #

  #
  # Logging of incoming HTTP query args
  #
  # This optionally disables the logging of incoming URL request
  # query args.
  #
  # This flag is global and currently only affects the Rack
  # instrumentation which reports incoming request URLs and
  # query args by default.
  AppOpticsAPM::Config[:include_remote_url_params] = true

  #
  # Logging of outgoing HTTP query args
  #
  # This optionally disables the logging of query args of outgoing
  # HTTP clients such as Net::HTTP, excon, typhoeus and others.
  #
  # This flag is global to all HTTP client instrumentation.
  #
  # To configure this on a per instrumentation basis, set this
  # option to true and instead disable the instrumentation specific
  # option <tt>log_args</tt>:
  #
  #   AppOpticsAPM::Config[:nethttp][:log_args] = false
  #   AppOpticsAPM::Config[:excon][:log_args] = false
  #   AppOpticsAPM::Config[:typhoeus][:log_args] = true
  #
  AppOpticsAPM::Config[:include_url_query_params] = true

  #
  # Sanitize SQL Statements
  #
  # The AppOpticsAPM Ruby client has the ability to sanitize query literals
  # from SQL statements.  By default this is enabled.  Disable to
  # collect and report query literals to AppOpticsAPM.
  #
  # AppOpticsAPM::Config[:sanitize_sql] = true
  #

  # Do Not Trace
  # These two values allow you to configure specific URL patterns to
  # never be traced.  By default, this is set to common static file
  # extensions but you may want to customize this list for your needs.
  #
  # dnt_regexp and dnt_opts is passed to Regexp.new to create
  # a regular expression object.  That is then used to match against
  # the incoming request path.
  #
  # The path string originates from the rack layer and is retrieved
  # as follows:
  #
  #   req = ::Rack::Request.new(env)
  #   path = URI.unescape(req.path)
  #
  # Usage:
  #   AppOpticsAPM::Config[:dnt_regexp] = "lobster$"
  #   AppOpticsAPM::Config[:dnt_opts]   = Regexp::IGNORECASE
  #
  # This will ignore all requests that end with the string lobster
  # regardless of case
  #
  # Requests with positive matches (non nil) will not be traced.
  # See lib/appoptics_apm/util.rb: AppOpticsAPM::Util.static_asset?
  #
  # AppOpticsAPM::Config[:dnt_regexp] = "\.(jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|pdf|txt|tar|wav|bmp|rtf|js|flv|swf|ttf|woff|svg|less)$"
  # AppOpticsAPM::Config[:dnt_opts]   = Regexp::IGNORECASE

  #
  # Blacklist urls
  #
  # This configuration is used by outbound calls. If the call
  # goes to a blacklisted url then we won't add any
  # tracing information to the headers.
  #
  # The list has to an array of strings, even if only one url is blacklisted
  #
  # Example: AppOpticsAPM::Config[:blacklist] = ['google.com']
  #
  # AppOpticsAPM::Config[:blacklist]
  #

  #
  # Rails Exception Logging
  #
  # In Rails, raised exceptions with rescue handlers via
  # <tt>rescue_from</tt> are not reported to the AppOptics
  # dashboard by default.  Setting this value to true will
  # report all raised exception regardless.
  #
  # AppOpticsAPM::Config[:report_rescued_errors] = false
  #

  #
  # Bunny Controller and Action
  #
  # The bunny (Rabbitmq) instrumentation can optionally report
  # Controller and Action values to allow filtering of bunny
  # message handling in # the UI.  Use of Controller and Action
  # for filters is temporary until the UI is updated with
  # additional filters.
  #
  # These values identify which properties of
  # Bunny::MessageProperties to report as Controller
  # and Action.  The defaults are to report :app_id (as
  # Controller) and :type (as Action).  If these values
  # are not specified in the publish, then nothing
  # will be reported here.
  #
  # AppOpticsAPM::Config[:bunnyconsumer][:controller] = :app_id
  # AppOpticsAPM::Config[:bunnyconsumer][:action] = :type
  #

  #
  # Resque Argument logging
  #
  # Set to true to enable Resque argument logging (Default: false)
  #
  # AppOpticsAPM::Config[:resqueworker][:log_args] = false
  # AppOpticsAPM::Config[:resqueclient[:log_args] = false
  #

  #
  # Enabling/Disabling Instrumentation
  #
  # If you're having trouble with one of the instrumentation libraries, they
  # can be individually disabled here by setting the :enabled
  # value to false:
  #
  # AppOpticsAPM::Config[:action_controller][:enabled] = true
  # AppOpticsAPM::Config[:action_controller_api][:enabled] = true
  # AppOpticsAPM::Config[:action_view][:enabled] = true
  # AppOpticsAPM::Config[:active_record][:enabled] = true
  # AppOpticsAPM::Config[:bunnyclient][:enabled] = true
  # AppOpticsAPM::Config[:bunnyconsumer][:enabled] = true
  # AppOpticsAPM::Config[:cassandra][:enabled] = true
  # AppOpticsAPM::Config[:curb][:enabled] = true
  # AppOpticsAPM::Config[:dalli][:enabled] = true
  # AppOpticsAPM::Config[:delayed_jobclient][:enabled] = true
  # AppOpticsAPM::Config[:delayed_jobworker][:enabled] = true
  # AppOpticsAPM::Config[:em_http_request][:enabled] = true
  # AppOpticsAPM::Config[:excon][:enabled] = true
  # AppOpticsAPM::Config[:faraday][:enabled] = true
  # AppOpticsAPM::Config[:grape][:enabled] = true
  # AppOpticsAPM::Config[:httpclient][:enabled] = true
  # AppOpticsAPM::Config[:memcache][:enabled] = true
  # AppOpticsAPM::Config[:memcached][:enabled] = true
  # AppOpticsAPM::Config[:mongo][:enabled] = true
  # AppOpticsAPM::Config[:moped][:enabled] = true
  # AppOpticsAPM::Config[:nethttp][:enabled] = true
  # AppOpticsAPM::Config[:redis][:enabled] = true
  # AppOpticsAPM::Config[:resqueclient][:enabled] = true
  # AppOpticsAPM::Config[:resqueworker][:enabled] = true
  # AppOpticsAPM::Config[:rest_client][:enabled] = true
  # AppOpticsAPM::Config[:sequel][:enabled] = true
  # AppOpticsAPM::Config[:sidekiqclient][:enabled] = true
  # AppOpticsAPM::Config[:sidekiqworker][:enabled] = true
  # AppOpticsAPM::Config[:typhoeus][:enabled] = true
  #

  #
  # Enabling/Disabling Backtrace Collection
  #
  # Instrumentation can optionally collect backtraces as they collect
  # performance metrics.  Note that this has a negative impact on
  # performance but can be useful when trying to locate the source of
  # a certain call or operation.
  #
  # AppOpticsAPM::Config[:action_controller][:collect_backtraces] = true
  # AppOpticsAPM::Config[:action_controller_api][:collect_backtraces] = true
  # AppOpticsAPM::Config[:action_view][:collect_backtraces] = true
  # AppOpticsAPM::Config[:active_record][:collect_backtraces] = true
  # AppOpticsAPM::Config[:bunnyclient][:collect_backtraces] = true
  # AppOpticsAPM::Config[:bunnyconsumer][:collect_backtraces] = true
  # AppOpticsAPM::Config[:cassandra][:collect_backtraces] = true
  # AppOpticsAPM::Config[:curb][:collect_backtraces] = true
  # AppOpticsAPM::Config[:dalli][:collect_backtraces] = false
  # AppOpticsAPM::Config[:delayed_jobclient][:collect_backtraces] = false
  # AppOpticsAPM::Config[:delayed_jobworker][:collect_backtraces] = false
  # AppOpticsAPM::Config[:em_http_request][:collect_backtraces] = true
  # AppOpticsAPM::Config[:excon][:collect_backtraces] = false
  # AppOpticsAPM::Config[:faraday][:collect_backtraces] = false
  # AppOpticsAPM::Config[:grape][:collect_backtraces] = false
  # AppOpticsAPM::Config[:httpclient][:collect_backtraces] = false
  # AppOpticsAPM::Config[:memcache][:collect_backtraces] = false
  # AppOpticsAPM::Config[:memcached][:collect_backtraces] = false
  # AppOpticsAPM::Config[:mongo][:collect_backtraces] = true
  # AppOpticsAPM::Config[:moped][:collect_backtraces] = true
  # AppOpticsAPM::Config[:nethttp][:collect_backtraces] = true
  # AppOpticsAPM::Config[:rack][:collect_backtraces] = true
  # AppOpticsAPM::Config[:redis][:collect_backtraces] = false
  # AppOpticsAPM::Config[:resqueclient][:collect_backtraces] = true
  # AppOpticsAPM::Config[:resqueworker][:collect_backtraces] = true
  # AppOpticsAPM::Config[:rest_client][:collect_backtraces] = true
  # AppOpticsAPM::Config[:sequel][:collect_backtraces] = true
  # AppOpticsAPM::Config[:sidekiqclient][:collect_backtraces] = true
  # AppOpticsAPM::Config[:sidekiqworker][:collect_backtraces] = true
  # AppOpticsAPM::Config[:typhoeus][:collect_backtraces] = false
  #
end
