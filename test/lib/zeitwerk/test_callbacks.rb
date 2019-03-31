require "test_helper"

class TestCallbacks < LoaderTest
  test "autoloading a file triggers on_file_autoloaded" do
    def loader.on_file_autoloaded(file)
      if file == File.realpath("x.rb")
        $on_file_autoloaded_called = true
      end
      super
    end

    files = [["x.rb", "X = true"]]
    with_setup(files) do
      $on_file_autoloaded_called = false
      assert X
      assert $on_file_autoloaded_called
    end
  end

  test "requiring an autoloadable file triggers on_file_autoloaded" do
    def loader.on_file_autoloaded(file)
      if file == File.realpath("y.rb")
        $on_file_autoloaded_called = true
      end
      super
    end

    files = [
      ["x.rb", "X = true"],
      ["y.rb", "Y = X"]
    ]
    with_setup(files, load_path: ".") do
      $on_file_autoloaded_called = false
      require "y"
      assert Y
      assert $on_file_autoloaded_called
    end
  end

  test "autoloading a directory triggers on_zdir_autoloaded" do
    def loader.on_zdir_autoloaded(zdir)
      if zdir == "z\x1f" + File.realpath("m")
        $on_zdir_autoloaded_called = true
      end
      super
    end

    files = [["m/x.rb", "M::X = true"]]
    with_setup(files) do
      $on_zdir_autoloaded_called = false
      assert M::X
      assert $on_zdir_autoloaded_called
    end
  end
end
