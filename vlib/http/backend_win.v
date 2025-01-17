// Copyright (c) 2019 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module http


#flag windows -I @VROOT/thirdparty/vschannel
#flag -l ws2_32
#flag -l crypt32
#flag -l secur32
 
#include "vschannel.c"

fn C.new_tls_context() C.TlsContext

fn init() int { return 1 }

fn (req &Request) ssl_do(port int, method, host_name, path string) ?Response {
	mut ctx := C.new_tls_context()
	C.vschannel_init(&ctx)

	mut buff := malloc(C.vsc_init_resp_buff_size)
	addr := host_name
	sdata := req.build_request_headers(method, host_name, path)
	length := int(C.request(&ctx, port, addr.to_wide(), sdata.str, &buff))

	C.vschannel_cleanup(&ctx)
	return parse_response(string(buff, length))
}
