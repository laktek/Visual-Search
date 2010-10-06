# Copyright (c) 2007 Nokia Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# viewfinder.py - shows viewfinder on the screen
#

import appuifw 
import camera
from graphics import *
import e32
import key_codes
import datetime
import httplib
import mimetypes

class ViewFinder:
    def __init__(self):
        self.script_lock = e32.Ao_lock()
        self.timer = e32.Ao_timer()
        self.finder_on=0
        self.status_text=None
        self.results_text=None

    def run(self):
        old_title = appuifw.app.title
        self.refresh()
        self.script_lock.wait()
        appuifw.app.title = old_title
        appuifw.app.body = None

    def refresh(self):
        appuifw.app.title = u"Visual Search"
        appuifw.app.menu = [(u"Tag", self.tag_image),
            (u"Find", self.find_with_image),
            (u"Exit", self.do_exit)]
        appuifw.app.directional_pad = False
        appuifw.app.exit_key_handler = self.exit_key_handler
        appuifw.app.body=self.canvas=appuifw.Canvas()
        self.screen_image = Image.new((500,375), mode='RGB')
        self.canvas.bind(key_codes.EButton1Up, self.find_with_image)
        self.start_finder()
        self.finder_on=1

    def tag_image(self):
        self.tag_value = appuifw.query(u"Tag", 'text')
        self.current_action = "tag"
        self.status_text = u"Please focus on the image"
        self.timer.after(5, self.save_image)
        
    def find_with_image(self, (event)):
        self.current_action = "find"
        self.save_image()

    def save_image(self):
        self.timer.cancel()
        img = self.current_image
        self.status_text = u"Saving..."
        today = datetime.datetime.now()
        timestamp = today.strftime("%Y%m%d%H%M%S")
        self.filename = u"E:\\data\\visual_search\\images\\%s.jpg" % (timestamp)
        img.save(self.filename, callback=self.upload_image)  

    def upload_image(self, error_code):
        self.status_text = u"Uploading..."
        image_data = file(self.filename).read()
        if self.current_action == "find":
          #home
          #response = self.post_multipart("192.168.16.70:4567", "/search", [], [('tag_image', self.filename, image_data)])
          #response = self.post_multipart("127.0.0.1", "/upload_test.php", [], [('tag_image', self.filename, image_data)])

          #uni
          response = self.post_multipart("10.42.43.1:4567", "/search", [], [('tag_image', self.filename, image_data)])
        elif self.current_action == "tag":
          #response = self.post_multipart("192.168.16.70:4567", "/tag", [('tag_name', self.tag_value)], [('tag_image', self.filename, image_data)])

          response = self.post_multipart("10.42.43.1:4567", "/tag", [('tag_name', self.tag_value)], [('tag_image', self.filename, image_data)])

          #response = self.post_multipart("127.0.0.1", "/upload_test.php", [], [('tag_image', self.filename, image_data)])
        self.show_results(response)

    def show_results(self, response):
        self.status_text = None
        self.results_text = unicode(response.strip()) 

    def stop_finder(self):
        camera.stop_finder()
        self.finder_on=0
        appuifw.note(u"Viewfinder stopped")

    def start_finder(self):
        if (not self.finder_on):
            camera.start_finder(self.show_final_image, size=(500,375))
            self.finder_on=1
        else:
            appuifw.note(u"Viewfinder already on")

    def transform_image(self, image_frame):
        self.screen_image.blit(image_frame)
        self.screen_image.transpose(ROTATE_90, callback=self.show_final_image)

    def show_final_image(self, img):
        if self.status_text:
          #image_frame.rectangle([(10,20),(50, 20)],fill=0xFF0000)
          img.text((10,30), self.status_text, fill=(255, 255, 255))
        if self.results_text:
          #image_frame.rectangle([(100, 100),(250, 220)],fill=0xC8C8C8)
          img.text((150,150), self.results_text, fill=(255, 255, 255))
        if (not img == None):
          self.canvas.blit(img, target=(00,10))
          self.current_image = img

    def do_exit(self):
        self.exit_key_handler()

    def exit_key_handler(self):
        camera.stop_finder()
        self.canvas=None
        appuifw.app.exit_key_handler = None
        self.script_lock.signal()

    def post_multipart(self, host, selector, fields, files):
        """
        Post fields and files to an http host as multipart/form-data.
        fields is a sequence of (name, value) elements for regular form fields.
        files is a sequence of (name, filename, value) elements for data to be uploaded as files
        Return the server's response page.
        """
        content_type, body = self.encode_multipart_formdata(fields, files)
        h = httplib.HTTP(host)
        h.putrequest('POST', selector)
        h.putheader('content-type', content_type)
        h.putheader('content-length', str(len(body)))
        h.endheaders()
        h.send(body)
        errcode, errmsg, headers = h.getreply()
        return h.file.read()

    def encode_multipart_formdata(self, fields, files):
        """
        fields is a sequence of (name, value) elements for regular form fields.
        files is a sequence of (name, filename, value) elements for data to be uploaded as files
        Return (content_type, body) ready for httplib.HTTP instance
        """
        BOUNDARY = '----------ThIs_Is_tHe_bouNdaRY_$'
        CRLF = '\r\n'
        L = []
        for (key, value) in fields:
            L.append('--' + BOUNDARY)
            L.append('Content-Disposition: form-data; name="%s"' % key)
            L.append('')
            L.append(value)
        for (key, filename, value) in files:
            L.append('--' + BOUNDARY)
            L.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename))
            L.append('Content-Type: %s' % self.get_content_type(filename))
            L.append('')
            L.append(value)
        L.append('--' + BOUNDARY + '--')
        L.append('')
        from cStringIO import StringIO
        file_str = StringIO()
        for i in range(len(L)):
          file_str.write(L[i])
          file_str.write(CRLF)
        body = file_str.getvalue()
        content_type = 'multipart/form-data; boundary=%s' % BOUNDARY
        return content_type, body

    def get_content_type(self, filename):
        return 'application/octet-stream'

if __name__ == '__main__':
    ViewFinder().run()
