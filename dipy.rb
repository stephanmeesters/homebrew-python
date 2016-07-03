class Dipy < Formula
  desc "Diffusion Imaging in Python"
  homepage "http://dipy.org/"
  url "https://github.com/nipy/dipy/archive/0.11.0.tar.gz"
  sha256 "b9b7c19ccf9d5087f2bdea86478319a5355bb4d4c5cb23afd7d85b09048d1716"
  head "https://github.com/nipy/dipy.git"

  option "without-python", "Build without python2 support"

  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional
  depends_on "clang-omp" => :recommended

  numpy_options = []
  numpy_options << "with-python3" if build.with? "python3"
  depends_on "homebrew/python/numpy" => numpy_options

  option "without-check", "Don't run tests during installation"

  resource "nibabel" do
    url "https://pypi.python.org/packages/source/n/nibabel/nibabel-2.0.2.tar.gz"
    sha256 "2d725e862b9a383db22b595e749142a6d0e181e371b245a12bd837ba9ddb"
  end

  def install

    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"
    %w[nibabel].each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    Language::Python.each_python(build) do |python, version|
      ENV["PYTHONPATH"] = Formula["dipy"].opt_lib/"python#{version}/site-packages"
      ENV["CC"] = "clang-omp"
      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"

      if build.with? "clang-omp"
        system python, "setup.py", "build"#, "--fcompiler=clang-omp"
      else
        system python, "setup.py", "build"
      end
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import dipy; assert dipy.test().wasSuccessful()"
    end
  end

end
