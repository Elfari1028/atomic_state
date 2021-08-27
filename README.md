# atom_state

A helper package for 
- global & modular state management.
- automatic `setState` calls for your widget
- potentially reduce the number of `StatefulWidgets`

## Usage

### Use AtomicState to allow auto `setState`, and use state data across all widgets globally 

in regular StatefulWigets, we would usually encoutner code like:
```dart
class Home extends StatefulWidget{
    createState() => HomeState();
}

class HomeState extends State<Home>{

    int counter;
    
    @override
    Widget build(BuildContext) {
        return Container();
    }
}
```
with Atom State, it looks a bit like this

```dart
class HomeState extends AtomicState<Home>{
    
    // `register` is automatically called at the end of `initState()`
    // you can leave a blank implementation of this function and call manageent
    // `registeredTags` contains a list of state names that already exist at the time of calling this function, use them if you need to.
    @override
    void register(List<String> registeredTags){
        // subscribe to a state, or multiple states, so that you any changes in its memeber will trigger a setState of this instance automatically!
        // for safety measures, you will not be allowed to access a state member with helper functions inside `AtomicState` unless you have subscribed to it
        // you can still access unsubscribed state members with `Atom`, just make sure you know what you're doing.
        bindTag("home");
        // `deleteOldState is `false` by default, when it's true, a brand new empty state will be generated and replace the old state (if there was one).  `
        // `setStateCallback` is the function that is passed as the parameter to `setState( Function() fn )`, it will be used when `setState` is called by AtomicState
        bindTag("account",deleteOldState:true, setStateCallback: (){} );
    
        // you can subscribe to states in batch
        bindTags(["download","message"],deleteOldState:false,setStateCallback:(){});


        // initialize some members with helper functions
        // note: passing `null` will do nothing to value, to set a value to null, please use `setNull(stateName,valueName)`
        integer("home","counter", 0);
        string("home","title","Atom Demo");
        value<Map>("home","map_data", {"name":"my name"});
        value<MyObjcet>("home","myobject", MyObject());

        // you can retrieve them later in the same way, just omit the last parameter, see below for examples

        // you can register some callbacks for specific values when they are mutated, which will be called both before and after the mutation
        // globally, there can be only one callback to one member, therefore, latter registered callbacks to override the previous one.
        // set it to null to remove callbacks.
        onBeforeMemberUpdate("home", "counter", (oldVal, newVal) {
            debugPrint("before update! $oldVal -> $newVal");
        });
        onAfterMemberUpdate("home", "counter", null);
    }

    // for easier usage, you can choose to implememnt a getter and setter for the values you need
    // you can access value through the same helper function (only in you are subsribed, or else you will get a runtime error)
    int get counter => integer("home","counter") 
    set counter(int val) => integer("home","counter",val);
    // you can use it like it's a local variable now!

    // for unsubscribed states, you can access it like this:
    Map get data => Atom.getState("global")?.value<Map>("info") ?? {"default":0};
    set data(val) => Atom.getState("global")?.put("info",val);
    
    @override
    Widget build(BuildContext) {
        // you can unsubcribe through: 
        unbindTag("home");
        // you can DELETE a state, too. just make sure you know what you are doing.
        deleteTag("home");
        
        return Container();
    }

}
```

### Wrap your root widget in AtomRootWidget and don't worry about using StatefulWiget ever again