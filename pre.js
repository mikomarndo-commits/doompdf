var Module = {};
let framebuffer_img = document.getElementById("framebuffer_img");
let main_table = document.getElementById("main_table");

let img_data = null;
let img_header = new Uint8Array(54);
let blob_url = null;
let key_queue = [];

document.addEventListener("keydown", (event) => {
  if (event.keyCode === 9) {
    event.preventDefault();
    event.stopImmediatePropagation();
    document.body.focus();
  }
  let doomkey = _key_to_doomkey(event.keyCode);
  key_queue.push([doomkey, 1]);
});
document.addEventListener("keyup", (event) => {
  let doomkey = _key_to_doomkey(event.keyCode);
  key_queue.push([doomkey, 0]);
});

function create_framebuffer(width, height) {
  let bitmap_size = width * height * 4;
  let size = img_header.length + bitmap_size;
  let view = new DataView(img_header.buffer);

  //bmp header
  view.setUint16(0x00, 0x424d);
  view.setUint32(0x02, size, true);
  view.setUint32(0x0a, img_header.length, true);
  
  //dib header
  view.setUint32(0x0e, 40, true);
  view.setInt32(0x12, width, true);
  view.setInt32(0x16, -height, true);
  view.setUint16(0x1a, 1, true);
  view.setUint16(0x1c, 32, true);

  view.setUint32(0x22, bitmap_size, true);

  img_data = new Uint8Array(size);
  img_data.set(img_header);
}

function update_framebuffer(framebuffer_ptr, framebuffer_len) {
  let framebuffer = Module.HEAPU8.subarray(framebuffer_ptr, framebuffer_ptr + framebuffer_len);
  img_data.set(framebuffer, img_header.length);

  if (blob_url) 
    URL.revokeObjectURL(blob_url);
  let blob = new Blob([img_data], {type: "image/bmp"});
  blob_url = URL.createObjectURL(blob);
  framebuffer_img.src = blob_url;
}

Module.preRun = () => {
  ENV.TIMIDITY_CFG = "dgguspat/timid_d1.cfg"
};

