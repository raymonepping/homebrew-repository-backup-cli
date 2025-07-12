class RepositoryBackupCli < Formula
  desc "CLI toolkit for backing up GitHub repositories with tagging, ignore rules, and recovery"
  homepage "https://github.com/raymonepping/repository_backup_cli"
  url "https://github.com/raymonepping/homebrew-repository-backup-cli/archive/refs/tags/v1.1.1.tar.gz"
  
  sha256 "0882e015d5ff86aa803d1bdb113b103d2cb83b05b60a6e2ca6a38618cf96d201"
  license "MIT"
  version "1.1.1"

  depends_on "bash"

  def install
    bin.install "bin/repository_backup.sh" => "repository_backup"
    pkgshare.install "core", "templates"
    doc.install "README.md"
  end

  def caveats
    <<~EOS
      To get started, run:
        repository_backup --help

      If you use templates or configs from the repo, export:
        export REPO_BACKUP_HOME=#{opt_pkgshare}
    EOS
  end

  test do
    assert_match "repository_backup", shell_output("#{bin}/repository_backup --version")
  end
end
