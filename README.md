# uniqueStudio_task2

## 4.9
查了一下哪些东西可以用，哪些需要自己写，确定了基本思路。

## 4.10
确定了基本框架，实现了入口和运用相机拍照。

## 4.11
原本想先写从相册选择图片部分，后发现细节和难点较多，写了裁剪部分，想了很久如何实现图片拖拽，以前看文档以为scrollView只能单向滑动，原来缩放后可以向各个方向拖拽，，，还有一些细节没有完成。

## 4.12
昨天写了裁剪部分没有调试。。。今天发现了无数个bug,特别是自动布局和绝对布局的混用导致了很多bug，应该更加深入的学习他们的关系。还有cgimage.cropping(),原本以为rect是相对于view而言，结果是相对于image。经过测试发现scrollview缩放时subview.frame不变image.size不变，而scrollview的contentSize和contentOffset会变。最终找到了坐标关系。裁剪后image会旋转的问题在简书上找到了解决办法

## 4.13
今天课比较多，只实现了图库授权和从图库中获取照片的一小部分。

## 4.14
实现了从相册获取图片并显示，照片可以选取和裁剪。但还未实现传值，由于图片获取是异步的所以第一次选完后并不能展示。准备明天解决这个问题并实现图片添加实时更新和传值，如果有时间再实现相册分类显示。

## 4.15
实现了实时更新增加的照片，但增加后之前选中的会被清空，实现了controller间传值，还未实现不同文件夹的相册显示和根据业务方条件选择。
## 4.16
除判断图片是否合格外基本实现了需求。解决了一些之前没遇到过的bug。
## 4.17
摸鱼。
## 4.18
使用代理实现了由业务方选择图片为单选或多选以及判断图片是否合格。