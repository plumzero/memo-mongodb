
[参考](https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/)

```js
db.collection.deleteOne(
   <filter>,
   {
      writeConcern: <document>,
      collation: <document>,
      hint: <document|string>        // Available starting in MongoDB 4.4
   }
)
```

`filter` 指定了删除规则。如果设置为 `{}` 会删除集合中的第一个文档。


### 行为特征

##### 删除顺序

`db.collection.deleteOne()` 会删除匹配到的第一个文档。

##### 固定集合

如果对固定集合使用 `db.collection.deleteOne()`，会抛出 `WriteError` 异常。

##### 时间序列集合

如果对时间序列集合使用 `db.collection.deleteOne()`，会抛出 `WriteError` 异常。


### 示例

orders 集合:
```js
db.orders.insertOne(
{
   _id: ObjectId("563237a41a4d68582c2509da"),
   stock: "Brent Crude Futures",
   qty: 250,
   type: "buy-limit",
   limit: 48.90,
   creationts: ISODate("2015-11-01T12:30:15Z"),
   expiryts: ISODate("2015-11-01T12:35:15Z"),
   client: "Crude Traders Inc."
}
)
```

通过 `_id: ObjectId("563237a41a4d68582c2509da")` 删除文档:
```js
db.orders.deleteOne( { "_id" : ObjectId("563237a41a4d68582c2509da") } );
```

删除 `expiryts` 大于 `ISODate("2015-11-01T12:40:15Z")` 的文档:
```js
db.orders.deleteOne( { "expiryts" : { $lt: ISODate("2015-11-01T12:40:15Z") } } );
```
