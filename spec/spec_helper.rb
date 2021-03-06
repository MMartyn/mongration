$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'coveralls'
Coveralls.wear!

require 'timecop'
Timecop.safe_mode = true

if RUBY_PLATFORM == 'java'
  require 'ruby-debug'
else
  if RUBY_VERSION.to_f >= 2.0
    require 'byebug'
  elsif RUBY_VERSION.to_f >= 1.9
    require 'debugger'
  end
end

require 'mongration'
Mongration.configure do |config|
  config.config_path = File.join('spec', 'config', 'mongoid.yml')
  config.silent = true
end

Dir[File.join(Dir.pwd, 'spec', 'support', '*.rb')].each { |f| require f }
Dir[File.join(Dir.pwd, 'spec', 'fixtures', '*.rb')].each { |f| require f }

RSpec.configure do |config|

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  config.include(IntegrationFixtures)

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
    expectations.syntax = :expect
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    # For more details, see:
    #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end

  def clean_migration_files
    dir = File.join('spec', 'db', 'migrate')
    Mongration.configure do |config|
      config.dir = dir
      config.timestamps = false
    end
    Dir.glob(File.join(dir, '*')).each { |f| File.delete(f) }
  end

  config.before(:each) do
    clean_migration_files

    # clear out database
    Mongoid.purge!

    # clear out models
    Foo.instances = []
    Bar.instances = []
  end

  config.after(:all) do
    clean_migration_files # prevents tailor from looking in this directory
  end
end
