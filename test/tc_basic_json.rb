require File.expand_path(File.dirname(__FILE__) + '/smartrunner')
load File.expand_path(File.dirname(__FILE__) + '/json.mt_')

class TestBasicJSON <  Minitest::Test

  def test_json
    s = TestJSON.new
    s.__markus_indent = true
    puts s.json_!(:main)
    # assert s.xml_!(:main) == "<html>\n  <body class=\"test\">\n    <a href=\"https://ruby-lang.org\">Ruby</a>\n    <span>\nSome Text\n    </span>\n    <input type=\"text\" value=\"hello world\"/>\n  </body>\n</html>"
  end

  def test_json_noindent
    s = TestJSON.new
    s.__markus_indent = false
    puts s.json_!(:main)
    # assert s.xml_!(:main) == "<html><body class=\"test\"><a href=\"https://ruby-lang.org\">Ruby</a><span>Some Text</span><input type=\"text\" value=\"hello world\"/></body></html>"
  end

end
