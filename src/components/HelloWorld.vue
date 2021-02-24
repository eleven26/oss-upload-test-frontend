<template>
  <div>
    <el-upload
        :action="policy.url"
        multiple
        :data="data"
        :before-upload="beforeUpload"
        list-type="picture-card"
        :limit="3">
      <i class="el-icon-plus"></i>
      <div slot="tip" class="el-upload__tip">最多只能上传3张图片，第一次上传完之后，如果过了10秒再请求，会重新获取 policy 数据（后端的 policy 过期时间为 10 秒）</div>
    </el-upload>
    <p>上传的图片地址：<br/>
      <span v-for="item in fileList" :key="item">
        <el-link :href="item" target="_blank">{{ item }}</el-link>
      </span>
    </p>
  </div>
</template>

<script>
import SparkMD5 from 'spark-md5'
const axios = require('axios').default

export default {
  name: 'HelloWorld',
  data() {
    return {
      fileList: [],
      // 存储上一次获取的 policy 数据，如果尚未过期可以继续使用，已经过期需要重新获取
      policy: {
        access_id: '',
        url: '',
        policy: '',
        signature: '',
        expire: 0,
        callback: '',
        dir: ''
      },
      data: {
        key: '',
        policy: '',
        OSSAccessKeyId: '',
        success_action_status: '200',
        signature: '',
        // callback: ''
      }
    }
  },
  methods: {
    async beforeUpload(file) {
      const extension = file.type.split('/').pop()

      // 获取 policy 数据
      const policy = await this.getPolicy()
      this.data.policy = policy.policy
      this.data.OSSAccessKeyId = policy.access_id
      this.data.signature = policy.signature

      return new Promise(resolve => {
        // 使用 md5 获取文件 hash 值作为文件名
        const reader = new FileReader();
        reader.addEventListener("loadend", () => {
          // reader.result 包含被转化为类型数组 typed array 的 blob
          const md5 = SparkMD5.ArrayBuffer.hash(reader.result)
          this.data.key = `${policy.dir}${md5}.${extension}`
          this.fileList.push(this.url)
          resolve()
        });
        reader.readAsArrayBuffer(file);
      })
    },
    async getPolicy() {
      // 尚未获取过 policy 或者上次获取的已经过期就才调用接口获取
      if (this.policy.expire === 0 || this.policy.expire <= Math.floor((new Date).getTime() / 1000)) {
        this.policy = (await axios.get('http://oss-backend.baiguiren.com/oss-upload/policy')).data
      }

      return this.policy
    }
  },
  computed: {
    url() {
      return `${this.policy.url}/${this.data.key}`
    }
  }
}
</script>

<style scoped>

</style>
