require File.expand_path(File.dirname(__FILE__) + '/smartrunner')
load File.expand_path(File.dirname(__FILE__) + '/change.mt_')

class TestChange <  Minitest::Test

  def test_json
    fname = File.expand_path(File.dirname(__FILE__) + '/change.mt_')

    s = TestJsonChange.new
    newnum = nil
    newcontent = File.read(fname).gsub(/query_ (\d+)/) do
      newnum = ($1.to_i + 1).to_s
      "query_ " + newnum
    end
    File.write(fname,newcontent)
    assert s.json_!(:main) == %Q({"query": #{newnum}})
  end

end
