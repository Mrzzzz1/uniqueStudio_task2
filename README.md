# uniqueStudio_task2

## 4.9
查了一下哪些东西可以用，哪些需要自己写，确定了基本思路。

## 4.10
确定了基本框架，实现了入口和运用相机拍照。

## 4.11
原本想先写从相册选择图片部分，后发现细节和难点较多，写了裁剪部分，想了很久如何实现图片拖拽，以前看文档以为scrollView只能单向滑动，原来缩放后可以向各个方向拖拽，，，还有一些细节没有完成。

## 4.12
昨天写了裁剪部分没有调试。。。今天发现了无数个bug,特别是自动布局和绝对布局的混用导致了很多bug，应该更加深入的学习他们的关系。还有cgimage.cropping(),原本以为rect是相对于view而言，结果是相对于image。经过测试发现scrollview缩放时subview.frame不变image.size不变，而scrollview的contentSize和contentOffset会变。最终找到了坐标关系。裁剪后image会旋转的问题在简书上找到了解决办法
