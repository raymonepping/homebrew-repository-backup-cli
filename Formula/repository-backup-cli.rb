class RepositoryBackupCli < Formula
  desc "CLI toolkit for backing up GitHub repositories with tagging, ignore rules, and recovery"
  homepage "https://github.com/raymonepping/repository_backup_cli"
  url "https://github.com/raymonepping/homebrew-repository-backup-cli/archive/refs/tags/v1.6.0.tar.gz"

  sha256 "9adcab402dbad5cad997ee70d72604964744c61345244bafc929890cad5ba804"
  license "MIT"
  version "1.6.0"

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
