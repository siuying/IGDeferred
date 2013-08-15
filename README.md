# IGDeferred

A chainable defer object that can register multiple callbacks into callback queues, 
invoke callback queues, and relay the success or failure state of any sync or async function.

## Usage

Use IGDeferred object relay callbacks.

```objective-c
    __block IGDeferred* deferred = [[IGDeferred alloc] init];

    deferred.progress(^(id progress){
        [view showProgress:progress]
    }).done(^(id value){
        [view showCompleted:value]
    });

    // after some long running task, call resolve() or reject()
    // which will trigger callbacks registered via done(), fail(), always() or then()
    deferred.resolve(value_from_remote);

```

Use IGMultiDeferred to chain multiple deferreds:

```objective-c
    IGMultiDeferred* multiDeferred = [[IGMultiDeferred alloc] init];
    multiDeferred
      .add(deferred1)
      .add(deferred2)
      .add(deferred3)
      .done(^(id obj){
        // will be called when all deferred resolved
      })
      .fail(^(id obj){
        // will be called when any deferred rejected
      });
```


## License

This software is licensed in MIT License.