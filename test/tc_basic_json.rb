require File.expand_path(File.dirname(__FILE__) + '/smartrunner')
load File.expand_path(File.dirname(__FILE__) + '/json.mt_')

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

end