
[first参考](https://docs.mongodb.com/manual/reference/operator/aggregation/first/)

版本 >= 5.0

返回将表达式应用于一组聚合文档中的第一个文档而产生的值。只在文档定义排序之后有意义。

### 语法

```js
{ $first: <expression> }
```

### 行为特征

当 `$first` 应用于 `$group` 阶段时，为了让文档有序，需要在进行 `$group` 阶段之前进行 `$sort` 阶段。


### 示例

在 `$group` 阶段中使用。

测试集合如下:
```js
db.sales.insertMany([
    { "_id" : 1, "item" : "abc", "price" : 10, "quantity" : 2, "date" : ISODate("2014-01-01T08:00:00Z") },
    { "_id" : 2, "item" : "jkl", "price" : 20, "quantity" : 1, "date" : ISODate("2014-02-03T09:00:00Z") },
    { "_id" : 3, "item" : "xyz", "price" : 5, "quantity" : 5, "date" : ISODate("2014-02-03T09:05:00Z") },
    { "_id" : 4, "item" : "abc", "price" : 10, "quantity" : 10, "date" : ISODate("2014-02-15T08:00:00Z") },
    { "_id" : 5, "item" : "xyz", "price" : 5, "quantity" : 10, "date" : ISODate("2014-02-15T09:05:00Z") },
    { "_id" : 6, "item" : "xyz", "price" : 5, "quantity" : 5, "date" : ISODate("2014-02-15T12:05:10Z") },
    { "_id" : 7, "item" : "xyz", "price" : 5, "quantity" : 10, "date" : ISODate("2014-02-15T14:12:12Z") }
])
```
以 "item" 作为分组字段，接下来的操作会使用 `$first` 累加器来计算出每个 "item" 的第一个销售日期:
```js
db.sales.aggregate(
   [
     { $sort: { item: 1, date: 1 } },
     {
       $group:
         {
           _id: "$item",
           firstSalesDate: { $first: "$date" }
         }
     }
   ]
)
```
上面的操作一共进行了两个阶段。
- 第一阶段: 通过 `$sort` 对 "item" 和 "date" 进行排序。事实上，由于后面要对 "item" 进行分组，且只要求返回每个分组的第一个销售日期，所以这里对 "item" 的排序是可以省略的。
- 第二阶段: 通过 `$group` 对 "item" 字段进行分组，并返回各分组中的第一个销售日期。
