#include "ollama_client.h"
#include <algorithm>
#include <iostream>
#include <sstream>
#include <vector>
#include <nlohmann/json.hpp>

#ifdef _WIN32
#include <windows.h>
#include <winhttp.h>
#pragma comment(lib, "winhttp.lib")
#endif

namespace RawrXD {
namespace Backend {

using json = nlohmann::json;

namespace {
bool ParseBaseUrl(const std::string& base, std::wstring& hostOut, unsigned short& portOut) {
    hostOut = L"127.0.0.1";
    portOut = 11434;
    if (base.empty()) return true;
    std::string s = base;
    if (s.rfind("http://", 0) == 0) s = s.substr(7);
    else if (s.rfind("https://", 0) == 0) s = s.substr(8);
    auto slash = s.find('/');
    if (slash != std::string::npos) s = s.substr(0, slash);
    auto colon = s.find(':');
    std::string host = (colon == std::string::npos) ? s : s.substr(0, colon);
    if (colon != std::string::npos && colon + 1 < s.size()) {
        portOut = static_cast<unsigned short>(atoi(s.c_str() + colon + 1));
    }
    if (host.empty()) host = "127.0.0.1";
    hostOut.assign(host.begin(), host.end());
    return true;
}
} // namespace

// CURL callback for writing response data
size_t curlWriteCallback(void* contents, size_t size, size_t nmemb, std::string* userp) {
    userp->append((const char*)contents, size * nmemb);
    return size * nmemb;
}

// CURL callback for streaming response data
size_t curlStreamCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    auto* callback_data = static_cast<std::tuple<StreamCallback, ErrorCallback, CompletionCallback>*>(userp);
    auto& [on_chunk, on_error, on_complete] = *callback_data;
    
    std::string chunk((const char*)contents, size * nmemb);
    
    try {
        // Parse the JSON chunk
        json j = json::parse(chunk);
        
        if (j.contains("response")) {
            std::string response_chunk = j["response"];
            if (on_chunk) {
                on_chunk(response_chunk);
            }
        }
        
        if (j.contains("done") && j["done"].get<bool>()) {
            OllamaResponse final_response;
            final_response.done = true;
            final_response.model = j.value("model", "");
            final_response.total_duration = j.value("total_duration", 0ULL);
            final_response.prompt_eval_count = j.value("prompt_eval_count", 0ULL);
            final_response.eval_count = j.value("eval_count", 0ULL);
            final_response.load_duration = j.value("load_duration", 0ULL);
            final_response.prompt_eval_duration = j.value("prompt_eval_duration", 0ULL);
            final_response.eval_duration = j.value("eval_duration", 0ULL);
            
            if (on_complete) {
                on_complete(final_response);
            }
        }
    } catch (const std::exception& e) {
        if (on_error) {
            on_error(std::string("JSON parse error: ") + e.what());
        }
    }
    
