import React, { useEffect, useState } from 'react';
import axios from 'axios';

const ImportedHTML = ({url, containerClass=''}) => {
    const [html, setHtml] = useState('');

    useEffect(() => {
        axios.get(url)
            .then(response => {
                setHtml(response.data);
            })
            .catch(error => {
                console.error('Error fetching html from '+url+':', error);
            });
    }, []);

    return (
        <div className={containerClass} dangerouslySetInnerHTML={{ __html: html }} />
    );
};

export default ImportedHTML;