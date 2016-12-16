# frozen_string_literal: true
class GetCloneData
  attr_reader :repo, :dev, :url, :repo_path, :repo_lib_path
  GITHUB_SITE_URL = 'https://github.com'

  def initialize(developer,repository)
    @repo = repository
    @dev = developer
    @url = [GITHUB_SITE_URL, @dev, [@repo, 'git'].join('.')].join('/')
    @repo_path = repo_path
    `git clone #{@url} #{@repo_path}`
  end

  def repo_path
    File.expand_path(
      File.join(
        File.dirname(__FILE__), "git_clone_tmp", @dev, @repo
      )
    )
  end

  def loc_in_folder(folder)
  	if Dir.exists? @repo_path
  	  loc_in_folder = `cloc #{@repo_path}/#{folder}`
        .split("SUM").last.split("\n").first.split(" ")[1..5]
        .map { |i| i.to_f }
  	end
  	# response is an array of [no of files, no blank lines, no comments, no code lines]
  	loc_in_folder if loc_in_folder
  end

  def loc_in_file(file)
  	if File.exists? @repo_path
  	  loc_in_file = `wc -l #{@repo_path}/#{file}`.split(" ").first.to_f
  	end
  	# response is fixnum of lines of code in file (no comments or blanks)
  	loc_in_file if loc_in_file
  end

  def get_flog_scores
    if Dir.exists? @repo_path
      flog_response = `flog #{@repo_path}`.split("\n")
        .map { |item| item.split(":").first.to_f }
  	end
  	# reponse is an array of all the flog scores from total , ave, each method...
  	flog_response if flog_response
  end

  def get_flay_score
    if Dir.exists? @repo_path
      `flay #{@repo_path}`.split("=").last.split("\n").first.to_f
    end
  end

  def get_rubocop_errors
  	holder = Array.new()
  	if Dir.exists? @repo_path
  	  rubocop_response = `rubocop #{@repo_path}`
  	  holder << rubocop_response.split("\n").last.split("files").first.to_f
  	  holder << rubocop_response.split("\n").last.split(",").last.split("offenses").first.to_f
  	end
  	# response is array [no. of files, no. of offenses]
  	holder
  end

  def get_loc
  	if Dir.exists? @repo_path
  	  loc_response = `cloc #{@repo_path}`.split("SUM").last.split("\n").first
        .split("    ")[2..5].map { |i| i.to_f }
  	end
  	loc_response
  end
end
