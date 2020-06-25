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

export { phoneMask, formatString }