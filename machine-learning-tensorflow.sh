flight start
flight set always on

flight env create conda@ml
flight env activate conda@ml 

conda create -n tensorflow python=3.6
source activate tensorflow
# Installs tensorflow-2.6.2 as of testing 2022/05/04
pip install tensorflow matplotlib pyyaml

mkdir machine-learning-fashion-demo
cd machine-learning-fashion-demo

cat << EOF > fashion-process.py
# Suppress GPU warnings
import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

# TensorFlow and tf.keras
import tensorflow as tf

# Helper libraries
import numpy as np

# Import fashion dataset
fashion_mnist = tf.keras.datasets.fashion_mnist

(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()


# Set class names
class_names = ['T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
               'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot']

# Preprocess data
train_images = train_images / 255.0
test_images = test_images / 255.0

# Setup layers
model = tf.keras.Sequential([
    tf.keras.layers.Flatten(input_shape=(28, 28)),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dense(10)
])

# Compile model
model.compile(optimizer='adam',
              loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
              metrics=['accuracy'])

# Train the model
model.fit(train_images, train_labels, epochs=10)

# Save model
modle.save('fashion_model')
EOF

cat << EOF > fashion-test.py
# Suppress GPU warnings
import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

# TensorFlow and tf.keras
import tensorflow as tf

# Helper libraries
import numpy as np

# Import fashion dataset (for test data)
fashion_mnist = tf.keras.datasets.fashion_mnist

(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

# Set class names
class_names = ['T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
               'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot']

# Import model
model = tf.keras.models.load_model('fashion_model')

# Check accuracy of trained model
test_loss, test_acc = model.evaluate(test_images,  test_labels, verbose=2)

print('\nTest accuracy:', test_acc)
EOF

cat << EOF > fashion-view.py
# Suppress GPU warnings
import os
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"

# TensorFlow and tf.keras
import tensorflow as tf

# Helper libraries
import numpy as np
import matplotlib.pyplot as plt

# Import fashion dataset (for test data)
fashion_mnist = tf.keras.datasets.fashion_mnist

(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

# Set class names
class_names = ['T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat',
               'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot']

# Import model
model = tf.keras.models.load_model('fashion_model')

# Do some visual testing
probability_model = tf.keras.Sequential([model,
                                         tf.keras.layers.Softmax()])
predictions = probability_model.predict(test_images)

def plot_image(i, predictions_array, true_label, img):
  true_label, img = true_label[i], img[i]
  plt.grid(False)
  plt.xticks([])
  plt.yticks([])

  plt.imshow(img, cmap=plt.cm.binary)

  predicted_label = np.argmax(predictions_array)
  if predicted_label == true_label:
    color = 'blue'
  else:
    color = 'red'

  plt.xlabel("{} {:2.0f}% ({})".format(class_names[predicted_label],
                                100*np.max(predictions_array),
                                class_names[true_label]),
                                color=color)

def plot_value_array(i, predictions_array, true_label):
  true_label = true_label[i]
  plt.grid(False)
  plt.xticks(range(10))
  plt.yticks([])
  thisplot = plt.bar(range(10), predictions_array, color="#777777")
  plt.ylim([0, 1])
  predicted_label = np.argmax(predictions_array)

  thisplot[predicted_label].set_color('red')
  thisplot[true_label].set_color('blue')

i = 12
plt.figure(figsize=(6,3))
plt.subplot(1,2,1)
plot_image(i, predictions[i], test_labels, test_images)
plt.subplot(1,2,2)
plot_value_array(i, predictions[i],  test_labels)
plt.show()
EOF
