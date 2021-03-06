class MinioMc < Formula
  desc "Replacement for ls, cp and other commands for object storage"
  homepage "https://github.com/minio/mc"
  url "https://github.com/minio/mc.git",
      :tag      => "RELEASE.2019-01-25T23-38-19Z",
      :revision => "e940856fee744b6d05f80f4f8a313374c70fc3bc"
  version "20190125233819"

  bottle do
    cellar :any_skip_relocation
    sha256 "1133bdb7579ff534ad8fed21ab19310791347ffc762021b1e9b8ce4aee6b9ebc" => :mojave
    sha256 "497efa2b1e4d1cebf572a47afd2b8df96bb0b726b4d17f8f25ea718d606184bf" => :high_sierra
    sha256 "b31d42becb40ca0a9ca834afb53eb3f2ab4b59dcc4c1115342dccef3065b1722" => :sierra
    sha256 "3d640911f28f03632e3a0174fc496befd17148c08aafc144315e7384df0c4099" => :x86_64_linux
  end

  depends_on "go" => :build

  conflicts_with "midnight-commander", :because => "Both install a `mc` binary"

  def install
    ENV["GOPATH"] = buildpath

    clipath = buildpath/"src/github.com/minio/mc"
    clipath.install Dir["*"]

    cd clipath do
      if build.head?
        system "go", "build", "-o", buildpath/"mc"
      else
        minio_release = `git tag --points-at HEAD`.chomp
        minio_version = minio_release.gsub(/RELEASE\./, "").chomp.gsub(/T(\d+)\-(\d+)\-(\d+)Z/, 'T\1:\2:\3Z')
        minio_commit = `git rev-parse HEAD`.chomp
        proj = "github.com/minio/mc"

        system "go", "build", "-o", buildpath/"mc", "-ldflags", <<~EOS
          -X #{proj}/cmd.Version=#{minio_version}
          -X #{proj}/cmd.ReleaseTag=#{minio_release}
          -X #{proj}/cmd.CommitID=#{minio_commit}
        EOS
      end
    end

    bin.install buildpath/"mc"
    prefix.install_metafiles
  end

  test do
    system bin/"mc", "mb", testpath/"test"
    assert_predicate testpath/"test", :exist?
  end
end
