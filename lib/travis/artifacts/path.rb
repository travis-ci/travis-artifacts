module Travis::Artifacts
  class Path < Struct.new(:from, :to, :root)
    def fullpath
      if from =~ /^\//
        from
      else
        File.join(root, from)
      end
    end

    def directory?
      File.directory?(fullpath)
    end
  end
end
