#include <iostream>
#include <stdio.h>
#include <string.h>
#include "webview/webview.h"
#include "nlohmann/json.hpp"
#include "bundle-webview-js.h"
#include "webview/menu.h"

using json = nlohmann::json;

extern "C" {
    extern void do_a_conversion(char *, char *, char *);
}

extern char log_buffer[4096];
extern char *log_buffer_ptr;

webview::webview *wp;

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

std::string copy(std::string j) {
	std::cout << "copy called " << j << '\n';
	return "undefined";
}

void callback(const char *ev) {
	std::cout << "menu event " << ev << "\n";
	std::string_view str = ev;

    if (str == "copy") {
		wp->eval("document.execCommand('copy');");
	} else if (str == "cut") {
		wp->eval("document.execCommand('cut');");
	} else if (str == "paste") {
		wp->eval("document.execCommand('paste');");
	} else if (str == "close") {
		exit(0);
	} else if (str == "undo") {
		wp->eval("document.execCommand('undo');");
	} else if (str == "redo") {
		wp->eval("document.execCommand('redo');");
	} else if (str == "select_all") {
		wp->eval("document.execCommand('selectAll');");
	}
}


extern char g_argv_0[128];

int main(int argc, char **argv) {
    strlcpy(g_argv_0, argv[0], 128);
    // cookie_io_functions_t iofns = {NULL};
    // iofns.cookie_write_function_t = writer;
    //
    // stdout = fopencookie(NULL, "r", iofns);
    
    try {
        webview::webview w(true, nullptr);
		wp = &w;
        w.set_title("Units");
        w.set_size(480, 320, WEBVIEW_HINT_MIN);
        w.bind("convert", convert);
		w.bind("copy", copy);
		w.eval("window.webview = {};");
        w.set_html(get_html());
        // w.navigate("http://localhost:8000/index-webview.html");

		webview_menu_item menu[] = {
				{0, "File", "", ""},
				{1, "Open", "C-o", "open"},
				{1, "Save", "C-s", "save"},
				{1, "New", "C-n", "new"},
				{1, "-"},
				{1, "Close Window", "C-w", "close"},
				{0, "Edit", "", ""},
                {1, "Undo", "C-z", "undo"},
                {1, "Redo", "CS-z", "redo"},
                {1, "-"},
				{1, "Cut", "C-x", "cut"},
				{1, "Copy", "C-c", "copy"},
                {1, "Paste", "C-v", "paste"},
                {1, "Select All", "C-a", "select_all"},
		};

		webview_set_menu(sizeof(menu) / sizeof(menu[0]), menu, callback);

        w.run();
    } catch (const webview::exception &e) {
        std::cerr << e.what() << std::endl;
        return 1;
    }

    
	return 0;
}
