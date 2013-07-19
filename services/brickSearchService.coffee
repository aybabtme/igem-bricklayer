# Retrieve data from partsregistry.org. For how this works see partsRegistrySearchFormat.md
request = require 'request'
parser = require './parserService'

exports.routes = routes =
    text: "/api/v1/search/text"
    thousand: "/api/v1/search/thousand"
    subparts: "/api/v1/search/subparts"
    superparts: "/api/v1/search/superparts"

searchConfig =
    baseSearchUrl: "http://parts.igem.org/cgi/partsdb/search.cgi?"
    baseApiUrl: "http://parts.igem.org/cgi/xml/part.cgi?part="
    text:
        nameTextInput: "searchfor1"
        nameSubmitButton: "searchfor"
    thousand:
        nameTextInput: "fist_part"
        nameSubmitButton: "search_from_to"
    subparts:
        nameTextInput: "part_list"
        nameSubmitButton: "search_subparts"
    superparts:
        nameTextInput: "super_part_list"
        nameSubmitButton: "search_superparts"

# Construct the url needed to submit a search on partsregistry.org
# http://parts.igem.org/cgi/partsdb/search.cgi?[nameTextInput]=[STRING];[nameSubmitButton]=Search`
# * `textInput`: The name of the text input. Should come from searchConfig
# * `submitButton`: The name of the submit button. Should come from searchConfig
# * `searchString`: The string to search for.
getQueryUrl = (textInput, submitButton, searchString) ->
    searchConfig.baseSearchUrl + textInput + "=" + searchString + ";" + submitButton + "=Search"

search = (req, res) ->
    path = req.route.path
    searchTerms = req.query.searchTerms
    # callback
    done = (error, response, body) ->
        if error then res.send 404, error
        # The response from partsregistry is the full HTML page.
        # Parse the page and get a list of parts.
        parts = parser.parseListFromPage body
        res.send 200, parts

    if path is routes.text
        searchText searchTerms, done
    else if path is routes.thousand
        searchThousand searchTerms, done
    else if path is routes.subparts
        searchSubparts searchTerms, done
    else if path is routes.superparts
        searchSuperparts searchTerms, done

searchText = (searchTerms, done) ->
    url = getQueryUrl(
        searchConfig.text.nameTextInput,
        searchConfig.text.nameSubmitButton,
        searchTerms
        )
    console.log url
    request url, done

searchThousand = (searchTerms, done) ->
    url = getQueryUrl(
        searchConfig.thousand.nameTextInput,
        searchConfig.thousand.nameSubmitButton,
        searchTerms
        )
    console.log url
    request url, done

searchSubparts = (searchTerms, done) ->
    url = getQueryUrl(
        searchConfig.subparts.nameTextInput,
        searchConfig.subparts.nameSubmitButton,
        searchTerms
        )
    console.log url
    request url, done

searchSuperparts = (searchTerms, done) ->
    url = getQueryUrl(
        searchConfig.superparts.nameTextInput,
        searchConfig.superparts.nameSubmitButton,
        searchTerms
        )
    console.log url
    request url, done

# search = (req, res) ->
#     doSearch = req.query.doSearch
#     url = "http://igempartview.appspot.com/query/json?param=categories&value=/cds/membrane"
#     request url, (error, response, body) ->
#         data = JSON.parse body
#         res.send 200, data

# Builds a queryString from a params object, then returns url + queryString
# TODO: Adds an unnecessary "&" to the end of the url. Get rid of it.
attachQueryString = (url, params) ->
    queryString = "?"
    for paramKey, value of params
        queryString += paramKey + "=" + value + "&"
    url + queryString

# Exports
exports.search = search
