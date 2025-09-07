// Simple CORS proxy for development
const corsProxy = {
  proxyUrl: 'https://api.allorigins.win/raw?url=',
  
  async fetch(url, options = {}) {
    try {
      // Try direct fetch first
      const response = await fetch(url, {
        ...options,
        mode: 'cors',
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        }
      });
      return response;
    } catch (error) {
      console.log('Direct fetch failed, trying proxy:', error);
      
      // Use proxy for CORS issues
      const proxyUrl = this.proxyUrl + encodeURIComponent(url);
      return await fetch(proxyUrl, {
        ...options,
        mode: 'cors'
      });
    }
  }
};

window.corsProxy = corsProxy;