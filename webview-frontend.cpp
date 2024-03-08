#include <iostream>
#include <stdio.h>
#include "webview/webview.h"
#include "nlohmann/json.hpp"
#include "bundle-webview-js.h"

using json = nlohmann::json;

extern "C" {
    extern void do_a_conversion(char *, char *, char *);
}

extern char log_buffer[4096];
extern char *log_buffer_ptr;


std::string convert(std::string arg) {
	std::cout << "Params: " << arg << std::endl;
    json j = json::parse(arg);
    
    auto from = j[0].template get<std::string>(),
        to = j[1].template get<std::string>(),
        system = j[2].template get<std::string>();
        
    std::cout << from << ' ' << to << std::endl;
    
    do_a_conversion((char *)from.data(), to.size() > 0 ? (char *)to.data() : nullptr, (char *)system.data());
    std::string res = json(std::string(log_buffer, log_buffer_ptr - log_buffer)).dump();
    log_buffer_ptr = log_buffer;
    std::cout << res << std::endl;
    return res;
}

std::string get_html() {
    return std::string("<div id=app></div><script>") + std::string((const char *)bundle_webview_js, bundle_webview_js_len) + std::string("</script>");
}

#ifdef WIN32
int WINAPI WinMain(HINSTANCE hInt, HINSTANCE hPrevInst, LPSTR lpCmdLine,
                   int nCmdShow) {
#else
int main() {
#endif
    // cookie_io_functions_t iofns = {NULL};
    // iofns.cookie_write_function_t = writer;
    //
    // stdout = fopencookie(NULL, "r", iofns);
    
    try {
        webview::webview w(false, nullptr);
        w.set_title("Units");
        w.set_size(480, 320, WEBVIEW_HINT_NONE);
        w.bind("convert", convert);
        w.set_html(get_html());
        // w.navigate("http://localhost:8000/index-webview.html");
        w.run();
    } catch (const webview::exception &e) {
        std::cerr << e.what() << std::endl;
        return 1;
    }

    
	return 0;
}
