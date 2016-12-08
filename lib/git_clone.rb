class GetCloneData

  def initialize(developer,repository)
    @GITHUB_SITE_URL = "https://github.com"
    @route = "/#{developer}/#{repository}.git"
	  @repo = "#{repository}"
    @url = @GITHUB_SITE_URL + @route
    `git clone #{@url}`
  end

  def loc_in_folder(folder)
  	if Dir.exists?("#{@repo}/#{folder}")
  	  loc_response = `cloc ./#{@repo}/#{folder}`
  	  loc_in_folder = loc_response.split("SUM").last.split("\n").first.split(" ")[1..5].map { |i| i.to_f }
  	else
  	  loc_in_folder = 0
  	end
  	# response is an array of [no of files, no blank lines, no comments, no code lines]
  	loc_in_folder
  end

  def loc_in_file(file)
  	if File.exists?("#{@repo}/#{file}")
  	  loc_response = `wc -l ./#{@repo}/#{file}`
  	  loc_in_file = loc_response.split(" ").first.to_f
  	else
  	  loc_in_file = 0
  	end
  	# response is fixnum of lines of code in file (no comments or blanks)
  	loc_in_file
  end

  def get_flog_scores
    if Dir.exists?("#{@repo}/lib")
      flog_response = `flog ./#{@repo}/lib`
      flog_response = flog_response.split("\n").map { |item| item.split(":").first.to_f }
  	else
  	  flog_response = 0
  	end
  	# reponse is an array of all the flog scores from total , ave, each method...
  	flog_response
  end

  def get_flay_score
  	if Dir.exists?("#{@repo}/lib")
  	  flay_response = `flay ./#{@repo}/lib`
  	  flay_response = flay_response.split("=").last.split("\n").first.to_f
    else
      flay_response = 0
    end
    # response is fixnum of flay score
    flay_response
  end

  def get_rubocop_errors
  	holder = Array.new()
  	if Dir.exists?("#{@repo}/lib")
  	  rubocop_response = `rubocop ./#{@repo}/lib`
  	  holder << rubocop_response.split("\n").last.split("files").first.to_f
  	  holder << rubocop_response.split("\n").last.split(",").last.split("offenses").first.to_f
  	end
  	# response is array [no. of files, no. of offenses]
  	holder
  end

  def get_loc
  	if Dir.exists?("#{@repo}/lib") 
  	  loc_response = `cloc ./#{@repo}/lib`
  	  loc_response = loc_response.split("SUM").last.split("\n").first.split("    ")[2..5].map { |i| i.to_f }
  	else
  	  loc_response = 0
  	end
  	loc_response
  end

end
