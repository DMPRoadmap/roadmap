import { useState, useEffect, useRef } from "react";

import { DmpApi } from "../api.js";
import { useDebounce } from "../utils.js";
import Spinner from "./spinner.js";
import "./typeahead.scss";


const DEBOUNCE_TIMEOUT_MS = 100;

function TypeAhead(props) {
    const [suggestions, setSuggestions] = useState([]);
    const [showSuggestionSpinner, setShowSuggestionSpinner] = useState(false);
    const [selected, setSelected] = useState('');
    const [activeDescendentId, setActiveDescendentId] = useState(null);
    const [otherSelected, setOtherSelected] = useState(false)
    const debounceQuery = useDebounce(props.inputValue, 500);

    const [open, setOpen] = useState(false);
    const [currentListItemFocused, setCurrentListItemFocused] = useState(-1);

    let isDropDownOpen = false;

    function openDropdown(e) {
        isDropDownOpen = true;
        setOpen(true);
        setCurrentListItemFocused(-1);
    }

    const inputRef = useRef(null);
    const listRef = useRef(null);

    const toggleDropDown = (e) => {
        e.preventDefault();
        if (!isDropDownOpen) {
            setOpen(true);
        } else {
            setOpen(false);
            setActiveDescendentId('');
        }
    }

    const handleSelection = (e) => {
        const item = e.target.innerText || e.target.value;
        setSelected(item);
        setCurrentListItemFocused(-1);
        isDropDownOpen = false;

        if (inputRef && inputRef.current) {
            inputRef.current.focus();
        }

        if (item.toLowerCase() === 'other') {
            props.setOtherField(true);
            setOtherSelected(true);
        } else {
            props.setOtherField(false);
            setOtherSelected(false);
        }

        handleInputChange(e, 'repository', item);
    }

    const focusListItem = (index) => {
        setCurrentListItemFocused(index);
        if (listRef.current) {
            const listItems = listRef.current.querySelectorAll('.autocomplete-item');
            const listItem = listItems[index];
            if (listItem) {
                listItem.focus();
                setActiveDescendentId(listItem.id);
            }
        }
    };

    const handleKeyboardEvents = (e) => {
        let itemToFocus = null;
        let listItems = [];
        if (listRef && listRef.current) {
            // Convert NodeListOf<ChildNode> to an array of HTMLElement
            listItems = listRef.current.childNodes;
        }


        //Prevent default if needed
        if (["ArrowUp", "ArrowDown", "Enter"].includes(e.key)) {
            e.preventDefault();
        }

        switch (e.key) {
            case "ArrowDown":
                if (currentListItemFocused < listItems.length - 1) {
                    setCurrentListItemFocused(currentListItemFocused + 1);
                    if (!isDropDownOpen) {
                        setOpen(true);
                    }
                    focusListItem(currentListItemFocused + 1);
                }
                break;

            case "ArrowUp":
                if (currentListItemFocused > 0) {
                    setCurrentListItemFocused(currentListItemFocused - 1);
                    focusListItem(currentListItemFocused - 1);
                } else {
                    setCurrentListItemFocused(-1);
                    setActiveDescendentId('');
                    props.setOtherField(false);
                    setOtherSelected(false);
                    if (inputRef && inputRef.current) {
                        inputRef.current.focus();
                    }
                }
                break;
            case 'Enter':
                if (currentListItemFocused !== -1) {
                    setCurrentListItemFocused(-1);
                    setActiveDescendentId('');
                    props.setOtherField(false);
                    setOtherSelected(false);
                    if (inputRef && inputRef.current) {
                        inputRef.current.focus();
                    }
                    handleSelection(e)
                }
                break;
            case 'Backspace':
                setCurrentListItemFocused(-1);
                setActiveDescendentId('');
                if (!isDropDownOpen) {
                    setOpen(true);
                }
                handleSelection(e)

                break;
            case 'Home':
                if (currentListItemFocused > 0) {
                    setCurrentListItemFocused(-1);
                    setActiveDescendentId('');
                    focusListItem(0);
                }
                break;
            case 'End':
                if (currentListItemFocused < listItems.length - 1) {
                    setCurrentListItemFocused(listItems.length - 1);
                    focusListItem(0);
                }
                break;
            case "Escape":
                if (isDropDownOpen) {
                    setOpen(false);
                    setActiveDescendentId('')
                }
                break;
            case "Tab":
                setOpen(false);
                setActiveDescendentId('');
                setOtherSelected(false);
                break;
            default:
                const input = document.querySelector(".autocomplete__input");
                setCurrentListItemFocused(-1);
                setOtherSelected(false);
                if (e.target !== input) {
                    if (/([a-zA-Z0-9_]|ArrowLeft|ArrowRight)/.test(e.key)) {
                        // If list item is focused and user presses an alphanumeric key, or left or right
                        // Focus on the input instead
                        if (inputRef && inputRef.current) {
                            inputRef.current.focus();
                        }

                    }
                }
                break;
        }
    }

    const setResults = (results) => {
        setFilteredResults(results);
        setCurrentListItemFocused(-1);
    }

    function escapeRegExp(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
    }
    const filter = (value) => {
        let results = [];
        if (value) {
            const escapedValue = escapeRegExp(value);
            const regexToFilterBy = new RegExp(`^${value}.*`, "i");
            results = colors.filter(color => regexToFilterBy.test(color))
        } else {
            results = [...colors];
        }

        setResults(results);
    }

    let bounce = undefined;
    function debounce(callback) {
        clearTimeout(bounce);
        bounce = setTimeout(() => {
            callback();
        }, DEBOUNCE_TIMEOUT_MS)
    }

    // Annoyingly, react components don't use the shadow dom, which mean
    // the ID's will be globally available instead of isolated within the
    // component. For this reason we'll use a simple random number for our
    // search lookup. We don't need somthing super random and secure, just
    // random enough not to clash with another search field.
    let resultsId = `lookupResults-${Math.floor(Math.random() * 1000)}`;

    let disabledClass = props?.disabled ? "group-disabled" : "";
    let requiredClass = props?.required ? "required" : "";
    let errorMsg = props?.error ? props.error : "";

    var controller;

    let errorClass = "";
    if (errorMsg) {
        errorClass = "has-error";
        errorMsg = errorMsg;
    }

    const handleInputChange = (ev, n, v) => {
        let name;
        let value;
        if (n === undefined && v === undefined) {
            name = ev.target.name;
            value = ev.target.value;
        } else {
            name = n;
            value = v;
        }

        setSelected(value);
        document.querySelectorAll(`#${resultsId} li`).forEach(el => {
            if (el.innerHTML.toLowerCase() === value.toLowerCase()) {
                let index = el.dataset['index'];
                ev.data = suggestions[index];
            }
        });

        debounce(() => {
            props.onChange(ev, name, value);
            if (!isDropDownOpen) {
                setOpen(true);
            }
        })


    }


    function handleChange(ev) {
        const { name, value } = ev.target;
        document.querySelectorAll(`#${resultsId} option`).forEach(el => {
            if (el.value === value) {
                let index = el.dataset['index'];
                ev.data = suggestions[index];
            }
        });
        props.onChange(ev);
    }

    useEffect(() => {
        // NOTE: Since the server requires a limit of 3 characters,
        // we might as well avoid any work till we reach the minimum.
        if (props.inputValue.length > 2) {
            setShowSuggestionSpinner(true);
            if (controller) controller.abort();

            controller = new AbortController();

            let api = new DmpApi();
            let options = api.getOptions({ signal: controller.signal });

            fetch(
                api.getPath(`/${props.endpoint}?search=${props.inputValue}`),
                options
            )
                .then((resp) => {
                    api.handleResponse(resp);
                    return resp.json();
                })
                .then((data) => {
                    let newItems = [...data.items];
                    setSuggestions(newItems);
                    setShowSuggestionSpinner(false);
                })
                .catch((err) => {
                    if (err.response && err.response.status === 404) {
                        setSuggestions(null);
                        setShowSuggestionSpinner(false);
                    } else {
                        console.log('Api error:');
                        console.log(err.response);
                    }
                });
        } else {
            setSuggestions(null);
            setShowSuggestionSpinner(false);
        }

        // Cleanup the controller on component unmount
        return () => {
            if (controller) controller.abort();
        };
    }, [debounceQuery]);


    useEffect(() => {
        // Function to handle click outside the input and list
        const handleClickOutside = (event) => {
            if (
                inputRef.current &&
                !inputRef.current.contains(event.target) && // Click is outside input
                listRef.current &&
                !listRef.current.contains(event.target)   // Click is outside list
            ) {
                setOpen(false); // Hide the list
                setActiveDescendentId('');
            }
        };

        // Attach the event listener when component mounts
        document.addEventListener('click', handleClickOutside);

        // Cleanup: remove event listener when component unmounts
        return () => {
            document.removeEventListener('click', handleClickOutside);
        };
    }, []);

    return (
        <>
            <div className={`dmpui-field-group ${disabledClass} ${errorClass} ${requiredClass}`}>
                <label
                    className="dmpui-field-label"
                    htmlFor={props?.id ? props.id : ""}
                >
                    {props?.label ? props.label : ""}
                </label>
                <p
                    className="dmpui-field-help"
                    id={props?.id ? props.id + "-description" : ""}
                >
                    {props?.help ? props.help : ""}
                </p>

                {errorMsg && <p className="dmpui-field-error"> {errorMsg} </p>}

                <div
                    className="autocomplete__container"
                    role="combobox"
                    aria-labelledby="autocomplete-label"
                    aria-expanded={open ? true : false}

                >
                    <input
                        role="textbox"
                        type="text"
                        aria-controls={resultsId}
                        aria-activedescendant={activeDescendentId}
                        className={'dmpui-field-input-text autocomplete__input ' + (showSuggestionSpinner ? 'show-spinner' : '')}
                        onClick={openDropdown}
                        onKeyDown={handleKeyboardEvents}
                        onChange={handleInputChange}
                        value={props.inputValue ? selected : ''}
                        name={props?.name ? props.name : "lookup_query"}
                        placeholder={props?.placeholder}
                        autoComplete={props?.autocomplete ? props.autocomplete : "off"}
                        disabled={props.disabled}
                        {...(props.help && { "aria-describedby": `${props.id}-description` })}
                        title=" "
                        ref={inputRef}
                    />
                    <Spinner className="dmpui-field-input-spinner"
                        message="Searching…"
                        isActive={showSuggestionSpinner}
                        tabIndex="-1" />
                    <button
                        aria-label="toggle dropdown"
                        className={'autocomplete__dropdown-arrow ' + (open ? 'expanded' : '')}
                        onClick={e => toggleDropDown(e)}
                        tabIndex="-1"
                        aria-hidden="true"
                    >
                        <svg width="10" height="5" viewBox="0 0 10 5" fillRule="evenodd">
                            <title>Open drop down</title>
                            <path d="M10 0L5 5 0 0z"></path>
                        </svg>
                    </button>
                    <ul
                        role="listbox"
                        id={resultsId}
                        className={`autocomplete__results ${resultsId} ` + (open ? 'visible' : '')}
                        onClick={handleSelection}
                        onKeyDown={handleKeyboardEvents}
                        ref={listRef}
                        tabIndex="-1"
                    >
                        {!otherSelected && (<li className="autocomplete-item other-option" id="autocomplete-item-0" role="listitem" data-value="other" tabIndex={0}>Other</li>)}


                        {props.inputValue.length > 0 && suggestions?.map((el, index) => {
                            if (el.name !== '') {
                                return (
                                    <li
                                        key={index}
                                        className='autocomplete-item '
                                        id={`autocomplete-item-${index + 1}`}
                                        role='listitem'
                                        data-index={index}
                                        data-value={el.name}
                                        tabIndex='-1'
                                    >{el.name}</li>
                                )
                            }

                        })}
                    </ul>
                </div>
                {/* <div className="dmpui-field-input-group">
                    <div className="dmpui-field-input-lookup-icon-wrapper">
                        <input
                            type="text"
                            onChange={handleChange}
                            value={props.inputValue}
                            name={props?.name ? props.name : "lookup_query"}
                            id={props?.id ? props.id : ""}
                            placeholder={props?.placeholder}
                            autoComplete={props?.autocomplete ? props.autocomplete : "off"}
                            list={resultsId}
                            className={`dmpui-field-input-text ${showSuggestionSpinner ? "show-spinner" : ""
                                }`}
                            disabled={props.disabled}
                            {...(props.help && { "aria-describedby": `${props.id}-description` })}


                        />
                        <Spinner className="dmpui-field-input-spinner"
                            message="Searching…"
                            isActive={showSuggestionSpinner} />
                    </div>
                    <datalist id={resultsId}>
                        {props.inputValue.length > 0 && suggestions?.map((el, index) => {
                            return <option key={index} data-index={index} value={el.name} />
                        })}
                    </datalist>
                </div> */}
            </div>
        </>
    );
}

export default TypeAhead;
