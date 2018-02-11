module Reruby
  class ConfigParser
    def initialize(cli_options: {})
      @cli_options = cli_options
    end

    def config
      file_config = Config.new(
        options: parse_file_options,
        fallback_config: Config.default
      )

      Config.new(
        options: parse_cli_options,
        fallback_config: file_config
      )
    end

    private

    attr_reader :cli_options

    def parse_cli_options
      cli_options.keys.reduce({}) do |config_opts, cli_option|
        new_config = cli_mappings[cli_option] || {}
        config_opts.merge(new_config)
      end
    end

    def parse_file_options
      possible_paths = [
        cli_options['config-file'],
        ".reruby.yml",
        File.join(Dir.home, ".reruby.yml")
      ]
      config_file_path = possible_paths.detect do |path|
        path && File.exist?(path)
      end

      return {} unless config_file_path

      YAML.safe_load(File.read(config_file_path))
    end

    # rubocop:disable Metrics/MethodLength
    # Inline configuration hash
    def cli_mappings
      {
        'ignore-paths' => {
          'paths' => {
            'exclude' => cli_options['ignore-paths']
          }
        },
        'ruby-extensions' => {
          'ruby_extensions' => cli_options['ruby-extensions']
        },
        'verbose' => {
          'verbose' => cli_options['verbose']
        }
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
