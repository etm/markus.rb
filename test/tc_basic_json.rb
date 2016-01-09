require File.expand_path(File.dirname(__FILE__) + '/smartrunner')
load File.expand_path(File.dirname(__FILE__) + '/json.mt_')
load File.expand_path(File.dirname(__FILE__) + '/includes.mt_')
load File.expand_path(File.dirname(__FILE__) + '/json_arguments.mt_')

class TestBasicJSON <  Minitest::Test

  def test_json
    s = TestJSON.new
    s.__markus_indent = true
    assert s.json_!(:main) == "\"from\": 1,\n\"size\": 6,\n\"query\": {\n  \"filtered\": {\n    \"filter\": {\n      \"bool\": {\n        \"must\": [\n          {\n            \"bool\": {\n              \"should\": [\n                {\n                  \"nested\": {\n                    \"path\": \"contact\",\n                    \"query\": {\n                      \"term\": {\n                        \"contact.durchwahl\": 1\n                      }\n                    }\n                  }\n                },\n                {\n                  \"nested\": {\n                    \"path\": \"contact\",\n                    \"query\": {\n                      \"term\": {\n                        \"contact.durchwahl\": \"aaa\"\n                      }\n                    }\n                  }\n                }\n              ]\n            }\n          }\n        ]\n      }\n    }\n  }\n}"
  end

  def test_json_noindent
    s = TestJSON.new
    s.__markus_indent = false
    assert s.json_!(:main) == "\"from\": 1,\"size\": 6,\"query\": {\"filtered\": {\"filter\": {\"bool\": {\"must\": [{\"bool\": {\"should\": [{\"nested\": {\"path\": \"contact\",\"query\": {\"term\": {\"contact.durchwahl\": 1}}}},{\"nested\": {\"path\": \"contact\",\"query\": {\"term\": {\"contact.durchwahl\": \"aaa\"}}}}]}}]}}}}"
  end

  def test_json_arguments
    s = TestJSONArguments.new
    assert s.json_!(:array) == "\"query\": [ 2, 3, \"world\" ]"
    assert s.json_!(:hash)  == "\"query\": { \"a\": 2, \"b\": \"hello\" }"
    assert s.json_!(:date)  =~ /"query": "\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} \+\d{4}\"/
  end

  def test_json_includes
    s = TestIncludes.new
    assert s.json_!(:main) == "\"query\": [ 2, 3, \"world\" ],\n\"query\": { \"a\": 2, \"b\": \"hello\" }"
  end

end
