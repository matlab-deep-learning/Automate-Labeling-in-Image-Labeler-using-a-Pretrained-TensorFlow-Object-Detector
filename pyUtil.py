# This Python helper file contains functions to load the deep learning model and
# perform predictions. These functions will be called via the custom automation
# algorithm in MATLAB.

import tensorflow as tf
tf.get_logger().setLevel('ERROR')

def createModel():
    # load the pre-trained model
    detector = tf.saved_model.load('efficientdet_d1_1/')
    return detector

def detect(model,inp):
    # Helper function to rehsape images and perform the predition
    img = tf.convert_to_tensor(inp)
    detector_output = model(img)
    return detector_output
    
def testHelper():
   # This function is used to test the helper file by feeding the model a random image. 
    detector = createModel()
    img = tf.random.uniform([1,640,640,3])
    img_uint8 = tf.cast(img, tf.uint8)
    out = detect(detector, img_uint8)
    return out
