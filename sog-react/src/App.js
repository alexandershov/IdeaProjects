import './App.css';
import {useState} from 'react'

// react allows to build web apps using components
// creating react app from scratch is tedious (you need webpack, babel, etc)
// Here I've just used IDEA to create react project

// your write components using functions
function Button() {
    // count is the current state
    // setCount is a function to change state
    const [count, setCount] = useState(0);

    function handleClick() {
        setCount(count + 1);
    }

    // this is not a plain javascript, this is jsx
    // jsx is javascript + markup
    return <button onClick={handleClick}>Count = {count}</button>
}

// react maintains virtual dom and figures out which parts of the page
// need rerendering

function App() {
    // you can nest components, Button is component, because it is capitalized
    return (
        <div className="App">
            <Button/>
            <Button/>
        </div>
    );
}

export default App;
