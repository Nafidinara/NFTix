import React from 'react';
import { Link } from 'react-router-dom';
import Newsletter from './Newsletter';

const Footer = () => {
  return (
    <footer className="footer-section">
      <Newsletter />
      <div className="container">
        <div className="footer-top">
          <div className="logo">
            <Link to="/">
              <img 
                style={{ maxWidth: '25%', maxHeight: '25%' }}
                src="https://i.ibb.co.com/nnRLrXc/6217364158c6b-thumb900-removebg-preview.png" 
                alt="footer"
              />
            </Link>
          </div>
          <ul className="social-icons">
            <li>
              <a href="#0">
                <i className="fab fa-facebook-f"></i>
              </a>
            </li>
            <li>
              <a href="#0" className="active">
                <i className="fab fa-twitter"></i>
              </a>
            </li>
            <li>
              <a href="#0">
                <i className="fab fa-pinterest-p"></i>
              </a>
            </li>
            <li>
              <a href="#0">
                <i className="fab fa-google"></i>
              </a>
            </li>
            <li>
              <a href="#0">
                <i className="fab fa-instagram"></i>
              </a>
            </li>
          </ul>
        </div>
        <div className="footer-bottom">
          <div className="footer-bottom-area">
            <div className="left">
              <p>Copyright © 2024.All Rights Reserved By <a href="#0">NFTix </a></p>
            </div>
            <ul className="links">
              <li>
                <Link to="/about">About</Link>
              </li>
              <li>
                <Link to="/terms">Terms Of Use</Link>
              </li>
              <li>
                <Link to="/privacy">Privacy Policy</Link>
              </li>
              <li>
                <Link to="/faq">FAQ</Link>
              </li>
              <li>
                <Link to="/feedback">Feedback</Link>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;