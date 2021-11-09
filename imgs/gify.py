import numpy as np
import PIL
from PIL import Image

files = ['hijacking_path_lorawan_globecom.jpg', 'hijacking_path_lorawan_globecom (1).jpg', 'hijacking_path_lorawan_globecom (2).jpg', 'hijacking_path_lorawan_globecom (3).jpg', 'hijacking_path_lorawan_globecom (4).jpg', 'hijacking_path_lorawan_globecom (5).jpg']

ims = [Image.open(file).crop((50,65,940,470)) for file in files]
F = 1700  #milliseconds

ims[0].save(
	"out.gif",
	save_all=True,
	append_images=ims[1:],
	duration=[F,F,F,F,F,2*F],
	loop=10
	)

