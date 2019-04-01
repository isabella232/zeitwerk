# frozen_string_literal: true

module Kernel
  module_function

  # We cannot decorate with prepend + super because Kernel has already been
  # included in Object, and changes in ancestors don't get propagated into
  # already existing ancestor chains.
  alias_method :zeitwerk_original_require, :require

  def require(path)
    path = path.to_s
    if path.start_with?("z\x1f")
      Zeitwerk::Registry.loader_for(path).on_zdir_autoloaded(path)
    else
      zeitwerk_original_require(path).tap do |required|
        if required
          realpath = $LOADED_FEATURES.last
          if loader = Zeitwerk::Registry.loader_for(realpath)
            loader.on_file_autoloaded(realpath)
          end
        end
      end
    end
  end
end
