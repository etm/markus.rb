require File.expand_path(File.dirname(__FILE__) + '/smartrunner')
load File.expand_path(File.dirname(__FILE__) + '/html.mt_')

class TestBasicHTML <  Minitest::Test

  def test_xml
    s = TestHTML.new
    s.__markus_indent = true
    assert s.xml_!(:main) == "<html>\n  <body class=\"test\">\n    <a href=\"https://ruby-lang.org\">Ruby</a>\n    <span>\nSome Text\n    </span>\n    <input type=\"text\" value=\"hello world\"/>\n  </body>\n</html>"
  end

  def test_html
    s = TestHTML.new
    s.__markus_indent = true
    assert s.html_!(:main) == "<html>\n  <body class=\"test\">\n    <a href=\"https://ruby-lang.org\">Ruby</a>\n    <span>\nSome Text\n    </span>\n    <input type=\"text\" value=\"hello world\"></input>\n  </body>\n</html>"
  end

  def test_xml_noindent
    s = TestHTML.new
    s.__markus_indent = false
    assert s.xml_!(:main) == "<html><body class=\"test\"><a href=\"https://ruby-lang.org\">Ruby</a><span>Some Text</span><input type=\"text\" value=\"hello world\"/></body></html>"
  end

end
