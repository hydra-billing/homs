module FileContainsYaml
  extend ActiveSupport::Concern

  def hash_from_file
    return @hash if @hash

    @hash = YAML.load(file)
    @hash.is_a?(Hash) ? @hash.deep_symbolize_keys! : @hash = { }
  rescue Psych::SyntaxError
    logger.warn { "Warning: #{__FILE__}:#{__LINE__} rescued \
                   Psych::SyntaxError while parsing file: #{file[0..127]}" }
    @hash = { }
  end

  def html_from_file
    content = file.dup.force_encoding(Encoding::UTF_8)

    CodeRay.scan(content, :yml).div(
      tab_width: 0,
      css: :style,
      line_numbers: nil
    )
  end
end
