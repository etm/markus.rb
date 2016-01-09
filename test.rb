require './lib/markus'
require './something'
s = Something.new
puts s.json! :main

# {                                                                                                                                                            
#   "from": 1,
#   "size": 6,
#   "query": {
#     "filtered": {
#       "filter": {
#         "bool": {
#           "must": [
#             {
#               "bool": {
#                 "should": [
#                   {
#                     "nested": {
#                       "path": "contact",
#                       "query": {
#                         "term": {
#                           "contact.durchwahl": "aaa"
#                         }
#                       }
#                     }
#                   },
#                   {
#                     "nested": {
#                       "path": "functions.contact",
#                       "query": {
#                         "term": {
#                           "functions.contact.durchwahl": "5555"
#                         }
#                       }
#                     }
#                   }
#                 ]
#               }
#             }
#           ]
#         }
#       }
#     }
#   }
# }
