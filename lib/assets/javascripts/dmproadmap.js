window.DMPROADMAP = (function(){
    return {
        /*
            Delays invoking of the function passed until after wait milliseconds have elapsed since
            the last time the debounced function was invoked.
            @param {function} func - the function to execute later on
            @param {number} wait - the number of milliseconds to wait until func is executed
            @returns The debounced function. It comes with a cancel method to cancel delayed func invocation
        */
        debounce: function(func, wait){
            var timeoutID = null;
            function cancel() {
                if(timeoutID !== null){
                    clearTimeout(timeoutID);
                    return true;
                }
                return false;    
            }
            return (function() {
                var debounced = function() {
                    var ctx = this;
                    var args = arguments;
                    var later = function() {
                        timeoutID = null;
                        func.apply(ctx, args);
                    }
                    clearTimeout(timeoutID);
                    timeoutID = setTimeout(later, wait || 5000);
                }
                debounced.cancel = cancel;
                return debounced;
            })();
        }
    };
})();