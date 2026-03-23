# specific for windows, will miss one byte otherwise
if defined?(Propshaft::Asset)
  Propshaft::Asset.class_eval do
    def content(encoding: "ASCII-8BIT")
      File.binread(path)
    end
  end
end
