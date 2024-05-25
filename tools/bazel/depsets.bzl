def play_with_depsets(order):
    # depset (dependencies set) is a data structure that can efficiently store dependencies
    # across dependency tree
    # it's implemented as DAG, so creating new depset is fast
    # converting it to list is O(n)
    # first argument of `depset` is a list of direct dependencies
    # `depset` also takes an optional list of transitive dependencies (depsets)
    # `depset` also takes optional `order`, it can preorder/postorder/topological
    # and it affects result of .to_list()
    stdlib = depset(["argparse.py", "heap.py"], order = order)
    starlette = depset(["starlette.py"], transitive = [stdlib], order = order)
    fastapi = depset(["fastapi.py"], transitive = [starlette, stdlib], order = order)
    app = depset(["app.py"], transitive = [starlette, fastapi, stdlib], order = order)

    # convert depset to list, each dependency will be listed only once
    print("depset(order={}).to_list() = {}".format(order, app.to_list()))
    # expected postorder = argparse.py, heap.py, starlette.py, fastapi.py, app.py
    # expected preorder = app.py, starlette.py, argparse.py, heap.py, fastapi.py
    # expected topological = there's no guarantee which topological order we'll choose
    # creating new depset is efficient, it's just connecting nodes in a DAG
    # if you represented transitive dependencies as a list you could O(n^2) behaviour.
    # app has 3 deps, fastapi has 2 deps, starlette has 1 dep, that's classic quadratic