    return size * nmemb;
}

OllamaClient::OllamaClient(const std::string& base_url)
    : m_base_url(base_url.empty() ? std::string("http://127.0.0.1:11434") : base_url) {
}

OllamaClient::~OllamaClient() {
}

void OllamaClient::setBaseUrl(const std::string& url) {
    m_base_url = url;
}

void OllamaClient::cancelStream() {
    m_cancelStream.store(true);
}

bool OllamaClient::testConnection() {
    std::string response = makeGetRequest("/api/tags");
    return !response.empty();
}

std::string OllamaClient::getVersion() {
    std::string response = makeGetRequest("/api/version");
    if (response.empty()) return "";
    
    try {
        json j = json::parse(response);
        return j.value("version", "");
    } catch (...) {
        return "";
    }
}

bool OllamaClient::isRunning() {
    return testConnection();
}

std::vector<OllamaModel> OllamaClient::listModels() {
    std::string response = makeGetRequest("/api/tags");
    if (response.empty()) return {};
    
    return parseModels(response);
}

std::vector<OllamaModel> OllamaClient::filterModels(
    const std::vector<OllamaModel>& models,
    std::function<bool(const OllamaModel&)> predicate) const {
    
    std::vector<OllamaModel> filtered;
    for (const auto& model : models) {
        if (predicate(model)) {
            filtered.push_back(model);
        }
    }
    return filtered;
}

const OllamaModel* OllamaClient::findModelById(
    const std::vector<OllamaModel>& models,
    const std::string& targetId) const {
    
    for (const auto& model : models) {
        if (model.id == targetId) {
            return &model;
        }
    }
    return nullptr;
}

OllamaResponse OllamaClient::generateSync(const OllamaGenerateRequest& request) {
    std::string json_body = createGenerateRequestJson(request);
    std::string response = makePostRequest("/api/generate", json_body);
    
    if (response.empty()) {
        OllamaResponse res;
        res.error = true;
        res.error_message = "Empty response from server";
        return res;
    }
    
    return parseResponse(response);
}

OllamaResponse OllamaClient::chatSync(const OllamaChatRequest& request) {
    std::string json_body = createChatRequestJson(request);
    std::string response = makePostRequest("/api/chat", json_body);
    
    if (response.empty()) {
        OllamaResponse res;
        res.error = true;
        res.error_message = "Empty response from server";
        return res;
    }
    
    return parseResponse(response);
}

bool OllamaClient::generate(const OllamaGenerateRequest& request,
                            StreamCallback on_chunk,
                            ErrorCallback on_error,
                            CompletionCallback on_complete) {
    std::string json_body = createGenerateRequestJson(request);
    return makeStreamingPostRequest("/api/generate", json_body, on_chunk, on_error, on_complete);
}

bool OllamaClient::chat(const OllamaChatRequest& request,
                        StreamCallback on_chunk,
                        ErrorCallback on_error,
                        CompletionCallback on_complete) {
    std::string json_body = createChatRequestJson(request);
    return makeStreamingPostRequest("/api/chat", json_body, on_chunk, on_error, on_complete);
}

std::vector<float> OllamaClient::embeddings(const std::string& model, const std::string& prompt) {
    json request_json;
    request_json["model"] = model;
    request_json["prompt"] = prompt;
    
    std::string json_body = request_json.dump();
    std::string response = makePostRequest("/api/embeddings", json_body);
    
    if (response.empty()) return {};
    
    try {
        json j = json::parse(response);
        if (j.contains("embedding")) {
            return j["embedding"].get<std::vector<float>>();
        }
    } catch (...) {
        return {};
    }
    
    return {};
}

std::string OllamaClient::createGenerateRequestJson(const OllamaGenerateRequest& req) {
    json j;
    j["model"] = req.model;
    j["prompt"] = req.prompt;
    j["stream"] = req.stream;
    if (req.raw) {
        j["raw"] = true;
    }
    
    if (!req.options.empty()) {
        json options = json::object();
        for (const auto& [key, value] : req.options) {
            options[key] = value;
        }
        j["options"] = options;
    }
    
    return j.dump();
}

std::string OllamaClient::createChatRequestJson(const OllamaChatRequest& req) {
    json j;
    j["model"] = req.model;
    j["stream"] = req.stream;
    j["messages"] = json::array();
    
    for (const auto& msg : req.messages) {
        j["messages"].push_back({
            {"role", msg.role},
            {"content", msg.content}
        });
    }
    
    if (!req.options.empty()) {
        json options = json::object();
        for (const auto& [key, value] : req.options) {
            options[key] = value;
        }
        j["options"] = options;
    }
    
    return j.dump();
}

OllamaResponse OllamaClient::parseResponse(const std::string& json_str) {
    OllamaResponse response;
    
    try {
        json j = json::parse(json_str);
        
        response.model = j.value("model", "");
        response.response = j.value("response", "");
        response.done = j.value("done", false);
        
        if (j.contains("message")) {
            response.message.role = j["message"].value("role", "");
            response.message.content = j["message"].value("content", "");
        }
        
        response.total_duration = j.value("total_duration", 0ULL);
        response.prompt_eval_count = j.value("prompt_eval_count", 0ULL);
        response.eval_count = j.value("eval_count", 0ULL);
        response.load_duration = j.value("load_duration", 0ULL);
        response.prompt_eval_duration = j.value("prompt_eval_duration", 0ULL);
        response.eval_duration = j.value("eval_duration", 0ULL);
        
    } catch (const std::exception& e) {
        response.error = true;
        response.error_message = std::string("Parse error: ") + e.what();
    }
    
    return response;
}

std::vector<OllamaModel> OllamaClient::parseModels(const std::string& json_str) {
    std::vector<OllamaModel> models;
    
    try {
        json j = json::parse(json_str);
        
        if (j.contains("models") && j["models"].is_array()) {
            for (const auto& model_json : j["models"]) {
                OllamaModel model;
                model.name = model_json.value("name", "");
                model.id = model.name;  // Use name as ID
                model.size = model_json.value("size", 0ULL);
                model.digest = model_json.value("digest", "");
                model.modified_at = model_json.value("modified_at", "");
                
                // Parse details if available
                if (model_json.contains("details")) {
                    auto details = model_json["details"];
                    model.format = details.value("format", "");
                    model.family = details.value("family", "");
                    model.parameter_size = details.value("parameter_size", "");
                    model.quantization_level = details.value("quantization_level", "");
                }
                
                if (!model.name.empty()) {
                    models.push_back(model);
                }
            }
        }
        
    } catch (const std::exception& e) {
        std::cerr << "Error parsing models: " << e.what() << std::endl;
    }
    
    return models;
}

std::string OllamaClient::makeGetRequest(const std::string& endpoint) {
#ifdef _WIN32
    std::wstring host;
    unsigned short port = 11434;
    ParseBaseUrl(m_base_url, host, port);
    HINTERNET ses = WinHttpOpen(L"RawrXD-NativeClient/1.0", WINHTTP_ACCESS_TYPE_NO_PROXY,
                                WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (!ses) return {};
    WinHttpSetTimeouts(ses, 5000, 5000, 15000, 15000);
    HINTERNET con = WinHttpConnect(ses, host.c_str(), port, 0);
    if (!con) { WinHttpCloseHandle(ses); return {}; }
    std::wstring wpath(endpoint.begin(), endpoint.end());
    HINTERNET req = WinHttpOpenRequest(con, L"GET", wpath.c_str(), nullptr, WINHTTP_NO_REFERER,
                                       WINHTTP_DEFAULT_ACCEPT_TYPES, 0);
    if (!req) { WinHttpCloseHandle(con); WinHttpCloseHandle(ses); return {}; }
    std::string body;
    if (WinHttpSendRequest(req, WINHTTP_NO_ADDITIONAL_HEADERS, 0, WINHTTP_NO_REQUEST_DATA, 0, 0, 0) &&
        WinHttpReceiveResponse(req, nullptr)) {
        DWORD avail = 0, got = 0;
        do {
            avail = 0;
            if (!WinHttpQueryDataAvailable(req, &avail) || avail == 0) break;
            std::vector<char> buf(avail + 1, 0);
            if (!WinHttpReadData(req, buf.data(), avail, &got)) break;
            body.append(buf.data(), got);
        } while (avail > 0);
    }
    WinHttpCloseHandle(req); WinHttpCloseHandle(con); WinHttpCloseHandle(ses);
    return body;
#else
    (void)endpoint;
    return {};
#endif
}

std::string OllamaClient::makePostRequest(const std::string& endpoint, const std::string& json_body) {
#ifdef _WIN32
    std::wstring host;
    unsigned short port = 11434;
    ParseBaseUrl(m_base_url, host, port);
    HINTERNET ses = WinHttpOpen(L"RawrXD-NativeClient/1.0", WINHTTP_ACCESS_TYPE_NO_PROXY,
                                WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (!ses) return {};
    WinHttpSetTimeouts(ses, 5000, 5000, 60000, 60000);
    HINTERNET con = WinHttpConnect(ses, host.c_str(), port, 0);
    if (!con) { WinHttpCloseHandle(ses); return {}; }
    std::wstring wpath(endpoint.begin(), endpoint.end());
    HINTERNET req = WinHttpOpenRequest(con, L"POST", wpath.c_str(), nullptr, WINHTTP_NO_REFERER,
                                       WINHTTP_DEFAULT_ACCEPT_TYPES, 0);
    if (!req) { WinHttpCloseHandle(con); WinHttpCloseHandle(ses); return {}; }
    WinHttpAddRequestHeaders(req, L"Content-Type: application/json\r\n", (ULONG)-1L,
                             WINHTTP_ADDREQ_FLAG_ADD);
    std::string body;
    BOOL ok = WinHttpSendRequest(req, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
                                 (LPVOID)json_body.data(), (DWORD)json_body.size(),
                                 (DWORD)json_body.size(), 0);
    if (ok) ok = WinHttpReceiveResponse(req, nullptr);
    if (ok) {
        DWORD avail = 0, got = 0;
        do {
            avail = 0;
            if (!WinHttpQueryDataAvailable(req, &avail) || avail == 0) break;
            std::vector<char> buf(avail + 1, 0);
            if (!WinHttpReadData(req, buf.data(), avail, &got)) break;
            body.append(buf.data(), got);
        } while (avail > 0);
    }
    WinHttpCloseHandle(req); WinHttpCloseHandle(con); WinHttpCloseHandle(ses);
    return body;
#else
    (void)endpoint; (void)json_body;
    return {};
#endif
}

bool OllamaClient::makeStreamingPostRequest(const std::string& endpoint,
                                           const std::string& json_body,
                                           StreamCallback on_chunk,
                                           ErrorCallback on_error,
                                           CompletionCallback on_complete) {
#ifdef _WIN32
    m_cancelStream.store(false);
    std::wstring host;
    unsigned short port = 11434;
    ParseBaseUrl(m_base_url, host, port);
    HINTERNET ses = WinHttpOpen(L"RawrXD-NativeClient/1.0", WINHTTP_ACCESS_TYPE_NO_PROXY,
                                WINHTTP_NO_PROXY_NAME, WINHTTP_NO_PROXY_BYPASS, 0);
    if (!ses) {
        if (on_error) on_error("WinHTTP session open failed");
        return false;
    }
    WinHttpSetTimeouts(ses, 5000, 5000, 120000, 120000);
    HINTERNET con = WinHttpConnect(ses, host.c_str(), port, 0);
    if (!con) {
        WinHttpCloseHandle(ses);
        if (on_error) on_error("WinHTTP connect failed (Ollama down?)");
        return false;
    }
    std::wstring wpath(endpoint.begin(), endpoint.end());
    HINTERNET req = WinHttpOpenRequest(con, L"POST", wpath.c_str(), nullptr, WINHTTP_NO_REFERER,
                                       WINHTTP_DEFAULT_ACCEPT_TYPES, 0);
    if (!req) {
        WinHttpCloseHandle(con); WinHttpCloseHandle(ses);
        if (on_error) on_error("WinHTTP OpenRequest failed");
        return false;
    }
    WinHttpAddRequestHeaders(req, L"Content-Type: application/json\r\n", (ULONG)-1L,
                             WINHTTP_ADDREQ_FLAG_ADD);
    BOOL ok = WinHttpSendRequest(req, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
                                 (LPVOID)json_body.data(), (DWORD)json_body.size(),
                                 (DWORD)json_body.size(), 0);
    if (ok) ok = WinHttpReceiveResponse(req, nullptr);
    if (!ok) {
        WinHttpCloseHandle(req); WinHttpCloseHandle(con); WinHttpCloseHandle(ses);
        if (on_error) on_error("WinHTTP send/receive failed");
        return false;
    }

    std::string acc;
    OllamaResponse finalResp;
    finalResp.done = false;
    bool cancelled = false;
    DWORD avail = 0, got = 0;
    do {
        if (m_cancelStream.load()) { cancelled = true; break; }
        avail = 0;
        if (!WinHttpQueryDataAvailable(req, &avail)) break;
        if (avail == 0) break;
        std::vector<char> buf(avail + 1, 0);
        if (!WinHttpReadData(req, buf.data(), avail, &got) || got == 0) break;
        acc.append(buf.data(), got);
        size_t pos = 0;
        while ((pos = acc.find('\n')) != std::string::npos) {
            std::string line = acc.substr(0, pos);
            acc.erase(0, pos + 1);
            if (line.empty()) continue;
            try {
                json j = json::parse(line);
                if (j.contains("response") && on_chunk) {
                    on_chunk(j["response"].get<std::string>());
                } else if (j.contains("message") && j["message"].contains("content") && on_chunk) {
                    on_chunk(j["message"]["content"].get<std::string>());
                }
                if (j.contains("done") && j["done"].get<bool>()) {
                    finalResp = parseResponse(line);
                    finalResp.done = true;
                }
            } catch (...) {
            }
            if (m_cancelStream.load()) { cancelled = true; break; }
        }
    } while (!cancelled && avail > 0);

    WinHttpCloseHandle(req); WinHttpCloseHandle(con); WinHttpCloseHandle(ses);
    if (cancelled) {
        if (on_error) on_error("cancelled");
        finalResp.done = true;
        finalResp.error = false;
        if (on_complete) on_complete(finalResp);
        return true;
    }
    if (!acc.empty() && on_chunk) {
        try {
            json j = json::parse(acc);
            if (j.contains("response")) on_chunk(j["response"].get<std::string>());
            else if (j.contains("message") && j["message"].contains("content"))
                on_chunk(j["message"]["content"].get<std::string>());
            if (j.contains("done") && j["done"].get<bool>()) {
                finalResp = parseResponse(acc);
                finalResp.done = true;
            }
        } catch (...) {
        }
    }
    if (!finalResp.done) finalResp.done = true;
    if (on_complete) on_complete(finalResp);
    return true;
#else
    (void)endpoint; (void)json_body; (void)on_chunk; (void)on_complete;
    if (on_error) on_error("HTTP backend unavailable: non-Windows build");
    return false;
#endif
}

} // namespace Backend
} // namespace RawrXD
