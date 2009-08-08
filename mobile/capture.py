import camera, appuifw, e32  

WHITE = (255,255,255)  

def viewfinder(img):
  img.rectangle((100,100,300,300), outline = WHITE)  
  img.text((250, 250), u'This is the output', fill = WHITE)  
  canvas.blit(img)  
  
def update_view():
  self.imgview.text((200, 200), u'Updated', fill = WHITE)
  canvas.blit(self.imgview)  

def quit():
  camera.stop_finder()
  lock.signal()  

appuifw.app.body = canvas = appuifw.Canvas()  
appuifw.app.exit_key_handler = quit  
camera.start_finder(viewfinder, size=(800, 600))  
lock = e32.Ao_lock()  
lock.wait()  


