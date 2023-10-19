module CONST
  class MissingConstant < ArgumentError; end

  CONSTANTS = {
    CL_CREATING_ALLOWED: 1212
  }.freeze

  def self.const_missing(name)
    unless (value = CONSTANTS[name])
      raise MissingConstant, <<-MSG.strip
        Missing constant #{name}
      MSG
    end

    const_set(name, value)
    value
  end
end
