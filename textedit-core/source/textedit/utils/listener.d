module textedit.utils.listener;

import std.algorithm.iteration;
import std.array;

/** 
 * A listener that can be cancelled.
 * Note that implementations of this object are allowed
 * to call the `cancel` method when the object is garbage collected,
 * so keep a reference to the listener around.
 */
interface Listener
{
    /**
     * Cancels the listener.
     */
    void cancel();

    /**
     * Returns: `true` if the listener was cancelled, `false` if it wasn't.
     */
    bool isCancelled() const pure;
}

/** 
 * A generic container for listeners.
 * Allows listeners to be added, fired, and removed.
 */
struct ListenerContainer(Arguments...)
{
    alias Callback = void delegate(Arguments);
    private InternalListener[] callbacks;

    /** 
     * Adds an event listener.
     * Params:
     *   callback = The callback to execute when the listener is executed.
     * Returns: A listener object that can be used to cancel the listener.
     */
    Listener add(Callback callback)
    {
        auto listener = new InternalListener(&this, callback);
        callbacks ~= listener;
        return listener;
    }

    /** 
     * Fires each event listener.
     */
    void fire()
    {
        foreach (listener; callbacks)
        {
            listener.fire();
        }
    }

    private class InternalListener : Listener
    {
        private ListenerContainer* _container;
        private Callback _callback;
        private bool _cancelled = false;

        this(ListenerContainer* container, Callback callback)
        {
            _container = container;
            _callback = callback;
        }

        void fire()
        {
            _callback();
        }

        override void cancel()
        {
            if (_cancelled)
                return;
            _cancelled = true;
            InternalListener[] oldCallbacks = _container.callbacks;
            _container.callbacks = oldCallbacks
                .filter!(listener => listener !is this)
                .array();
        }

        override bool isCancelled() const pure
        {
            return _cancelled;
        }
    }   
}

@("ListenerContainer#fire fires event")
unittest
{
    ListenerContainer!() container;
    int count = 0;
    const listener = container.add({count++;});
    assert(listener.isCancelled == false);
    container.fire();
    assert(count == 1);
}

@("Listener#cancel cancels event")
unittest
{
    ListenerContainer!() container;
    int count = 0;
    auto listener = container.add({count++;});
    assert(listener.isCancelled == false);
    listener.cancel();
    container.fire();
    assert(listener.isCancelled == true);
    assert(count == 0);
}

@("Listener can cancel itself")
unittest
{
    ListenerContainer!() container;
    int countA, countB, countC;
    Listener listenerA, listenerB, listenerC;
    listenerA = container.add({countA++;});
    listenerB = container.add({countB++; listenerB.cancel();});
    listenerC = container.add({countC++;});
    container.fire();
    container.fire();
    assert(countA == 2);
    assert(countB == 1);
    assert(countC == 2);
}