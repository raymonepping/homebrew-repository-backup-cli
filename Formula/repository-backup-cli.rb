class RepositoryBackupCli < Formula
  desc "Modular, dryrun-safe, self-healing backup CLI with integrity checks and Markdown summaries"
  homepage "https://github.com/raymonepping/repository_backup_cli"
  url "https://github.com/raymonepping/repository_backup_cli/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"
  version "1.0.0"

  depends_on "bash"

  def install
    bin.install "bin/repository_backup.sh" => "repository_backup"
    pkgshare.install "lib", "docs", "examples" if File.directory?("lib")
    doc.install "README.md" if File.exist?("README.md")
  end

  def caveats
    <<~EOS
      To get started, run:
        repository_backup --help

      The library and examples (if present) are located in:
        #{opt_pkgshare}

      If needed in scripts:
        export REPOSITORY_BACKUP_HOME=#{opt_pkgshare}
    EOS
  end

  test do
    assert_match "repository_backup", shell_output("#{bin}/repository_backup --version 2>&1", 1)
  end
end
