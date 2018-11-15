# Use this file to define when/how often the API background jobs should run.
# This is an example file that will not work without adding the "whenever" gem to your API project
# If you wish to use another scheduling system you can use this as a basis
env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']
env :GEM_HOME, ENV['GEM_HOME']
env :BUNDLE_BIN_PATH, ENV['BUNDLE_BIN_PATH']

set :environment, :development
set :ruby_version, '2.3.1'
job_type :runner,  "cd :path && bundle exec rails runner -e :environment ':task' :output"
set :output, {:error => 'log/development.log', :standard => 'log/development.log'}

every '*/5 * * * *' do
  runner 'SupplejackApi::InteractionMetricsWorker.perform_async'
end

every '* * * * *' do
  runner 'SupplejackApi::IndexRemainingRecordsInQueue.perform_async'
end

every '57 23 * * *' do
  runner 'SupplejackApi::DailyMetricsWorker.perform_async'
end

every '30 23 * * *' do
  runner 'SupplejackApi::StoreUserActivityWorker.perform_async'
end
