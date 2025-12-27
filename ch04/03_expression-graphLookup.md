
[参考](https://docs.mongodb.com/manual/reference/operator/aggregation/graphLookup/#mongodb-pipeline-pipe.-graphLookup)

在一个集合上执行递归搜索，并可以通过递归深度和查询过滤器来限制搜索。

`$graphLookup` 搜索过程总结如下:
1. 输入文档流入聚合操作的 `$graphLookup` 阶段。
2. `$graphLookup` 搜索目标集合，目标集合通过 `from` 参数指定。
3. 对于每个输入文档，搜索开始处的值通过 `startWith` 指定。
4. `$graphLookup` 将 `startWith` 值与参数 `connectToField` 指定的 `from` 集合中其他文档中的字段进行比较，是否匹配。
5. 对于每个匹配的文档，`$graphLookup` 获取 `connectFromField` 的值，并检查 `from` 集合中的每个文档是否有一个匹配的 `connectToField` 值。