class Dipy < Formula
  desc "Diffusion Imaging in Python"
  homepage "http://dipy.org/"
  url "https://github.com/nipy/dipy/archive/0.11.0.tar.gz"
  sha256 "b9b7c19ccf9d5087f2bdea86478319a5355bb4d4c5cb23afd7d85b09048d1716"
  head "https://github.com/nipy/dipy.git"

  option "without-python", "Build without python2 support"

  depends_on :python => :recommended if MacOS.version <= :snow_leopard
  depends_on :python3 => :optional
  depends_on "cmake" => :build
  depends_on "clang-omp" => :recommended

  numpy_options = []
  numpy_options << "with-python3" if build.with? "python3"
  depends_on "homebrew/python/numpy" => numpy_options
  depends_on "homebrew/science/vtk" => :recommended

  option "without-check", "Don't run tests during installation"

  resource "nibabel" do
    url "https://pypi.python.org/packages/source/n/nibabel/nibabel-2.0.2.tar.gz"
    sha256 "f0ccd90ccf9ff5f9a203e1d7e2f21989db0bee1db4f9cc2762db2c5e7fd9154d"
  end

  resource "cython" do
    url "https://pypi.python.org/packages/source/C/Cython/Cython-0.24.tar.gz"
    sha256 "6de44d8c482128efc12334641347a9c3e5098d807dd3c69e867fa8f84ec2a3f1"
  end

  def install
    Language::Python.each_python(build) do |python, version|
      ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{version}/site-packages"
      resource("cython").stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end

      ENV.prepend_create_path "PYTHONPATH", lib/"python#{version}/site-packages"
      resource("nibabel").stage do
        system "python", *Language::Python.setup_install_args(prefix)
      end

      if build.with? "clang-omp"
        ENV["CC"] = "clang-omp"
        ENV["C_INCLUDE_PATH"]="/usr/local/include/libiomp:$C_INCLUDE_PATH"
      end

      system python, "setup.py", "build"
      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", "import dipy; assert dipy.test().wasSuccessful()"
    end
  end
end