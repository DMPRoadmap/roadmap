import { useState, useEffect, useRef, memo } from "react";
import { DmpApi } from "../api.js";
import { useDebounce } from "../utils.js";
import Spinner from "./spinner.js";
import "./typeahead.scss";


const DEBOUNCE_TIMEOUT_MS = 100;

const TypeAhead = ({
    inputValue,
    setOtherField,
    endpoint,
    onChange,
    disabled,
    required,
    error,
    id,
    label,
    help,
    name,
    placeholder,
    autocomplete,
}) => {
    const [suggestions, setSuggestions] = useState([]);
    const [showSuggestionSpinner, setShowSuggestionSpinner] = useState(false);
    const [selected, setSelected] = useState("");
    const [activeDescendentId, setActiveDescendentId] = useState(null);
    const [otherSelected, setOtherSelected] = useState(false)
    const [open, setOpen] = useState(false);
    const [currentListItemFocused, setCurrentListItemFocused] = useState(-1);

    const debounceQuery = useDebounce(inputValue, 500);

    const inputRef = useRef(null);
    const listRef = useRef(null);

    const handleSelection = (e) => {
        setOpen(false);
        const item = e.target.innerText || e.target.value;
        setSelected(item);
        setCurrentListItemFocused(-1);

        if (inputRef && inputRef.current) {
            inputRef.current.focus();
        }

        if (item.toLowerCase() === 'other') {
            setOtherField(true);
            setOtherSelected(true);
        } else {
            setOtherField(false);
            setOtherSelected(false);
        }

        handleInputChange(e, 'repository', item);
    }

    const focusListItem = (index) => {
        setCurrentListItemFocused(index);
        if (listRef.current) {
            const listItems = listRef.current.querySelectorAll(".autocomplete-item");
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
        if (listRef.current) {
            // Convert NodeListOf<ChildNode> to an array of HTMLElement
            listItems = Array.from(listRef.current.childNodes);
        }


        if (["ArrowUp", "ArrowDown", "Enter"].includes(e.key)) {
            e.preventDefault();
        }

        switch (e.key) {
            case "ArrowDown":
                if (currentListItemFocused < listItems.length - 1) {
                    focusListItem(currentListItemFocused + 1);
                }
                break;

            case "ArrowUp":
                if (currentListItemFocused > 0) {
                    focusListItem(currentListItemFocused - 1);
                } else {
                    setCurrentListItemFocused(-1);
                    setActiveDescendentId("");
                    setOtherField(false);
                    setOtherSelected(false);
                    if (inputRef && inputRef.current) {
                        inputRef.current.focus();
                    }
                }
                break;
            case "Tab":
                setCurrentListItemFocused(-1);
                // If the entered value is not in the response, then don't let user tab
                const hasSelectedValue = suggestions ? suggestions.some(item => item.name === selected) : false;

                if (listItems.length > 1 && open && !hasSelectedValue ||
                    (selected && suggestions && !hasSelectedValue) ||
                    (selected && suggestions === null)) {
                    e.preventDefault();
                } else {
                    setOpen(false);
                    setActiveDescendentId("");
                    setOtherSelected(false);
                }
                break;
            case 'Enter':
                if (currentListItemFocused !== -1) {
                    setCurrentListItemFocused(-1);
                    setOpen(false);
                    setActiveDescendentId("");
                    setOtherField(false);
                    setOtherSelected(false);
                    if (inputRef && inputRef.current) {
                        inputRef.current.focus();
                    }
                    handleSelection(e)
                }
                break;
            case 'Home':
                if (currentListItemFocused > 0) {
                    setCurrentListItemFocused(-1);
                    setActiveDescendentId("");
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
                if (open) {
                    setOpen(false);
                    setActiveDescendentId("")
                }
                break;

            default:
                setCurrentListItemFocused(-1);
                setOtherSelected(false);
                if (/([a-zA-Z0-9_]|ArrowLeft|ArrowRight)/.test(e.key)) {
                    // If list item is focused and user presses an alphanumeric key, or left or right
                    // Focus on the input instead
                    if (inputRef && inputRef.current) {
                        inputRef.current.focus();
                    }

                }

                break;
        }
    }


    // Annoyingly, react components don't use the shadow dom, which mean
    // the ID's will be globally available instead of isolated within the
    // component. For this reason we'll use a simple random number for our
    // search lookup. We don't need somthing super random and secure, just
    // random enough not to clash with another search field.
    let resultsId = `lookupResults-${Math.floor(Math.random() * 1000)}`;

    const handleInputChange = (ev, n, v) => {
        if (!open) {
            setOpen(true);
        }
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
        if (listRef.current) {
            const listItems = listRef.current.querySelectorAll("li");
            listItems.forEach((el) => {
                if (el.innerHTML.toLowerCase() === value.toLowerCase()) {
                    let index = el.dataset.index;
                    ev.data = suggestions[index];
                }
            });
        }

        onChange(ev, name, value);

    }


    useEffect(() => {
        // NOTE: Since the server requires a limit of 3 characters,
        // we might as well avoid any work till we reach the minimum.
        if (inputValue.length > 2) {
            setShowSuggestionSpinner(true);

            const controller = new AbortController();

            let api = new DmpApi();
            let options = api.getOptions({ signal: controller.signal });

            fetch(
                api.getPath(`/${endpoint}?search=${inputValue}`),
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
            return () => controller.abort();
        } else {
            setSuggestions(null);
            setShowSuggestionSpinner(false);
        }

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
                setActiveDescendentId("");
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
        <div
            className={`dmpui-field-group ${disabled ? "group-disabled" : ""
                } ${error ? "has-error" : ""} ${required ? "required" : ""}`}
        >
            <label
                className="dmpui-field-label"
                htmlFor={id || ""}
            >
                {label || ""}
            </label>
            <p
                className="dmpui-field-help"
                id={id || ""}
            >
                {help || ""}
            </p>

            {error && <p className="dmpui-field-error"> {error} </p>}

            <div
                className="autocomplete__container"
                role="combobox"
                aria-labelledby="autocomplete-label"
                aria-expanded={open}

            >
                <input
                    role="textbox"
                    type="text"
                    aria-controls={resultsId}
                    aria-activedescendant={activeDescendentId}
                    className={`dmpui-field-input-text autocomplete__input ${showSuggestionSpinner ? "show-spinner" : ""
                        }`}
                    onClick={() => setOpen(true)}
                    onKeyDown={handleKeyboardEvents}
                    onChange={handleInputChange}
                    value={inputValue ? selected : ""}
                    name={name || "lookup_query"}
                    placeholder={placeholder}
                    autoComplete={autocomplete || "off"}
                    disabled={disabled}
                    {...(help && { "aria-describedby": `${id}-description` })}
                    title=" "
                    ref={inputRef}
                />
                <Spinner className="dmpui-field-input-spinner"
                    message="Searching…"
                    isActive={showSuggestionSpinner} />
                <div
                    className={`autocomplete__dropdown-arrow ${open ? "expanded" : ""}`}
                    onClick={e => e.preventDefault()}
                    tabIndex="-1"
                    aria-hidden="true"
                >
                    <svg width="10" height="5" viewBox="0 0 10 5" fillRule="evenodd">
                        <title>Open drop down</title>
                        <path d="M10 0L5 5 0 0z"></path>
                    </svg>
                </div>
                <ul
                    role="listbox"
                    id={resultsId}
                    className={`autocomplete__results ${resultsId} ` + (open ? 'visible' : '')}
                    onClick={handleSelection}
                    onKeyDown={handleKeyboardEvents}
                    ref={listRef}
                    tabIndex="-1"
                >

                    {suggestions === null && (

                        <li
                            className="autocomplete-item no-results"
                            role="option"
                            aria-selected="false"
                            tabIndex="0"
                        >
                            No results found.
                        </li>

                    )}
                    {selected.length > 0 && suggestions && suggestions.length > 0 && (
                        <>
                            {!otherSelected && (<li key="other" className="autocomplete-item other-option" id="autocomplete-item-0" role="listitem" data-value="other" tabIndex={-1}>Other</li>)}


                            {suggestions?.map((el, index) => {
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

                        </>
                    )}

                </ul>
            </div>
        </div>
    );
}

export default memo(TypeAhead);
