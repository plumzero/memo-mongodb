
### 参考

- [事务](https://docs.mongodb.com/manual/core/transactions/)


### 辅助语句

同数据库下的集合复制:
```js
    db.mid_orders.find().forEach(function(x){db.bak_mid_orders.insert(x)})
    db.big_orders.find().forEach(function(x){db.bak_big_orders.insert(x)})
```
