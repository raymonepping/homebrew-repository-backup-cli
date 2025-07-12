class RepositoryBackupCli < Formula
  desc "CLI toolkit for backing up GitHub repositories with tagging, ignore rules, and recovery"
  homepage "https://github.com/raymonepping/repository_backup_cli"
  url "https://github.com/raymonepping/medium_scripts/archive/refs/tags/v1.0.6.tar.gz"
  
  sha256 "da4f2adedde23b5a1c1b5cc453e26e8ee4bf5de5d4ccc4961d1da5e11ca114aa"
  license "MIT"
  version "1.0.6"

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
