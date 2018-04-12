# frozen_string_literal: true
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yaml'
require 'rubocop/rake_task'
load "tasks/dev.rake"
RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Run RuboCop style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end
