//This is a reusable function to mask the phone number in the format "(###) ###-####"
const phoneMask = (val) => {
    const x = val.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
    return !x[2] ? x[1] : `(${x[1]}) ${x[2]}` + (x[3] ? `-${x[3]}` : ``);
};

//This is a reusable function to format a string like "{0} lives in {1}"
const formatString = (stringToFormat, ...formattingArguments) => {
    return stringToFormat.replace(/{(\d+)}/g, (match, index) => {
        return typeof formattingArguments[index] !== undefined ? formattingArguments[index] : '';
    });
};

//This is reusable function to check if string is blank (or) undefined (or) null
const isBlank = (val) => {
    return (val === '' || val === undefined || val === null);
};

//This is reusable function to check if string is not blank
const isNotBlank = (val) => {   
    return (val !== '' && val !== undefined && val !== null);
};

export { phoneMask, formatString, isBlank, isNotBlank }