# frozen_string_literal: true
require 'jettywrapper'

def print_out_solr_and_fedora_urls
  puts '---------------------------'
  puts 'Fedora URL: ' + Valkyrie::Classic.fedora_config[:url]
  puts 'Solr URL: ' + Valkyrie::Classic.solr_config[:url]
  puts '---------------------------'
  puts ''
end

Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/7.x-stable.zip"

namespace :valkyrie_classic do
  namespace :setup do
    task :config_files do
      # default ports
      default_ports = YAML.load_file('config/jetty.yml').map { |k, v| [k, v['jetty_port']] }.to_h
      default_port = default_ports['default']
      # fedora.yml
      fedora_yml_file = 'config/fedora.yml'
      FileUtils.touch(fedora_yml_file) # Create if it doesn't exist
      fedora_yml = YAML.load_file(fedora_yml_file) || {}
      ['development', 'test'].each do |env_name|
        jetty_port = default_ports.fetch(env_name, default_port)
        fedora_yml[env_name] = {
          user: 'fedoraAdmin',
          password: 'fedoraAdmin',
          url: 'http://localhost:' + jetty_port.to_s + (env_name == 'test' ? '/fedora-test' : '/fedora'),
          time_zone: 'America/New_York'
        }
      end
      File.open(fedora_yml_file, 'w') { |f| f.write fedora_yml.to_yaml }

      # solr.yml
      solr_yml_file = 'config/solr.yml'
      FileUtils.touch(solr_yml_file) # Create if it doesn't exist
      solr_yml = YAML.load_file(solr_yml_file) || {}
      ['development', 'test'].each do |env_name|
        jetty_port = default_ports.fetch(env_name, default_port)
        solr_yml[env_name] = {
          'url' => 'http://localhost:' + jetty_port.to_s + '/solr/valkyrie_classic_' + env_name
        }
      end
      File.open(solr_yml_file, 'w') { |f| f.write solr_yml.to_yaml }
    end

    task :solr_cores do
      env_name = ENV['RAILS_ENV'] || 'development'
      ## Copy cores ##
      FileUtils.cp_r('spec/fixtures/solr_cores/valkyrie_classic', File.join(Jettywrapper.jetty_dir, 'solr'))
      FileUtils.mv(File.join(Jettywrapper.jetty_dir, 'solr/valkyrie_classic'), File.join(Jettywrapper.jetty_dir, 'solr/valkyrie_classic_' + env_name))
      ## Copy solr.xml template ##
      FileUtils.cp_r('spec/fixtures/solr.xml', File.join(Jettywrapper.jetty_dir, 'solr'))

      # Update solr.xml configuration file so that it recognizes this code
      solr_xml_data = File.read(File.join(Jettywrapper.jetty_dir, 'solr/solr.xml'))
      solr_xml_data.gsub!(
        '<!-- ADD CORES HERE -->',
        '<core name="valkyrie_classic_' + env_name + '" instanceDir="valkyrie_classic_' + env_name + '" />' + "\n"
      )
      File.open(File.join(Jettywrapper.jetty_dir, 'solr/solr.xml'), 'w') { |file| file.write(solr_xml_data) }
    end
  end

  desc "run full ci suite"
  task ci: [:rubocop] do
    ENV['RAILS_ENV'] ||= 'test'
    Jettywrapper.jetty_dir = 'jetty-' + ENV['RAILS_ENV']
    unless File.exist?(Jettywrapper.jetty_dir)
      puts "\n"
      puts 'No test jetty found.  Will download / unzip a copy now.'
      puts "\n"
    end

    Rake::Task["jetty:clean"].invoke
    Rake::Task["valkyrie_classic:setup:solr_cores"].invoke

    jetty_params = Jettywrapper.load_config.merge(jetty_home: Jettywrapper.jetty_dir)
    error = Jettywrapper.wrap(jetty_params) do
      Rake::Task['valkyrie_classic:coverage'].invoke
    end
    raise "test failures: #{error}" if error
  end

  desc "Execute specs with coverage"
  task :coverage do
    # Put spec opts in a file named .rspec in root
    ruby_engine = defined?(RUBY_ENGINE) ? RUBY_ENGINE : "ruby"
    ENV['COVERAGE'] = 'true' unless ruby_engine == 'jruby'

    Rake::Task[:spec].invoke
  end
end
