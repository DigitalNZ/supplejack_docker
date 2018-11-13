# frozen_string_literal: true

# This rake task is performed once every minute to add new records in the the solr index.  You can see the source code here:
# https://github.com/DigitalNZ/supplejack_api/blob/master/app/workers/supplejack_api/index_remaining_records_in_queue.rb

require 'progressbar'

namespace :index do

  desc 'Index records'
  task :index_remaining_records => :environment do
    SupplejackApi::IndexRemainingRecordsInQueue.perform
  end
end
