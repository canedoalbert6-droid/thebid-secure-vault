const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Config keys:
// firebase functions:config:set gmail.user="yourgmail@gmail.com" gmail.pass="your_app_password" gmail.from="no-reply@yourdomain.com"

const gmailUser = functions.config().gmail.user;
const gmailPass = functions.config().gmail.pass;
const gmailFrom = functions.config().gmail.from || gmailUser;

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: gmailUser,
    pass: gmailPass,
  },
});

exports.sendWelcomeEmailOnCreate = functions.auth.user().onCreate(async (user) => {
  const email = user.email;
  if (!email) return;

  const displayName = user.displayName || "there";

  const mailOptions = {
    from: gmailFrom,
    to: email,
    subject: "Welcome to TheBid Vault",
    text: `Hi ${displayName},\n\nThanks for creating an account with TheBid Vault.\n\nBest,\nTheBid Team`,
    html: `<p>Hi ${displayName},</p>
           <p>Thanks for creating an account with <strong>TheBid Vault</strong>.</p>
           <p>Best,<br/>TheBid Team</p>`,
  };

  await transporter.sendMail(mailOptions);
});

