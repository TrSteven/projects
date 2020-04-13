import pandas as pd
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
from sklearn import decomposition

# Load labeled data
labeled_images = pd.read_csv('data/train.zip')
images = labeled_images.iloc[0:5000,1:]
labels = labeled_images.iloc[0:5000,:1]

# Split in train and test
# Deep copy to avoid SettingWithCopyWarning
train_images, test_images, train_labels, test_labels = \
    map(lambda x: x.copy(deep = True),
    train_test_split(images, labels, train_size=0.8, random_state=0))

# Plot some numbers
def plot_number(images_df, index, reshape_size = 28):
    img = images_df.iloc[index].values
    img = img.reshape((reshape_size, reshape_size))
    plt.imshow(img, cmap='gray')
    plt.title(train_labels.iloc[index,0])   
    plt.show()

plot_number(train_images, 50)
plot_number(train_images, 100)

# Scale data so values are between 0 and 1
train_images /= 255
test_images /= 255 

#######
# SVM #
#######

clf_svc = SVC(max_iter=1e4).fit(train_images, train_labels.values.ravel())
clf_svc.score(test_images, test_labels)

test_labels_pred = clf_svc.predict(test_images)
pd.crosstab(test_labels.values.ravel(), test_labels_pred, 
            rownames=['True'], colnames=['Predicted'], margins=True)

#############
# PCA + SVM #
#############

pca = decomposition.PCA(n_components=90, copy = True, random_state = 0)
pca.fit(train_images)
train_images_pca = pca.transform(train_images)
test_images_pca = pca.transform(test_images)

# Train model
clf_pca_svc = SVC(max_iter=1e4).fit(train_images_pca, train_labels.values.ravel())
clf_pca_svc.score(test_images_pca, test_labels)

test_labels_pred_pca = clf_pca_svc.predict(test_images_pca)
pd.crosstab(test_labels.values.ravel(), test_labels_pred_pca, 
            rownames=['True'], colnames=['Predicted'], margins=True)










