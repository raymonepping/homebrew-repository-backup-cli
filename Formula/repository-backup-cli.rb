class RepositoryBackupCli < Formula
  desc "Modular, dryrun-safe, Git-aware backup CLI with config detection and markdown summary"
  homepage "https://github.com/raymonepping/repository_backup_cli"
  url "https://github.com/raymonepping/repository_backup_cli/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "<UPDATE_ME>" # Generated after pushing the release tarball
  license "MIT"
  version "1.0.0"

  depends_on "bash"
  depends_on "coreutils" # for md5sum and other portable utils
  depends_on "yq" => :optional
  depends_on "hclq" => :optional

  def install
    bin.install "bin/repository_backup.sh" => "repository_backup"
    pkgshare.install "lib", "examples"
    doc.install "README.md"
  end

  def caveats
    <<~EOS
      To get started:
        repository_backup --help

      To use the backup library from scripts:
        export REPOSITORY_BACKUP_HOME=#{opt_pkgshare}

      Examples and templates are in:
        #{opt_pkgshare}/examples
    EOS
  end

  test do
    assert_match "repository_backup", shell_output("#{bin}/repository_backup --help")
  end
end
